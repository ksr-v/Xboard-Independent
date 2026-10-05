# Xboard-Node Dependency Audit

Status: ORPHANING IN PROGRESS

## Scope

This file documents verified external dependencies for the `Xboard-Node` repository only. Cross-repository coordination remains in `../Project-Docs/MASTER-STATUS.md`.

## UPSTREAM_CRITICAL

- Historical source repository `cedar2025/Xboard-Node`.
  - Retained in Git history only; the active source checkout no longer has a remote to it.
- Historical release and raw installer endpoints.
  - Removed as implicit defaults. The installer now requires local binaries or an explicitly configured private download base.

## PUBLIC_INFRASTRUCTURE

- `go.mod` and `go.sum`
  - Versioned Go module dependencies and checksums. They are public infrastructure, and an archived vendor bundle is stored locally at `private-assets/xboard-node/go-vendor-fea5732.zip` (not in Git) and as a private GitHub Release attachment (https://github.com/ksr-v/Xboard-Node--Custom-Source/releases/tag/go-vendor-fea5732); unzip it as `vendor/` in the source tree and build with `go build -mod=vendor`.
- Public DNS and TLS providers used by cert automation
  - These are ecosystem dependencies, not a private fork target.

## OPTIONAL_EXTERNAL (feature-conditional)

- GHCR container publishing
  - CI now uses the owner of the repository where the workflow runs; no cedar2025 image path remains. Docker is not a required recovery target.

- `https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db`
- `https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db`
- `https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat`
- `https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat`
  - Xboard-Node requests only the matching geo files when configured routes reference `geoip:` or `geosite:` data. Core startup without those route rules does not require them. The four geo files are present in `private-assets/xboard-node/geo-data/` and checksum verified.

## UNKNOWN

- Whether the install flow can be safely replaced with a version-pinned local artifact in the event the upstream release service becomes unavailable.
- Whether there are additional private assets beyond the documented release URLs and GHCR references.
- Geo-data fallback is implemented (fea5732) but not yet tested at runtime on a clean host.

## Verified Notes

- The install script references upstream release and raw GitHub download flows.
- The installer's default metadata version is pinned to `v1.13-orphan.1` and it supports explicit `--binary` and `--xbctl-binary` paths. Without local binaries it fails unless an operator explicitly provides a private `--download-base`/`XBOARD_NODE_DOWNLOAD_BASE`.
- The project README describes private/local-binary installation; it no longer instructs operators to clone or curl from cedar2025.
- The Go code includes runtime geodata downloads from public upstream projects.
- Both local bare Git mirrors contain the expected baseline tags. The root recovery checksum manifest records 30 assets, including the published Xboard source overlays; all entries were verified at publication time.
- The four geo-data files, independent private installer copy, four preserved v1.13 Linux binaries, and two rebuilt v1.13-orphan.1 xbctl binaries are present locally; this verifies storage and integrity, not clean-host installation.
- `go.mod` and internal Go imports still use the historical `github.com/cedar2025/xboard-node` module identity so local packages resolve compatibly. This is not a remote URL or network dependency; renaming it would be a separate source-compatibility change.

## Recovery Action Plan

- Preserve exact Git and tag baselines in the private repository.
- Use the rebuilt v1.13-orphan.1 xbctl binaries with the preserved v1.13 node binaries through `--binary` and `--xbctl-binary`; validate installation on a clean host when authorized.
- Add a private geo-data fallback to the recovery procedure for deployments that use geo routing; do not classify these optional route datasets as required for every node startup.
- Offline rebuild: extract the vendor archive into the source tree and use `-mod=vendor`. For geo routing, place the four geo files in `/usr/local/share/xboard-node/geo-data` or set `XBOARD_GEO_DATA_SOURCE`.
