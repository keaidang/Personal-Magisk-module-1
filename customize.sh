#!/system/bin/sh

SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=true
LATESTARTSERVICE=true

REPLACE=""

print_modname() {
  ui_print "*******************************"
  ui_print "          Auto MV"
  ui_print "*******************************"
}

on_install() {
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" "common/*" -d "$MODPATH" >&2
  unzip -o "$ZIPFILE" "system/*" -d "$MODPATH" >&2
  unzip -o "$ZIPFILE" "system.prop" -d "$MODPATH" >&2
  unzip -o "$ZIPFILE" "post-fs-data.sh" -d "$MODPATH" >&2
  unzip -o "$ZIPFILE" "service.sh" -d "$MODPATH" >&2
  unzip -o "$ZIPFILE" "uninstall.sh" -d "$MODPATH" >&2
  unzip -o "$ZIPFILE" "action.sh" -d "$MODPATH" >&2
  unzip -o "$ZIPFILE" "sepolicy.rule" -d "$MODPATH" >&2
}

set_permissions() {
  set_perm_recursive "$MODPATH" 0 0 0755 0644
  [ -f "$MODPATH/common/auto_mv_worker.sh" ] && set_perm "$MODPATH/common/auto_mv_worker.sh" 0 0 0755
  [ -f "$MODPATH/post-fs-data.sh" ] && set_perm "$MODPATH/post-fs-data.sh" 0 0 0755
  [ -f "$MODPATH/service.sh" ] && set_perm "$MODPATH/service.sh" 0 0 0755
  [ -f "$MODPATH/uninstall.sh" ] && set_perm "$MODPATH/uninstall.sh" 0 0 0755
  [ -f "$MODPATH/action.sh" ] && set_perm "$MODPATH/action.sh" 0 0 0755
}
