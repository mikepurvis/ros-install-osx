ros-install-osx   ![Manual test on Parallels VM](https://img.shields.io/badge/yosemite-2015--08--13-green.svg)
===============

This repo aims to maintain a usable, scripted, up-to-date installation procedure for
[ROS](http://ros.org). The intent is that the `install` script may be executed on a
bare Mavericks or Yosemite machine and produce a working desktop_full installation,
including RQT, rviz, and Gazebo.

This is the successor to my [popular gist on the same topic][1].

[1]: https://gist.github.com/mikepurvis/9837958


Usage
-----

    curl https://raw.githubusercontent.com/mikepurvis/ros-install-osx/master/install | bash

or

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

    catkin build \
      -DCMAKE_BUILD_TYPE=Release \
      -DPYTHON_LIBRARY=$(python -c "import sys; print sys.prefix")/lib/libpython2.7.dylib \
      -DPYTHON_INCLUDE_DIR=$(python -c "import sys; print sys.prefix")/include/python2.7 \
      --start-with rviz

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

#### No definition of [procps] for OS [osx]

This issue is known to the developers and is being addressed. See:

* http://answers.ros.org/question/224956/no-definition-of-procps-for-os-osx
* https://github.com/ros-perception/vision_opencv/pull/109

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

This may occur after installation has finished successfully and you try to
execute something like `rosrun`. For example:

```bash
rosrun turtlesim turtlesim_node
dyld: Library not loaded: librospack.dylib
  Referenced from: # Some file in the catkin ws
  Reason: image not found
find: ftsopen: No such file or directory
[rosrun] Couldnt find executable named turtlesim_node below
find: ftsopen: No such file or directory
```

The quick fix is to add

```bash
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/opt/ros/indigo/lib
```

to the start of `/opt/ros/indigo/bin/rosrun` (or other problematic script).

### other

#### Qt hack

The `install` script carries out the following "hack":

```shell
if [ -d /usr/local/Cellar/qt/4.8.7 ]; then
    pushd /usr/local/Cellar/qt
    if [ ! -d "4.8.6" ]; then
      ln -s 4.8.7 4.8.6
    fi
    popd
  fi
```
However, it is very likely that this won't work as Qt gets upgraded.
For example, as of the writing of this section, the latest version is `4.8.7_2`.
Therefore, you would have to modify the `install` script:
```shell
ln -s 4.8.7_2 4.8.6
```
In addition, if you ever perform a `brew cleanup`, Homebrew will delete this
symlink that the script created (`4.8.6`) and you will have to create it again.
You can check the status of your symlink using:
```shell
ls -lh /usr/local/Cellar/qt # You should see 4.8.6 -> 4.8.7_2
```
