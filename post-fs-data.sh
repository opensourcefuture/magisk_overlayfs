unset vendor
unset product
unset system_ext


MAGISKTMP="$(magisk --path)"
[ -z "$MAGISKTMP" ] && MAGISKTMP=/sbin

mkdir -p "$MAGISKTMP/.magisk/tmp"

TMPDIR="$MAGISKTMP/.magisk/tmp"

# exec &>>"$MAGISKTMP/mount_error.txt

DATA_BLOCK="$(mount | grep " /data " | awk '{ print $1 }')"
DATA_BLOCK="/dev/block/$(basename "$DATA_BLOCK")"
test -z "$DATA_BLOCK" && exit
DATA_MOUNTPOINT="/dev/mnt_mirror/data"
MAGISK_DATAMIRROR="$MAGISKTMP/.magisk/mirror/data"
OVERLAYFS_DIR="/dev/mnt_mirror/overlay"

mkdir -p "$DATA_MOUNTPOINT"

mount -o rw,seclabel,relatime $DATA_BLOCK "$DATA_MOUNTPOINT"


MODID="$(basename "${0%/*}")"
MODPATH="$DATA_MOUNTPOINT/adb/modules/$MODID"
ln -fs "$DATA_MOUNTPOINT/adb/modules/$MODID" "$OVERLAYFS_DIR"

MODDIR="$OVERLAYFS_DIR"
MODDIR2="$MAGISK_DATAMIRROR/adb/modules/$MODID"

mount | grep -q " /vendor " && vendor=/vendor
mount | grep -q " /system_ext " && system_ext=/system_ext
mount | grep -q " /product " && product=/product




get_modules(){ (
extra="$1"; data="$2"
test -z "$data" && data="$DATA_MOUNTPOINT"
IFS=$'\n'
modules="$(find $data/adb/modules/*/system -prune -type d)"
( for module in $modules; do
[ ! -e "${module%/*}/disable" ] && [ -f "${module%/*}/overlay" -o -f "$MODDIR/enable" ] && [ -d "${module}${extra}" ] && echo -ne "${module}/${extra}\n"
done ) | tr '\n' ':'
) }



overlay(){ (
fs="$1"
extra="$2"
mkdir -p "$MODDIR/overlay/$fs"
mkdir -p "$MODDIR/workdir/$fs"
magisk --clone-attr "$fs" "$MODDIR/overlay/$fs"
true
mount -t overlay -o "ro,lowerdir=$extra$fs,upperdir=$MODDIR/overlay/$fs,workdir=$MODDIR/workdir/$fs" overlay "$fs" 
mount -t overlay -o "ro,lowerdir=$extra$MAGISKTMP/.magisk/mirror/$fs,upperdir=$MODDIR2/overlay/$fs,workdir=$MODDIR2/workdir/$fs" overlay "$MAGISKTMP/.magisk/mirror/$fs" 
mount | grep " $fs " | grep -q "^overlay" && echo -n  "$fs " >>"$TMPDIR/overlay_mountpoint"
) &
}



ROPART="
$vendor
$system_ext
$product
"

for block in system system_root vendor system_ext product; do
if [ -b "$MAGISKTMP/.magisk/block/$block" ]; then
mkdir -p "$MAGISKTMP/.magisk/mirror/real_$block"
mount --bind "$MAGISKTMP/.magisk/mirror/$block" "$MAGISKTMP/.magisk/mirror/real_$block"
fi
done

overlay /system

mk_nullchar_dev(){
TARGET="$1"
rm -rf "$TARGET"
mkdir -p "${TARGET%/*}"
mknod "$TARGET" c 0 0
}

for delfile in /system/addon.d /system/etc/init.d /system/bin/su /system/xbin/su /vendor/bin/su; do
mk_nullchar_dev "$MODDIR/overlay/$delfile"
done

(cd /system; find * -prune -type d ) | while read dir; do
if [ ! -L "/system/$dir" ]; then
mountpoint "/system/$dir" -q || overlay "/system/$dir" "$(get_modules "/$dir")"
fi
done


for part in $ROPART; do
find $part/* -prune -type d | while read dir; do
if [ ! -L "$dir" ]; then
mountpoint $dir -q || overlay $dir "$(get_modules "$dir")"
fi
done
done

sleep 0.05


cp "$MODPATH/module.prop" "$TMPDIR/overlay_status"

MOUNTED=$(cat "$TMPDIR/overlay_mountpoint")

[ "${#MOUNTED}" -gt 50 ] && MOUNTED="${MOUNTED: 0: 50}..."

DESC="OverlayFS is working normally 😋. Loaded overlay on $MOUNTED"

[ -z "$MOUNTED" ] && MOUNTED="OverlayFS is not working!! ☹️"


sed -Ei "s|^description=(\[.*][[:space:]]*)?|description=[ $DESC ] |g" "$TMPDIR/overlay_status"

mount --bind "$TMPDIR/overlay_status" "$MAGISKTMP/.magisk/modules/$MODID/module.prop"