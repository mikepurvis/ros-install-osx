# NOTE: These instructions do not represent a robust, self-troubleshooting install; they
# are definitely not suitable for dumping to a giant script and running as one. If you 
# use them, they should be run one at a time, with an eye out for errors or problems
# along the way.
#
# The #1 issue you are likely to encounter is with Homebrew or Python packages whose
# binary components link against system Python. This will result in runtime segfaults,
# especially in rviz. If you suspect this is occurring, you can attempt to remove and
# reinstall the offending packages, or go for the nuclear option--- empty your Cellar
# and site-packages folders and start over with brewed python from the beginning.
#
# If you haven't already, install XQuartz using the installer from its own website:
# https://xquartz.macosforge.org

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
brew install https://github.com/osrf/homebrew-simulation/raw/ogre_1_9/ogre-1.9.rb

# ROS infrastructure tools
pip install -U setuptools rosdep rosinstall_generator wstool rosinstall catkin_tools catkin_pkg bloom empy sphinx
sudo rosdep init
rosdep update

# ROS Indigo Source Install
mkdir indigo_desktop_ws && cd indigo_desktop_ws
rosinstall_generator desktop_full --rosdistro indigo --deps --tar > indigo.rosinstall
wstool init -j8 src indigo.rosinstall

# Package dependencies.
rosdep install --from-paths src --ignore-src --rosdistro indigo -y --as-root pip:no --skip-keys="ogre gazebo"

# Parallel build
sudo mkdir -p /opt/ros/indigo
sudo chown $USER /opt/ros/indigo
catkin config --install  --install-space /opt/ros/indigo
catkin build \
  -DCMAKE_BUILD_TYPE=Release \
  -DPYTHON_LIBRARY=/usr/local/Cellar/python/2.7.9/Frameworks/Python.framework/Versions/2.7/lib/libpython2.7.dylib \
  -DPYTHON_INCLUDE_DIR=/usr/local/Cellar/python/2.7.9/Frameworks/Python.framework/Versions/2.7/include/python2.7

source /opt/ros/indigo/setup.bash