ros-install-osx   [![Build Status](https://travis-ci.org/mikepurvis/ros-install-osx.svg?branch=master)](https://travis-ci.org/mikepurvis/ros-install-osx)
===============

This repo aims to maintain a usable, scripted, up-to-date installation procedure for
[ROS](http://ros.org), currently Lunar. The intent is that the `install` script may
be executed on a El Capitan or newer machine and produce a working desktop_full
installation, including RQT, rviz, and Gazebo.

This is the successor to my [popular gist on the same topic][1].

[1]: https://gist.github.com/mikepurvis/9837958


Usage
-----

```shell
git clone https://github.com/mikepurvis/ros-install-osx.git
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


Step by Step
------------

The `install` script should just work for most users. However, if you run into trouble,
it's a pretty big pain to rebuild everything. Note that in this scenario, it may make
sense to treat the script as a list of instructions, and execute them one by one,
manually.

If you have a build fail, for example with rviz, note that you can modify the `catkin build`
line to start at a particular package. Inside your `indigo_desktop_full_ws` dir, run:

    catkin build --start-with rviz

If you've resolved whatever issue stopped the build previously, this will pick up where
it left off.


## Troubleshooting

### Python and pip packages

Already-installed homebrew and pip packages are the most significant source of errors,
especially pip packages linked against the system Python rather than Homebrew's Python,
and Homebrew packages (like Ogre) where multiple versions end up installed, and things
which depend on them end up linked to the different versions. If you have MacPorts or
Fink installed, and Python from either of those is in your path, that will definitely
be trouble.

The script makes _some_ attempt at detecting and warning about these situations, but some
problems of this kind will only be visible as segfaults at runtime.

Unfortunately, it's pretty destructive to do so, but the most reliable way to give
yourself a clean start is removing the current homebrew installation, and all
currently-installed pip packages.

For pip: `pip freeze | xargs sudo pip uninstall -y`

For homebrew, see the following: https://gist.github.com/mxcl/1173223

If you take these steps, obviously also remove your ROS workspace and start the install
process over from scratch as well. Finally, audit your `$PATH` variable to ensure that
when you run `python`, you're getting Homebrew's `python`.
Another way to check which Python you are running is to do:

```bash
which python # Should result in /usr/local/bin/python
ls -l $(which python) # Should show a symlink pointing to Homebrew's Cellar
```

If you are getting permission errors when you `sudo uninstall` pip packages,
see [Issue #11](https://github.com/mikepurvis/ros-install-osx/issues/11) and
[this StackOverflow Q&A](http://stackoverflow.com/a/35051066/2653356).

### El Capitan support

The `install` script may not work as smoothly in OS X El Capitan.
Here are some pointers, tips, and hacks to help you complete the installation.
This list was compiled based on the discussion in [Issue #12](https://github.com/mikepurvis/ros-install-osx/issues/12).

#### library not found for -ltbb

See [Issue #4](https://github.com/mikepurvis/ros-install-osx/issues/4).
You need to compile using Xcode's Command Line Tools:

```shell
xcode-select --install # Install the Command Line Tools
sudo xcode-select -s /Library/Developer/CommandLineTools # Switch to using them
gcc --version # Verify that you are compiling using Command Line Tools
```

The last command should output something that includes the following:

```bash
Configured with: --prefix=/Library/Developer/CommandLineTools/usr
```

You'll then have to rerun the entire `install` script or do the following:

```bash
rm -rf /opt/ros/indigo/* # More generally, /opt/ros/${ROS_DISTRO}/*
rm -rf build/ devel/ # Assuming your working dir is the catkin workspace
catkin build \
  ... # See actual script for the 4-line-long command
```

#### dyld: Library not loaded

If you see this after installation, when trying to execute `rosrun`, then you
have [System Integrity Protection](https://support.apple.com/en-us/HT204899) enabled.
The installation script should have detected that and *suggested* a quick fix.
Please refer to the very last section of 
[`install`](https://github.com/mikepurvis/ros-install-osx/blob/master/install)

#### Assorted notes

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
    * Rviz needs ogre1.9
    * Follow attached install script
    * make sure to "brew link qt5 —force”
* boost 1.65 causes major problems
    * rviz does not compile with it
        * this issue is related: https://github.com/osrf/homebrew-simulation/issues/267
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