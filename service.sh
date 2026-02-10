#!/system/bin/sh
MODDIR=${0%/*}

WORKER="$MODDIR/common/auto_mv_worker.sh"

[ -f "$WORKER" ] || exit 0
chmod 0755 "$WORKER" 2>/dev/null

"$WORKER" --daemon >/dev/null 2>&1 &

exit 0
