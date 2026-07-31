# n8n on Render

Deploy a persistent n8n instance on Render with Docker and Render Postgres.

## What this configuration fixes

- Pins n8n to `2.31.1` instead of tracking the moving `latest` tag.
- Includes the PostgreSQL connection-recovery fix that bounds pool teardown.
- Gives Node.js a 1 GB heap on the Render Standard service.
- Limits production concurrency and stores binary data on the persistent disk.
- Adds database startup retries and conservative pool settings.
- Derives the public editor and webhook URLs from `RENDER_EXTERNAL_HOSTNAME`.
- Uses `/healthz` for Render health checks.

## Deploy

1. Create or sync a Render Blueprint from this repository.
2. Keep the web service on the `standard` plan. A small/free instance does not provide enough memory for current n8n releases.
3. Enter `N8N_ENCRYPTION_KEY` when Render prompts for it. Generate a long random value and keep it unchanged for the lifetime of the instance.
4. Deploy the Blueprint.

The Blueprint creates:

- One Docker web service.
- One `basic-1gb` Render Postgres database.
- One 5 GB persistent disk mounted at `/home/node/.n8n`.

## Existing deployments

Do not replace an existing `N8N_ENCRYPTION_KEY`. Rotating it without following n8n's encryption-key migration process makes previously saved credentials unreadable.

After merging configuration changes, open the Render Blueprint page, run **Sync Blueprint**, confirm that the service plan remains **Standard**, and deploy the latest commit.

## Custom domains

For the default `onrender.com` hostname, no URL variables are required. `render-entrypoint.sh` derives `N8N_HOST`, `N8N_EDITOR_BASE_URL`, and `N8N_WEBHOOK_URL` automatically.

For a custom domain, set these variables in the Render dashboard:

```text
N8N_HOST=n8n.example.com
N8N_EDITOR_BASE_URL=https://n8n.example.com
N8N_WEBHOOK_URL=https://n8n.example.com/
```

## Troubleshooting

### JavaScript heap out of memory

Confirm that the web service uses the Standard plan and that `NODE_OPTIONS` is `--max-old-space-size=1024`. Do not raise the heap above the available instance memory.

### Database connection timed out

Confirm that the web service and database are healthy and in the same Render region. The Blueprint uses Render's private Postgres hostname and retries transient startup failures.

### Python task runner warning

The official n8n image can report that Python 3 is unavailable for the internal Python runner. This warning is separate from the JavaScript heap crash and does not prevent normal JavaScript workflows from starting.

## Updating n8n

Do not change the Docker image back to `n8nio/n8n:latest`. Upgrade the pinned version intentionally, review the n8n release notes, back up PostgreSQL, and deploy the new version through a pull request.
