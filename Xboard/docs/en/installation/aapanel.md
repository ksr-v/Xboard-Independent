# Xboard aaPanel 部署教程

本教程用于在干净的 Ubuntu 24.04 LTS 内网服务器上，通过 aaPanel 软件中心部署独立维护的 Xboard。当前验证环境为 Ubuntu 24.04.3、aaPanel 8.0.6、Nginx 1.30.5、PHP 8.3.33、MariaDB 10.11.10 和 Redis 7.0.15。

本教程默认使用内网 IP，不验证公网 IP 证书、域名、DNS 或 443 公网访问。

## 目录

1. [环境要求](#环境要求)
2. [安装 aaPanel](#安装-aapanel)
3. [安装运行环境](#安装运行环境)
4. [创建网站和数据库](#创建网站和数据库)
5. [部署 Xboard](#部署-xboard)
6. [配置站点和运行任务](#配置站点和运行任务)
7. [验证部署](#验证部署)
8. [维护与故障排查](#维护与故障排查)

## 环境要求

### 硬件

- CPU：至少 2 vCPU
- 内存：至少 2 GB，推荐 4 GB
- 磁盘：至少 30 GB，推荐 40 GB
- Swap：建议 2 GB
- 静态内网 IP：使用自己的内网地址，例如 `192.168.1.10`

### 系统

- Ubuntu 24.04 LTS（在 24.04.3 上验证）
- SSH 用户具备免密 sudo
- 干净系统，不预装 Nginx、Apache、PHP、MariaDB、Redis、Docker 或其他面板
- 80、aaPanel 实际配置的面板端口及 SSH 端口可访问

### 重要边界

- aaPanel 会接管 Web 服务、PHP、数据库和软件安装任务，不要在同一台机器上混装另一套面板。
- 本教程使用 aaPanel PHP 8.3 作为实际验证版本。Xboard native 路线使用 PHP 8.2，两条路线不要混淆。
- Xboard 源码必须从本项目私有发布资产取得；不要从 cedar2025 仓库、release 或 raw 安装脚本下载。
- 本教程的源码归档不含 `vendor`。`init.sh` 会运行 Composer `self-update` 和 `composer install`，需要访问 Composer/Packagist 公共基础设施；干净环境离线安装尚未验证。
- 私有归档更新端点只接受部署该端点的服务器本机 loopback 请求。外部测试服务器可以用私有源码归档安装，但不能用 `127.0.0.1` 指向其他主机；只有在目标机也部署了受保护的更新端点后，才启用 archive 更新模式。
- 本教程不验证公网证书。内网访问通常使用 aaPanel 自签名证书，浏览器需要手动接受证书警告。
- 安装完成后请保存面板地址、面板安全入口、面板用户名、面板密码、数据库 root 密码和 Xboard 管理员信息。

## 安装 aaPanel

### 1. 下载官方脚本

在 Windows PowerShell 连接服务器：

```powershell
ssh -tt codex@服务器IP
```

在 Ubuntu 中执行：

```bash
cd /tmp
curl -4 -fL --retry 3 --retry-delay 2 \
  --connect-timeout 15 --max-time 120 \
  https://www.aapanel.com/script/install_6.0_en.sh \
  -o install_6.0_en.sh
```

建议确认脚本已下载且大小合理：

```bash
wc -c install_6.0_en.sh
head -n 3 install_6.0_en.sh
```

### 2. 交互式安装

使用带 TTY 的 SSH 执行：

```bash
sudo bash /tmp/install_6.0_en.sh aapanel
```

出现以下提示时，由用户亲自输入 `y`：

```text
Do you want to install aaPanel to the /www directory now?(y/n):
```

不要在同一台 VM 上重复启动多个 aaPanel 安装脚本。安装期间 aaPanel 会占用 apt/dpkg 锁，这是正常现象；不要手动删除 `/var/lib/dpkg/lock`。

非交互自动化方式也可以使用：

```bash
printf 'y\n' | sudo bash /tmp/install_6.0_en.sh aapanel
```

### 3. 保存面板信息

安装完成后记录脚本输出的内容：

```text
aaPanel 内网地址
面板端口
安全入口路径
用户名
密码
```

也可以在服务器上查看端口和安全入口：

```bash
sudo cat /www/server/panel/data/port.pl
sudo cat /www/server/panel/data/admin_path.pl
```

内网访问示例：

```text
https://服务器IP:37090/安全入口
```

使用自签名证书时，在浏览器中选择“高级”并继续访问。

## 安装运行环境

登录 aaPanel 后打开软件商店，按顺序安装：

- Nginx 1.30.5 或兼容版本
- PHP 8.3.33
- MariaDB 10.11.10
- phpMyAdmin 可选

本项目验证环境使用 Ubuntu Redis 7.0.15，而不是 aaPanel 软件商店中的 Redis。新环境可使用 aaPanel Redis 或系统 Redis 7.x，但建议只绑定 loopback，并确认 PHP CLI 与 FPM 都启用匹配的 phpredis 扩展。

本项目实际验证中，aaPanel 软件队列需要通过“消息盒子”查看。如果任务全部显示 `waiting`，点击 aaPanel 的 `Restart` 让任务队列开始执行。

### 1. PHP 8.3 扩展

在 aaPanel 的 PHP 8.3 设置中安装或确认以下扩展：

- curl
- fileinfo
- mbstring
- openssl
- PDO
- pdo_mysql
- zip
- gd
- bcmath
- intl
- pcntl
- redis / phpredis

Xboard 使用 Redis 时必须确认 PHP CLI 和 PHP-FPM 都加载了 `redis` 扩展。检查 aaPanel PHP CLI：

```bash
/www/server/php/83/bin/php -m | grep redis
/www/server/php/83/bin/php -v
```

如果 aaPanel PHP 8.3 没有 phpredis，可以使用 PECL 或从官方 phpredis 源码编译。扩展目录通常为：

```text
/www/server/php/83/lib/php/extensions/no-debug-non-zts-20230831/
```

配置完成后重启 aaPanel PHP-FPM：

```bash
sudo /etc/init.d/php-fpm-83 restart
```

### 2. 服务检查

```bash
ps -ef | grep BT-Panel | grep -v grep
ps -ef | grep BT-Task | grep -v grep
ps -ef | grep php-fpm | grep -v grep
redis-cli ping
ss -ltn
```

Redis 应返回：

```text
PONG
```

MariaDB 应监听本机或受控内网地址的 `3306`，Redis 建议只监听 `127.0.0.1:6379`。

## 创建网站和数据库

### 1. 创建网站

在 aaPanel 中进入：

```text
aPanel → Website → Add site
```

填写：

- Domain：内网 IP，例如 `192.168.1.10`
- Root directory：`/www/wwwroot/xboard/public`
- PHP version：PHP 8.3
- Database：可先不自动创建，后续手动创建更容易核对权限

如果 aaPanel 不能使用内网 IP 创建站点，可先创建一个内部占位域名，并在 Nginx vhost 中确认 `root` 指向 Xboard 的 `public` 目录。

### 2. 创建数据库

可以在 aaPanel 数据库页面创建，也可以使用 root 密码通过命令行创建：

```bash
sudo mariadb -uroot -p
```

执行：

```sql
CREATE DATABASE xboard CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'xboard'@'127.0.0.1' IDENTIFIED BY '替换为随机长密码';
GRANT ALL PRIVILEGES ON xboard.* TO 'xboard'@'127.0.0.1';
FLUSH PRIVILEGES;
EXIT;
```

aaPanel 安装 MariaDB 后，Ubuntu 默认的 `sudo mariadb` socket 认证可能不再适用；请使用 aaPanel 输出或设置的 root 密码，不要反复尝试无密码 root 登录。

## 部署 Xboard

### 0. 获取并校验私有源码归档

在受信任的 Windows 工作站从项目私有恢复资产读取发布清单和对应归档。不要从历史上游仓库下载源码。以下示例会按 `latest.json` 选择当前发布，并在上传前检查大小和 SHA-256：

```powershell
$releaseRoot = 'C:\path\to\private-xboard-releases'
$manifest = Get-Content (Join-Path $releaseRoot 'latest.json') -Raw | ConvertFrom-Json
$archive = Join-Path (Join-Path (Join-Path $releaseRoot 'releases') $manifest.version) 'xboard.tar.gz'
$actualHash = (Get-FileHash $archive -Algorithm SHA256).Hash.ToLower()
$actualSize = (Get-Item $archive).Length
if ($actualHash -ne $manifest.sha256 -or $actualSize -ne [int64]$manifest.size) {
  throw 'Release archive failed manifest integrity validation.'
}
"Version=$($manifest.version) Size=$actualSize SHA256=$actualHash"
scp $archive "codex@服务器IP:/tmp/xboard-source.tar.gz"
```

`latest.json` 指向当前发布；以后发布更新时应以清单中的版本和校验值为准。通过受保护的 SSH/SCP 通道传输；不要把 `.env`、token 或数据库密码放入归档或命令行。

### 1. 上传并解压

确认 `/www/wwwroot/xboard` 是新建的空目录；不要将安装归档解压覆盖现有实例。先在 Windows 输出中记录 SHA-256，再在服务器核对：

```bash
sha256sum /tmp/xboard-source.tar.gz
tar -tzf /tmp/xboard-source.tar.gz | head
sudo install -d -o www -g www -m 0755 /www/wwwroot/xboard
sudo tar -xzf /tmp/xboard-source.tar.gz --no-same-owner -C /www/wwwroot/xboard
sudo chown -R www:www /www/wwwroot/xboard
```

服务器上的哈希必须与工作站清单中的 `sha256` 完全一致。该源码 overlay 包含已 vendored 的 Admin 静态文件，但不含 `.git`、真实 `.env`、`storage`、`vendor` 或 `bootstrap/cache`；它不是完整应用/数据库备份。

### 2. 运行一次初始化

在数据库和 aaPanel 网站准备完成后，推荐使用归档自带的一键初始化脚本：

```bash
cd /www/wwwroot/xboard
sudo -u www env XBOARD_PHP_BIN=/www/server/php/83/bin/php sh init.sh
```

脚本会安装 Composer 依赖、创建 `.env`/应用密钥、交互询问数据库信息并运行 `xboard:install`，随后建立 storage 链接并优化 Laravel 配置。它不会创建 MariaDB 数据库/用户，也不会配置 aaPanel vhost；这些必须先手动完成。数据库密码通过脚本的隐藏交互提示输入，不要把密码写在命令参数或 shell history 中。

注意：`init.sh` 会运行 Composer `self-update --stable`，然后按 `composer.lock` 安装依赖；这需要访问 Composer/Packagist 公共基础设施。若外部测试机不能访问这些公共依赖，停止安装，不要声称该流程支持完全离线恢复。Composer lock 与 manifest 的兼容性问题仍在恢复清单中跟踪。

一键初始化成功后，不要再重复执行下面手工初始化步骤中的 Composer 安装、`.env` 生成或 `xboard:install`。若要手工执行，按后续步骤逐项操作并跳过一键脚本。

#### 更新器与 Node 安装资产

归档更新端点只接受部署该端点的服务器本机 loopback 请求。若应用安装在另一台服务器，`http://127.0.0.1/private-xboard-updates` 会指向该服务器自身。只有在目标机也部署了归档端点和对应发布文件后，才在其受保护 `.env` 中设置 archive 更新模式、loopback URL、随机 token，以及与所装归档匹配的完整 `XBOARD_BUILD_COMMIT`。token 只在服务器本地生成/保存，不要放入命令行、Git 或聊天。

归档包本身不包含 Node 二进制。若要在新 Xboard 实例中使用面板的一键 Node 安装命令，还需从受保护的私有恢复资产中单独取得 installer、目标 CPU 架构的 Node 二进制和独立维护版 `xbctl`，放入 `storage/app/private/node-installer` 并设置为 `www:www` 可读/可执行。未完成此步骤时，Xboard 核心面板仍可安装运行，但生成的机器安装命令不可用。

### 3. 手工安装 Composer 依赖（仅手工流程）

只有在没有运行 `init.sh` 时才执行。使用 aaPanel PHP 8.3：

```bash
cd /www/wwwroot/xboard
/www/server/php/83/bin/composer install --no-dev --prefer-dist --optimize-autoloader
```

如果 Composer 不在 aaPanel PHP 目录，确认使用 Composer 2，并显式调用 PHP 8.3：

```bash
/www/server/php/83/bin/php /usr/local/bin/composer install --no-dev --prefer-dist --optimize-autoloader
```

### 4. 配置 `.env`（仅手工流程）

```bash
cd /www/wwwroot/xboard
cp .env.example .env
/www/server/php/83/bin/php artisan key:generate
```

设置：

```dotenv
APP_ENV=production
APP_DEBUG=false
APP_URL=http://服务器IP
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=xboard
DB_USERNAME=xboard
DB_PASSWORD=数据库密码
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
```

### 5. 执行 Xboard 初始化（仅手工流程）

```bash
/www/server/php/83/bin/php artisan xboard:install \
  --database=mysql \
  --db-host=127.0.0.1 \
  --db-port=3306 \
  --db-name=xboard \
  --db-user=xboard \
  --db-password='数据库密码' \
  --redis-host=127.0.0.1 \
  --redis-port=6379 \
  --redis-password= \
  --no-interaction
```

保存命令输出的：

- 管理员邮箱
- 管理员初始密码
- 管理员安全路径

首次登录后立即修改管理员密码。

## 配置站点和运行任务

### 1. Nginx 站点

aaPanel 创建站点后，确认站点 Nginx 配置包含：

```nginx
root /www/wwwroot/xboard/public;

location / {
    try_files $uri $uri/ /index.php?$query_string;
}

location ~ \.php$ {
    try_files $uri =404;
    include fastcgi_params;
    fastcgi_pass unix:/tmp/php-cgi-83.sock;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```

不要让 aaPanel 默认的 `0.default.conf` 抢占 `80 default_server`。如果访问首页显示“website has been stopped”，检查站点加载顺序和默认 vhost。

### 2. 权限和缓存

```bash
sudo chown -R www:www /www/wwwroot/xboard
sudo chown -R www:www /www/wwwroot/xboard/storage /www/wwwroot/xboard/bootstrap/cache
sudo chmod -R ug+rwX /www/wwwroot/xboard/storage /www/wwwroot/xboard/bootstrap/cache
cd /www/wwwroot/xboard
/www/server/php/83/bin/php artisan storage:link
/www/server/php/83/bin/php artisan optimize
```

### 3. 队列 Worker

如果 aaPanel 队列统计不能识别自定义 Worker，可以创建 systemd 服务：

```ini
[Unit]
Description=Xboard aaPanel queue worker
After=network.target

[Service]
Type=simple
User=www
Group=www
WorkingDirectory=/www/wwwroot/xboard
ExecStart=/www/server/php/83/bin/php artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

保存为 `/etc/systemd/system/xboard-aapanel-queue.service`，然后执行：

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now xboard-aapanel-queue
sudo systemctl status xboard-aapanel-queue --no-pager
```

添加 Laravel scheduler：

```cron
* * * * * www cd /www/wwwroot/xboard && /www/server/php/83/bin/php artisan schedule:run >/dev/null 2>&1
```

保存到 `/etc/cron.d/xboard-aapanel`。

## 验证部署

本教程按当前项目范围只验证内网 IP，不验证公网证书。

### 1. 服务验证

```bash
ps -ef | grep BT-Panel | grep -v grep
ps -ef | grep BT-Task | grep -v grep
ps -ef | grep php-fpm | grep -v grep
redis-cli ping
ss -ltn
```

### 2. HTTP 验证

```bash
curl -I http://服务器IP/
curl -I http://服务器IP/管理员路径
```

首页和管理员入口应返回：

```text
HTTP/1.1 200 OK
```

### 3. 管理员验证

使用安装输出的管理员信息访问：

```text
http://服务器IP/管理员路径
```

确认可以：

- 登录后台
- 看到 Dashboard
- 打开系统配置
- 查看用户管理
- 查看节点管理
- 查看套餐管理

普通用户登录、节点联调和公网证书不属于本次教程的强制验证项。

## 维护与故障排查

### apt 被占用

aaPanel 安装软件时会启动 apt/dpkg 子进程。不要删除锁文件，也不要同时启动第二个安装任务：

```bash
sudo fuser -v /var/lib/dpkg/lock
ps -ef | grep apt
```

等待当前 aaPanel 任务结束即可。

### 软件任务全部 waiting

打开 aaPanel 消息盒子，点击 `Restart` 重新启动任务队列。确认没有其他 apt/dpkg 进程后再操作。

### PHP 报 `Class Redis not found`

这表示 PHP-FPM 使用的 PHP 8.3 没有加载 phpredis。确认 CLI 和 FPM 使用同一个 aaPanel PHP 运行时，并检查：

```bash
/www/server/php/83/bin/php -m | grep redis
```

安装扩展后重启：

```bash
sudo /etc/init.d/php-fpm-83 restart
```

### 首页显示“website has been stopped”

通常是 aaPanel 默认 vhost 抢占 80 端口。检查：

```bash
sudo nginx -T
sudo ss -ltnp | grep ':80'
```

确认 Xboard 站点 root 为 `/www/wwwroot/xboard/public`，并禁用冲突的默认 vhost。

### aaPanel 证书警告

内网 IP 使用自签名证书时，浏览器出现证书警告是预期现象。当前不申请公网证书，也不验证公网 HTTPS。

### 备份

至少保存以下内容到 VM 外部的加密位置：

- `/www/wwwroot/xboard/.env`
- Xboard 数据库 dump
- `/www/wwwroot/xboard` 应用归档
- aaPanel 安全入口、面板账号和密码
- PHP、Nginx、MariaDB、Redis 的实际版本

不要把 `.env`、数据库 dump 或管理员密码提交到 GitHub。

## 当前验证范围

本项目已验证 aaPanel 登录、软件中心、PHP 8.3、MariaDB、Redis、phpredis、Xboard 初始化、首页和管理员入口。普通用户登录、节点/用户/套餐页面、公网证书和 clean-room 恢复演练可以按项目安排跳过或延期。
