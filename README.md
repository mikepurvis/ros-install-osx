Hey friends and fans! This project is looking for a new maintainer and owner, in part because I'm moving out of the Apple ecosystem for personal and work computers. If you use or have used this and would be interested in periodically updating it as new things happen upstream to break it, please get in touch— see my email in the git history.

----

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
