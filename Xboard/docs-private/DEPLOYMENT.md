# Xboard Deployment Record

Status: VERIFIED (native Ubuntu deployment)

## Current VM Status

The native validation VM was deleted by the user on 2026-09-10 after the deployment, expansion, and functional checks were completed. No project VM is currently active. A future aaPanel verification requires a new dedicated clean VM; do not reuse this status as evidence that aaPanel has passed.

## 2026-09-11 aaPanel Verification Attempt

A dedicated clean Ubuntu 22.04.5 Hyper-V VM was prepared for aaPanel verification at `<vm-ip>`:

- 2 vCPU and 3.8 GiB RAM were verified after the user corrected the VM memory allocation.
- The 30 GB disk was expanded to a 28 GB root filesystem with approximately 21 GB free.
- The static IP configuration was normalized by removing the conflicting cloud-init DHCP netplan file.
- No Nginx, MariaDB, Redis, Docker or other panel service was present before testing.

The official aaPanel installer was attempted twice. The first attempt timed out while downloading the installer; the second download succeeded and returned a 90,940-byte script, but the installer then remained alive for approximately five minutes without creating `/www/server/panel`, starting a panel service, or opening its advertised port (`25628`). The process was stopped and the VM was confirmed clean afterward.

Current classification: `DISCOVERED` failure, not a successful aaPanel deployment. GitHub and aaPanel endpoints both returned HTTP 200 during the network comparison, so the second attempt's failure was not explained by general outbound connectivity.

The interactive retry later completed the aaPanel installation and created the panel service, internal web server, Unix socket, and port `37090`. However, both the public security path and direct local requests returned HTTP 404. The aaPanel error log also recorded a Flask `TypeError` for the login view during an earlier `HEAD` request. The official repair command reported that version `3.1` was already current, but the login path remained 404 after repair. Therefore aaPanel installation is present, but aaPanel login verification failed and Xboard deployment was not started on this VM.

## 2026-09-11 aaPanel Login and Xboard Verification

The aaPanel security path was successfully opened from the Hyper-V host browser after accepting the self-signed certificate. The aaPanel software center was usable. The default software queue installed Nginx 1.30.4, PHP 8.3.33, MariaDB, OpenLiteSpeed, Pure-FTPd and phpMyAdmin; Redis 7.2 was then installed separately.

Xboard was initialized under `/www/wwwroot/xboard` using the aaPanel PHP 8.3 runtime. The PHP Redis extension was compiled and enabled specifically for `/www/server/php/83`. The aaPanel-managed Nginx vhost was corrected to remove the default stopped-site vhost and serve `/www/wwwroot/xboard/public` through `/tmp/php-cgi-83.sock`.

Verified from the host and VM using the private IP `<vm-ip>`:

- Xboard home page: HTTP 200.
- Xboard administrator path: HTTP 200.
- MariaDB: listening on port 3306.
- Redis: listening on loopback port 6379.
- PHP 8.3 CLI and phpredis: loaded.

This is an aaPanel + PHP 8.3 verification, not the PHP 8.2 native baseline. Public certificates and public IP access remain out of scope.

The Xboard queue worker was started as `xboard-aapanel-queue.service` using the aaPanel PHP 8.3 binary, and the Laravel scheduler was added to `/etc/cron.d/xboard-aapanel`. The Xboard dashboard queue card still reports `Abnormal` and `0 / 0` because aaPanel's queue metric does not discover this systemd-managed worker; the actual worker process is active and connected to Redis.

Final aaPanel runtime status verified after the user chose to skip the node, user, and plan page checks:

- aaPanel `BT-Panel` and `BT-Task` processes are running.
- PHP-FPM 8.3, MariaDB, Redis, and OpenLiteSpeed processes are running.
- MariaDB responds through `/tmp/mysql.sock`; Redis responds with `PONG`.
- aaPanel/Nginx/WebServer ports and Xboard port 80 are listening.
- Xboard home and administrator paths both return HTTP 200 using the private IP.
- Ordinary-user login and dashboard node/user/plan page verification were intentionally skipped.

## 2026-10-05 aaPanel Revalidation

