unset vendor
unset product
unset system_ext
MODDIR=${0%/*}
mount | grep -q " /vendor " && vendor=/vendor
mount | grep -q " /system_ext " && system_ext=/system_ext
mount | grep -q " /product " && product=/product

ROPART="
/system
$vendor
$system_ext
$product
"
for fs in $ROPART; do
mkdir -p $MODDIR/overlay/$fs
mkdir -p $MODDIR/workdir/$fs
mount -t overlay -o lowerdir=$fs,upperdir=$MODDIR/overlay/$fs,workdir=$MODDIR/workdir/$fs overlay $fs
done
