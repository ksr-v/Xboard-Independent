# Xboard-Node Dependency Audit

Status: VERIFIED

## Scope

This file documents verified external dependencies for the `Xboard-Node` repository only. Cross-repository coordination remains in `../Project-Docs/MASTER-STATUS.md`.

## UPSTREAM_CRITICAL

- `https://github.com/cedar2025/Xboard-Node.git`
  - Source baseline repository used as the upstream origin.
- `https://github.com/cedar2025/xboard-node/releases`
  - Release asset base referenced by the install flow.
- `https://raw.githubusercontent.com/cedar2025/xboard-node/dev/install.sh`
  - Downloaded installer used by deployment and upgrade operations.
- `ghcr.io/cedar2025/xboard-node:latest`
  - Container image path referenced in GitHub workflow and documentation.

## PUBLIC_INFRASTRUCTURE

- `go.mod` and `go.sum`
  - Module dependencies for the Go runtime; they must be preserved with lock data.
- Public DNS and TLS providers used by cert automation
  - These are ecosystem dependencies, not a private fork target.

## OPTIONAL_EXTERNAL

- `https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db`
- `https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db`
- `https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat`
- `https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat`
  - Geo-data downloads are necessary for some runtime functions but are not owned by the Xboard-Node repository itself.

## UNKNOWN

- Whether the install flow can be safely replaced with a version-pinned local artifact in the event the upstream release service becomes unavailable.
- Whether there are additional private assets beyond the documented release URLs and GHCR references.

## Verified Notes

- The install script references upstream release and raw GitHub download flows.
- The project README provides direct GitHub clone and curl installation instructions.
- The Go code includes runtime geodata downloads from public upstream projects.

## Recovery Action Plan

- Preserve exact Git and tag baselines in the private repository.
- Record and store any required release assets locally.
- Replace upstream install URLs with internally controlled mirrors or offline bundles when the private recovery path is defined.
