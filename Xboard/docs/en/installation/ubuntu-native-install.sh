#!/usr/bin/env bash
set -Eeuo pipefail

# Xboard Ubuntu native installer. Review this file before execution.

if [[ "${EUID}" -ne 0 ]]; then
  echo "请使用 sudo 运行此脚本。"
  exit 1
fi

read -r -p "服务器 IP 或访问地址: " SERVER_IP
read -r -p "Xboard 源码地址 [https://github.com/cedar2025/Xboard.git]: " SOURCE_URL
SOURCE_URL="${SOURCE_URL:-https://github.com/cedar2025/Xboard.git}"
read -r -p "源码分支或标签 [master]: " SOURCE_REF
SOURCE_REF="${SOURCE_REF:-master}"
read -r -p "应用目录 [/var/www/xboard]: " APP_DIR
APP_DIR="${APP_DIR:-/var/www/xboard}"

DB_NAME="xboard"
DB_USER="xboard"
DB_PASSWORD="$(openssl rand -hex 24)"
INSTALL_LOG="/root/xboard-install-$(date +%Y%m%d-%H%M%S).log"

cat <<SUMMARY

请确认安装参数：
  访问地址: ${SERVER_IP}
  源码地址: ${SOURCE_URL}
  源码版本: ${SOURCE_REF}
  应用目录: ${APP_DIR}
  数据库名: ${DB_NAME}
  数据库用户: ${DB_USER}
  安装日志: ${INSTALL_LOG}

数据库密码会在安装完成后输出一次，请立即保存到密码管理器。
SUMMARY
read -r -p "继续安装? [y/N] " CONFIRM
[[ "${CONFIRM}" =~ ^[Yy]$ ]] || { echo "已取消。"; exit 0; }

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y software-properties-common ca-certificates curl unzip git openssl redis-server mariadb-server nginx
add-apt-repository -y ppa:ondrej/php
apt-get update
apt-get install -y \
  php8.2 php8.2-cli php8.2-fpm php8.2-mysql php8.2-redis \
  php8.2-curl php8.2-mbstring php8.2-xml php8.2-zip \
  php8.2-gd php8.2-bcmath php8.2-intl

systemctl enable --now mariadb redis-server nginx php8.2-fpm

if ! command -v composer >/dev/null 2>&1; then
  tmp_composer="$(mktemp)"
  curl -fsSL https://getcomposer.org/installer -o "${tmp_composer}"
  php8.2 "${tmp_composer}" --install-dir=/usr/local/bin --filename=composer
  rm -f "${tmp_composer}"
fi

if [[ -e "${APP_DIR}" ]]; then
  echo "应用目录已存在：${APP_DIR}"
  read -r -p "删除并重新部署该目录? [y/N] " REMOVE_APP
  [[ "${REMOVE_APP}" =~ ^[Yy]$ ]] || { echo "已取消，未修改现有应用。"; exit 1; }
  rm -rf "${APP_DIR}"
fi

mkdir -p "$(dirname "${APP_DIR}")"
git clone --branch "${SOURCE_REF}" --depth 1 "${SOURCE_URL}" "${APP_DIR}"
chown -R "${SUDO_USER:-root}":"${SUDO_USER:-root}" "${APP_DIR}"
cd "${APP_DIR}"
composer install --no-dev --prefer-dist --optimize-autoloader

mariadb <<SQL
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASSWORD}';
ALTER USER '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
SQL

cp -n .env.example .env || true
export SERVER_IP APP_DIR DB_NAME DB_USER DB_PASSWORD
python3 - <<'PY'
from pathlib import Path
import os
path = Path(os.environ["APP_DIR"]) / ".env"
values = {
    "APP_ENV": "production",
    "APP_DEBUG": "false",
    "APP_URL": "http://" + os.environ["SERVER_IP"],
    "DB_CONNECTION": "mysql",
    "DB_HOST": "127.0.0.1",
    "DB_PORT": "3306",
    "DB_DATABASE": os.environ["DB_NAME"],
    "DB_USERNAME": os.environ["DB_USER"],
    "DB_PASSWORD": os.environ["DB_PASSWORD"],
    "REDIS_HOST": "127.0.0.1",
    "REDIS_PORT": "6379",
    "REDIS_PASSWORD": "",
    "CACHE_DRIVER": "redis",
    "QUEUE_CONNECTION": "redis",
    "SESSION_DRIVER": "redis",
}
lines = path.read_text().splitlines() if path.exists() else []
seen = set()
for index, line in enumerate(lines):
    key = line.split("=", 1)[0] if "=" in line else ""
    if key in values:
        lines[index] = key + "=" + values[key]
        seen.add(key)
for key, value in values.items():
    if key not in seen:
        lines.append(key + "=" + value)
path.write_text("\n".join(lines) + "\n")
PY

php8.2 artisan key:generate
php8.2 artisan xboard:install \
  --database=mysql --db-host=127.0.0.1 --db-port=3306 \
  --db-name="${DB_NAME}" --db-user="${DB_USER}" --db-password="${DB_PASSWORD}" \
  --redis-host=127.0.0.1 --redis-port=6379 --redis-password= \
  --no-interaction 2>&1 | tee "${INSTALL_LOG}"

cat > /etc/nginx/sites-available/xboard <<NGINX
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name ${SERVER_IP} _;
    root ${APP_DIR}/public;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \\.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
    }

    location ~ /\\.(?!well-known).* {
        deny all;
    }
}
NGINX

rm -f /etc/nginx/sites-enabled/default
ln -sfn /etc/nginx/sites-available/xboard /etc/nginx/sites-enabled/xboard
chown -R www-data:www-data "${APP_DIR}/storage" "${APP_DIR}/bootstrap/cache"
find "${APP_DIR}/storage" "${APP_DIR}/bootstrap/cache" -type d -exec chmod 775 {} +
find "${APP_DIR}/storage" "${APP_DIR}/bootstrap/cache" -type f -exec chmod 664 {} +
chown "${SUDO_USER:-root}":www-data "${APP_DIR}/.env"
chmod 640 "${APP_DIR}/.env"
php8.2 artisan storage:link
php8.2 artisan optimize

cat > /etc/systemd/system/xboard-queue.service <<SERVICE
[Unit]
Description=Xboard queue worker
After=redis-server.service mariadb.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=${APP_DIR}
ExecStart=/usr/bin/php8.2 artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

printf '%s\n' "* * * * * www-data cd ${APP_DIR} && /usr/bin/php8.2 artisan schedule:run >/dev/null 2>&1" > /etc/cron.d/xboard
chmod 644 /etc/cron.d/xboard
systemctl daemon-reload
systemctl enable --now xboard-queue
nginx -t
systemctl restart nginx php8.2-fpm

cat <<SUMMARY

安装完成，请立即保存以下关键参数：
  访问地址: http://${SERVER_IP}/
  应用目录: ${APP_DIR}
  数据库名: ${DB_NAME}
  数据库用户: ${DB_USER}
  数据库密码: ${DB_PASSWORD}
  安装日志: ${INSTALL_LOG}

管理员路径和初始凭据请从安装日志中读取，并在首次登录后修改密码。
SUMMARY

systemctl is-active nginx php8.2-fpm mariadb redis-server xboard-queue cron
curl -fsSI "http://${SERVER_IP}/" | head
