# Xboard Dependency Audit

Status: VERIFIED

## Scope

This file documents verified external dependencies for the `Xboard` repository only. Cross-repository coordination remains in `../Project-Docs/MASTER-STATUS.md`.

## UPSTREAM_CRITICAL

- `https://github.com/cedar2025/Xboard.git`
  - Source baseline repository used as the upstream origin.
- `https://github.com/cedar2025/xboard-admin-dist.git`
  - Git submodule configured at `public/assets/admin`.
- `ghcr.io/cedar2025/xboard:latest`
  - Referenced in compose samples and container deployment paths.
- `https://raw.githubusercontent.com/cedar2025/xboard-node/dev/install.sh`
  - Referenced by admin-side server machine controller logic.

## PUBLIC_INFRASTRUCTURE

- `composer.json` and `composer.lock`
  - Composer ecosystem dependencies are used by the application runtime and are not in scope for direct fork replacement.
- `package.json` and generated frontend assets
  - Frontend build dependencies are not yet classified as private-critical, but they should be frozen by lockfile and local artifact preservation.

## OPTIONAL_EXTERNAL

- `https://cdn.v2ex.com/gravatar/`
  - Used for avatar image delivery; not core to service operation.
- Third-party CDN and public image resources referenced by frontend or rule files
  - Not required for the core service, but should be reviewed when deployment connectivity is limited.

## UNKNOWN

- Exact runtime policy for admin theme restoration and front-end asset replacement when the upstream admin dist repo becomes unavailable.
- Whether any upstream release assets are required beyond the Git checkout and local build path.

## Verified Notes

- The repository includes a Git submodule declaration in `.gitmodules`.
- The repo includes `init.sh` that calls `git submodule update --init --recursive --force`.
- `composer validate` reports that `composer.lock` is not synchronized with `composer.json`.
- `symfony/yaml` and `webmozart/assert` currently use unbounded `*` constraints in `composer.json`.
- The upstream project expects local restoration of the admin frontend theme when the submodule is missing.

## Recovery Action Plan

- Preserve the exact upstream Git baseline and private mirror.
- Store the submodule content or replacement admin dist artifact locally.
- Replace any required upstream-hosted install URL with a locally controlled alternative before production changes.
