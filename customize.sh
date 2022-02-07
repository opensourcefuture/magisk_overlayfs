MODID=$(basename "$MODPATH")
echo "- Perserve all changes..."
SKIPUNZIP=1
mkdir -p "/data/adb/modules/$MODID"
unzip -o "$ZIPFILE" 'post-fs-data.sh' 'module.prop' -d "/data/adb/modules/$MODID"
rm -rf "$MODPATH"
(sleep 1; rm -rf "/data/adb/modules/$MODID/update")&