# Master Status

This file is the shared status view for the `Xboard` and `Xboard-Node` repositories.

Project-wide operating rules are maintained in `PROJECT-INSTRUCTIONS.md`.

## Ownership Rules

- Keep repository-specific facts in the matching repository's `docs-private/` directory.
- Keep only cross-repository status, integration dependencies, milestones, blockers, and coordination decisions here.
- Do not duplicate implementation details, complete dependency inventories, deployment runbooks, or private changelogs from either repository.

## Overall Status

- Last updated: 2026-09-11
- Overall state: VERIFIED (native and aaPanel IP validation)
- Current milestone: Handoff and migration packaging

## Verified Baseline

- Official upstream repositories were verified reachable and cloned successfully.
- Private local mirrors were created under `D:\Xboard-Independent\private-repos`.
- Baseline tags were created for both repositories:
  - `Xboard`: `baseline-2026-09-09`
  - `Xboard-Node`: `baseline-2026-09-09`
- Upstream commit SHAs recorded:
  - `Xboard`: `4f48e61a2cbc6db5338872b6bdb45ef954ec1256`
  - `Xboard-Node`: `0a29338e1f102a462363ce3527417029f89bab28`

## Repository Status

### Xboard

- State: VERIFIED (native and aaPanel IP validation)
- Current focus: Handoff and migration packaging
- Blockers: Clean-room recovery rehearsal is deferred; Xboard-Node live node integration is not complete; ordinary-user and some aaPanel backend page checks were intentionally skipped.
- Repository details: `../Xboard/docs-private/`

### Xboard-Node

- State: VERIFIED
- Current focus: Dependency and install-script audit
- Blockers: GitHub release and raw installer URLs, GHCR image, and geo-data download URLs require ownership classification.
- Repository details: `../Xboard-Node/docs-private/`

## Cross-Repository Coordination

- Integration contract: DISCOVERED; both projects are linked through the Xboard panel and Xboard-Node installer flow.
- Shared blockers: GitHub-hosted installer URLs, GHCR images, and upstream release assets remain single points of failure.
- Decisions affecting both repositories: Both repositories require private mirrors, local backups, and replacement recovery paths for critical upstream URLs.
- Next coordination checkpoint: Private recovery plan and artifact mirroring design.

## Deployment Investigation

- Docker Compose and native Ubuntu deployment approaches were exercised on a second dedicated VM.
- Docker was subsequently cleaned from that VM.
- aaPanel was installed on a dedicated private-IP VM; the host browser login succeeded, the aaPanel software stack was installed, and Xboard home/admin paths returned HTTP 200 through the aaPanel-managed web server.
- The aaPanel validation used PHP 8.3, MariaDB, Redis, phpredis, a systemd queue worker and cron scheduler. Public certificates were intentionally not tested.

## Verified Critical Findings

- `Xboard` contains a Git submodule at `public/assets/admin` pointing to `https://github.com/cedar2025/xboard-admin-dist.git`.
- `Xboard` Docker files and sample compose files reference `ghcr.io/cedar2025/xboard:latest`.
- `Xboard` installer scripts and admin dashboard code reference the `xboard-node` raw install URL.
- `Xboard-Node` install scripts and README reference GitHub release assets and raw install scripts.
- `Xboard-Node` contains geo-data download URLs from third-party projects (SagerNet and Loyalsoldier) that are not upstream-owned but still critical for runtime behavior.

Update this file only when the shared status or the relationship between the two repositories changes.
