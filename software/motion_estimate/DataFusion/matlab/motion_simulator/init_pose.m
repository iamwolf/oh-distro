function pose = init_pose()

pose.utime = 0;
pose.P_l = zeros(3,1);
pose.V_l = zeros(3,1);
pose.R = eye(3);
pose.f_l = zeros(3,1);
pose.da = zeros(3,1);