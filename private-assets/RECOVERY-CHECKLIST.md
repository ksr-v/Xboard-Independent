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

- Final production deployment topology
- Full clean-room database restore rehearsal (deferred by user request; remind before project completion)
- Final server and docker layout for a clean-room recovery test
- Final production image/version pinning strategy

## 6. Recovery Readiness

The project has a verified local recovery path for critical upstream dependencies and the validated IP-based deployment. The VM backup is stored outside the server at `private-assets/backups/xboard-current/`; its SQL dump, application archive, and environment file passed local SHA-256 and archive-read checks. The project is handoff-ready for validation/light testing, but is not production-ready because the VM is undersized and no clean-room restore rehearsal has been performed.
