# Private Recovery Checklist

Status: VERIFIED

## 1. Source Baseline

- [x] Official upstream repo verified reachable
- [x] Xboard source cloned to `source/Xboard`
- [x] Xboard-Node source cloned to `source/Xboard-Node`
- [x] Private mirror created under `private-repos`
- [x] Baseline tag created for both repos

## 2. Dependency Backup

- [x] Composer PHAR stored locally
- [x] Xboard admin submodule content stored locally
- [x] Xboard-Node install script stored locally
- [x] Xboard-Node geo-data cached locally
- [x] Xboard-Node release asset directory prepared locally
- [x] Xboard-Node v1.13 Linux amd64 and arm64 release binaries stored locally
- [x] Independent xbctl v1.13-orphan.1 Linux amd64 and arm64 binaries rebuilt locally

## 3. Version and Integrity

- [x] Composer PHAR SHA256 recorded
- [x] Recovery asset locations documented
- [x] Recovery asset plan written
- [x] Recovery checksum manifest written for all currently stored files

## 4. Recovery Order

1. Private Git mirror
2. Local Composer PHAR
3. Local admin submodule content
4. Local Xboard-Node installer and geo-data
5. Local release assets
6. Private config and database backup
7. Service deployment and validation

## 5. Remaining Unknowns

- Native/aaPanel on machine1 is the selected required deployment path; public domain/HTTPS rollout remains outside the current scope.
- VMware snapshot metadata for the user-confirmed machine1 VMX `E:\Virtual Machines\machine1\machine2.vmx` contains `快照 261005` (`Snapshot3`). The snapshot entry is present; no restore/revert test was run.
- Existing workstation database/config backups date from 2026-09-10 and are stale for the current launch. The user deferred refreshing them; keep them explicitly marked stale until an encrypted destination is provided. A source-only rollback archive and full Git bundle were copied/generated on 2026-10-05 and checksummed.
- The Git bundle contains current Xboard history through `403604e`; the two commits were also pushed to private remote `master`, verified at `403604e`.
- Full clean-room database restore rehearsal (deferred by user request; remind before project completion)
- Final server layout for a clean-room recovery test
- Xboard Composer lock mismatch and install-time Composer self-update mean clean-source offline installation is unverified; the deployed-app archive does include a complete vendor tree.
- Xboard supports private Git fast-forward updates and versioned source-archive overlays. Machine1's archive updater is deployed and release `20261005-403604e` is active; its rollback rehearsal is deferred until post-launch.
- Xboard-Node installer and orphan xbctl no longer default to the upstream release host; the v1.13-orphan.1 local-binary path is not yet validated on a clean host.
- Geo-data copies are checksummed but not yet used as the runtime download fallback.
- No Go module cache bundle is currently recorded; fully offline Go builds would need one. This is a post-launch recovery enhancement, not a blocker for the current running machine2 deployment.
- Xboard admin generates signed local asset URLs. The Node assets are staged on machine1 and a signed installer download was hash-verified; the installer was not run.

## 6. Recovery Readiness

The project has verified local copies and matching checksums for the assets listed above. The application snapshot includes its Composer vendor tree; clean-source Composer bootstrap remains network-dependent. The Node asset delivery overlay is deployed on machine1 and its signed download path was verified, but installer execution and clean-host installation remain untested. Source code supports a versioned archive update protocol that preserves `.env`, `storage`, and `vendor`; its loopback endpoint and updater client are deployed. Release `20261005-403604e` is applied, authenticated update checks report current/latest equal, and machine1's home page returns HTTP 200. The token remains only in the protected server `.env`. A source-only rollback archive is backed up on the workstation and a complete local Git bundle through `403604e` is verified; the older workstation SQL and `.env` backups remain from 2026-09-10. The machine1 VMware snapshot is not confirmed. The live Xboard launch is running, but recovery and production readiness are not fully verified.
