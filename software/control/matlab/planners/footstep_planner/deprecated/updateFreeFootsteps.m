function [X, outputflag] = updateFreeFootsteps(X, biped, fixed_steps, ndx_r, ndx_l, heightfun)

max_diag_dist = sqrt(biped.max_step_length^2 + biped.step_width^2);

x_flat = reshape(X([1,2,6],:), 1, []);
X = locate_step_centers(x_flat);
x_flat = reshape(X([1,2,6],:), 1, []);

x_l = min(X, [], 2);
x_u = max(X, [], 2);
x_lb = x_l - abs(x_u - x_l) * 0.5;
x_ub = x_u + abs(x_u - x_l) * 0.5;
lb = repmat(x_lb, 1, length(X(1,:)));
ub = repmat(x_ub, 1, length(X(1,:)));
lb(6,:) = repmat(-pi, 1, length(X(1,:)));
ub(6,:) = repmat(pi, 1, length(X(1,:)));

ndx_fixed = find(any(cellfun(@(x) ~isempty(x),fixed_steps),2));
lb(:, ndx_fixed) = X(:, ndx_fixed);
ub(:, ndx_fixed) = X(:, ndx_fixed);

[x_flat, ~, outputflag] = fmincon(@cost, x_flat,[],[],[],[],...
  reshape(lb([1,2,6],:), 1, []), reshape(ub([1,2,6],:), 1, []),@nonlcon,...
  optimset('Algorithm', 'interior-point', 'MaxIter', 10, 'Display', 'off'));


X = locate_step_centers(x_flat);

function [c, ceq] = nonlcon(x_flat)
  X = locate_step_centers(x_flat);
  [Xright, Xleft] = biped.stepLocations(X);
  Xright(3,:) = heightfun(Xright(1:2,:));
  Xleft(3,:) = heightfun(Xleft(1:2,:));
  [d_r, r_r] = stepDistance(Xright(:,1:(end-1)), Xright(:,2:end), 0);
  [d_l, r_l] = stepDistance(Xleft(:,1:(end-1)), Xleft(:,2:end), 0);
  [d_alt_r, r_alt_r] = stepDistance(Xright(:,1:end-1), Xleft(:,2:end), 0);
  [d_alt_l, r_alt_l] = stepDistance(Xleft(:,1:end-1), Xright(:,2:end), 0);
  height_diff = [abs(Xright(3,ndx_r(1:end-1)) - Xright(3,ndx_r(2:end)))';
                 abs(Xleft(3,ndx_l(1:end-1)) - Xleft(3,ndx_l(2:end)))'];
  
%   obs_dist = [sum((Xright(1:2,ndx_r) - repmat(obs_center, 1, length(ndx_r))).^2)';
%     sum((Xleft(1:2,ndx_l) - repmat(obs_center, 1, length(ndx_l))).^2)'];
  c = [d_r' - biped.max_step_length;
       d_l' - biped.max_step_length;
       d_alt_r' - max_diag_dist;
       d_alt_l' - max_diag_dist;
       r_r' - biped.max_step_rot;
       r_l' - biped.max_step_rot;
       height_diff - 0.5];
%        -obs_dist + obs_radius];
  ceq = 0;
end

function c = cost(x_flat)
  X = locate_step_centers(x_flat);
  [d, r] = stepDistance(X(:,1:(end-1)), X(:,2:end),1);
  c = sum(d.^2 + (r .* (biped.max_step_length / biped.max_step_rot)).^2 + (d .* r .* (10 * biped.max_step_length / biped.max_step_rot)).^2);
%   plot_lcm_poses(Xright(1:3,ndx_r)', Xright(6:-1:4,ndx_r)', 1, 'Foot Steps (right)', 4, 1, 0, -1);
%   plot_lcm_poses(Xleft(1:3,ndx_l)', Xleft(6:-1:4,ndx_l)', 2, 'Foot Steps (left)', 4, 1, 0, -1);
end

function X = locate_step_centers(x_flat)
  x_flat = reshape(x_flat, 3, []);
  X = [[x_flat(1:2,:)]; zeros(3, length(x_flat(1,:))); [x_flat(3,:)]];
  for i = 1:length(X(1,:))
    if ~isempty(fixed_steps{i,1}) && ~isempty(fixed_steps{i,2})
      X(:,i) = mean([fixed_steps{i,1}, fixed_steps{i,2}],2);
    elseif ~isempty(fixed_steps{i,1})
      yaw = fixed_steps{i,1}(6);
      angle = yaw - biped.foot_angles(1);
      X(:,i) = fixed_steps{i,1} + (biped.step_width / 2) * [cos(angle); sin(angle);0;0;0;0];
    elseif ~isempty(fixed_steps{i,2})
      yaw = fixed_steps{i,2}(6);
      angle = yaw - biped.foot_angles(2);
      X(:,i) = fixed_steps{i,2} + (biped.step_width / 2) * [cos(angle); sin(angle);0;0;0;0];
    end
  end
end
end