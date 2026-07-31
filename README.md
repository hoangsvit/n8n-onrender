# n8n on Render Free

Run a lightweight n8n instance on a Render Free web service without a separate PostgreSQL service.

n8n still requires an internal state store, so this profile uses the built-in SQLite database at `/home/node/.n8n/database.sqlite`. It does not create or connect to an external database.

## Free profile

- Uses the Render `free` web-service plan.
- Pins n8n to `1.123.65`, the maintained v1 release used by this low-memory profile.
- Limits the Node.js heap to 320 MB.
- Runs only one production execution at a time.
- Disables task runners, diagnostics, templates, personalization, and version notifications.
- Keeps at most 100 executions for 24 hours and does not save execution payloads.
- Stores binary data on the local filesystem instead of the JavaScript heap.
- Uses SQLite automatically; no `databases:` or persistent `disk:` resource is defined.

## Important: data is temporary

Render Free web services have an ephemeral filesystem and cannot attach a persistent disk. Render also spins a Free service down after it has been idle. When the service spins down, restarts, or redeploys, the local SQLite database is deleted.

This means all of the following can disappear:

- Owner account and settings.
- Workflows and activation state.
- Credentials.
- Execution history.
- Community packages and other local files.

There is no code-only fix for this limitation. Use this profile only for temporary testing or demos. To preserve SQLite without an external database, move the web service to a paid Render instance and attach a persistent disk at `/home/node/.n8n`.

## Deploy

1. Merge the free-profile pull request.
2. Open the Render Blueprint and run **Sync Blueprint**.
3. Confirm that the web service instance type is **Free**.
4. Set `N8N_ENCRYPTION_KEY` to a long random value in the Render environment.
5. Deploy the latest commit.
6. Verify that `/healthz` returns a successful response.

## Existing service previously using PostgreSQL

Before redeploying, remove these variables from the Render service's manually configured environment variables:

```text
DB_TYPE
DB_POSTGRESDB_HOST
DB_POSTGRESDB_DATABASE
DB_POSTGRESDB_PORT
DB_POSTGRESDB_USER
DB_POSTGRESDB_PASSWORD
DB_POSTGRESDB_SCHEMA
DB_POSTGRESDB_POOL_SIZE
DB_POSTGRESDB_CONNECTION_TIMEOUT
DB_POSTGRESDB_DESTROY_TIMEOUT_MS
DB_STARTUP_CONNECT_MAX_RETRIES
DB_PING_INTERVAL_SECONDS
DB_PING_MAX_FAILURES_BEFORE_RECOVERY
```

Also remove any old manual `NODE_OPTIONS=--max-old-space-size=1024` value. The Free profile uses `--max-old-space-size=320` and bakes that limit into the Docker image so it still applies if Blueprint variables have not synced yet.

The old Render Postgres resource is no longer referenced by `render.yaml`. Delete that database separately from the Render Dashboard only after confirming that you no longer need its data.

## Custom domains

For the default `onrender.com` hostname, no URL variables are required. `render-entrypoint.sh` derives the public URLs automatically.

For a custom domain, configure:

```text
N8N_PROTOCOL=https
N8N_HOST=n8n.example.com
N8N_EDITOR_BASE_URL=https://n8n.example.com
N8N_WEBHOOK_URL=https://n8n.example.com/
```

## Memory limits

The Free profile is intended for small webhook, HTTP, scheduling, and data-transformation tests. AI Agent, LLM, large file, large JSON, and high-concurrency workflows can still exceed 512 MB total memory.

If the process still runs out of memory:

1. Confirm the deployed image is `n8nio/n8n:1.123.65`.
2. Confirm the log or environment shows `NODE_OPTIONS=--max-old-space-size=320`.
3. Confirm `N8N_RUNNERS_ENABLED=false` and concurrency is `1`.
4. Remove heavy AI/file-processing nodes or use a service with at least 1 GB RAM.

## Python runner warning

Task runners are disabled in this low-memory profile. Python Code nodes are therefore not supported. Use JavaScript Code nodes for lightweight tests.

## Backups

Render Free does not provide shell access or persistent storage. Export important workflows from the n8n UI before a restart, redeploy, or idle spin-down. `export_workflows.sh` is intended only for local Docker installations where `/home/node/.n8n` is available.

## Updating n8n

Do not switch back to `latest`. Upgrade the pinned image deliberately and confirm that the selected release can start within the Free instance memory limit before deploying it.
