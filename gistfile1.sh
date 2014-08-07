# Preparation
brew tap ros/deps
brew tap osrf/simulation
brew tap homebrew/versions
brew tap homebrew/science

# Prerequisites
brew install cmake python libyaml lz4
brew install opencv --with-qt --with-eigen --with-tbb

# Install PIL (Pending: https://github.com/ros/rosdistro/issues/5220 ?)
ln -s /usr/local/include/freetype2 /usr/local/include/freetype
pip install pil --allow-external pil --allow-unverified pil

# Create install path
sudo mkdir -p /opt/ros/indigo
sudo chown $USER /opt/ros/indigo

# ROS build infrastructure tools
pip install -U setuptools rosdep rosinstall_generator wstool rosinstall catkin_tools bloom
sudo rosdep init
rosdep update

# Standard ROS Source Setup
mkdir indigo_desktop_ws && cd indigo_desktop_ws
rosinstall_generator desktop --rosdistro indigo --deps --tar > indigo.rosinstall
wstool init -j4 src indigo.rosinstall
rosdep install --from-paths src --ignore-src --rosdistro indigo -y

# Parallel build (python overrides unnecessary pending: https://github.com/Homebrew/homebrew/issues/25118 )
catkin build --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/indigo \
  -DPYTHON_LIBRARY=/usr/local/Cellar/python/2.7.8/Frameworks/Python.framework/Versions/2.7/lib/libpython2.7.dylib \
  -DPYTHON_INCLUDE_DIR=/usr/local/Cellar/python/2.7.8/Frameworks/Python.framework/Versions/2.7/include/python2.7

source /opt/ros/indigo/setup.bash