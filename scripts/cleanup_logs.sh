#!/usr/bin/env bash
# Nightly Laravel log cleanup: compress old daily logs, delete old archives, warn on size.
set -u
LOG_DIR="${LOG_DIR:-/var/www/guestbook/storage/logs}"
KEEP_DAYS="${KEEP_DAYS:-14}"
MAX_MB="${MAX_MB:-500}"
CLEANUP_LOG="${CLEANUP_LOG:-$HOME/log-cleanup.log}"

log() { echo "$(date '+%F %T') $*" >> "$CLEANUP_LOG"; }

COMPRESSED=0
while IFS= read -r -d '' f; do
  gzip -f "$f" && COMPRESSED=$((COMPRESSED + 1))
done < <(find "$LOG_DIR" -maxdepth 1 -type f -name 'laravel-*.log' -mtime +0 -print0)

DELETED=0
while IFS= read -r -d '' f; do
  rm -f -- "$f" && DELETED=$((DELETED + 1))
done < <(find "$LOG_DIR" -maxdepth 1 -type f -name 'laravel-*.log.gz' -mtime +"$KEEP_DAYS" -print0)

SIZE_MB=$(du -sm "$LOG_DIR" | cut -f1)
log "compressed=$COMPRESSED deleted=$DELETED size=${SIZE_MB}MB"
if [ "$SIZE_MB" -gt "$MAX_MB" ]; then
  log "WARNING logs folder is ${SIZE_MB}MB, limit is ${MAX_MB}MB"
fi
