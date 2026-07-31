# Pin n8n so an upstream `latest` release cannot unexpectedly break Render.
# n8n 2.31.1 includes the bounded PostgreSQL pool teardown fix used during
# database connection recovery.
FROM n8nio/n8n:2.31.1

USER root
COPY render-entrypoint.sh /render-entrypoint.sh
RUN chmod 0755 /render-entrypoint.sh
USER node

ENTRYPOINT ["tini", "--", "/render-entrypoint.sh"]
