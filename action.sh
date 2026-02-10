#!/system/bin/sh
MODDIR=${0%/*}

WORKER="$MODDIR/common/auto_mv_worker.sh"

if [ ! -f "$WORKER" ]; then
  echo "Auto MV: worker script not found."
  exit 1
fi

chmod 0755 "$WORKER" 2>/dev/null

if "$WORKER" --once; then
  echo "Auto MV: scan completed."
  exit 0
fi

echo "Auto MV: scan failed."
exit 1
