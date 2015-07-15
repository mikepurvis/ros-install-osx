ROS_DISTRO=indigo
ROS_CONFIGURATION=desktop_full
ROS_INSTALL_DIR=/opt/ros/${ROS_DISTRO}

# Homebrew
if ! hash brew 2>/dev/null; then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  echo export PATH='/usr/local/bin:$PATH' >> ~/.bash_profile
  source .bash_profile
  brew doctor
  brew update
fi

# XQuartz
if ! hash xquartz 2>/dev/null; then
  brew install caskroom/cask/brew-cask
  brew cask install xquartz
  echo "Log out and in to finalize XQuartz setup."
  exit 0
fi

# Brewed Python
if [ $(which python) != "/usr/local/bin/python" ]; then
  brew install python
  mkdir -p ~/Library/Python/2.7/lib/python/site-packages
  echo "$(brew --prefix)/lib/python2.7/site-packages" >> ~/Library/Python/2.7/lib/python/site-packages/homebrew.pth
fi

# Homebrew taps for prerequisites
brew tap ros/deps
brew tap osrf/simulation
brew tap homebrew/versions
brew tap homebrew/science

# Prerequisites
brew install cmake libyaml lz4 assimp
brew install boost --with-python
brew install opencv --with-qt --with-eigen --with-tbb
brew install ogre
brew install gazebo5

# ROS infrastructure tools
pip install -U setuptools rosdep rosinstall_generator wstool rosinstall catkin_tools catkin_pkg bloom empy sphinx
if [ ! -d /etc/ros/rosdep/ ]; then
  sudo rosdep init
fi
rosdep update

# ROS Indigo Source Install
WS=${ROS_DISTRO}_${ROS_CONFIGURATION}_ws
mkdir $WS && cd $WS
rosinstall_generator ${ROS_CONFIGURATION} --rosdistro ${ROS_DISTRO} --deps --tar > ${WS}.rosinstall
#rosinstall_generator rviz --rosdistro hydro --tar >> ${WS}.rosinstall  # Version of rviz from Hydro
wstool init -j8 src ${WS}.rosinstall

# Package dependencies.
rosdep install --from-paths src --ignore-src --rosdistro ${ROS_DISTRO} -y --as-root pip:no --skip-keys="ogre gazebo"

# Parallel build
sudo mkdir -p ${ROS_INSTALL_DIR}
sudo chown $USER ${ROS_INSTALL_DIR}
catkin config --install  --install-space ${ROS_INSTALL_DIR}
catkin build \
  -DCMAKE_BUILD_TYPE=Release \
  -DPYTHON_LIBRARY=$(python -c "import sys; print sys.prefix")/lib/libpython2.7.dylib \
  -DPYTHON_INCLUDE_DIR=$(python -c "import sys; print sys.prefix")/include/python2.7

source ${ROS_INSTALL_DIR}/setup.bash
