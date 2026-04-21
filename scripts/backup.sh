#!/bin/bash
# GestiQ — Daily PostgreSQL backup
# Setup: chmod +x scripts/backup.sh
# Cron:  0 2 * * * /Users/said/new\ Gestion/scripts/backup.sh >> /var/log/gestiq-backup.log 2>&1

set -euo pipefail

BACKUP_DIR="${BACKUP_DIR:-$HOME/gestiq-backups}"
DB_HOST="${PG_HOST:-127.0.0.1}"
DB_PORT="${PG_PORT:-5433}"
DB_NAME="${PG_DATABASE:-gestiq}"
DB_USER="${PG_USER:-said}"
RETENTION_DAYS=30
DATE=$(date +%Y-%m-%d_%H-%M-%S)
FILE="$BACKUP_DIR/gestiq_$DATE.sql.gz"

mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting backup → $FILE"
pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" \
  --no-password \
  --format=plain \
  --no-owner \
  --no-acl \
  | gzip -9 > "$FILE"

SIZE=$(du -sh "$FILE" | cut -f1)
echo "[$(date)] Backup complete: $FILE ($SIZE)"

# Delete backups older than RETENTION_DAYS
find "$BACKUP_DIR" -name "gestiq_*.sql.gz" -mtime +$RETENTION_DAYS -delete
echo "[$(date)] Cleaned backups older than $RETENTION_DAYS days"

# Verify backup is readable
if gunzip -t "$FILE" 2>/dev/null; then
  echo "[$(date)] Backup integrity: OK"
else
  echo "[$(date)] ERROR: Backup integrity check FAILED"
  exit 1
fi
