# Clean-Room Recovery Test

Status: PLANNED

## Objective

This document defines the final validation step required to mark the project as independently recoverable.

## Test Assumptions

The recovery test assumes that all cedar2025-controlled resources are unavailable, including:

- GitHub repositories
- GitHub releases
- GHCR images
- raw GitHub install scripts
- Git submodules
- frontend assets
- release binaries
- any upstream-controlled download URLs

Only the following may be used:

1. private local repo mirror
2. private local backup assets
3. private config and DB backups
4. public infrastructure and OS packages

## Test Environment

- A fresh clean server or clean VM
- Standard OS and package manager
- Docker runtime if needed
- MySQL and Redis services
- Local private artifacts available offline

## Test Sequence

1. Provision a fresh server with required public dependencies.
2. Restore Git mirror and source baseline from private local storage.
3. Restore the local recovery asset set.
4. Restore private config and DB backups.
5. Restore the Xboard admin submodule content from local backup.
6. Restore or build the private image for Xboard.
7. Restore or build the private image for Xboard-Node.
8. Start MySQL and Redis.
9. Run the private migration and update path.
10. Start Xboard.
11. Start Xboard-Node.
12. Validate the connection and core functionality.
13. Record the exact recovery log and any issues encountered.

## Success Criteria

Project is considered independently recoverable only when all of the following are true:

- Xboard starts successfully from the private mirror and local assets
- Xboard-Node starts successfully from the private mirror and local assets
- Xboard and Xboard-Node communicate successfully
- MySQL and Redis are restored and operational
- The system can be used for core functions with the restored configuration
- The entire sequence is reproducible without any cedar2025-controlled resources

## Status

This is the final end-to-end verification step. It must be executed before the project can be marked as `INDEPENDENTLY RECOVERABLE`.
