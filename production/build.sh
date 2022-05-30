#!/bin/bash

# export executables
../godot.linuxbsd.tools.64 --export "Windows Desktop" ../Tracker.exe
../godot.linuxbsd.tools.64 --export "Linux/X11" ../Tracker.x86_64

# change windows icon
../godot.linuxbsd.tools.64 -s production/ReplaceIcon.gd image/icon.ico ../Tracker.exe

# create compressed archives
7z u ../TrackerWindows.7z ../Tracker.exe
7z u ../TrackerLinux.7z ../Tracker.x86_64

