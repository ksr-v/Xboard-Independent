# Xboard-Node Repository Guide

This file applies only to the `Xboard-Node` repository.

Before starting work, read the project-wide rules in `../Project-Docs/PROJECT-INSTRUCTIONS.md`.

## Scope

- Keep Xboard-Node code, configuration, architecture, dependencies, deployment notes, recovery procedures, and private changelog in this repository.
- Store repository-specific documentation in `docs-private/`.
- Do not copy Xboard implementation details or operational notes into this repository.
- Do not use `Project-Docs/MASTER-STATUS.md` for details that belong only to Xboard-Node.
- Do not start Phase 0 or any repository operation unless the user explicitly requests it.
- If a required environment tool or dependency is missing, pause immediately. Complete it automatically only when possible; otherwise report the manual prerequisite and wait for an explicit instruction to continue.
- Keep verification labels accurate: `VERIFIED`, `DISCOVERED`, `PLANNED`, or `UNKNOWN`.

## Documentation Map

- `docs-private/PROJECT.md`: project purpose, architecture, and current repository decisions.
- `docs-private/DEPENDENCIES.md`: dependency inventory and compatibility constraints.
- `docs-private/DEPLOYMENT.md`: Xboard-Node deployment and environment instructions.
- `docs-private/DISASTER-RECOVERY.md`: Xboard-Node recovery procedures.
- `docs-private/CHANGELOG-PRIVATE.md`: private changes and operational history.

When a change affects both repositories, record the Xboard-Node-specific details here and update the shared summary in `../Project-Docs/MASTER-STATUS.md`.

## Current Phase

Phase 0 is planned but not started. Do not modify business code during Phase 0 until the required investigation and the user's explicit instruction are complete.
