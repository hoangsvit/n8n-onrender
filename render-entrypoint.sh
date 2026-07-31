#!/bin/sh
set -eu

# Render exposes the public hostname at runtime. Derive n8n's public URLs unless
# custom-domain values were explicitly configured in the Render dashboard.
if [ -n "${RENDER_EXTERNAL_HOSTNAME:-}" ]; then
  N8N_PROTOCOL="${N8N_PROTOCOL:-https}"
  N8N_HOST="${N8N_HOST:-${RENDER_EXTERNAL_HOSTNAME}}"
  N8N_EDITOR_BASE_URL="${N8N_EDITOR_BASE_URL:-${N8N_PROTOCOL}://${N8N_HOST}}"
  N8N_WEBHOOK_URL="${N8N_WEBHOOK_URL:-${N8N_PROTOCOL}://${N8N_HOST}/}"

  export N8N_PROTOCOL N8N_HOST N8N_EDITOR_BASE_URL N8N_WEBHOOK_URL
fi

exec /docker-entrypoint.sh "$@"
