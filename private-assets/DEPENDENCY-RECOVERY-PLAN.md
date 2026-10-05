# Dependency Recovery Plan

Status: PARTIALLY VERIFIED (asset existence and checksums; offline recovery path pending)

## Verified Asset Snapshot (2026-10-05)

- Both private bare Git mirrors contain their expected baseline tags.
- The Xboard admin submodule worktree commit is `ef5f43da335092cbff8fdf0ad7ff9b4d92d7d0d7`; a local admin dist file copy is present.
- The Composer PHAR, Xboard-Node installer, four preserved v1.13 Linux release binaries, two independent v1.13-orphan.1 xbctl rebuilds, and four geo-data files are present in the documented private asset paths.
- All 26 files listed in `RECOVERY-SHA256SUMS.txt` exist and match their SHA-256 values.
- These checks establish stored-asset integrity only. No offline build or upstream-independent restore was performed.

## Objective

This document defines the first-pass private recovery plan for the dependencies that would break the prioritized Native/aaPanel path if required upstream resources disappear. Docker/Compose and GHCR are outside the current required recovery scope.

## Xboard Critical Assets

### 1. Composer PHAR

- Source discovered from: `source/Xboard/init.sh` and `source/Xboard/update.sh`
- Risk: Composer distribution is downloaded from GitHub release URL and is not version-pinned in the project itself.
- Recovery plan:
  - Download and retain a verified Composer PHAR in `private-assets/xboard/composer/bin/`
  - Record the exact version and hash used
  - Use a local path in scripts when the upstream URL cannot be reached

### 2. Admin submodule

- Source discovered from: `source/Xboard/.gitmodules`
- Risk: `public/assets/admin` points to `https://github.com/cedar2025/xboard-admin-dist.git`
- Recovery plan:
  - Mirror the submodule repo or store a local zip/tarball in `private-assets/xboard/submodule/admin-dist/`
  - Preserve the exact commit used by the baseline
  - Update local scripts to prefer private path if upstream is unavailable

### 3. Xboard Docker image and Compose assets (optional path)

- Source discovered from: compose YAML files and GHCR references
  - Risk: container image is hosted in GHCR and not guaranteed to remain available
  - Current decision: Docker/Compose is not a required recovery target; Native/aaPanel takes priority.

## Xboard-Node Critical Assets

### 1. Release binary assets

- Source discovered from: `source/Xboard-Node/install.sh`
- Risk: install flow downloads binaries from a GitHub release base URL
- Recovery plan:
  - Download and preserve the exact release payload into `private-assets/xboard-node/releases/`
  - Record version tag and checksum
  - Prefer private local binary path for reproducible recovery

### 2. Installer scripts

- Source discovered from: README and install.sh
- Risk: the install process uses raw GitHub-hosted Shell scripts
- Recovery plan:
  - Copy the verified installer script into `private-assets/xboard-node/installers/`
  - Keep a versioned replacement that can be executed without external GitHub access

### 3. Geo-data runtime assets

- Source discovered from: `source/Xboard-Node/internal/kernel/geodata/geodata.go`
- Risk: runtime download URLs are hosted on third-party GitHub releases and are required for some runtime behavior
- Recovery plan:
  - Cache the exact geo-data files under `private-assets/xboard-node/geo-data/`
  - Use local file fallback when remote hosts are unreachable

## Recovery Priority

1. Preserve the exact upstream baseline and private mirrors
2. Snapshot Composer and release artifacts locally
3. Snapshot submodule admin dist and geo-data assets
4. Create a private installer path and local override files
5. Verify recovery on a clean environment before relying on the setup in production

## Known Gaps

- Xboard `init.sh` self-updates Composer from the network; the existing `composer.lock` was previously reported out of sync with `composer.json`. The deployed-app archive contains a complete vendor tree, but clean-source offline installation has not been demonstrated.
- Xboard `update.sh` now fetches the private remote and fast-forwards only, preserving the Composer lockfile. The deployed archive still has no `.git`, so built-in updating is not enabled there.
- Xboard-Node's installer is pinned to v1.13 and uses local binaries by default; no download source is contacted unless a private `--download-base` is explicitly provided.
- `xbctl upgrade` also requires a private download base; the default no longer resolves to an upstream release host.
- Geo-data is requested conditionally when geo route rules are configured. Local copies are stored, but runtime fallback to those copies has not been established.
- No Go module cache bundle was identified; this matters only if fully offline Go builds are required.
- Xboard's Node install command uses short-lived signed panel URLs. The installer, v1.13 node binaries, and v1.13-orphan.1 xbctl binaries are staged on machine1; hashes match local copies, and the signed installer download was verified. The installer itself was not run.
- The Xboard updater supports either a private Git fast-forward or a source-archive overlay. The archive updater validates the manifest, checksum, protected paths, and unchanged Composer manifests. Machine1's loopback endpoint and updater client are deployed; release `20261005-403604e` is applied and the authenticated updater reports current/latest equal. The token is kept only in the protected server `.env`. A rollback rehearsal remains outstanding; a root-only source backup is retained on machine1.

## Verification Labels

- VERIFIED: baseline source, local mirrors, stored recovery files, and matching checksums
- DISCOVERED: critical dependencies identified
- PLANNED: wire stored assets into version-pinned, offline-capable recovery paths
- UNKNOWN: Composer lock repair compatibility and final offline restore behavior
