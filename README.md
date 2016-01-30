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
curl -O https://raw.githubusercontent.com/mikepurvis/ros-install-osx/master/install
bash install
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


Troubleshooting
---------------

Already-installed homebrew and pip packages are the most significant source of errors,
especially pip packages linked against the system python rather than homebrew's python,
and homebrew packages (like Ogre) where multiple versions end up installed, and things
which depend on them end up linked to the different versions. If you have macports or
fink installed, and python from either of those is in your path, that will definitely
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

### El Capitan support

The `install` script may not work as smoothly in OS X El Capitan (see [Issue #12](https://github.com/mikepurvis/ros-install-osx/issues/12))
Here are some pointers, tips, and hacks to help you complete the installation:

#### No definition of [procps] for OS [osx]

This issue is known to the developers and is being addressed. See:

* http://answers.ros.org/question/224956/no-definition-of-procps-for-os-osx
* https://github.com/ros-perception/vision_opencv/pull/109

#### FLTK fails to build

For a quick fix, you can do the following:

```
brew reinstall --devel https://raw.githubusercontent.com/dpo/homebrew/ec46018128dde5bf466b013a6c7086d0880930a3/Library/Formula/fltk.rb

```