A clean VMware snapshot was restored on the private-IP VM `<panel-host>`. The guest runs Ubuntu 24.04.3 LTS with 2 vCPU and 3.8 GiB RAM. Its 50 GB virtual disk had a 24 GB root logical volume; the root volume and ext4 filesystem were expanded online to approximately 48 GB, leaving about 39 GB free.

### VMware Recovery Checkpoint

- VM: `machine1` (`<panel-host>`)
- Snapshot status: VMware snapshot metadata for the user-confirmed machine1 VMX `E:\Virtual Machines\machine1\machine2.vmx` contains `快照 261005` (`Snapshot3`). The snapshot entry is present; Workstation UI confirmation was not performed by the agent.
- Snapshot label: `快照 261005`.
- Intended checkpoint contents: Ubuntu 24.04.3, aaPanel 8.0.6, Nginx 1.30.5, PHP 8.3.33, MariaDB 10.11.10, Redis 7.0.15, deployed Xboard, its initialized database, PHP/runtime configuration, and the active queue/scheduler setup described below.
- Source baseline: Xboard commit `089d838b657f12d42d1d3e3858c43a13ba12f135`; deployment archive SHA-256 `7f779733a6e68d1dce096350d06e1e2c503e0df0c72636dde33b744b0f076684`.
- The VM contains credentials in root-only files (`<root-only db credential file>` and `<root-only install log>`) and the application's protected `.env`; secure the VMware snapshot accordingly and do not export or share it publicly.
- Rolling back to this checkpoint will discard changes made inside the VM after snapshot creation. It does not back up this workstation's source repository or private recovery assets.
- After a VMware revert, verify `redis-server`, `xboard-queue.service`, PHP-FPM 8.3, and Nginx; then check Redis `PONG`, Xboard home/API/admin HTTP 200, and Laravel migration status.

The official aaPanel installer was downloaded from `https://www.aapanel.com/script/install_6.0_en.sh` (SHA-256 `211c1a0daa23135498fce2fec1485070c0e91dd2364f9aafbca29a34e3d04cea`). The script explicitly supports Ubuntu 24 and completed successfully. The official repair/update action subsequently reported aaPanel version 8.0.6.

Verified:

- `BT-Panel` and `BT-Task` processes are running.
- The aaPanel WebServer listens on TCP `41013`; UFW allows this port.
- The installer-generated security entrance returned HTTP 200 with a browser User-Agent, and interactive browser login succeeded.
- Requests using curl's default User-Agent return HTTP 404 because the panel deliberately filters spider requests; this is not a login-route failure.
- The panel uses a self-signed certificate because automatic IP certificate issuance failed.

This is a successful aaPanel installation and Xboard deployment on Ubuntu 24.04. The user installed Nginx 1.30.5, PHP 8.3.33, and MariaDB 10.11.10; all three services are running. Ubuntu Redis server 7.0.15 is installed and running, with `redis-cli ping` returning `PONG`; the listener is restricted to `127.0.0.1` and `::1`. The PHP Redis extension reports version 6.3.0. The required PHP CLI extensions (`bcmath`, `curl`, `fileinfo`, `gd`, `intl`, `mbstring`, `openssl`, `pcntl`, `PDO`, `pdo_mysql`, `redis`, and `zip`) are loaded.

Xboard was deployed from source commit `089d838b657f12d42d1d3e3858c43a13ba12f135`. The source archive was transferred with SHA-256 `7f779733a6e68d1dce096350d06e1e2c503e0df0c72636dde33b744b0f076684`; it excluded `.git` and any real `.env`, and included the local admin dist entry point. Composer 2.10.3 was used through `/www/wwwroot/xboard/composer.phar`. A dedicated `xboard` database and `xboard@127.0.0.1` account were created; the random database password is stored only in `<root-only db credential file>` (mode `600`) and the application's `.env` (mode `600`). Laravel initialization completed and all migrations report `Ran`.

The aaPanel site `<panel-host>` uses PHP 8.3 and document root `/www/wwwroot/xboard/public`. The default aaPanel vhost was retained, while the site-specific Laravel rewrite is configured in `/www/server/panel/vhost/rewrite/<panel-host>.conf`. aaPanel initially set `open_basedir` to only `public/`, which blocked `vendor/autoload.php`; `public/.user.ini` now allows `/www/wwwroot/xboard/` and `/tmp`, with its original backed up as `.user.ini.pre-openbasedir` and immutable protection restored. `APP_URL` is `http://<panel-host>`, and cache, queue, and session use Redis.

