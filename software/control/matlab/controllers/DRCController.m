classdef DRCController

  properties (SetAccess=protected,GetAccess=public)
    name=''; % controller name
  end  
  
  properties (SetAccess=protected,GetAccess=protected)
    controller; % drake system
    controller_data; % optional shared data handle reference
    
    controller_input_frames; % lcm frames w/coders for controller inputs
    n_input_frames;
    input_frame_which_triggers_update=-1;  % index into controller_input_frames
    input_frames_which_dont_trigger_update
    controller_input_duplicate;   % index into preceding input frame to duplicate data from (or 0)
    controller_output_frame;
    
    transition_coders; % lcm coders for transition events
    transition_monitors; % message monitors for transition events
    transition_targets; % list of names of controllers to transition to
    transition_channels; 
    
    constructors; % cell array of lcm type constructors (function handles)
    t_final = inf; % controller time limit
    timed_transition; % name of the controller to transition to when t>=t_final
    absolute_time; % bool: whether t_final is absolute or relative to start time

    lc;
  end

  methods (Abstract)
    initialize(obj,data); % controllers need to implement this
    %  in the event of a lcm transition, data contains a struct that maps channel names to the 
    %  decoded lcm message data. for timed transitions, it maps input frame names to the latest data
    msg = status_message(obj,t_sim,t_ctrl); % each controller should populate a drc_controller_status_t message
    %  and send it back to the base station
  end

  methods
    function obj = DRCController(name,sys,input_subframe_which_triggers_update)
      typecheck(name,'char');
      if ~(isa(sys,'DrakeSystem') || isa(sys,'SimulinkModel'))
        error('DRCController::Argument sys should be a DrakeSystem or SimulinkModel');
      end
      if ~isDT(sys)
        error('DRCController: only supports discrete time systems');
      end
      typecheck(input_subframe_which_triggers_update,'CoordinateFrame');
        
      obj.name = name;
      obj.controller = sys;
      
      if typecheck(sys.getInputFrame,'MultiCoordinateFrame')
        obj.controller_input_frames = sys.getInputFrame.frame;
        obj.n_input_frames = length(obj.controller_input_frames);
      else
        obj.controller_input_frames{1} = obj.controller.getInputFrame();
        obj.n_input_frames = 1; 
      end
      obj.controller_output_frame = obj.controller.getOutputFrame();
      
      name_hash = inf*ones(obj.n_input_frames,1); % no name_hash can be inf
      obj.controller_input_duplicate = zeros(obj.n_input_frames,1);
      for i=1:obj.n_input_frames
        obj.controller_input_frames{i}.subscribe(defaultChannel(obj.controller_input_frames{i}));
        name_hash(i) = obj.controller_input_frames{i}.name_hash;
        if (obj.input_frame_which_triggers_update < 0 && name_hash(i)==input_subframe_which_triggers_update.name_hash)
          obj.input_frame_which_triggers_update = i;
        end
        d = find(name_hash(i)==name_hash(1:i-1),1);
        if ~isempty(d)
          obj.controller_input_duplicate(i) = d;
        end
      end
      if (obj.input_frame_which_triggers_update<0)
        error('couldn''t find input_frame_which_triggers_update in the input frames of sys');
      end
      obj.input_frames_which_dont_trigger_update = [1:obj.input_frame_which_triggers_update-1,obj.input_frame_which_triggers_update+1:obj.n_input_frames];
      
      obj.lc = lcm.lcm.LCM.getSingleton();
      
      % in order to support backup mode:
      typecheck(obj.controller_output_frame,{'LCMCoordinateFrameWCoder','LCMCoordinateFrame'}); % could be more general, but this should get us started
      obj.controller_output_frame.subscribe(defaultChannel(obj.controller_output_frame));
    end
    
    function obj = setTimedTransition(obj,t_final,transition_to_controller,absolute_time)
      typecheck(t_final,'double');
      typecheck(transition_to_controller,'char');
      if nargin > 3
        typecheck(absolute_time,'logical');
      else
        absolute_time = false;
      end

      obj.t_final = t_final;
      obj.timed_transition = transition_to_controller;
      obj.absolute_time = absolute_time;
    end
    
    function obj = setDuration(obj,t_final,absolute_time)
      typecheck(t_final,'double');
      if nargin > 2
        typecheck(absolute_time,'logical');
      else
        absolute_time = false;
      end

      obj.t_final = t_final;
      obj.absolute_time = absolute_time;
    end

    function tf = getDuration(obj)
      tf = obj.t_final;
    end
    function target = getTimedTransition(obj)
      target = obj.timed_transition;
    end

    
    function obj = addLCMTransition(obj,channel,lcmtype_or_lcmcoder,transition_to_controller)
      typecheck(channel,'char');
      typecheck(transition_to_controller,'char');

      n = length(obj.transition_monitors)+1;
      if typecheck(lcmtype_or_lcmcoder,'LCMCoder')
        obj.transition_coders{n} = lcmtype_or_lcmcoder;
        lcmtype = obj.transition_coders{n}.encode(0,zeros(obj.transition_coders{n}.dim(),1));
      else
        obj.transition_coders{n} = [];
        [lcmtype,obj.constructors{n}]=DRCController.parseLCMType(lcmtype_or_lcmcoder);
      end
      
      mon = drake.util.MessageMonitor(lcmtype,'utime');
      obj.lc.subscribe(channel,mon);
      
      obj.transition_channels{n} = channel;
      obj.transition_monitors{n} = mon;
      obj.transition_targets{n} = transition_to_controller;
    end

    function [targets,channels] = getLCMTransitions(obj)
      targets = obj.transition_targets;
      channels = obj.transition_channels;
    end
        
    function [transition,data] = checkLCMTransitions(obj)
      data = struct();
      transition=false;
      
      for i=1:length(obj.transition_monitors)
        d = obj.transition_monitors{i}.getNextMessage(0);
        if ~isempty(d)
          if isempty(obj.transition_coders{i})
            data.(obj.transition_targets{i}) = struct(obj.transition_channels{i},obj.constructors{i}.newInstance(d));
          else
            data.(obj.transition_targets{i}) = struct(obj.transition_channels{i},obj.coders{i}.decode(d));
          end
          transition = true;
        end
      end
    end
        
    function [data,backup_mode] = run(obj,backup_mode)
      % runs the controller and, upon receiving a message on a termination
      % channel or if t >= t_final, halts and returns a struct mapping the
      % name of the controller to take over to lcm message data (or halting
      % time in the case of a timed transition)
      % 
      % @param if backup_mode=true, the controller will continue to
      % listen for incoming messages and run update.  It will also
      % subscribe to the messages that it is supposed to publish, and if it
      % does not hear that message, then it will switch out of backup mode
      % and start publishing (e.g. assuming that the primary controller has
      % crashed).
      
      if (nargin<2) backup_mode = false; end
      
      % on startup, populate input frames with last received data
      data = struct();
      input_frame_data = cell(obj.n_input_frames,1);
      for i=1:obj.n_input_frames
          [x,~] = getMessage(obj.controller_input_frames{i});
          if ~isempty(x)
            % use previous message
           input_frame_data{i} = x;
          else
            input_frame_data{i} = zeros(obj.controller_input_frames{i}.dim,1);
          end
      end
      
      % clear lcm transition buffers
      for i=1:length(obj.transition_monitors)
        obj.transition_monitors{i}.getNextMessage(0);
      end
      
