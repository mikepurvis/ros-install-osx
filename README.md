ros-install-osx   
===============

* This commonly breaks depending on what gets pushed over brew and whether the corresponding packages update deprecated code. Efforts have been made to pick out working versions of specific packages, but nothing is guaranteed.

This repo aims to maintain a usable, scripted, up-to-date installation procedure for [ROS](http://ros.org), currently melodic. The intent is that the `install` script may be executed on a Catalina or newer machine and produce a working desktop_full  installation, including RQT, rviz, and Gazebo.

This is the successor to the [popular gist on the same topic][1]. Also thanks to [Boris Gromov](https://gist.github.com/bgromov) for [his helpful gist](https://gist.github.com/bgromov/23a74bbe846d965964b150080cb2d574).

## Current Status

**Note: This should work as of March 1, 2020 on Catalina 10.15.3** 

Required software versions (installed via script):

* **boost**: 1.72
* **opencv3**
* **python2**

Usage
-----

The `install` script should just work for most users, although you may need to run it multiple times. Run these steps first to have a better chance of success:

1. [Disable system integrity protection](https://www.imore.com/how-turn-system-integrity-protection-macos).

2. If on Catalina, set your terminal back to bash. This is very helpful for building software via brew, and roslaunch will not autocomplete using zsh.

   ```bash
   chsh -s /bin/bash
   ```

3. Attempting to clone this repo onto your machine should trigger the xcode command line tools to download.

   ```bash
   xcode-select --install
   git clone https://github.com/smnogar/ros-install-osx.git
   cd ros-install-osx
   ```

4. Install brew

   ```bash
   ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
   echo export PATH='/usr/local/bin:$PATH' >> ~/.bash_profile
   source ~/.bash_profile
   brew doctor
   ```

5. Install xquartz

   ```bash
   brew cask install xquartz
   ```

6. Run: `./install`

7. After it completes successfully, add the following to your bash_profile:

   ```bash
   cat bash_profile_recommendations.sh >> ~/.bash_profile
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

### El Capitan (and newer) support

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

**It is strongly recommended to disable SIP**

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
    * Rviz needs ogre1.9

* Gazebo8

    * Uses Ogre1.9

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
  * `sudo sysctl -w kern.maxfiles=99999`
  * `sudo sysctl -w kern.maxfilesperproc=99999`
  * `ulimit -n 65536`

* [If running out of pty devices](https://codybonney.com/increase-the-max-number-of-ptys-on-os-x-10-8-3/)

  * `sudo sysctl -w kern.tty.ptmx_max=999`

* image_publisher currently fails. [See this fix](https://github.com/ros-perception/image_pipeline/pull/304)

* For Gazebo plugins, don't forget to setup `/opt/ros/kinetic/lib` in `GAZEBO_PLUGIN_PATH` and to export it into env

* mavros/mavlink

  * [workaround to get mavros to compile (endian.h) errors] (https://github.com/mavlink/mavros/issues/851)

* If errors are encountered such as:

    ```
    Errors     << qt_gui_cpp:cmake /Users/steve/Documents_local/temp/kinetic/logs/qt_gui_cpp/build.cmake.000.log                        
    CMake Error at /Users/steve/Documents/ARL/Snapdragon/ros-install-osx/kinetic_desktop_full_ws/src/qt_gui_core/qt_gui_cpp/src/qt_gui_cpp/CMakeLists.txt:3 (find_package):
      By not providing "FindQt5Widgets.cmake" in CMAKE_MODULE_PATH this project
      has asked CMake to find a package configuration file provided by
      "Qt5Widgets", but CMake did not find one.
    
      Could not find a package configuration file provided by "Qt5Widgets" with
      any of the following names:
    
        Qt5WidgetsConfig.cmake
        qt5widgets-config.cmake
    
      Add the installation prefix of "Qt5Widgets" to CMAKE_PREFIX_PATH or set
      "Qt5Widgets_DIR" to a directory containing one of the above files.  If
      "Qt5Widgets" provides a separate development package or SDK, be sure it has
      been installed.
    ```

    * It means qt or pyqt are not correctly installed or in the path. Try the various relevant lines in the installation script such as:

      * 

        ```
        pushd /usr/local/share/sip
          if [ ! -e PyQt5 ]; then
            ln -s Qt5 PyQt5
          fi
          popd
        ```

      * `export PATH=$(pwd)/shim:$PATH`

      * `brew link qt --force `

      * `export PATH="/usr/local/opt/qt/bin:$PATH" `

* Python Crypto errors

    * ```
        pip uninstall Crypto
        pip uninstall pycrypto
        pip install pycrypto
        ```

* If having issues with packages not finding terminal_color, you need to up catkin_pkg_modules

	```bash
	sudo pip install --upgrade catkin_pkg_modules
	```


