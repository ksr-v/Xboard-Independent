# Xboard-Node Deployment Record

Status: VERIFIED (machine-mode control plane and Shadowsocks socket; client traffic pending)

## 2026-10-05 Machine 2 Integration Test

Xboard-Node was deployed to VMware machine 2 at `<node-host>` and connected to the Xboard panel on machine 1 at `http://<panel-host>`.

Machine 2 baseline:

- Hostname: `machine2`
- OS: Ubuntu 24.04.3 LTS, amd64
- Resources: 2 vCPU, 3.8 GiB RAM, 24 GB root filesystem
- It was clean before this test; no previous `/etc/xboard-node` configuration or node binary was present.

Deployment used the existing private v1.13 release artifacts, not a new build or the upstream raw installer:

- `xboard-node-linux-amd64`, SHA-256 `55bf71fa9d9f2048d3255ae7c0af929a41897ca7743f6ead34132a6ca4c79043`
- `xbctl-linux-amd64`, SHA-256 `8ec7b9bbf0abb99a9c24b1b3ceef1ed5496f458e7dc22b09c33b098d5b2aad9e`
- Private installer `install.sh`, SHA-256 `d0323e37dfbb24fd34efa62cdb96b0f3c5594791d0a50f6f4f66af6f570dad8e`

The installer copy uploaded from Windows initially had CRLF line endings, which Bash rejected. Line endings were normalized on the temporary machine-2 copy; the repository installer was not changed. Installation then completed in machine mode with Xboard machine ID `1`. The machine token is stored only in `/etc/xboard-node/credentials.env` with mode `600`; configuration is also mode `600`. Neither token nor credentials are recorded here.

Verified:

- `/usr/local/bin/xboard-node` and `/usr/local/bin/xbctl` both report v1.13.
- `xboard-node.service` is active and enabled, with zero restarts.
- Local health endpoint `http://127.0.0.1:65530/healthz` returns `{"status":"ok"}`.
- `xbctl list` reports a healthy machine-mode instance targeting `http://<panel-host>`, machine ID `1`.
- Xboard's server record `machine2` (SID `1`) changed from “never reported” to online and displayed a recent heartbeat.
- The latest Xboard server detail view reports a recent heartbeat, CPU 1%, memory 12%, and disk usage 6.49 GB / 23.45 GB.
- Xboard-Node logs report that the panel has WebSocket disabled, so this test is using REST control-plane polling.
- Xboard node ID `1` (`machine2-ss-smoke`) is enabled, bound to machine SID `1`, and configured as Shadowsocks (`aes-128-gcm`) on `<node-host>:24680`.
- The preserved release folder contains v1.13 node and xbctl binaries. For orphan-managed installs, use independent `xbctl` v1.13-orphan.1 builds under `private-assets/xboard-node/orphan-builds/2026-10-05/` instead of the old release xbctl; original release artifacts remain unchanged.
- A temporary permission group `machine2-ss-smoke`, zero-price 1 GB test plan, and eligible test user ID `2` (`<test-user-email>`) were created. The node is assigned to that group; no user password or machine credential is recorded here.
- The first node startup had zero eligible users and logged `kernel will not start until users are available`; no data-plane socket opened. After the group and test user were in place, restarting `xboard-node.service` produced an initial snapshot with one user and a successful Shadowsocks start.
- `ss -lntup` on machine 2 shows TCP `LISTEN` and UDP `UNCONN` on `*:24680`; the health endpoint remains on `*:65530`. UFW was inactive and no firewall rules were added.

Scope boundary: machine-to-panel control-plane registration, node discovery, and the Shadowsocks data-plane socket are verified. The user chose to skip actual encrypted client traffic and subscription-flow testing; those behaviors remain unverified. The temporary test node, user, plan, and group are retained. This is a normal Xboard-Node deployment test only; no independent/recovery redesign work was performed.

## 2026-10-05 Clean-State Reinstall Confirmation

After machine2 was restored to a clean state, the user reported that the machine-mode node deployment completed normally against the Xboard server record SID 1. The user ended validation at that point. This is user-reported confirmation; no additional machine2 inspection was performed. Encrypted client traffic and subscription flow remain intentionally untested.

Next project step: continue with separately authorized project work. Do not treat client traffic or subscription behavior as verified; do not remove the retained test fixtures without instruction.
