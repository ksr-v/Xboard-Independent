# Database Recovery Plan

Status: PLANNED

## Objective

This document defines the database and service recovery path for both Xboard and Xboard-Node when the upstream project resources and deployment scripts are unavailable.

## Required Services

- MySQL
- Redis
- Docker runtime (if using container deployment)
- Optional: reverse proxy or host service manager

## Recovery Principles

- Never rely on the upstream project web UI or install script as the only source of truth.
- Keep local database backups and migration state as private assets.
- Maintain versioned DB dumps and migration metadata.
- Record the exact DB schema version and the matching repo baseline tag.

## Recovery Sequence

1. Restore the verified repo baseline from the private mirror.
2. Restore MySQL and Redis service from the local host or private runtime image.
3. Restore the verified database dump from local backup storage.
4. Confirm the database name, user, and schema version match the active deployment config.
5. Run the application-specific migration/update commands from the private repo, not from upstream raw install scripts.
6. Validate the app can start and queries succeed before enabling routes or external traffic.

## Xboard Database Notes

- The repo includes `.env.example` with MySQL configuration variables.
- The application assumes a MySQL database and Redis cache.
- The database should be backed up as a private, versioned dump and restored using a local toolchain.

## Xboard-Node Database/Config Notes

- `config.yml.example` shows the required panel URL, token, node ID, and machine configuration.
- Recovery must preserve the exact node registration metadata and panel credentials in a private configuration store.
- The node registration must be restored before enabling service startup.

## Recovery Verification

- Confirm the database schema matches the baseline repo and migration state.
- Confirm Redis is reachable and writable.
- Confirm Xboard starts successfully with the restored config.
- Confirm Xboard-Node registers successfully with the restored panel configuration.
- Confirm service connectivity is restored between Xboard and Xboard-Node.
