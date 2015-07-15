
# Homebrew (if you haven't yet got it)
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo export PATH='/usr/local/bin:$PATH' >> ~/.bash_profile
source .bash_profile
brew doctor
brew update

# Brewed Python
brew install python
mkdir -p ~/Library/Python/2.7/lib/python/site-packages
echo "$(brew --prefix)/lib/python2.7/site-packages" >> ~/Library/Python/2.7/lib/python/site-packages/homebrew.pth

# Homebrew taps for prerequisites
brew tap ros/deps
brew tap osrf/simulation
brew tap homebrew/versions
brew tap homebrew/science

# Prerequisites
brew install cmake libyaml lz4 assimp
brew install boost --with-python
brew install opencv --with-qt --with-eigen --with-tbb
brew install ogre  # Ogre v1.7
brew install gazebo5

# ROS infrastructure tools
pip install -U setuptools rosdep rosinstall_generator wstool rosinstall catkin_tools catkin_pkg bloom empy sphinx
sudo rosdep init
rosdep update

# ROS Indigo Source Install
mkdir indigo_desktop_ws && cd indigo_desktop_ws
rosinstall_generator desktop_full --rosdistro indigo --deps --tar > indigo.rosinstall
rosinstall_generator rviz --rosdistro hydro --tar >> indigo.rosinstall  # Version of rviz from Hydro
wstool init -j8 src indigo.rosinstall

# Package dependencies.
rosdep install --from-paths src --ignore-src --rosdistro indigo -y --as-root pip:no --skip-keys="ogre gazebo"

# Parallel build
sudo mkdir -p /opt/ros/indigo
sudo chown $USER /opt/ros/indigo
catkin config --install  --install-space /opt/ros/indigo
catkin build \
  -DCMAKE_BUILD_TYPE=Release \
  -DPYTHON_LIBRARY=$(python -c "import sys; print sys.prefix")/lib/libpython2.7.dylib \
  -DPYTHON_INCLUDE_DIR=$(python -c "import sys; print sys.prefix")/include/python2.7

source /opt/ros/indigo/setup.bash
