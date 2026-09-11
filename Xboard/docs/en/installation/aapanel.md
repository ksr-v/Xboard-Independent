# Xboard aaPanel 部署教程

本教程用于在干净的 Ubuntu 22.04 LTS 内网服务器上，通过 aaPanel 软件中心部署 Xboard。教程结构参考官方 aaPanel 安装指南，但命令、目录和验证步骤结合本项目实际测试结果整理。

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
- 静态内网 IP：示例为 `172.19.73.87`

### 系统

- Ubuntu 22.04.5 LTS
- SSH 用户具备免密 sudo
- 干净系统，不预装 Nginx、Apache、PHP、MariaDB、Redis、Docker 或其他面板
- 80、37090 等需要的内网端口可访问

### 重要边界

- aaPanel 会接管 Web 服务、PHP、数据库和软件安装任务，不要在同一台机器上混装另一套面板。
- 本教程使用 aaPanel PHP 8.3 作为实际验证版本。Xboard native 路线使用 PHP 8.2，两条路线不要混淆。
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

- Nginx 1.30 或兼容版本
- PHP 8.3
- MariaDB 10.11 或兼容版本
- Redis 7.2
- phpMyAdmin 可选

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

- Domain：内网 IP，例如 `172.19.73.87`
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

### 0. 一键安装入口

源码目录中的 `init.sh` 已支持官方教程式的一键安装，同时兼容源码归档部署。重新打包自定义源码后，使用归档中的脚本：

```bash
cd /www/wwwroot/xboard
sh init.sh
```

归档校验和建议在上传前保存：

```powershell
Get-FileHash .\xboard-custom-test.tar.gz -Algorithm SHA256
```

脚本会自动：

- 选择 aaPanel PHP 8.3、PHP 8.2 或系统 PHP
- 安装 Composer 依赖
- 如果是 Git 工作树且管理端资源缺失，更新 Git submodule
- 如果归档已经包含 `public/assets/admin/index.html`，跳过 submodule
- 创建 `.env` 并生成应用密钥
- 执行 Xboard 初始化
- 建立 storage 链接并缓存 Laravel 配置
- 输出需要保存的管理员路径和初始密码

源码归档没有 `.git` 时，不能直接依赖 `git submodule update`；本项目的脚本会根据管理端资源是否存在自动选择路径。当前归档内已经包含 `public/assets/admin/index.html`，因此会跳过 submodule 更新。

如果需要完全非交互运行，请先设置数据库密码：

```bash
export XBOARD_DB_PASSWORD='替换为数据库密码'
export XBOARD_NON_INTERACTIVE=1
sh init.sh
```

如果不设置数据库参数，`init.sh` 会在终端交互询问：

```text
Database name [xboard]:
Database user [输入的数据库名]:
Database password for 输入的数据库用户:
```

数据库名直接回车默认使用 `xboard`，数据库用户直接回车默认使用数据库名；数据库密码使用隐藏输入且不能为空。脚本会在初始化前执行 `php artisan optimize:clear`，避免旧的 Laravel 配置缓存继续使用空密码。

也可以显式指定 PHP：

```bash
XBOARD_PHP_BIN=/www/server/php/83/bin/php sh init.sh
```

一键脚本不会自动创建 MariaDB 数据库用户，不会配置 aaPanel 网站 vhost，也不会替你保存管理员密码。运行前必须先完成本教程中的数据库和网站准备步骤。

### 1. 上传源码

在本地准备官方源码或经过审核的私有归档，然后上传到：

```text
/www/wwwroot/xboard
```

示例：

```bash
cd /www/wwwroot
sudo tar -xzf /path/to/xboard.tar.gz
sudo chown -R www:www /www/wwwroot/xboard
```

### 2. 安装 Composer 依赖

使用 aaPanel PHP 8.3：

```bash
cd /www/wwwroot/xboard
/www/server/php/83/bin/composer install --no-dev --prefer-dist --optimize-autoloader
```

如果 Composer 不在 aaPanel PHP 目录，确认使用的是 Composer 2，并显式调用 PHP 8.3：

```bash
/www/server/php/83/bin/php /usr/local/bin/composer install --no-dev --prefer-dist --optimize-autoloader
```

### 3. 配置 `.env`

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

### 4. 执行 Xboard 初始化

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
