# Magisk OverlayFS
From Android 10+, system may no longer to be mounted as read-write. A simple script that can emulate read-write partition for read-only system partitions.

## Requirements
- Your kernel must support overlayfs

## What this module do?

> This module is experimental, might not work or cause some problems on some devices/ROMs

- The aim of this module is to emulate system writeable by using overlayfs also make any modifications to system partition become systemless. That's mean no actual changes are made on system partition through overlayfs. The modified files are stored inside `/data/adb/modules/magisk_overlayfs/overlay`. Note, overlay is mounted read-only by default, you can create `mountrw` in `/data/adb/modules/magisk_overlayfs` to make it mounted read-write by default and allow runtime modified files.
- Hide Custom ROM: Use overlayfs to hide `addon.d` and `init.d` of Custom ROM from Momo detection
- Remove non-Magisk root solution if needed
- Overlay-based modules for Magisk modules: 
    - Enable on some modules: Create `overlay` and `skip_mount` (if you don't want to use Magic Mount) dummy file in which module directory you want to enable this feature
    - Enable for all modules (Global mode): Create `enable` dummy file in `/data/adb/modules/magisk_overlayfs`. Enable global mode can bypass "Found files modified by Magisk" detection of Momo
