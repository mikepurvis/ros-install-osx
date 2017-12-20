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

# Troubleshooting

Below are assorted tips that I have compiled for fixing any issues that can crop up.

* It is basically impossible to get indigo to work on macOS sierra
    * This has to do with home-brew dropping qt4 support: https://github.com/mikepurvis/ros-install-osx/issues/63
* Could also install indigo on snapdragon, but would take a VERY long time to install
* rosdep —skip-keys command is useful for resolving dependencies
    * rosdep check --from-paths src --ignore-src --rosdistro kinetic --skip-keys geographiclib --skip-keys geographiclib-tools
* Indigo still doesn’t work using qt@4
    * Can’t detect correct qt installation
* Important steps to get kinetic to work (all of these are critical):
    * Make sure using brew python/pip
    * Use boost@1.59 —c++11 —with-icu4c
        * Newest version (1.65) does not include tr1 libraries so some packages fail
    * Use boost-python@1.59
    * Rviz needs ogre1.9
        * Actually I think you can get away with regular ogre, which is necessary for gazebo7
    * Follow attached install script
    * make sure to "brew link qt5 —force”
* boost 1.65 causes major problems
    * rviz does not compile with it
        * this issue is related: https://github.com/osrf/homebrew-simulation/issues/267
    * need to use cmake —HEAD to build
    * This may have been resolved
* Gazebo8
    * Uses Ogre1.9, requires "gazebo8_ros_pkgs-release” to integrate with ROS kinetic
* Geometry2
    * Better support for tf2
* cmake args: 
    *Use install script
* High Sierra
    * Make sure to set `ROS_MASTER_URI` to the actual machine name
    * Otherwise significant delays exist in running especially python based commands
* If having QT errors compiling look at the end of this thread:
    * https://github.com/Homebrew/legacy-homebrew/issues/29938
    * Basically add path
* Command for updating pip if getting weird python errors
    * pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
* If you start getting weird errors with accessing too many files, try:
	* `ulimit -n 4096`
	* See [here](https://superuser.com/questions/433746/is-there-a-fix-for-the-too-many-open-files-in-system-error-on-os-x-10-7-1) for details
	* or
	* `sudo sysctl -w kern.maxfiles=67584`
	* `sudo sysctl -w kern.maxfilesperproc=65536    # (67584 - 2048)`
	* `ulimit -n 65536`
* [If running out of pty devices](https://codybonney.com/increase-the-max-number-of-ptys-on-os-x-10-8-3/)
* image_publisher currently fails. [See this fix](https://github.com/ros-perception/image_pipeline/pull/304)
* For Gazebo plugins, don't forget to setup `/opt/ros/kinetic/lib` in `GAZEBO_PLUGIN_PATH` and to export it into env