Background processing is configured with enabled systemd unit `xboard-queue.service` running `queue:work redis` as `www`, plus `/etc/cron.d/xboard` for Laravel's per-minute scheduler. The queue process is active with zero systemd restarts. `artisan schedule:list` shows the expected order, commission, ticket, traffic, log-reset, reminder-mail, Horizon snapshot, and online-status cleanup tasks. A manual `schedule:run --verbose` invocation succeeded, although several scheduled commands reported that their scheduler locks indicated they had already run on another server; individual task side effects have not yet been independently verified.

Verified from the VM/browser:

- Nginx configuration test succeeds.
- Xboard home page: HTTP 200 and renders the public login screen.
- `/api/v1/guest/comm/config`: HTTP 200 with a success JSON response.
- Admin secure path `/86f708d5`: HTTP 200; the user completed administrator authentication successfully.
- Authenticated Dashboard, System Settings, User Management, Server Management, Node Management, and Plan Management pages all render. New-environment user/server/node/plan lists are empty as expected. The observed plugin, user-group/plan, and machine-list API requests returned HTTP 200.
- Laravel reports production environment, debug off, MySQL database, and Redis cache/queue/session drivers.
- Redis responds `PONG`; all migrations are applied; no pending migration remains.
- The embedded browser blocks the optional Gravatar request to `cdn.v2ex.com` with `ERR_BLOCKED_BY_RESPONSE.NotSameOrigin`; this did not prevent Xboard pages or APIs from working.

The installer-created admin email is `<admin-email>`. The initial admin password is present only in `<root-only install log>` (mode `600`); it is intentionally not recorded here. The user completed the initial sign-in.

## 2026-10-05 Orphan Maintenance Setup (Source Changes)

- Official cedar2025 Git remotes were removed from the active source worktrees; local bare origins, baseline history, and the user's configured private Xboard remote were preserved.
- Xboard's built-in update check is configured for the private repository `ksr-v/Xboard-Custom-Source`, ref `master`. Configure `XBOARD_BUILD_COMMIT` for source-archive deployments and, only if the private repository requires it, set `XBOARD_UPDATE_TOKEN` in the server's protected `.env`/service environment. Never put the token in this record.
- The built-in updater now fetches the `private` Git remote and accepts fast-forward merges only. It requires a Git checkout with that remote; the existing `.git`-excluded deployment archive does not satisfy this requirement until deployment is changed to a private Git checkout or a release-artifact update workflow is added.
- Xboard machine installation generates 15-minute signed download URLs for local Node assets and requests CLI metadata version `v1.13-orphan.1`. The installer, preserved v1.13 node binaries, and rebuilt `v1.13-orphan.1` xbctl binaries have now been staged in machine1's `storage/app/private/node-installer` directory.

### 2026-10-05 Orphan Overlay Deployment

- A narrow overlay was deployed to machine1 (`<panel-host>`) without converting or replacing the `.git`-excluded application archive. The deployed Laravel files are `MachineController.php`, `NodeInstallerAssetController.php`, `UpdateService.php`, `config/orphan.php`, and `routes/web.php`.
- The five Node assets were staged in `/www/wwwroot/xboard/storage/app/private/node-installer`. The directory is `www:www` mode `750`; files are `www:www` mode `755`.
- The three pre-existing PHP files were backed up to `/root/xboard-orphan-backup-20261005` (directory mode `700`, owned by root). The new controller, config, and asset directory were absent before deployment.
- All ten deployed files matched their local SHA-256 values. PHP syntax checks passed for all five PHP files; Laravel route and config caches were cleared, and `node-installer.asset` was present in the route list.
- A short-lived signed URL returned `install.sh` with the expected SHA-256 and 24,733 bytes. The installer was not executed. No `.env` values or API token were changed or read.
- This validates file deployment and the signed asset download only. The archive still has no `.git`; no private update API request or client connection test was performed.

