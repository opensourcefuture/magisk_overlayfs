MODID=$(basename "$MODPATH")
ui_print "- Test if your kennel support overlayfs"
is_overlayfs=false
mkdir -p /dev/overlay_test/layer1
mkdir -p /dev/overlay_test/layer2
mkdir -p /dev/overlay_test/merged
mount -t overlay -o lowerdir=/dev/overlay_test/layer1:/dev/overlay_test/layer2 overlay /dev/overlay_test/merged
if mount -t overlay | grep -q "overlay" &>/dev/null; then
is_overlayfs=true
fi

umount -l /dev/overlay_test/*
rm -rf /dev/overlay_test

$is_overlayfs && ui_print "- Great! Your kernel support overlayfs" || abort "! Your kernel doesn't support overlayfs"

ui_print "- Perserve all current changes..."
SKIPUNZIP=1
mkdir -p "/data/adb/modules/$MODID"
unzip -o "$ZIPFILE" 'post-fs-data.sh' 'module.prop' -d "/data/adb/modules/$MODID" &>/dev/null
rm -rf "$MODPATH"
(sleep 1; rm -rf "/data/adb/modules/$MODID/update")&

ui_print "- Real partition is"
ui_print "  [MAGISKTMP]/.magisk/mirror/real_[partition_name]!"