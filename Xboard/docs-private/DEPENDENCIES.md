# Xboard Dependency Audit

Status: ORPHANING IN PROGRESS

## Scope

This file documents verified external dependencies for the `Xboard` repository only. Cross-repository coordination remains in `../Project-Docs/MASTER-STATUS.md`.

## UPSTREAM_CRITICAL

- Historical source repository `cedar2025/Xboard`.
  - Retained in Git history only. Its remote was removed from the active checkout.
- Historical admin-dist submodule `cedar2025/xboard-admin-dist`.
  - The submodule gitlink and `.gitmodules` were removed; the verified 12-file asset tree is now vendored under `public/assets/admin`.

## PUBLIC_INFRASTRUCTURE

- `composer.json` and `composer.lock`
  - Composer ecosystem dependencies are used by the application runtime and are not in scope for direct fork replacement. The lockfile exists, but a prior `composer validate` reported it is not synchronized with `composer.json`.
- `package.json`
  - The manifest currently lists `chokidar` only. No npm, pnpm, or Yarn lockfile is present; preserve a lockfile if this dependency is used in the supported build/development workflow.

## OPTIONAL_EXTERNAL

- Historical GHCR images
  - Removed from Compose samples; Docker now builds from the local Xboard Dockerfile and remains outside the required recovery target.
- `https://cdn.v2ex.com/gravatar/`
  - Used for avatar image delivery; not core to service operation.
- Third-party CDN and public image resources referenced by frontend or rule files
  - Not required for the core service, but should be reviewed when deployment connectivity is limited.

## UNKNOWN

- Whether any upstream release assets are required beyond the Git checkout and local build path.
- Whether a clean-source Composer install is recoverable offline: `init.sh` runs `composer self-update --stable` even when a local Composer PHAR exists, then resolves packages through Composer repositories. The existing deployed-app archive does include a complete `vendor` tree, so restoring that archive is a separate path; an offline clean-source install has not been demonstrated.

## Verified Notes

- The historical baseline included a Git submodule at `public/assets/admin`; the active source now vendors that asset tree and has no `.gitmodules` file or admin gitlink.
- `init.sh` retains a conditional submodule command for legacy checkouts, but the normal vendored admin path does not need it.
- `composer validate` reports that `composer.lock` is not synchronized with `composer.json`.
- `symfony/yaml` and `webmozart/assert` currently use unbounded `*` constraints in `composer.json`.
- The upstream project expects local restoration of the admin frontend theme when the submodule is missing.
- Both local bare Git mirrors contain the expected baseline tags. The admin submodule worktree commit matches the commit recorded by the Xboard source tree.
- The recovery checksum manifest currently records 30 assets; all entries were verified after publishing the Xboard archive releases.
- A Composer PHAR and admin dist file copy are present in private assets; asset preservation is verified, but offline installation/build is not.
- The Xboard application backup archive includes `vendor/autoload.php`, `vendor/composer/installed.json`, and the full vendor tree; this supports restoration of that deployed application snapshot, but does not make `init.sh` or a clean-source build offline-capable.
- `update.sh` now fetches only the `private` remote and applies a fast-forward-only merge, preserving `composer.lock`; Composer uses `install` rather than deleting the lock and resolving a new dependency graph.
- The built-in update checker now targets `XBOARD_UPDATE_REPOSITORY`/`XBOARD_UPDATE_REF` (defaulting to the user's configured private repository) and can use `XBOARD_UPDATE_TOKEN` from the server environment for a private GitHub API. The updater fetches remote `private` and permits fast-forward merges only; it does not hard-reset.
- A separate source-archive update mode is implemented for `.git`-excluded deployments. It uses a loopback-only `latest.json` endpoint and a version-derived tar.gz path, validates SHA-256 and safe archive paths, preserves `.env`/`storage`/`vendor`, and rejects Composer manifest changes. The endpoint and updater are deployed on machine1, and release `20261005-403604e` is applied. A rollback rehearsal remains deferred until post-launch.
- One-click Node installation uses short-lived signed links and a fixed v1.13-orphan.1 asset allowlist. The installer, preserved node binaries, and rebuilt orphan xbctl binaries are staged under machine1's `storage/app/private/node-installer`; all hashes match and a signed installer download was verified. The installer was not executed.

## Recovery Action Plan

- Preserve the exact upstream Git baseline and private mirror.
- Store the submodule content or replacement admin dist artifact locally.
- Resolve the Composer lock mismatch and remove or locally satisfy the install-time `self-update` network dependency before claiming offline installation. Do not regenerate the lockfile without a compatibility review.
- For Git deployments, configure the checkout with the private `private` remote, approved ref, build commit, and protected API token if required. Machine1 uses archive mode; preserve its private endpoint, versioned release artifacts, protected token, and pre-update source backup. Rehearse rollback on staging after launch.
- Keep the verified Node installer, v1.13 node binaries, and v1.13-orphan.1 xbctl binaries in machine1's private storage directory; deployment and signed download are verified, but installation remains untested.