### Private Archive Update Endpoint (machine1)

- The Laravel endpoint is deployed on machine1 at `/private-xboard-updates/latest.json` and `/private-xboard-updates/releases/<version>/xboard.tar.gz`. It only accepts direct loopback requests (`127.0.0.1` or `::1`) with a Bearer token, so the same-host updater can use `http://127.0.0.1/private-xboard-updates` without sending the token over the network. The update client also permits HTTP only for these loopback literals; all remote endpoints still require HTTPS.
- The endpoint serves `latest.json` and `releases/<version>/xboard.tar.gz`. The manifest fields are `version` (`YYYYMMDD-<commit-prefix>`), full 40-character `commit`, `sha256`, compressed `size` in bytes (maximum 250 MiB), parseable `published_at`, `author`, and `message`. The archive URL is derived locally; manifest URLs are not followed.
- The tar.gz contains the application root and must include `artisan`, `composer.json`, `composer.lock`, and files under `app/`, `config/`, and `routes/`. It must not contain `.env`, `.git`, `storage/`, `vendor/`, `public/storage`, `bootstrap/cache`, symlinks, or special files. Composer manifests must exactly match the installed versions; this overlay path does not update dependencies.
- The updater downloads without following redirects, verifies exact size and SHA-256, stages and validates archive paths, backs up every overwritten file, and restores those files if application fails. It overlays files and does not remove obsolete files. The current build commit is recorded in `storage/app/private/xboard-build.json`.
- On 2026-10-05, the loopback-only endpoint and archive updater client were deployed. The client sends the configured `APP_URL` host header while connecting to loopback, avoiding aaPanel default-vhost routing. PHP syntax and route registration passed; unauthenticated loopback requests return 404. The root-managed (`root:www`, mode `750`) release directory now contains version `20261005-403604e`; local and remote manifest/archive hashes match. The prior `latest.json` is preserved in `/root/xboard-archive-client-backup-20261005/latest.json.previous`.
- Two local commits were created without pushing: `35860bfc723a17601b50e9573de325887b7aa0e2` and the loopback-host fix `403604e1fb5ad07ecf5b74c7cdfa66d0a221561b`. The clean-HEAD builder is `source/Xboard/scripts/build-private-release.sh`; the current manifest and both versioned archives are under `private-assets/xboard/releases/` and listed in `RECOVERY-SHA256SUMS.txt`.
- Both commits were subsequently pushed with authorization to the user's private `master`; the remote ref was confirmed at `403604e1fb5ad07ecf5b74c7cdfa66d0a221561b`. A full local Git bundle is also retained at `private-assets/backups/xboard-current/xboard-source-20261005.bundle`.
- The operator configured archive mode on 2026-10-05 in the protected `.env` using a locally generated token (the token is not recorded here), loopback base URL, and deployed source commit `089d838b657f12d42d1d3e3858c43a13ba12f135`. The authenticated manifest and archive download passed SHA-256/size validation; release `403604e1fb5ad07ecf5b74c7cdfa66d0a221561b` was then applied through `PrivateArchiveUpdateService`.
- The updater initially could not create work files because `storage/app/private` was root-owned and not writable by `www`. Its parent is now `root:www` mode `1770` (sticky); updater work/marker files can be created by `www`, while the root-owned release directory remains `root:www` mode `750` and cannot be replaced by `www`. Node assets retain their own existing permissions.
- Before applying the release, a source-only rollback archive was created at `/root/xboard-source-before-403604e-20261005.tar.gz`, owned by root with mode `600`, size 7,773,987 bytes, SHA-256 `1a344a383b8c0c796e064903c9c220b3a4129b23b65e7c044293dcd0371ca601`. It excludes `.env`, `.git`, `storage`, `vendor`, `public/storage`, and `bootstrap/cache`.
- Post-update checks report current/latest commit `403604e` with no update available; the local Xboard home returns HTTP 200. No client connection test, migration, Composer dependency update, installer execution, or installer-impact inspection was performed. The updater's per-file rollback staging is temporary and is deleted after success; retain the separate root-owned source archive for manual rollback.

