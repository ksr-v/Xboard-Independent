# Recovery Asset Checksums

Status: VERIFIED

This file is the version and integrity log for the private recovery assets created to replace critical upstream-only dependencies.

The machine-readable SHA256 manifest for every currently stored recovery file is `RECOVERY-SHA256SUMS.txt`. Hashes were recalculated locally on 2026-09-10.

## Xboard

### Composer PHAR

- Path: `private-assets/xboard/composer/bin/composer.phar`
- Verified SHA256: 7A2D379D5B8FFDAA028580EF26494C36D2FEEF4B178D3DD1473A4DBC5E17C8D6
- Notes: Backup created from the upstream Composer release URL. Keep this artifact pinned and use it if the upstream release URL becomes unavailable.

### Admin Dist Submodule

- Path: `private-assets/xboard/submodule/admin-dist`
- Source: `source/Xboard/public/assets/admin`
- Notes: This is the exact local copy of the admin UI submodule at the time of verification. Preserve it and keep the git SHA of the submodule commit as the reference.

## Xboard-Node

### Installer Script

- Path: `private-assets/xboard-node/installers/install.sh`
- Source: `source/Xboard-Node/install.sh`
- Notes: Use this file as the local replacement when the upstream raw GitHub installer is unavailable.

### Geo Data

- Path: `private-assets/xboard-node/geo-data`
- Source: upstream public release URLs from SagerNet and Loyalsoldier projects
- Notes: Cache validated copies here and prefer local file paths before external network fetches.

### Release Artifacts

- Path: `private-assets/xboard-node/releases`
- Version: `v1.13`, matching baseline commit `0a29338e1f102a462363ce3527417029f89bab28`
- Contents: `xboard-node` and `xbctl` binaries for Linux amd64 and arm64, plus `README.txt`
- Verification: All four binary SHA256 values match the digests published in the GitHub v1.13 release metadata.

## Recovery Use

When the upstream resources become unavailable, the recovery order should be:

1. Private Git mirror
2. Private release and binary artifacts
3. Composer PHAR and dependency bundle
4. Admin dist submodule
5. Installer script and runtime geo-data
6. Database and service configuration
7. Service startup and validation
