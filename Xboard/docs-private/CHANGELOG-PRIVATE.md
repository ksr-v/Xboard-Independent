# Private Changelog

## 2026-09-10

- Rebuilt deployment on a clean Ubuntu 22.04.5 LTS Hyper-V VM after deleting the two contaminated test VMs.
- Verified native Xboard deployment end to end: PHP 8.2, MariaDB 10.6, Redis, Composer, Nginx, PHP-FPM, HTTP 200 for the home/admin paths, queue worker, scheduler, and UFW.
- Tightened the deployed source tree to read-only runtime permissions, restricted `.env` to `640`, and left only `storage` and `bootstrap/cache` writable by `www-data`.
- Created and SHA-256 verified a root-only local VM backup containing the Xboard database dump, application archive, `.env`, and checksum manifest.
- Downloaded the verified backup into `private-assets/backups/xboard-current/`; local archive listing, SQL header, and SHA-256 checks passed. Added a Git ignore rule for the backup directory.
- Deferred the clean-room recovery rehearsal at the user's request; this must be raised as a pending reminder before the project is declared fully complete.
- Expanded the VM to approximately 3.8 GiB RAM and a 48 GB root filesystem with approximately 40 GB free; updated Xboard and Nginx to the new DHCP address `172.19.68.133`.
- Reviewed the existing deployment work without performing a new deployment.
- Recorded the second-VM Docker Compose, native Ubuntu, and aaPanel test state.
- Classified the aaPanel HTTP 404 as an unresolved panel routing/package compatibility issue rather than a verified Xboard conflict.
- Continued the unfinished non-interactive installer work with safe handling for existing MySQL databases and empty database/Redis passwords.
- Installed PHP 8.2.33 locally for verification; the modified installer passes PHP syntax validation and Laravel successfully loads its new command options.
- Installed dependencies from the existing lock file without updating it. `composer validate` reports that the lock file is out of sync with `composer.json`.
- Ran the existing PHP unit suite in an isolated SQLite test database: 7 tests passed and 3 registration tests were blocked by the unavailable PhpRedis extension. No business assertion failed in the executable tests.
