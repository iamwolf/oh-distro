# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/sisir/sandia-hand/ros/sandia_hand_driver

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/sisir/sandia-hand/ros/sandia_hand_driver/build

# Include any dependencies generated for this target.
include cli/CMakeFiles/loose_finger_cli.dir/depend.make

# Include the progress variables for this target.
include cli/CMakeFiles/loose_finger_cli.dir/progress.make

# Include the compile flags for this target's objects.
include cli/CMakeFiles/loose_finger_cli.dir/flags.make

cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: cli/CMakeFiles/loose_finger_cli.dir/flags.make
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: ../cli/loose_finger_cli.cpp
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: ../manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/share/roslang/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/share/roscpp/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/share/geometry_msgs/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/share/sensor_msgs/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/share/ros/core/rosbuild/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/share/roslib/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/share/rosconsole/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/stacks/pluginlib/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/share/message_filters/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/stacks/image_common/image_transport/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/stacks/common_rosdeps/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/stacks/image_common/camera_calibration_parsers/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/share/rostest/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /opt/ros/fuerte/stacks/image_common/camera_info_manager/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /home/sisir/sandia-hand/ros/sandia_hand_msgs/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /usr/share/osrf-common-1.0/ros/osrf_msgs/manifest.xml
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /home/sisir/sandia-hand/ros/sandia_hand_msgs/msg_gen/generated
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /home/sisir/sandia-hand/ros/sandia_hand_msgs/srv_gen/generated
cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o: /usr/share/osrf-common-1.0/ros/osrf_msgs/msg_gen/generated
	$(CMAKE_COMMAND) -E cmake_progress_report /home/sisir/sandia-hand/ros/sandia_hand_driver/build/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o"
	cd /home/sisir/sandia-hand/ros/sandia_hand_driver/build/cli && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -W -Wall -Wno-unused-parameter -fno-strict-aliasing -pthread -o CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o -c /home/sisir/sandia-hand/ros/sandia_hand_driver/cli/loose_finger_cli.cpp

cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/loose_finger_cli.dir/loose_finger_cli.i"
	cd /home/sisir/sandia-hand/ros/sandia_hand_driver/build/cli && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -W -Wall -Wno-unused-parameter -fno-strict-aliasing -pthread -E /home/sisir/sandia-hand/ros/sandia_hand_driver/cli/loose_finger_cli.cpp > CMakeFiles/loose_finger_cli.dir/loose_finger_cli.i

cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/loose_finger_cli.dir/loose_finger_cli.s"
	cd /home/sisir/sandia-hand/ros/sandia_hand_driver/build/cli && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -W -Wall -Wno-unused-parameter -fno-strict-aliasing -pthread -S /home/sisir/sandia-hand/ros/sandia_hand_driver/cli/loose_finger_cli.cpp -o CMakeFiles/loose_finger_cli.dir/loose_finger_cli.s

cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o.requires:
.PHONY : cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o.requires

cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o.provides: cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o.requires
	$(MAKE) -f cli/CMakeFiles/loose_finger_cli.dir/build.make cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o.provides.build
.PHONY : cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o.provides

cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o.provides.build: cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o

# Object files for target loose_finger_cli
loose_finger_cli_OBJECTS = \
"CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o"

# External object files for target loose_finger_cli
loose_finger_cli_EXTERNAL_OBJECTS =

../bin/loose_finger_cli: cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o
../bin/loose_finger_cli: ../lib/libsandia_hand.so
../bin/loose_finger_cli: cli/CMakeFiles/loose_finger_cli.dir/build.make
../bin/loose_finger_cli: cli/CMakeFiles/loose_finger_cli.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX executable ../../bin/loose_finger_cli"
	cd /home/sisir/sandia-hand/ros/sandia_hand_driver/build/cli && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/loose_finger_cli.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
cli/CMakeFiles/loose_finger_cli.dir/build: ../bin/loose_finger_cli
.PHONY : cli/CMakeFiles/loose_finger_cli.dir/build

cli/CMakeFiles/loose_finger_cli.dir/requires: cli/CMakeFiles/loose_finger_cli.dir/loose_finger_cli.o.requires
.PHONY : cli/CMakeFiles/loose_finger_cli.dir/requires

cli/CMakeFiles/loose_finger_cli.dir/clean:
	cd /home/sisir/sandia-hand/ros/sandia_hand_driver/build/cli && $(CMAKE_COMMAND) -P CMakeFiles/loose_finger_cli.dir/cmake_clean.cmake
.PHONY : cli/CMakeFiles/loose_finger_cli.dir/clean

cli/CMakeFiles/loose_finger_cli.dir/depend:
	cd /home/sisir/sandia-hand/ros/sandia_hand_driver/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/sisir/sandia-hand/ros/sandia_hand_driver /home/sisir/sandia-hand/ros/sandia_hand_driver/cli /home/sisir/sandia-hand/ros/sandia_hand_driver/build /home/sisir/sandia-hand/ros/sandia_hand_driver/build/cli /home/sisir/sandia-hand/ros/sandia_hand_driver/build/cli/CMakeFiles/loose_finger_cli.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : cli/CMakeFiles/loose_finger_cli.dir/depend
