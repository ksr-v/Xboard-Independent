# Xboard Disaster Recovery Record

## Current Verified Backup

The clean validation VM has a local backup at:

`/var/backups/xboard-current/`

Contents:

- `xboard.sql`: MariaDB dump of the `xboard` database.
- `xboard-app.tar.gz`: application archive excluding `vendor` and runtime logs.
- `xboard.env`: production environment file; treat as secret material.
- `SHA256SUMS`: checksums for the three recovery files.

The backup was created on 2026-09-10 and verified with `sha256sum -c`. The directory and files are root-only readable.

## Restore Outline

1. Install the pinned PHP, PHP-FPM, MariaDB, Redis, Nginx, and Composer runtime.
2. Restore `xboard-app.tar.gz` into `/var/www/xboard`.
3. Restore `xboard.env` with mode `640` and owner `code:www-data`.
4. Create the `xboard` database and grant the application database user access.
5. Restore `xboard.sql` into the database.
6. Restore `storage` and `bootstrap/cache` ownership to `www-data`.
7. Recreate the Nginx site, queue worker, scheduler, and UFW rules.
8. Run `php8.2 artisan optimize`, then verify the home and admin paths over the IP address.

## Limitations

- This is a local VM backup only; it is not an off-host or offsite backup.
- The current VM has approximately 40 GB free disk after expansion. Its DHCP address may change after reboot.
- Domain and HTTPS recovery are intentionally out of scope for the current project phase.

## Deferred Recovery Rehearsal

The clean-room restore rehearsal is intentionally deferred at the user's request. Do not run it during the current phase. Before declaring the overall project fully complete, remind the user that this rehearsal remains pending and ask whether to perform it.
