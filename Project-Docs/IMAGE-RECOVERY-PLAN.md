# Image and Container Recovery Plan

Status: OUT OF REQUIRED SCOPE (user decision, 2026-10-05)

## Objective

Docker/Compose and GHCR recovery are not required for the current project target. The user selected Native/aaPanel recovery and independent orphan maintenance. This file is retained as historical planning context only; do not treat its image-archive actions as active work.

## Critical Findings

- Xboard compose files reference `ghcr.io/cedar2025/xboard:latest`.
- Xboard-Node README and workflows reference `ghcr.io/cedar2025/xboard-node:latest`.
- The upstream project assumes the ability to pull the current image from GHCR.

## Recovery Principles

- Keep a local container image export for every deployed stable version.
- Record image tag and digest information.
- Maintain a local compose override and local build recipe for every private stable deployment.
- Avoid using `latest` in production recovery without a known local artifact and version record.

## Recovery Sequence

1. Restore the private repo baseline from the Git mirror.
2. Restore the exact image tarball for the matching version from the private image store.
3. Restore the local Compose override and private environment files.
4. Load the image into the local Docker daemon or a recovery environment.
5. Start the service with the restored private configuration.
6. Validate the app and service health before enabling user traffic.

## Xboard Container Notes

- The compose files use `ghcr.io/cedar2025/xboard:latest`.
- Recovery requires either a local image archive or a local rebuild using the private source tree.
- The local image export should be versioned and stored in the private asset store.

## Xboard-Node Container Notes

- The README references a GHCR image for the node runtime.
- Recovery should prefer a local image archive or a private image build from the verified baseline.
- The node config and credentials must remain in a private config store with version control.

## Production Rule

Never assume `latest` is recoverable without a local image export or a private build record. The private recovery plan must keep a stable image tag and digest list for every deployed version.
