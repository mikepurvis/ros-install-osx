# NOTE: These instructions do not represent a robust, self-troubleshooting install; they
# are definitely not suitable for dumping to a giant script and running as one. If you 
# use them, they should be run one at a time, with an eye out for errors or problems
# along the way.
#
# The #1 issue you are likely to encounter is with Homebrew or Python packages which
# binary components linked against system Python. This will result in runtime segfaults,
# especially in rviz. If you suspect this is occurring, you can attempt to remove and
# reinstall the offending packages, or go for the nuclear option--- empty your Cellar
# and site-packages folders and start over with brewed python from the beginning.
#
# If you haven't already, install XQuartz using the installer from its own website:
# https://xquartz.macosforge.org

# Homebrew (if you haven't yet got it)
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
echo export PATH='/usr/local/bin:$PATH' >> ~/.bash_profile
source .bash_profile
brew doctor
brew update

# Brewed Python
brew install python
mkdir -p ~/Library/Python/2.7/lib/python/site-packages
echo "$(brew --prefix)/lib/python2.7/site-packages" >> ~/Library/Python/2.7/lib/python/site-packages/homebrew.pth

# Homebrew taps for specific formulae
brew tap ros/deps
brew tap osrf/simulation
brew tap homebrew/versions
brew tap homebrew/science

# Prerequisites
brew install cmake libyaml lz4
brew install boost --with-python
brew install opencv --with-qt --with-eigen --with-tbb
brew install ogre  # --head  # Ogre 1.9 for indigo's rviz, but we're using hydro's rviz pending: https://github.com/ros-visualization/rviz/issues/782

# ROS build infrastructure tools
pip install -U setuptools rosdep rosinstall_generator wstool rosinstall catkin_tools catkin_pkg bloom
sudo rosdep init
rosdep update

# ROS Indigo Source Install
sudo mkdir -p /opt/ros/indigo
sudo chown $USER /opt/ros/indigo
mkdir indigo_desktop_ws && cd indigo_desktop_ws
rosinstall_generator desktop --rosdistro indigo --deps --tar > indigo.rosinstall
rosinstall_generator rviz --rosdistro hydro --tar >> indigo.rosinstall  # Version of rviz from Hydro
wstool init -j8 src indigo.rosinstall
rosdep install --from-paths src --ignore-src --rosdistro indigo -y

# Parallel build
catkin build --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/indigo \
  -DPYTHON_LIBRARY=/usr/local/Cellar/python/2.7.8/Frameworks/Python.framework/Versions/2.7/lib/libpython2.7.dylib \
  -DPYTHON_INCLUDE_DIR=/usr/local/Cellar/python/2.7.8/Frameworks/Python.framework/Versions/2.7/include/python2.7

source /opt/ros/indigo/setup.bash