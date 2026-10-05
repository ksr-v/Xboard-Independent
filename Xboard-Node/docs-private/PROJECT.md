# Xboard-Node Project Record

Status: VERIFIED

## Project Identity

- Historical source repo (provenance only; no longer synchronized): https://github.com/cedar2025/Xboard-Node
- Local baseline mirror: D:\Xboard-Independent\private-repos\Xboard-Node.git
- Verified baseline tag: baseline-2026-09-09
- Verified commit: 0a29338e1f102a462363ce3527417029f89bab28
- Active source checkout no longer has a cedar2025 remote; the local bare origin is retained.

## Private Recovery Objective

This repository must remain recoverable even when the upstream GitHub repo, release assets, raw install scripts, or GHCR registry are unavailable.

## Critical Upstream Dependencies

### UPSTREAM_CRITICAL (resolved by orphaning)

- Historical source repo, release assets, raw installer and GHCR refs: removed as defaults; replaced by the private repo (https://github.com/ksr-v/Xboard-Node--Custom-Source, branch dev), local binaries and an explicit private download base.
- Geo-data: local fallback (fea5732) plus private copies in private-assets/xboard-node/geo-data.

### PUBLIC_INFRASTRUCTURE

- Go module dependencies from go.mod and go.sum (offline vendor archive in private-assets/xboard-node/go-vendor-fea5732.zip)
- DNS and certificate ecosystem providers used by cert automation

### OPTIONAL_EXTERNAL

- Geo-data sources maintained by unrelated third-party projects
- Non-critical runtime data sources used by optional rule generation

## Private Recovery Plan

1. Preserve the exact upstream source and baseline tag in the private mirror.
2. Mirror required release binaries and installer scripts into a private local artifact store.
3. Replace raw GitHub installer URLs with internal, version-pinned alternatives.
4. Record the exact runtime dependency set for Go modules, cert providers, and geo-data assets.
5. Back up current installation metadata and config templates for disaster recovery.
6. Ensure the system can rebuild from private artifacts without any cedar2025-controlled resource.

## Verification Labels

- VERIFIED: baseline repo and private mirror established
- DISCOVERED: release/install/GHCR risks confirmed
- PLANNED: private artifact packaging and local installer replacement
- UNKNOWN: exact offline replacement for all optional geo-data sources until runtime validation completes

## Current Phase

The user chose independent orphan maintenance on 2026-10-05. Preserve upstream history and licenses, but do not synchronize from the historical source. Replace upstream release/install/runtime links with version-pinned private or local assets as each path is addressed. Native/aaPanel is the required recovery target; Docker is optional and client traffic testing remains intentionally skipped.
