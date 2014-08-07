# Install XQuartz from: https://xquartz.macosforge.org

# Homebrew Setup (skip if already done)
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
# TODO: Put /usr/local/bin at front of path, source .bash_profile
brew doctor
brew update

# Taps for specific formulae
brew tap ros/deps
brew tap osrf/simulation
brew tap homebrew/versions
brew tap homebrew/science

# Prerequisites
brew install cmake python libyaml lz4
brew install boost --with-python
brew install opencv --with-qt --with-eigen --with-tbb
brew install ogre --head  # Ogre 1.9 for indigo's rviz

# Install unreleased empy
curl http://www.alcyone.com/software/empy/empy-latest.tar.gz | tar xvz
pushd empy-3.3.2
python setup.py install
popd

# Install PIL (Pending: https://github.com/ros/rosdistro/issues/5220)
ln -s /usr/local/include/freetype2 /usr/local/include/freetype
pip install pil --allow-external pil --allow-unverified pil

# Create install path
sudo mkdir -p /opt/ros/indigo
sudo chown $USER /opt/ros/indigo

# ROS build infrastructure tools
pip install -U setuptools rosdep rosinstall_generator wstool rosinstall catkin_tools catkin_pkg bloom
sudo rosdep init
rosdep update

# ROS Source Install
mkdir indigo_desktop_ws && cd indigo_desktop_ws
rosinstall_generator desktop --rosdistro indigo --deps --tar > indigo.rosinstall
wstool init -j4 src indigo.rosinstall
rosdep install --from-paths src --ignore-src --rosdistro indigo -y

# Parallel build
catkin build --install -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/indigo \
  -DPYTHON_LIBRARY=/usr/local/Cellar/python/2.7.8/Frameworks/Python.framework/Versions/2.7/lib/libpython2.7.dylib \
  -DPYTHON_INCLUDE_DIR=/usr/local/Cellar/python/2.7.8/Frameworks/Python.framework/Versions/2.7/include/python2.7

source /opt/ros/indigo/setup.bash