%       missed_frames = 0;
%       max_state_delay = 0;
%       ttprev = [];
%       persistent count;  if isempty(count), count=0; end
      t_offset = -1;
      lcm_check_tic = tic;
      status_tic = tic;
      num_x = getNumStates(obj.controller);
      if (num_x>0), x = getInitialState(obj.controller); else x=[]; end
      while (1)
%         tic;
        if (toc(lcm_check_tic) > 0.05) % check periodically
          % check termination conditions and break if any are true        
          [transition,data] = checkLCMTransitions(obj);
          lcm_check_tic = tic;
          if transition 
 
            fn = fieldnames(data); % get channel names for transitions, take first one
            % append last input data
            tmpstruct = data.(fn{1});
            for i=1:obj.n_input_frames
              tmpstruct.(obj.controller_input_frames{i}.name) = input_frame_data{i};
            end
            data.(fn{1}) = tmpstruct;
            break;
          end
        end

        [x,tsim] = getNextMessage(obj.controller_input_frames{obj.input_frame_which_triggers_update},10);  % timeout is in msec - should be safely bigger than e.g. a 200Hz input rate
        if isempty(x) continue; end
%         count = count+1; fprintf(1,'count=%d\n',count);
        
        input_frame_data{obj.input_frame_which_triggers_update} = x;
