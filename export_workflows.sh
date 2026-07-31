#!/usr/bin/env bash

# Local workflow export helper. Render Free has no shell access or persistent
# disk, so export from the n8n UI before a redeploy or sleep cycle instead.
# Usage: ./export_workflows.sh [export_directory]

set -euo pipefail

EXPORT_DIR="${1:-n8n-export-$(date +%Y%m%d-%H%M%S)}"
DATA_FOLDER="${DATA_FOLDER:-/home/node/.n8n}"
BACKUP_ROOT="${BACKUP_ROOT:-/backup}"
N8N_VERSION="${N8N_VERSION:-1.123.65}"

echo "Starting n8n workflow export..."
echo "Export directory: $EXPORT_DIR"
echo "Data folder: $DATA_FOLDER"
echo "n8n version: $N8N_VERSION"

mkdir -p "$BACKUP_ROOT"

docker run --rm \
    -v "$DATA_FOLDER:/home/node/.n8n:ro" \
    -v "$BACKUP_ROOT:/backup" \
    -e N8N_ENCRYPTION_KEY="${N8N_ENCRYPTION_KEY:-}" \
    -e GENERIC_TIMEZONE="${GENERIC_TIMEZONE:-UTC}" \
    -e TZ="${TZ:-UTC}" \
    -u node \
    "n8nio/n8n:${N8N_VERSION}" \
    n8n export:workflow --backup --output="/backup/$EXPORT_DIR/" --data="/home/node/.n8n"

echo "Workflows exported to: $BACKUP_ROOT/$EXPORT_DIR/"
ls -la "$BACKUP_ROOT/$EXPORT_DIR/" || echo "Could not list export contents"
