# Private Changelog

## 2026-10-05

- Added geo-data local fallback (commit fea5732, pushed to the private Node repo): missing geo databases are copied from XBOARD_GEO_DATA_SOURCE or /usr/local/share/xboard-node/geo-data before any download. Created the offline Go vendor archive private-assets/xboard-node/go-vendor-fea5732.zip (SHA256 904779a08edefd57b24fa66e303f1134fad2e65e8d20dd5f333db22eb7749a3a); go build -mod=vendor ./... passed. Runtime tests of the fallback are not performed.
- Began independent orphan maintenance by removing the official Git remote, pinning installer metadata to v1.13-orphan.1, requiring local binaries or an explicitly supplied private download base, updating the installer README, and publishing CI images under the repository's current owner. The saved local installer was refreshed and its recovery checksum updated. The user's pre-existing README code-fence fix was preserved.
- Rebuilt `xbctl` for Linux amd64/arm64 as v1.13-orphan.1 with `GOPROXY=off` and `GOSUMDB=off`; saved both checksummed artifacts separately from the original v1.13 release files. Xboard's generated install command now requests the orphan CLI version.
- Deployed the existing private Xboard-Node v1.13 amd64 release to clean VMware machine2 (`<node-host>`) in machine mode and connected it to Xboard machine1 (`<panel-host>`, SID 1). The service is active, its local health endpoint returns `status: ok`, and machine1 reports a recent online heartbeat. This verifies control-plane connectivity only; machine2 has discovered zero nodes and no data-plane/user-traffic test was performed. No independent/recovery redesign work was done.
- Added Xboard node ID 1 (`machine2-ss-smoke`), permission group `machine2-ss-smoke`, and an eligible one-user test fixture. Empty users prevented kernel startup; after restarting the service with the fixture configured, logs confirmed one Shadowsocks user and `ss` confirmed TCP and UDP sockets on port 24680. Actual client traffic remains untested; no firewall rules were added.

## 2026-09-10

- Verified the complete existing Go test suite on Windows with Go 1.26.5; all packages passed.
- Corrected the unclosed systemd installer code block in the working README.
- Downloaded all four v1.13 Linux release binaries for amd64 and arm64 and verified them against the SHA256 digests in the official release metadata.
