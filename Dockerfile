# n8n v2 needs more memory than Render Free's 512 MB instance can reliably
# provide. Keep the latest maintained v1 release for this low-memory profile.
FROM n8nio/n8n:1.123.65

# Bake critical limits into the image so they apply even when an existing Render
# service has not yet synced the Blueprint environment variables.
ENV NODE_OPTIONS="--max-old-space-size=320" \
    N8N_PUSH_BACKEND="sse" \
    N8N_RUNNERS_ENABLED="false" \
    N8N_DIAGNOSTICS_ENABLED="false" \
    N8N_VERSION_NOTIFICATIONS_ENABLED="false" \
    N8N_TEMPLATES_ENABLED="false" \
    N8N_PERSONALIZATION_ENABLED="false" \
    N8N_CONCURRENCY_PRODUCTION_LIMIT="1" \
    N8N_DEFAULT_BINARY_DATA_MODE="filesystem" \
    EXECUTIONS_DATA_PRUNE="true" \
    EXECUTIONS_DATA_MAX_AGE="24" \
    EXECUTIONS_DATA_PRUNE_MAX_COUNT="100" \
    EXECUTIONS_DATA_SAVE_ON_ERROR="none" \
    EXECUTIONS_DATA_SAVE_ON_SUCCESS="none" \
    EXECUTIONS_DATA_SAVE_ON_PROGRESS="false" \
    EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS="false" \
    N8N_UNVERIFIED_PACKAGES_ENABLED="false"

USER root
COPY render-entrypoint.sh /render-entrypoint.sh
RUN chmod 0755 /render-entrypoint.sh
USER node

ENTRYPOINT ["tini", "--", "/render-entrypoint.sh"]
