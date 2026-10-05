# Ubuntu 原生安装 Xboard 教程

本教程用于在干净的 Ubuntu 22.04 LTS 服务器上，以原生方式部署 Xboard。方案使用 PHP-FPM、MariaDB、Redis 和 Nginx，不依赖 aaPanel，也不配置域名、HTTPS 或 443 端口。

## 目录

1. [环境要求](#环境要求)
2. [快速安装](#快速安装)
3. [详细配置](#详细配置)
4. [维护与备份](#维护与备份)
5. [故障排查](#故障排查)

## 环境要求

### 硬件要求

- CPU：至少 2 vCPU
- 内存：至少 2 GB，推荐 4 GB
- 磁盘：至少 20 GB，推荐 SSD
- Swap：小型验证机建议 1 GB 以上

### 软件和权限要求

- Ubuntu 22.04 LTS
- 可以使用 sudo 的部署用户
- 可用 SSH 连接
- PHP 8.2、Composer 2
- MariaDB 10.6 或兼容的 MySQL/MariaDB
- Redis 6 或兼容版本
- Nginx

同一台服务器不要同时安装 aaPanel 和另一套面板管理的 Nginx。80 端口只能由预期的 Web 服务管理。

### 本项目已验证基线

本教程来自一次真实的 Ubuntu 22.04.5 Hyper-V 验证部署，已验证的运行基线如下：

- PHP 8.2.33、Composer 2.10.3
- MariaDB 10.6.23、Redis 6
- Ubuntu Nginx 1.18、PHP-FPM
- 2 vCPU、约 3.8 GiB 内存、48 GB 根文件系统
- 首页和管理员入口均返回 HTTP 200
- Nginx、PHP-FPM、MariaDB、Redis、队列 Worker 和 cron 均为 active

版本可能随软件源更新而变化；安装后请保留实际版本输出，便于下次恢复时复现。

### 请先保存关键参数

开始安装前，请把下面的参数保存到密码管理器或加密笔记中，不要只留在终端历史里：

| 参数 | 示例 | 是否敏感 |
| --- | --- | --- |
| 服务器 IP | `<vm-ip>` | 否 |
| SSH 用户 | `code` | 否 |
| SSH 私钥位置 | 本机 `.ssh` 密钥路径 | 是 |
| 应用目录 | `/var/www/xboard` | 否 |
| 数据库名 | `xboard` | 否 |
| 数据库用户 | `xboard` | 否 |
| 数据库密码 | 自行生成的长随机密码 | 是 |
| Redis 密码 | 空或自行设置 | 是 |
| 管理员邮箱 | 自行指定 | 是 |
| 管理员路径 | 安装命令输出的随机路径 | 是 |
| Xboard 源码提交 | Git commit 或归档 SHA-256 | 否 |

管理员初始密码、数据库密码、`.env` 和数据库 dump 不要提交到 GitHub。安装结束后先修改管理员密码，再把版本、路径和备份位置补充到私有记录。

## 快速安装

### 自动化方式

仓库提供了与本教程对应的自动化脚本：

```bash
cd /tmp
curl -fsSLO https://raw.githubusercontent.com/ksr-v/Xboard-Independent/main/Xboard/docs/en/installation/ubuntu-native-install.sh
chmod 700 ubuntu-native-install.sh
sudo ./ubuntu-native-install.sh
```

脚本会安装系统依赖、创建数据库、准备 `.env`、执行 Xboard 初始化、配置 Nginx、建立队列 Worker 和定时任务，并在结束时输出需要保存的关键参数。执行前请打开脚本确认源码来源和本机策略；脚本不会替你保存管理员密码，也不会上传备份。

如果服务器不能访问 GitHub，请下载脚本后通过受控的私有渠道传输，并先验证脚本校验和。

### 1. 安装系统组件

```bash
sudo apt-get update
sudo apt-get install -y software-properties-common ca-certificates curl unzip git redis-server mariadb-server nginx
```

Ubuntu 22.04 默认源通常不提供 PHP 8.2，因此添加 PHP 软件源：

```bash
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y \
  php8.2 php8.2-cli php8.2-fpm php8.2-mysql php8.2-redis \
  php8.2-curl php8.2-mbstring php8.2-xml php8.2-zip \
  php8.2-gd php8.2-bcmath php8.2-intl
```

启用服务：

```bash
sudo systemctl enable --now mariadb redis-server nginx php8.2-fpm
```

### 2. 安装 Composer

```bash
cd /tmp
curl -fsSL https://getcomposer.org/installer -o composer-setup.php
sudo php8.2 composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm -f composer-setup.php
composer --version
```

离线恢复时，应使用私有恢复资产中的 Composer PHAR，并先验证文件校验和。

### 3. 准备 Xboard 源码

可以使用官方源码或经过审核的私有镜像。示例：

```bash
sudo mkdir -p /var/www
sudo git clone https://github.com/cedar2025/Xboard.git /var/www/xboard
sudo chown -R "$USER":"$USER" /var/www/xboard
cd /var/www/xboard
composer install --no-dev --prefer-dist --optimize-autoloader
```

如果使用私有归档包，请先验证归档校验和，再解压到 `/var/www/xboard`。Xboard-Node 不应直接放入 Xboard 面板目录，应按独立节点部署。

### 4. 创建数据库

使用长度足够且唯一的数据库密码，不要把密码写入 Git：

```bash
sudo mariadb
```

在 MariaDB 命令行中执行：

```sql
CREATE DATABASE xboard CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'xboard'@'127.0.0.1' IDENTIFIED BY '替换为随机长密码';
GRANT ALL PRIVILEGES ON xboard.* TO 'xboard'@'127.0.0.1';
FLUSH PRIVILEGES;
EXIT;
```

### 5. 配置环境并初始化

```bash
cd /var/www/xboard
cp .env.example .env
php8.2 artisan key:generate
```

编辑 `.env`，至少确认以下内容。真实密码不要提交到仓库：

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

使用 Xboard 安装命令：

```bash
php8.2 artisan xboard:install \
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

请私下保存安装输出的管理员路径和初始凭据。首次登录后立即修改管理员密码。

### 6. 配置 Nginx

创建 `/etc/nginx/sites-available/xboard`：

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name 服务器IP _;

    root /var/www/xboard/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

启用站点并测试：

```bash
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/xboard /etc/nginx/sites-enabled/xboard
sudo nginx -t
sudo systemctl restart nginx
```

### 7. 设置运行目录权限

只有运行目录需要由 Web 进程写入：

```bash
sudo chown -R www-data:www-data /var/www/xboard/storage /var/www/xboard/bootstrap/cache
sudo find /var/www/xboard/storage /var/www/xboard/bootstrap/cache -type d -exec chmod 775 {} +
sudo find /var/www/xboard/storage /var/www/xboard/bootstrap/cache -type f -exec chmod 664 {} +
cd /var/www/xboard
php8.2 artisan storage:link
php8.2 artisan optimize
```

保护 `.env`：

```bash
sudo chown "$USER":www-data /var/www/xboard/.env
sudo chmod 640 /var/www/xboard/.env
```

## 详细配置

### 队列 Worker

创建 `/etc/systemd/system/xboard-queue.service`：

```ini
[Unit]
Description=Xboard queue worker
After=redis-server.service mariadb.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/xboard
ExecStart=/usr/bin/php8.2 artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

启用 Worker：

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now xboard-queue
```

### 定时任务

创建 `/etc/cron.d/xboard`：

```cron
* * * * * www-data cd /var/www/xboard && /usr/bin/php8.2 artisan schedule:run >/dev/null 2>&1
```

### 防火墙

IP 测试部署只需放行 SSH 和 HTTP：

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw --force enable
sudo ufw status
```

不要把 MariaDB 或 Redis 暴露到公网；默认应只监听本机地址。

### 部署验证

```bash
sudo systemctl is-active nginx php8.2-fpm mariadb redis-server xboard-queue cron
curl -I http://服务器IP/
curl -I http://服务器IP/管理员路径
```

首页和管理员入口应返回：

```text
HTTP/1.1 200 OK
```

然后用浏览器分别验证普通用户和管理员登录。不要把真实凭据粘贴到 issue、聊天记录或 Git 提交中。

## 维护与备份

### 日常检查

```bash
sudo systemctl status nginx php8.2-fpm mariadb redis-server xboard-queue --no-pager
cd /var/www/xboard
php8.2 artisan about
sudo tail -n 100 storage/logs/laravel-$(date +%F).log
```

持续关注磁盘、内存、队列 Worker、数据库增长和 Laravel 日志。至少保留一份 VM 外部的加密备份。

### 备份

数据库、应用归档和 `.env` 应分别保存：

```bash
sudo mkdir -p /var/backups/xboard-current
sudo mariadb-dump --single-transaction --routines --events xboard > /var/backups/xboard-current/xboard.sql
sudo tar --exclude=/var/www/xboard/vendor --exclude=/var/www/xboard/storage/logs \
  -czf /var/backups/xboard-current/xboard-app.tar.gz -C /var/www xboard
sudo cp /var/www/xboard/.env /var/backups/xboard-current/xboard.env
sudo sha256sum /var/backups/xboard-current/* > /var/backups/xboard-current/SHA256SUMS
```

将备份加密后复制到其他电脑或私有云盘。绝不要公开 `xboard.env` 或数据库 dump。

### 更新边界

更新前应当：

1. 导出数据库备份。
2. 记录当前 Git 提交或源码归档校验和。
3. 阅读上游迁移说明和版本说明。
4. 按需要启用维护模式。
5. 根据锁定文件更新依赖。
6. 执行迁移和 `php8.2 artisan optimize`。
7. 代码或配置变化后重启队列 Worker 和 PHP-FPM。
8. 重新验证首页、管理员入口和普通用户登录。

不要在生产工作树上盲目执行 `git reset --hard`。

## 故障排查

### Nginx 返回 404 或默认页面

- 确认站点根目录是 `/var/www/xboard/public`。
- 执行 `sudo nginx -t`。
- 确认 `/etc/nginx/sites-enabled/default` 已删除。
- 确认 80 端口由预期的 Nginx 进程监听。

### PHP-FPM 报错

- 确认 `/run/php/php8.2-fpm.sock` 存在。
- 检查 `sudo systemctl status php8.2-fpm`。
- 检查 Laravel 和 Nginx 错误日志。
- 确认 `storage` 和 `bootstrap/cache` 可由 `www-data` 写入。

### 数据库连接失败

- 确认 MariaDB 正常运行并监听 `127.0.0.1:3306`。
- 核对 `.env` 中数据库名、用户和密码。
- 使用专用数据库用户测试，不要依赖 Ubuntu 的 socket root 认证。
- 修改 `.env` 后执行 `php8.2 artisan optimize:clear`，再执行 `php8.2 artisan optimize`。

### Redis 或队列失败

- 执行 `redis-cli ping`，应返回 `PONG`。
- 检查 `sudo systemctl status redis-server xboard-queue`。
- 查看 Laravel 日志中的 Redis 连接或权限错误。
- 应用配置变化后重启队列 Worker。

### 管理后台空白

- 确认 `public/assets/admin` 下存在管理端静态资源。
- 必要时从私有恢复资产恢复经过审核的管理端资源。
- 清理并重建 Laravel 缓存。
- 检查浏览器控制台和服务器日志。

## 范围说明

本教程对应已验证的 Ubuntu 原生 IP 部署路线。域名、HTTPS、DNS、aaPanel 和暂缓的 clean-room 恢复演练不属于当前阶段。