%        input_frame_time(obj.input_frame_which_triggers_update) = t;
        if (t_offset == -1)
          if obj.absolute_time
            t_offset = 0;
          else
            t_offset = tsim;
          end
        end
        tt=tsim-t_offset;
        
        % for each input subframe, get most recent message
        for i=obj.input_frames_which_dont_trigger_update
          if obj.controller_input_duplicate(i)
            input_frame_data{i} = input_frame_data{obj.controller_input_duplicate(i)};
%            input_frame_time{i} = input_frame_time{obj.controller_input_duplicate(i)};
          else
            x = getMessage(obj.controller_input_frames{i});
            if ~isempty(x)
              input_frame_data{i} = x;
            end
          end
        end
        
        if any(tt >= obj.t_final)
          % on timeout events, we pass back the latest input data 
          
          input_data = struct();
          for i=1:obj.n_input_frames
            input_data.(obj.controller_input_frames{i}.name) = input_frame_data{i};
          end
          data.(obj.timed_transition) = input_data;
          break;
        end
        
        if backup_mode  % backup_mode logic
          % tt+t_offset is the timestamp of the message that I should be
          % sending.  if I haven't seen that message for 10msec, then come
          % out of backup_mode
          t_heartbeat = getLastTimestamp(obj.controller_output_frame) / 1e6;

          if t_heartbeat>0 && tsim - t_heartbeat > 0.1
            backup_mode = false;
            disp('HEARTBEAT MISSED.  TRANSITIONING OUT OF BACKUP MODE.');
          elseif toc(status_tic)>0.2
            % send the backup status message
            msg = status_message(obj,tsim,tt);
            obj.lc.publish('BACKUP_CONTROLLER_STATUS',msg);
            status_tic=tic;
          end
        else
          u = obj.controller.output(tt,x,vertcat(input_frame_data{:}));
          obj.controller_output_frame.publish(tsim,u,defaultChannel(obj.controller_output_frame));

          % publish controller status
          if toc(status_tic)>0.2
            msg = status_message(obj,tt+t_offset,tt);
            obj.lc.publish('CONTROLLER_STATUS',msg);
            status_tic=tic;
          end
          
          if num_x>0
            % note: for simulink models, this will call output again,
            % unless I pass in my new additional flag.  try that when we
            % get there.
            x = obj.controller.update(tt,x,vertcat(input_frame_data{:}));
          end
        end
        %         fprintf('Num missed frames: %d \n',missed_frames);
        %         fprintf('Max state delay: %2.3f sim secs \n',max_state_delay);
        %         toc
      end
    end
  end
  
  methods (Static=true)
    function [lcmtype,constructor] = parseLCMType(lcmtype)
      if (ischar(lcmtype))
        lcmtype = eval(lcmtype);
      end
      if (~any(strcmp('getClass',methods(lcmtype))))
        error('lcmtype should be a valid java lcm object, or the string describing it');
      end
      lcmtypeClass=lcmtype.getClass();
      
      has_timestamp=false;
      names={};
      f = lcmtypeClass.getFields;
      for i=1:length(f)
        fname = char(f(i).getName());
        if strncmp(fname,'LCM_FINGERPRINT',15), continue; end
        if strcmp(fname,'utime'), 
          if ~strcmp(f(i).getGenericType.getName,'long')
            error('by convention, the timestamp field should be type int64_t');
          end
          has_timestamp=true; 
          continue; 
        end
      end
      if ~has_timestamp
        error('by convention, all lcm types should have a timestamp utime field of type int64_t');
      end
      
      constructors = lcmtypeClass.getConstructors();
      for i=1:length(constructors)
        f = constructors(i).getParameterTypes;
        if ~isempty(f) && strncmp('[B',char(f(1).getName),2)
          constructor = constructors(i);
        end
      end
      if isempty(constructor)
        error('didn''t find a constructor for this lcmtype');
      end
    end    
  end  
end