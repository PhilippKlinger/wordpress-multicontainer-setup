# WordPress Multi-Container Setup

This repository provides a WordPress installation with a MariaDB database. It
runs the applications as the `wordpress` and `db` Docker Compose services
using the official container images.

WordPress publishes port `8080` by default and stores its application and
database state in Docker named volumes. The same Compose workflow applies on a
local machine and on a VPS; each Docker host maintains its own volume data.

## Contents

- [Components](#components)
- [Quickstart](#quickstart)
- [Usage and persistence](#usage-and-persistence)
- [Configuration](#configuration)
- [WordPress setup](#wordpress-setup)
- [Security notes](#security-notes)
- [Validation](#validation)

## Components

- `docker-compose.yaml` defines the `wordpress` and `db` services, networking,
  port publishing, restart policies, and the two named volumes.
- `.env.example` documents the non-sensitive defaults and required credential
  variables without providing authentication values.
- `.gitignore` excludes the local `.env`, secrets, editor files, logs, database
  exports, and temporary files.
- `README.md` documents setup, operation, configuration, and validation.
- `LICENSE` contains the repository license.
- `Wordpress Checkliste.pdf` contains the academy checklist artifact; its
  markings must match the final verified project state.

The project uses the official WordPress and MariaDB images directly. No custom
`Dockerfile` or `entrypoint.sh` is required because both images already provide
the applications, runtime dependencies, and startup logic.

## Quickstart

Prerequisites:

- Docker Engine or Docker Desktop with Docker Compose
- Git

Clone the repository and create the local environment file:

```bash
git clone <repository-url>
cd wordpress-multicontainer-setup
cp .env.example .env
```

Open `.env`, set unique values for `WORDPRESS_DB_USER`,
`WORDPRESS_DB_PASSWORD`, and `MARIADB_ROOT_PASSWORD`, and review the values in
[Configuration](#configuration).

Start the services in the foreground and inspect their logs:

```bash
docker compose up
```

MariaDB is ready when its logs contain `ready for connections`. Open
`http://localhost:8080` for a local setup or
`http://<host-address>:<HOST_PORT>` on another Docker host. On the first start,
complete the WordPress installation and create the WordPress administrator.

## Usage and persistence

Use the same commands for routine operation on every Docker host:

```bash
docker compose up -d
docker compose restart
docker compose down
```

The `wordpress_data` named volume is mounted at `/var/www/html` and stores
WordPress files, plugins, themes, and uploaded media. The `db_data` named volume
is mounted at `/var/lib/mysql` and stores the database state, including users,
posts, and configuration. Docker creates both volumes on first use and retains
them after a normal `docker compose down` or container recreate.

> [!WARNING]
> Do not use `docker compose down -v` or remove `wordpress_data` or `db_data`
> unless the WordPress and MariaDB data has been intentionally backed up and
> may be discarded.

Named volumes are local to one Docker host. Moving the installation to a VPS or
another machine requires a separate backup and restore process or a controlled
WordPress export and import.

No host data directory or manual ownership change is required. MariaDB remains
available only through the internal Compose network; only WordPress publishes a
host port.

## Configuration

Copy `.env.example` to `.env`, set the required credentials, and adjust
non-sensitive values when needed. Do not commit `.env`.

| Variable | Purpose | Default value |
| --- | --- | --- |
| `WORDPRESS_VERSION` | Official WordPress image tag. | `7.0.2-php8.3-apache` |
| `MARIADB_VERSION` | Official MariaDB image tag. | `11.4.12` |
| `HOST_PORT` | Published WordPress host port. | `8080` |
| `WORDPRESS_DB_NAME` | MariaDB schema used by WordPress. | `wordpress` |
| `WORDPRESS_DB_USER` | MariaDB account used by WordPress. | Required; no default |
| `WORDPRESS_DB_PASSWORD` | Password for the WordPress database account. | Required; no default |
| `MARIADB_ROOT_PASSWORD` | MariaDB root password used during initialization. | Required; no default |

The variables above are the supported configuration contract. Compose provides
safe defaults for non-sensitive values and stops with a specific error when a
required credential is missing or empty. Changing credentials after MariaDB
has initialized its volume requires a deliberate credential migration; editing
`.env` alone does not update existing database accounts.

## WordPress setup

The database credentials in `.env` allow the WordPress service to connect to
MariaDB. They are not the WordPress administrator credentials.

The administrator is created through the WordPress installation page on the
first start. WordPress stores users, posts, and configuration in MariaDB, while
uploaded media and other application files remain in `wordpress_data`.

After the initial setup, the administrator account and WordPress content remain
available across a normal container restart, recreate, or `docker compose
down` followed by another start, as long as the named volumes are retained.

## Security notes

- Keep `.env`, SSH keys, credentials, tokens, host addresses, database exports,
  and logs with sensitive values out of commits, forks, screenshots, and shared
  archives.
- Use unique database credentials for each environment and review staged files
  before every push.
- Keep MariaDB on the internal Compose network; do not add a host port unless
  external database access is explicitly required and secured.
- Review pinned WordPress and MariaDB image versions regularly, test updates
  before deployment, and use only trusted official images.

## Validation

Start the stack and inspect its runtime state:

```bash
docker compose up -d
docker compose ps
docker compose logs --tail 100 db wordpress
curl --fail --head http://localhost:8080
```

Both containers must be `Up`, MariaDB must report `ready for connections`, and
the HTTP request must succeed. `curl` is optional; use a browser when it is not
available. If `HOST_PORT` was changed, use that port instead of `8080`.

Open WordPress in a browser, complete the initial setup when necessary, log in
as the WordPress administrator, and confirm that the dashboard is usable.
Create a uniquely named test post and upload a non-sensitive test image.

Verify persistence by recreating the containers without deleting the volumes:

```bash
docker compose down
docker compose up -d
```

Open the same post again, confirm that the image is still available, and verify
that the administrator can still log in.


For VPS validation, run the same Compose and persistence checks on the target
host. From a different machine, verify external reachability with:

```bash
curl --fail --head http://<host-address>:8080
```

Then repeat the browser login and content checks through the external address.
