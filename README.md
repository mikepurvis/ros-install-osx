ros-install-osx 
===============

This repo aims to maintain a usable, scripted, up-to-date installation procedure for
[ROS](http://ros.org) Kinetic. The intent is that the `install` script may be executed on a
bare Sierra machine and produce a working desktop_full installation,
including RQT, rviz, and Gazebo.

This is based on [Mike Purvis' script](https://github.com/mikepurvis/ros-install-osx). It modifies the install to use Gazebo8 and supporting packages such that ogre1.9 and up to date Rviz can be used.

[1]: https://gist.github.com/mikepurvis/9837958


Usage
-----

    curl https://raw.githubusercontent.com/smnogar/ros-install-osx/master/install | bash

or

```shell
git clone https://github.com/smnogar/ros-install-osx
cd ros-install-osx
./install
```

Note that if you do not yet have XQuartz installed, you will be forced to log out and
in after that installation, and re-run this script.

You will be prompted for your sudo password at the following points in this process:

   - Homebrew installation.
   - Caskroom installation.
   - XQuartz installation.
   - Initializing rosdep.
   - Creating and chowning your `/opt/ros/[distro]` folder.

The installation can be done entirely without sudo if Homebrew and XQuartz are already
installed, rosdep is already installed and initialized, and you set the `ROS_INSTALL_DIR`
environment variable to a path which already exists and you have write access to.
