## Trip System – Database Migrations (Flyway)

Flyway runs your SQL migration scripts in a deterministic order and records what has been applied in a schema history table. In this setup, Flyway is executed as a **one-shot container job**: run migrations and exit.

### What’s in this folder

- `docker-compose.yml`
  - Starts a `flyway` service that runs `flyway migrate`.
  - Mounts local config into the container.
- `config_local/flyway.conf`
  - Local Flyway configuration (DB connection, credentials, etc.).
  - **Update this for the target system** (trip-system DB name/host/credentials).
- `trip-system-db-migration/`
  - `Dockerfile` builds a Flyway image and copies SQL scripts into `/flyway/sql/`.
  - `sql/` contains the versioned migration scripts.
  - `helm/` contains a Kubernetes Helm chart for running Flyway in-cluster (optional).

### How it’s wired

#### 1) `docker-compose.yml`

The `flyway` service:

- **Builds** a Docker image from the `trip-system-db-migration` folder.
- Overrides the container command using:
  - `entrypoint: ["flyway", "migrate"]`
- Mounts the config file:
  - `./config_local/flyway.conf:/flyway/conf/flyway.conf`

This makes the container’s only responsibility: **connect to the DB, apply pending migrations, exit**.

#### 2) `trip-system-db-migration/Dockerfile`

- Uses `flyway/flyway:7.15.0` so the Flyway CLI is available.
- Copies SQL scripts from `sql/*` into the container at `/flyway/sql/`.

Flyway’s default behavior is to scan `/flyway/sql` for versioned scripts (for example `V1_0_1__init_schema.sql`) and apply anything not yet recorded in the schema history table.

### What happens at runtime (high level)

1. Docker builds the migration image (with your SQL files baked in).
2. Docker starts the `flyway` container.
3. Flyway reads configuration from `/flyway/conf/flyway.conf` (mounted from `config_local`).
4. Flyway connects to the target DB using `flyway.url`, `flyway.user`, `flyway.password`.
5. Flyway checks (or creates) the schema history table (usually `flyway_schema_history`).
6. Flyway executes pending migrations from `/flyway/sql/` in version order.
7. The container exits (success or failure).

Result: this behaves like a **migration job**, not a long-running service.

---

## Configuration: `config_local/flyway.conf`

For trip-system usage you typically need to change at least:

- `flyway.url` (database name and possibly host/port)
- `flyway.user`
- `flyway.password`

Security note:
- Don’t commit real production passwords into git.
- For shared environments, prefer injecting secrets via your CI/CD or orchestrator (Kubernetes secrets, environment variables, etc.).

---

## Running migrations locally

From inside the `trip-system/` folder:

```powershell
cd E:\trip-system-analysis\trip-system

docker compose up --build flyway
docker-compose up -d --build
```

Useful variations:

```powershell
# Re-run after changing SQL/config
docker compose up --build flyway

# Clean up containers after a run
docker compose down
```

---

## Troubleshooting

- **Can’t connect to DB**
  - Verify `flyway.url` host/port is reachable from Docker.
  - On Windows/macOS, `host.docker.internal` typically resolves to the host machine.
- **Migrations already applied**
  - Flyway will exit successfully with no pending work.
- **Migration failed mid-run**
  - Check the container logs and the `flyway_schema_history` table.
  - Fix the SQL and re-run; if a migration partially applied, handle it carefully (Flyway may require repair depending on failure mode).

---
