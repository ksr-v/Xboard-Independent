# Xboard Independent

This is the private management repository for the independently recoverable Xboard and Xboard-Node project.

## Repository Boundaries

- `Project-Docs/`: cross-repository status, plans, and operating rules
- `Xboard/docs-private/`: Xboard-specific records
- `Xboard-Node/docs-private/`: Xboard-Node-specific records
- `private-assets/`: verified recovery artifacts and SHA256 manifest
- `source/`: excluded nested upstream working trees with their own Git history
- `private-repos/`: excluded local bare source repositories

Large binary recovery artifacts are stored with Git LFS. A usable backup of this repository must include both normal Git objects and Git LFS objects.

Secrets, environment files, database dumps, and production credentials are intentionally excluded. They require a separate encrypted backup path.

See `Project-Docs/MASTER-STATUS.md` for current status and `Project-Docs/PROJECT-INSTRUCTIONS.md` for operating rules.
