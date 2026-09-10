# Xboard Deployment Record

Status: VERIFIED (native Ubuntu deployment)

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
