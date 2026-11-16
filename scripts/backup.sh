#!/usr/bin/env bash
# Hourly MySQL backup: dump the guestbook DB from db-vm, keep a gzip file on app-vm.
set -uo pipefail
umask 077

BACKUP_DIR="${BACKUP_DIR:-/var/backups/guestbook}"
CNF="${CNF:-/home/dbbackup/.backup.cnf}"   # user, password and host live here (mode 600)
DB_NAME="guestbook"
KEEP_DAYS=7
LOG="$BACKUP_DIR/backup.log"

STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
OUT="$BACKUP_DIR/${DB_NAME}_${STAMP}.sql.gz"
TMP="$OUT.part"

log() { echo "$(date '+%F %T') $*" >> "$LOG"; }

if mysqldump --defaults-extra-file="$CNF" --single-transaction --no-tablespaces "$DB_NAME" 2>>"$LOG" | gzip > "$TMP" \
   && gzip -t "$TMP" \
   && zcat "$TMP" | tail -n 1 | grep -q "Dump completed"; then
  mv "$TMP" "$OUT"
  log "OK     $(basename "$OUT") $(du -h "$OUT" | cut -f1)"
else
  rm -f "$TMP"
  log "FAILED backup of $DB_NAME - partial file removed"
  exit 1
fi

DELETED=$(find "$BACKUP_DIR" -maxdepth 1 -name "${DB_NAME}_*.sql.gz" -mtime +"$KEEP_DAYS" -print -delete | wc -l)
log "CLEAN  removed $DELETED backup(s) older than $KEEP_DAYS days"
