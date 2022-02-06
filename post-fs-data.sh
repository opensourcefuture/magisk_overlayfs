unset vendor
unset product
unset system_ext


MAGISKTMP="$(magisk --path)"
[ -z "$MAGISKTMP" ] && MAGISKTMP=/sbin

mkdir -p "$MAGISKTMP/.magisk/tmp"

TMPDIR="$MAGISKTMP/.magisk/tmp"

# exec &>>"$MAGISKTMP/mount_error.txt

DATA_BLOCK="$(mount | grep " /data " | awk '{ print $1 }')"
test -z "$DATA_BLOCK" && exit
DATA_MOUNTPOINT="/dev/mnt_mirror/data"
OVERLAYFS_DIR="/dev/mnt_mirror/overlay"
mount -t tmpfs tmpfs $SKELETON

mkdir -p "$DATA_MOUNTPOINT"

mount -o rw,seclabel,relatime $DATA_BLOCK "$DATA_MOUNTPOINT"


MODID="$(basename "${0%/*}")"
MODPATH="$DATA_MOUNTPOINT/adb/modules/$MODID"
ln -fs "$DATA_MOUNTPOINT/adb/modules/$MODID" "$OVERLAYFS_DIR"

MODDIR="$OVERLAYFS_DIR"

mount | grep -q " /vendor " && vendor=/vendor
mount | grep -q " /system_ext " && system_ext=/system_ext
mount | grep -q " /product " && product=/product




get_modules(){ (
extra="$1"
IFS=$'\n'
modules="$(find $DATA_MOUNTPOINT/adb/modules/*/system -prune -type d)"
( for module in $modules; do
[ ! -e "${module%/*}/disable" ] && [ -f "${module%/*}/overlay" -o -f "$MODDIR/enable" ] && [ -d "${module}${extra}" ] && echo -ne "${module}/${extra}\n"
done ) | tr '\n' ':'
) }



overlay(){
fs="$1"
extra="$2"
mkdir -p "$MODDIR/overlay/$fs"
mkdir -p "$MODDIR/workdir/$fs"
magisk --clone-attr "$fs" "$MODDIR/overlay/$fs"
true
mount -t overlay -o "ro,lowerdir=$extra$fs,upperdir=$MODDIR/overlay/$fs,workdir=$MODDIR/workdir/$fs" overlay "$fs" 
mount | grep " $fs " | grep -q "^overlay" && echo -n  "$fs " >>"$TMPDIR/overlay_mountpoint"
}

ROPART="
$vendor
$system_ext
$product
"
overlay /system

(cd /system; find * -prune -type d ) | while read dir; do
if [ ! -L "/system/$dir" ]; then
mountpoint "/system/$dir" -q || overlay "/system/$dir" "$(get_modules "/$dir")"
fi
done

mk_nullchar_dev(){
TARGET="$1"
mkdir -p "${TARGET%/*}"
mknod "$TARGET" c 0 0
}


for part in $ROPART; do
find $part/* -prune -type d | while read dir; do
if [ ! -L "$dir" ]; then
mountpoint $dir -q || overlay $dir "$(get_modules "$dir")"
fi
done
done

for delfile in /system/addon.d /system/etc/init.d /system/bin/su /system/xbin/su /vendor/bin/su; do
mk_nullchar_dev "$MODDIR/overlay/$delfile"
done


cp "$MODPATH/module.prop" "$TMPDIR/overlay_status"

MOUNTED=$(cat "$TMPDIR/overlay_mountpoint")

[ "${#MOUNTED}" -gt 50 ] && MOUNTED="${MOUNTED: 0: 50}..."

DESC="OverlayFS is working normally 😋. Loaded overlay on $MOUNTED"

[ -z "$MOUNTED" ] && MOUNTED="OverlayFS is not working!! ☹️"


sed -Ei "s|^description=(\[.*][[:space:]]*)?|description=[ $DESC ] |g" "$TMPDIR/overlay_status"

mount --bind "$TMPDIR/overlay_status" "$MAGISKTMP/.magisk/modules/$MODID/module.prop"