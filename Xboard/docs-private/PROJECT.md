# Xboard Project Record

Status: VERIFIED

## Project Identity

- Upstream official repo: https://github.com/cedar2025/Xboard
- Local baseline mirror: D:\Xboard-Independent\private-repos\Xboard.git
- Verified baseline tag: baseline-2026-09-09
- Verified commit: 4f48e61a2cbc6db5338872b6bdb45ef954ec1256

## Private Recovery Objective

This repository must remain recoverable even when the upstream GitHub project, release assets, GHCR images, or admin asset repo are unavailable.

## Critical Upstream Dependencies

### UPSTREAM_CRITICAL

- GitHub source repo for Xboard
- Git submodule at public/assets/admin
- xboard-admin-dist GitHub repo
- GHCR image refs in Docker Compose samples
- Raw installer and admin-side automation references to Xboard-Node

### PUBLIC_INFRASTRUCTURE

- Composer ecosystem and lockfile
- PHP runtime and deployment tools
- Docker/Compose ecosystem requirements

### OPTIONAL_EXTERNAL

- Gravatar CDN usage
- Third-party CDN resources in generated rule content
- Public frontend assets not essential for service start-up

## Private Recovery Plan

1. Preserve the exact upstream source and baseline tag in the private mirror.
2. Create a local archive for the admin submodule content or a replacement admin dist artifact.
3. Replace GitHub-hosted download URLs with locally controlled mirror paths before any production use.
4. Keep a version-pinned local copy of Composer PHAR and any necessary Composer dependency cache.
5. Keep a local Docker image export and Compose override templates for recovery.
6. Store deployment and rollback scripts in the private repository, not in the upstream project.

## Verification Labels

- VERIFIED: baseline repo and private mirror established
- DISCOVERED: submodule and release/install risks confirmed
- PLANNED: local replacement and recovery packaging
- UNKNOWN: exact runtime replacement for admin theme asset repo until validation occurs

## Current Phase

Native IP-based deployment, core functional verification, and local recovery export are complete on the clean validation VM. The project is handoff-ready for validation/light testing. Domain, HTTPS, and public production rollout are intentionally out of scope. The separate clean-room restore rehearsal is deferred by user request and must be raised as a pending item before the overall project is declared fully complete.
