ros-install-osx
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

Note that if you do not yet have command-line tools for XCode or XQuartz installed, you will
need to rerun the script after those installation steps, and log out and in after XQuartz
installation.

You may be prompted for your sudo password at the following points in this process:

   - Homebrew installation.
   - Caskroom installation.
   - XQuartz installation.
   - Creating and chowning your `/opt/ros/distro` folder.


Troubleshooting
---------------

Already-installed homebrew and pip packages are the most significant source of errors,
especially pip packages installed against the system python rather than homebrew's python,
and homebrew packages (like Ogre) where multiple versions end up installed, and things
which depend on them end up linking to the different versions. These problems are typically
visible at runtime, as segfaults and the like.

Unfortunately, it's pretty destructive to do so, but the most reliable way to give
yourself a clean start is removing the current homebrew installation, and currently-
installed pip packages.

For pip:

    rm -rf /Library/Python/2.7/site-packages/*
    rm -rf ~/Library/Python/2.7/lib/python/site-packages/*
    rm -rf /usr/local/lib/python2.7/site-packages/*

For homebrew, see the following: https://gist.github.com/mxcl/1173223

If you take these steps, obviously also remove your ROS workspace and start this process
over from scratch as well.
