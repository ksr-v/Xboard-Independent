# Disaster Recovery Plan

Status: PLANNED

## Objective

This document defines the recovery sequence that should be followed when the upstream GitHub repos, release assets, or GHCR resources are unavailable.

## Phase 1: Restore Private Baseline

1. Restore the Git mirror from `private-repos`
2. Restore the source baseline from the verified tag
3. Restore the exact local snapshot of private recovery assets
4. Verify the recovered files and hashes against the checksum log

## Phase 2: Restore Common Dependencies

1. Restore MySQL and Redis service
2. Restore database backup and migration state
3. Restore any local Composer dependency bundle or local artifact cache
4. Ensure PHP runtime and Docker runtime are installed and configured

## Phase 3: Restore Xboard

1. Restore the repo from the private mirror
2. Restore the admin submodule content from local private recovery asset
3. Restore `.env` from the private config backup
4. Restore the local Docker image tarball or use a locally built image
5. Run the required Laravel migration/install/update process
6. Validate the admin portal and required services

## Phase 4: Restore Xboard-Node

1. Restore the repo from the private mirror
2. Restore local installer and geo-data assets
3. Restore config credentials from private config backup
4. Run the local installer or service setup path without external GitHub dependency
5. Validate node registration with the Xboard panel

## Phase 5: Validate Service Connectivity

1. Confirm Xboard can access MySQL and Redis
2. Confirm Xboard-Node can reach the Xboard panel
3. Confirm node health checks succeed
4. Confirm basic user traffic and service features work

## Phase 6: Final Clean-Room Recovery Test

Test assumptions:

- No cedar2025 GitHub repo is reachable
- No cedar2025 release assets are reachable
- No cedar2025 GHCR image is reachable
- Only private local assets and public infrastructure may be used

The clean-room recovery test should be run only after all private asset paths are fully verified and the configuration backup is complete.
