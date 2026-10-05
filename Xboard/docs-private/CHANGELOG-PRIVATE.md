# Private Changelog

## 2026-10-05

- Recorded the user's planned VMware recovery snapshot for `machine1` (`<panel-host>`) at the verified aaPanel + Xboard deployment checkpoint. Snapshot creation and its exact VMware label are pending confirmation; suggested label: `xboard-aapanel-verified-2026-10-05`.

## 2026-09-11

- Prepared a dedicated aaPanel verification VM with 2 vCPU, 3.8 GiB RAM, a 28 GB root filesystem, and static IP `<vm-ip>`.
- Attempted the official aaPanel installer twice; the first download timed out and the second downloaded successfully but stalled without creating panel files or services. Stopped the process and confirmed no aaPanel residue remained.
- Resumed aaPanel installation with explicit `y` input after identifying the interactive `/www` confirmation prompt. Installation completed with panel port `37090`, but the security path returned HTTP 404 locally and externally. The aaPanel repair command reported version `3.1` current; login verification remains failed and Xboard installation was not attempted.
- Confirmed aaPanel login from the Hyper-V host browser, installed the aaPanel software stack, enabled phpredis for aaPanel PHP 8.3, deployed Xboard under `/www/wwwroot/xboard`, and verified home/admin HTTP 200 through the aaPanel-managed Nginx vhost.
- Added an aaPanel PHP 8.3 systemd queue worker and cron scheduler; recorded that the Xboard dashboard queue metric remains abnormal because it does not discover the systemd-managed worker, while the worker process itself is active.
- Completed final aaPanel runtime status verification while intentionally skipping ordinary-user login and node/user/plan page checks; confirmed panel processes, PHP-FPM, MariaDB, Redis, WebServer ports, and Xboard home/admin HTTP 200.

## 2026-09-10

- User deleted the native validation VM; current environment has no active project VM. Resume only after a new dedicated VM is provided, with aaPanel verification still pending.
- Rebuilt deployment on a clean Ubuntu 22.04.5 LTS Hyper-V VM after deleting the two contaminated test VMs.
- Verified native Xboard deployment end to end: PHP 8.2, MariaDB 10.6, Redis, Composer, Nginx, PHP-FPM, HTTP 200 for the home/admin paths, queue worker, scheduler, and UFW.
- Tightened the deployed source tree to read-only runtime permissions, restricted `.env` to `640`, and left only `storage` and `bootstrap/cache` writable by `www-data`.
- Created and SHA-256 verified a root-only local VM backup containing the Xboard database dump, application archive, `.env`, and checksum manifest.
- Downloaded the verified backup into `private-assets/backups/xboard-current/`; local archive listing, SQL header, and SHA-256 checks passed. Added a Git ignore rule for the backup directory.
- Deferred the clean-room recovery rehearsal at the user's request; this must be raised as a pending reminder before the project is declared fully complete.
- Expanded the VM to approximately 3.8 GiB RAM and a 48 GB root filesystem with approximately 40 GB free; updated Xboard and Nginx to the new DHCP address `<vm-ip>`.
- Reviewed the existing deployment work without performing a new deployment.
- Recorded the second-VM Docker Compose, native Ubuntu, and aaPanel test state.
- Classified the aaPanel HTTP 404 as an unresolved panel routing/package compatibility issue rather than a verified Xboard conflict.
- Continued the unfinished non-interactive installer work with safe handling for existing MySQL databases and empty database/Redis passwords.
- Installed PHP 8.2.33 locally for verification; the modified installer passes PHP syntax validation and Laravel successfully loads its new command options.
- Installed dependencies from the existing lock file without updating it. `composer validate` reports that the lock file is out of sync with `composer.json`.
- Ran the existing PHP unit suite in an isolated SQLite test database: 7 tests passed and 3 registration tests were blocked by the unavailable PhpRedis extension. No business assertion failed in the executable tests.