PHP-FPM's `php.ini` has aaPanel's populated `disable_functions` list, while CLI uses a separate `php-cli.ini` with `disable_functions` unset. `putenv`, `proc_open`, `pcntl_alarm`, and `pcntl_signal` remain enabled in both SAPIs. Keep these available, especially in CLI: Laravel queue workers use PCNTL alarm/signal handling for timeouts and graceful shutdown; process execution and environment mutation are also used by PHP tooling and application dependencies. Do not copy aaPanel's FPM disable list into CLI because it disables multiple `pcntl_*` functions. FPM and CLI ini files had duplicate explicit `mbstring` loads even though this PHP build includes mbstring; those lines were removed. The duplicate `zip.so` line was removed from FPM `php.ini` while retaining one load in each SAPI. Original ini files are preserved as `php.ini.pre-20261005-ext-cleanup` and `php-cli.ini.pre-20261005-ext-cleanup`. PHP-FPM config validation and restart succeeded, and CLI modules now load without duplicate-module warnings.

Redis initially failed to start because `/usr/local/lib/libjemalloc.so.2` shadowed Ubuntu's system jemalloc under the service sandbox. Redis now has a service-specific systemd drop-in at `/etc/systemd/system/redis-server.service.d/jemalloc.conf` that prioritizes `/usr/lib/x86_64-linux-gnu`; this avoids changing global library resolution and the service passes the `PONG` health check.

### 2026-10-05 Follow-up Scope

The user chose to skip checking whether a subsequently interrupted aaPanel installer attempt affected machine1. That installer's effect remains unverified. The later narrow overlay deployment above did not inspect that effect; no processes, apt/dpkg state, or logs were checked, and no installer was executed.

During aaPanel installation pip reported a `pyOpenSSL`/`cryptography` version constraint conflict; after the official update both modules imported successfully (pyOpenSSL 26.4.0, cryptography 50.0.2).

## 2026-09-10 Clean VM Native Deployment

Verified on a new Ubuntu 22.04.5 LTS Hyper-V VM; its current DHCP address is `<vm-ip>`:

- PHP 8.2.33, PHP-FPM, Composer 2.10.3, MariaDB 10.6.23, Redis 6, and Ubuntu Nginx 1.18 are active.
- Xboard is installed at `/var/www/xboard` with MariaDB, Redis cache/session/queue, and production debug disabled.
- Nginx serves `/var/www/xboard/public` through `/run/php/php8.2-fpm.sock`.
- The home page and admin path both return HTTP 200 from the development host.
- A single `xboard-queue.service` worker and `/etc/cron.d/xboard` scheduler are enabled.
- UFW is enabled with SSH and HTTP allowed; MariaDB remains bound to loopback.

Resource note: this VM has 2 vCPU, approximately 3.8 GiB RAM, and a 48 GB root filesystem with approximately 40 GB free. It remains suitable for validation and light testing; production suitability depends on workload.

## 2026-09-09 Deployment Investigation

The project was tested on a second dedicated Ubuntu VM using three deployment approaches:

- Docker Compose deployment was exercised and later cleaned from the VM.
- Native Ubuntu deployment was exercised.
- aaPanel installation completed and its `BT-Panel` and `BT-Task` services were running.

## aaPanel Access Blocker

Verified during the test:

- aaPanel was listening on TCP port `25953`.
- UFW allowed TCP port `25953`.
- Requests reached an HTTP service, but both the panel root and authentication path returned HTTP 404.
- Docker was removed before the remaining aaPanel access problem was assessed.

Current classification: `DISCOVERED`.

The available evidence points more strongly to an aaPanel package or web-routing compatibility problem than to an Xboard deployment conflict. This is not yet `VERIFIED` because the exact aaPanel version, HTTP response headers, route configuration, and relevant panel logs have not been preserved in this workspace.

## Next Diagnostic Evidence

Before reinstalling or changing the VM, capture:

- Ubuntu release and architecture
- aaPanel version and installer source
- output of the aaPanel status/default-info commands
- listening process details for port `25953`
- HTTP status, headers, and response body for the root and authentication URLs
- recent `BT-Panel`, web server, and aaPanel error logs
- configured panel port, security entrance, bind address, and SSL state

Do not continue Xboard deployment on this VM until the aaPanel routing problem is isolated.
