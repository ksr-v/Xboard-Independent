# Private Recovery Assets

This directory stores locally controlled copies and replacement artifacts for the upstream dependencies that are critical to Xboard and Xboard-Node recovery.

## Contents

- xboard/composer/bin: local Composer PHAR and related installation assets
- xboard/submodule/admin-dist: local replacement for the upstream admin UI submodule
- xboard-node/releases: local release binaries and package artifacts
- xboard-node/installers: local installer script copies and replacement scripts
- xboard-node/geo-data: cached runtime data for geo IP/site downloads

## Ownership Rule

Only place files here that are verified to be required for recovery, and only after checking the exact upstream origin and version.
