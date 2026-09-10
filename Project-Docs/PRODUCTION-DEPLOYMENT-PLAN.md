# Production Deployment Plan

Status: PLANNED

## Objective

This document defines the production deployment and version pinning strategy for Xboard and Xboard-Node in a way that supports independent recovery when upstream GitHub, release assets, and GHCR resources are unavailable.

## Core Rules

- Never use floating tags like `latest` as the only source of truth.
- Keep a stable version record for repo baseline, image tag, deployment config, and migration state.
- Keep private config and database backup copies outside the upstream repo.
- Keep local artifacts for recovery before making any production change.

## Version Record Format

For each stable deployment, record:

- Repo Git commit SHA
- Repo tag or release version
- Image tag used in deployment
- Image digest if available
- DB migration version or schema version
- Node registration metadata for Xboard-Node
- Deployment config hash

## Xboard Production Plan

1. Restore the private repo baseline.
2. Restore the local admin submodule content.
3. Restore the stable `.env` file from private config storage.
4. Restore or rebuild the matching private Docker image.
5. Start MySQL and Redis from the approved service image or host package.
6. Run the private migration/update path from the verified repo.
7. Validate the admin portal and core features before enabling traffic.

## Xboard-Node Production Plan

1. Restore the private repo baseline.
2. Restore the local installer and geo-data assets.
3. Restore the stable `config.yml` and credentials from private config storage.
4. Restore or rebuild the matching private Docker image.
5. Register the node with the Xboard panel using the private config.
6. Validate service health and runtime connectivity.

## Recovery Safety Gate

Production deployment is not considered safe unless all of the following are true:

- The source repo baseline is from the private mirror and tagged.
- The image and install assets are locally verified.
- The config and credentials are backed up privately.
- The database is backed up and has a matching migration state.
- The service connectivity between Xboard and Xboard-Node is tested.

## Final Recovery Target

The project should be able to recover from a clean server using only:

- private repo mirror
- private offline assets
- private config backups
- public infrastructure such as OS packages, Docker runtime, MySQL/Redis packages, and standard system dependencies
