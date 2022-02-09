# Magisk OverlayFS
From Android 10+, system may no longer to be mounted as read-write. A simple script that can emulate read-write partition for read-only system partitions.

## Requirements
- Your kernel must support overlayfs

## What this module do?

> This module is experimental, might not work or cause some problems on some devices/ROMs

- The aim of this module is to emulate system writeable by using overlayfs also make modifying system partition become systemless. That's mean no actual changes are make on system partition through overlayfs. The modified files are stored inside `/data/adb/modules/magisk_overlayfs/overlay`. Note, overlay is mounted read-only by default, you can create `mountrw` in `/data/adb/modules/magisk_overlayfs` to make it mounted read-write by default and allow runtime modified files.
- After modifying overlay, you can lock it as read-only by creating a dummy file name `lockro`, however overlay will not be able to be mounted as read-write
- Hide Custom ROM: Use overlayfs to hide `addon.d` and `init.d` of Custom ROM from Momo detection
- Remove non-Magisk root solution if needed
- Overlay-based modules for Magisk modules: 
    - Enable on some modules: Create `overlay` and `skip_mount` (if you don't want to use Magic Mount) dummy file in which module directory you want to enable this feature
    - Enable for all modules (Global mode): Create `enable` dummy file in `/data/adb/modules/magisk_overlayfs` and create `skip_mount` for all modules, you can do it by using this command in Terminal Emulator: 
```
for module in `ls /data/adb/modules`; do
touch /data/adb/modules/$module/skip_mount
done
```

<p>Tested on <a href="https://www.coolapk.com/apk/io.github.vvb2060.mahoshojo">Momo</a> - Momo is known as a strongest detection app ever!</br>
<img src="https://github.com/HuskyDG/huskydg.github.io/raw/main/img/Screenshot_20220207-132556_Adware.png" />
<img src="https://github.com/HuskyDG/huskydg.github.io/raw/main/img/Screenshot_20220207-133724_Momo.png" />
</p>

**NOTE: Modifications to OverlayFS is not hidden (unmounted) along with MagiskHide/DenyList so it is useful for some font modules on Android 12 due to new behavior, make sure your modules id doesn't include "magisk" word, DO NOT enable Global mode if not neccessary**

## Magic Mount vs OverlayFS

| Magic Mount | OverlayFS |
| :--: | :--: |
| Work on almost kernel | Only work if kernel support (usually Android 10+) |
| Does not support delete files systemlessly (It can but very complicated) | Can emulate files have been deleted without changing the original partition make remove files systemlessly possible |
| When a module want to add a file into real partition, Magisk cannot add it directly, has to do under-hood multiple mount bind tasks to achieve it | Add files by combining between lowerdir and upperdir |
