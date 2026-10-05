# Master Status

This file is the shared status view for the `Xboard` and `Xboard-Node` repositories.

Project-wide operating rules are maintained in `PROJECT-INSTRUCTIONS.md`.

## Ownership Rules

- Keep repository-specific facts in the matching repository's `docs-private/` directory.
- Keep only cross-repository status, integration dependencies, milestones, blockers, and coordination decisions here.
- Do not duplicate implementation details, complete dependency inventories, deployment runbooks, or private changelogs from either repository.

## Overall Status

- Last updated: 2026-10-05
- Overall state: VERIFIED (native and aaPanel IP validation)
- Current milestone: Orphaning upstream integration paths

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
- Current focus: Independent orphan source and deployment path
- Blockers: Official Git remotes and admin submodule are disconnected; private Git and source-archive updater paths are implemented locally. Machine1 now runs source overlay `403604e`; the authenticated archive path reports current/latest equal, and the home page returns HTTP 200. The protected token is held only in machine1's `.env`. A tested rollback rehearsal, clean-room recovery, and client traffic tests remain explicitly outstanding/skipped.
- Repository details: `../Xboard/docs-private/`

### Xboard-Node

- State: VERIFIED
- Current focus: Independent orphan source and local v1.13-orphan.1 CLI artifacts
- Blockers: Installer defaults no longer use the former release endpoint and CI publishes under its current repository owner. The user confirmed machine-mode deployment completed normally after machine2 was restored to a clean state; no further inspection was requested. Docker image and Go module cache archives are outside current required scope. Encrypted client traffic and subscription flow remain intentionally untested. The historical Go module namespace is retained as a non-network compatibility identifier.
- Repository details: `../Xboard-Node/docs-private/`

## Cross-Repository Coordination

- Integration contract: CONTROL PLANE AND DATA-PLANE SOCKET VERIFIED; machine2 running Xboard-Node v1.13 in machine mode is online in the machine1 Xboard panel (SID 1), and its Shadowsocks node listens on TCP/UDP port 24680. Client traffic and subscription flow are intentionally unverified.
- Shared blockers: Orphan policy is set; historical Git/license provenance remains, with no cedar2025 HTTP/GHCR endpoints in scanned source paths. Machine1 serves staged local Node assets through signed URLs; release `20261005-403604e` is applied through the loopback-only archive updater. Hashes and home HTTP 200 are verified. A tested rollback rehearsal, clean-room recovery, and client traffic tests remain outstanding/skipped. Docker/Compose is outside the required recovery target; Native/aaPanel is prioritized.
- Decisions affecting both repositories: Both repositories require private mirrors, local backups, and replacement recovery paths for critical upstream URLs.
- Next coordination checkpoint: The current Xboard release is live. The two local commits are pushed to the private Xboard remote (`master` at `403604e`); a full local Git bundle and source-only rollback archive are also backed up on the workstation. VMware snapshot metadata for machine1 contains `快照 261005`; no restore/revert test was run. Refreshing SQL and protected `.env` workstation backups is deferred by user choice; the existing 2026-09-10 copies remain stale. Continue with the post-launch deferred validation/fix backlog. The interrupted installer impact remains unchecked and requires renewed user authorization before inspection.

## Deferred Validation (Post-Launch)

- Archive updater rollback rehearsal on a separate staging copy; the root-only pre-update source archive remains available on machine1.
- Clean-room disaster-recovery restore rehearsal; deferred by user request.
- Xboard-Node encrypted client traffic and subscription-flow tests; explicitly skipped.
- Ordinary-user login and dashboard node/user/plan checks that were skipped during the earlier aaPanel verification.
- Whether the interrupted aaPanel installer attempt affected machine1; user explicitly chose not to inspect this. Do not check processes, apt/dpkg state, or logs unless the user changes that decision.

Run only the smallest relevant checks when resuming each item. Do not treat these deferred checks as passed or production-readiness evidence.

## Deployment Investigation

- Docker Compose and native Ubuntu deployment approaches were exercised on a second dedicated VM.
- Docker was subsequently cleaned from that VM.
- aaPanel was installed on a dedicated private-IP VM; the host browser login succeeded, the aaPanel software stack was installed, and Xboard home/admin paths returned HTTP 200 through the aaPanel-managed web server.
- The aaPanel validation used PHP 8.3, MariaDB, Redis, phpredis, a systemd queue worker and cron scheduler. Public certificates were intentionally not tested.

## Verified Critical Findings

- The historical Xboard baseline used an admin-dist Git submodule; the active source now vendors the verified asset files.
- Xboard Compose samples build locally, and Node CI derives image ownership from the repository owner.
- Xboard install commands use short-lived signed URLs for local Node assets; the assets are staged on machine1 and the signed installer download was verified without running it.
- Xboard-Node installer and xbctl updates require local binaries or an explicitly configured private asset base.
- Xboard-Node fea5732 (private GitHub dev) restores geo files from a private local source before downloading; an offline Go vendor archive is stored in private-assets/xboard-node. Neither has been verified on a clean host.
- `Xboard-Node` contains geo-data download URLs from third-party projects (SagerNet and Loyalsoldier) that are not upstream-owned but still critical for runtime behavior.

Update this file only when the shared status or the relationship between the two repositories changes.
