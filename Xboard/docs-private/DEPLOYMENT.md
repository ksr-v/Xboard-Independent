# Xboard Deployment Record

Status: VERIFIED (native Ubuntu deployment)

## Current VM Status

The native validation VM was deleted by the user on 2026-09-10 after the deployment, expansion, and functional checks were completed. No project VM is currently active. A future aaPanel verification requires a new dedicated clean VM; do not reuse this status as evidence that aaPanel has passed.

## 2026-09-11 aaPanel Verification Attempt

A dedicated clean Ubuntu 22.04.5 Hyper-V VM was prepared for aaPanel verification at `172.19.73.87`:

- 2 vCPU and 3.8 GiB RAM were verified after the user corrected the VM memory allocation.
- The 30 GB disk was expanded to a 28 GB root filesystem with approximately 21 GB free.
- The static IP configuration was normalized by removing the conflicting cloud-init DHCP netplan file.
- No Nginx, MariaDB, Redis, Docker or other panel service was present before testing.

The official aaPanel installer was attempted twice. The first attempt timed out while downloading the installer; the second download succeeded and returned a 90,940-byte script, but the installer then remained alive for approximately five minutes without creating `/www/server/panel`, starting a panel service, or opening its advertised port (`25628`). The process was stopped and the VM was confirmed clean afterward.

Current classification: `DISCOVERED` failure, not a successful aaPanel deployment. GitHub and aaPanel endpoints both returned HTTP 200 during the network comparison, so the second attempt's failure was not explained by general outbound connectivity.

The interactive retry later completed the aaPanel installation and created the panel service, internal web server, Unix socket, and port `37090`. However, both the public security path and direct local requests returned HTTP 404. The aaPanel error log also recorded a Flask `TypeError` for the login view during an earlier `HEAD` request. The official repair command reported that version `3.1` was already current, but the login path remained 404 after repair. Therefore aaPanel installation is present, but aaPanel login verification failed and Xboard deployment was not started on this VM.

## 2026-09-10 Clean VM Native Deployment

Verified on a new Ubuntu 22.04.5 LTS Hyper-V VM; its current DHCP address is `172.19.68.133`:

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
