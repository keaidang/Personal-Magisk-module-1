#!/system/bin/sh

SCRIPT_DIR=${0%/*}
MODDIR=${SCRIPT_DIR%/*}
SRC_DIR="/storage/emulated/0/DCIM/Camera"
DST_DIR="/storage/emulated/0/Music"
LOG_FILE="$MODDIR/auto_mv.log"
PID_FILE="$MODDIR/auto_mv.pid"
SCAN_INTERVAL=10
STABLE_WAIT=2

timestamp() {
  date "+%Y-%m-%d %H:%M:%S" 2>/dev/null || date
}

log_line() {
  echo "$(timestamp) $*" >> "$LOG_FILE"
}

is_number() {
  case "$1" in
    ""|*[!0-9]*)
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

file_size() {
  stat -c %s "$1" 2>/dev/null && return 0
  wc -c < "$1" 2>/dev/null
}

trim_mp4_suffix() {
  case "$1" in
    *.mp4)
      echo "${1%.mp4}"
      ;;
    *.MP4)
      echo "${1%.MP4}"
      ;;
    *)
      echo "$1"
      ;;
  esac
}

strip_vid_prefix() {
  case "$1" in
    VID_*)
      echo "${1#VID_}"
      ;;
    *)
      echo "$1"
      ;;
  esac
}

wait_storage_ready() {
  tries=0
  while [ "$tries" -lt 120 ]; do
    if [ -d "$SRC_DIR" ]; then
      mkdir -p "$DST_DIR" 2>/dev/null
      return 0
    fi
    tries=$((tries + 1))
    sleep 2
  done
  return 1
}

process_one_file() {
  src_path="$1"
  [ -f "$src_path" ] || return 0

  file_name="$(basename "$src_path")"
  case "$file_name" in
    VID*)
      ;;
    *)
      return 0
      ;;
  esac

  size_first="$(file_size "$src_path")"
  is_number "$size_first" || return 0
  [ "$size_first" -gt 0 ] || return 0

  sleep "$STABLE_WAIT"
  [ -f "$src_path" ] || return 0

  size_second="$(file_size "$src_path")"
  is_number "$size_second" || return 0
  [ "$size_first" = "$size_second" ] || return 0

  target_name="$(trim_mp4_suffix "$file_name")"
  target_name="$(strip_vid_prefix "$target_name")"
  [ -n "$target_name" ] || return 0

  mkdir -p "$DST_DIR" 2>/dev/null
  target_path="$DST_DIR/$target_name"
  if [ -e "$target_path" ]; then
    suffix=1
    while [ -e "${target_path}_$suffix" ]; do
      suffix=$((suffix + 1))
    done
    target_path="${target_path}_$suffix"
  fi

  if mv "$src_path" "$target_path" 2>/dev/null; then
    log_line "moved: $src_path -> $target_path"
  else
    log_line "move failed: $src_path"
  fi
}

scan_once() {
  [ -d "$SRC_DIR" ] || return 0
  find "$SRC_DIR" -maxdepth 1 -type f -name "VID*" 2>/dev/null | while IFS= read -r src_path; do
    process_one_file "$src_path"
  done
}

run_once() {
  if ! wait_storage_ready; then
    log_line "storage not ready for one-shot run"
    return 1
  fi
  scan_once
  return 0
}

run_daemon() {
  if [ -f "$PID_FILE" ]; then
    old_pid="$(cat "$PID_FILE" 2>/dev/null)"
    if is_number "$old_pid" && kill -0 "$old_pid" 2>/dev/null; then
      log_line "daemon already running: pid=$old_pid"
      return 0
    fi
  fi

  echo $$ > "$PID_FILE"
  trap 'rm -f "$PID_FILE"; exit 0' INT TERM EXIT

  if ! wait_storage_ready; then
    log_line "storage not ready, daemon exit"
    return 1
  fi

  log_line "daemon started"
  while true; do
    scan_once
    sleep "$SCAN_INTERVAL"
  done
}

case "$1" in
  --once)
    run_once
    ;;
  --daemon|"")
    run_daemon
    ;;
  *)
    echo "Usage: $0 [--daemon|--once]"
    exit 1
    ;;
esac
