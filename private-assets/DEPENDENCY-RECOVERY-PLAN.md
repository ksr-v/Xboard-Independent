# Dependency Recovery Plan

Status: PLANNED

## Objective

This document defines the first-pass private recovery plan for the critical upstream dependencies that would break Xboard and Xboard-Node if the original GitHub, GHCR, or raw GitHub resources disappear.

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

### 3. Xboard Docker image and Compose assets

- Source discovered from: compose YAML files and GHCR references
- Risk: container image is hosted in GHCR and not guaranteed to remain available
- Recovery plan:
  - Preserve container images locally as tarballs or OCI archives
  - Store local compose override files in the private backup set
  - Record image tags and digests used in the stable deployment

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

## Verification Labels

- VERIFIED: baseline source and local mirror
- DISCOVERED: critical dependencies identified
- PLANNED: local artifact locations defined
- UNKNOWN: final runtime validation and exact replacement packaging still pending
