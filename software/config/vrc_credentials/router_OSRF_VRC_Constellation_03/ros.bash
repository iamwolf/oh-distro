
# To connect via ROS:
# 1. Connect via OpenVPN 
# 2. Download this file: [ros.sh] <- autogenerated with the right IP addresses
# 3. In a terminal, go to the directory containing that file.
# 4. Execute the following command:
#    . ros.bash
# 5. Now your environment is configured to connect to a ROS master running on this machine.

# ROS's setup.sh will overwrite ROS_PACKAGE_PATH, so we'll first save the existing path
oldrpp=$ROS_PACKAGE_PATH
. /opt/ros/fuerte/setup.sh
eval export ROS_PACKAGE_PATH=$oldrpp:\$ROS_PACKAGE_PATH
export ROS_IP=11.8.0.2
export ROS_MASTER_URI=http://10.0.0.51:11311 

export GAZEBO_IP=11.8.0.2
export GAZEBO_MASTER_URI=http://10.0.0.51:11345
                
    