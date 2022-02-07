SKIPUNZIP=1
echo "- Perserve all changes..."
MODID=$(basename "$MODPATH")
unzip -o "$ZIPFILE" 'post-fs-data.sh' 'module.prop' -d "/data/adb/modules/$MODID"
rm -rf "$MODPATH"
(sleep 1; rm -rf "/data/adb/modules/$MODID/update")&