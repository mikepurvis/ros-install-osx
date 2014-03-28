# Standard setup (use desktop metapackage once released)
rosinstall_generator ros ros_comm robot_model robot_state_publisher diagnostic_msgs octomap rviz \
    --rosdistro indigo --deps --wet-only --tar > indigo.rosinstall
wstool init -j8 src indigo.rosinstall
rosdep install --from-paths src --ignore-src --rosdistro indigo -ry

# Install extra stuff (unnecessary pending rosdep updates?)
sudo pip install -U pillow
brew install wxpython

# Source version of orocos (unnecessary after next release of orocos packages)
pushd src
wstool remove orocos_kinematics_dynamics/*
wstool set orocos_kinematics_dynamics --git https://github.com/orocos/orocos_kinematics_dynamics
wstool update orocos_kinematics_dynamics
popd

# Parallel build (python overrides unnecessary pending: https://github.com/Homebrew/homebrew/issues/25118 )
catkin build --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/indigo \
  -DPYTHON_LIBRARY=/usr/local/Cellar/python/2.7.6/Frameworks/Python.framework/Versions/2.7/lib/libpython2.7.dylib \
  -DPYTHON_INCLUDE_DIR=/usr/local/Cellar/python/2.7.6/Frameworks/Python.framework/Versions/2.7/include/python2.7

catkin build --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/indigo
source /opt/ros/indigo/setup.bash