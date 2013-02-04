classdef QPController < DrakeSystem
  methods
  function obj = QPController(p,qstar)
    obj = obj@DrakeSystem(...  
      0, ... % number of continuous states
      0, ... % number of discrete states
      p.getNumStates(), ... % number of inputs
      p.getNumInputs(), ... % number of outputs
      false, ... % because the output does not depend on u
      true);  % because the update and output do not depend on t

    typecheck(p,'TimeSteppingRigidBodyManipulator');
    obj.plant = p;
    obj.qstar = qstar;

    obj = setInputFrame(obj,p.getStateFrame);
    obj = setOutputFrame(obj,p.getInputFrame);

    obj.nd = 4; % for friction cone approx, hard coded for now
    obj.dim = 3;
    
    obj.nu = p.getNumInputs();
    obj.nq = p.getNumStates()/2;
    obj.nc = p.getNumContacts(); 
    obj.nf = obj.nc+obj.nc*obj.nd;
    obj.nparams = obj.nq+obj.nu+obj.nf+obj.nc*obj.dim;

    % handy index matrices
    obj.Iqdd = zeros(obj.nq,obj.nparams);
    obj.Iqdd(:,1:obj.nq) = eye(obj.nq);
    obj.Iu = zeros(obj.nu,obj.nparams);
    obj.Iu(:,obj.nq+(1:obj.nu)) = eye(obj.nu);
    obj.Iz = zeros(obj.nc,obj.nparams);
    obj.Iz(:,obj.nq+obj.nu+(1:obj.nc)) = eye(obj.nc);
    obj.Ibeta = zeros(obj.nc*obj.nd,obj.nparams);
    obj.Ibeta(:,obj.nq+obj.nu+obj.nc+(1:obj.nc*obj.nd)) = eye(obj.nc*obj.nd);            
    obj.Ieps = zeros(obj.nc*obj.dim,obj.nparams);
    obj.Ieps(:,obj.nq+obj.nu+obj.nc+obj.nc*obj.dim+(1:obj.nc*obj.dim)) = eye(obj.nc*obj.dim);

    obj.lb = [-1e3*ones(1,obj.nq) p.umin' zeros(1,obj.nf)   -.01*ones(1,obj.nc*obj.dim)]'; % acceleration/input/contact force/lambda/slack vars
    obj.ub = [ 1e3*ones(1,obj.nq) p.umax' 1e4*ones(1,obj.nf) .01*ones(1,obj.nc*obj.dim)]';

    global alpha t_prev;
    t_prev = -1;
    alpha = zeros(obj.nparams,1);
  end
    
  function y=output(obj,t,~,u)
    % alpha = [qdd; \bar{u}; z_1; ...; z_nc; beta_1; ...; beta_nc; ...; 
    %           beta_{nc*nd}]
    % where nc is the number of contact points, and nd is the (even) 
    % number of direction vectors in the polyhedral friction cone
    % approx. 

    x = u;
    p = obj.plant;

    global alpha;
    q = x(1:obj.nq); 
    qd = x(obj.nq+(1:obj.nq));

    [H,C,B] = p.manipulatorDynamics(q,qd);
    [foot_pos,Jp,dJp] = p.contactPositions(q); 
    % note, if friction cone approx d=4, could just use
    % contactConstraints function to get position and J
    [phi,Jc,D_] = p.contactConstraints(q);
    % D_ is the parameterization of the polyhedral approximation of the 
    %    friction cone, in joint coordinates (figure 1 from Stewart96)
    %    D{k}(i,:) is the kth direction vector for the ith contact (of nC)

    % Create Dbar such that Dbar(:,(k-1)*nd+i) is ith direction vector for the kth
    % contact point
    D = cell(1,obj.nc);
    for k=1:obj.nc
      for i=1:obj.nd
        D{k}(:,i) = D_{i}(k,:)'; 
      end
    end
    Dbar = [D{:}];

    if any(phi < -1e-5)
      warning('QPController: Detected contact point penetration...');
    end

    % TEMP: assume mu=1
    mu = ones(obj.nc,1);

    Aeq_ = cell(1,3+obj.nc);
    beq_ = cell(1,3+obj.nc);
    Ain_ = cell(1,obj.nc);
    bin_ = cell(1,obj.nc);

    % CT dynamics constraint
    Aeq_{1} = H*obj.Iqdd - B*obj.Iu - Jc'*obj.Iz - Dbar*obj.Ibeta;
    beq_{1} = -C;

    % no-slip constraint
    Jpdot = zeros(obj.nc*obj.dim,obj.nq);
    for i=1:obj.nq
      Jpdot(:,i) = dJp(:,(i-1)*obj.nq+(1:obj.nq))*qd;
    end
    Aeq_{2} = Jp*obj.Iqdd + obj.Ieps;
    beq_{2} = -Jpdot*qd;

    % complementarity constraints
    %phi(abs(phi)<1e-3) = 0; % epsilon is close enough
    %Aeq_{3} = phi'*obj.Iz;
    %beq_{3} = 0;

    for i=1:obj.nc
      %Aeq_{3+i} = repmat(phi(i),1,obj.nd)*obj.Ibeta((i-1)*obj.nd+(1:obj.nd),:);
      %beq_{3+i} = 0;
      Ain_{i} = -mu(i)*obj.Iz(i,:) + ones(1,obj.nd)*obj.Ibeta((i-1)*obj.nd+(1:obj.nd),:);
      bin_{i} = 0;
    end

    % linear equality constraints: Aeq*alpha = beq
    %Aeq = sparse(blkdiag(Aeq_{:}) * repmat(eye(obj.nparams),3+obj.nc,1));
    Aeq = sparse(blkdiag(Aeq_{:}) * repmat(eye(obj.nparams),2,1));
    beq = vertcat(beq_{:});

    % linear inequality constraints: Ain*alpha <= bin
    Ain = sparse(blkdiag(Ain_{:}) * repmat(eye(obj.nparams),obj.nc,1));
    bin = vertcat(bin_{:});

    % get desired COM pos
    ch = convhull(foot_pos(1:2,:)');
    com_des = [mean(foot_pos(1:2,ch),2);0];

    [cm,J,dJ] = p.getCOM(q);
    Jdot = zeros(obj.dim,obj.nq);
    for i=1:obj.nq
      Jdot(:,i) = dJ(:,(i-1)*obj.nq+(1:obj.nq))*qd;
    end

    % COM PD controller
    Kp = 500*eye(obj.dim); 
    Kd = 120*eye(obj.dim);

    P = diag([1 1 0]); % ignore z
    err = P*(com_des - cm);
    cm_dot = P*J*qd;
    cm_ddot_des = Kp*err - Kd*cm_dot;

    % debug
    scope('Atlas','com_err',t,norm(err),struct('linespec','r','scope_id',1));

    % nominal pose PD controller
    Kp_q = 15*eye(obj.nq);
    Kd_q = 5*eye(obj.nq);
    Kp_q(1:6,1:6) = zeros(6); % ignore free body dofs
    Kd_q(1:6,1:6) = zeros(6); % ignore free body dofs
    err_q = obj.qstar - q;
    qdd_des = Kp_q*err_q - Kd_q*qd;

    w_com = 0.1;
    w_q = 1.0;

    Hqp = repmat(eye(obj.nparams),2,1)'*blkdiag(w_com*obj.Iqdd'*(J'*J + 0.0001*eye(obj.nq))*obj.Iqdd, w_q*obj.Iqdd'*obj.Iqdd)*repmat(eye(obj.nparams),2,1);
    Hqp(obj.nparams-obj.nc*obj.dim+1:end,obj.nparams-obj.nc*obj.dim+1:end) = eye(obj.nc*obj.dim); % drive slack vars to 0
    fqp = horzcat(w_com*(Jdot*qd - cm_ddot_des)'*J*obj.Iqdd, -w_q*qdd_des'*obj.Iqdd)*repmat(eye(obj.nparams),2,1);

    alpha = cplexqp(Hqp,fqp,Ain,bin,Aeq,beq,obj.lb,obj.ub,alpha);%,obj.options);
    y=alpha(obj.nq+(1:obj.nu));
   
  end
  end

  properties
    lb % QP lower bounds
    ub % QP upper bounds
    plant % to be controlled
    nd % number of tangent vectors for friction cone approx
    dim % number of dimensions (2 or 3)
    qstar % nominal standing configuration
    nu
    nq
    nc 
    nf
    nparams
    Iqdd
    Iu
    Iz
    Ibeta
    Ieps
    %options = cplexoptimset('Diagnostics','on');
    %options = cplexoptimset('MaxTime',0.01);
  end
end
