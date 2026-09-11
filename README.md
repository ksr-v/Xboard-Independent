# Xboard Independent

Xboard Independent 是一个面向私有部署、验证和恢复的 Xboard / Xboard-Node 项目资料库。它保留官方上游身份，同时整理可复现的部署记录、依赖资产和灾备资料。

## 项目简介

本项目不重新包装或替代官方 Xboard，而是围绕官方上游版本建立独立的验证和恢复边界：

- 保留 Xboard 与 Xboard-Node 的官方来源和版本基线
- 记录 Docker、原生 Ubuntu 和面板路线的验证结果
- 优先维护不依赖面板的 Ubuntu native 部署路径
- 保存 Composer、管理端静态文件、节点安装器和节点发行资产
- 将数据库、环境文件等敏感备份放在独立的加密路径

## 功能范围

- Xboard 面板的用户端和管理端部署
- MariaDB / MySQL 数据库支持
- Redis 缓存、Session 和队列支持
- PHP 8.2、PHP-FPM 与 Nginx 原生部署
- Xboard-Node 依赖和发行资产恢复
- 节点、用户、套餐和订阅管理验证
- 本地校验和灾备资料管理

## 快速开始

当前已验证的测试入口使用 Ubuntu 22.04 native 部署。项目资料和恢复资产位于本仓库；实际服务器环境变量、数据库备份和管理员凭据不提交到 Git。

```text
应用目录：/var/www/xboard
Web 根目录：/var/www/xboard/public
PHP-FPM：/run/php/php8.2-fpm.sock
数据库：MariaDB 10.6
缓存/队列：Redis 6
```

当前验证机的部署状态、服务清单和恢复说明见：

- [项目总状态](Project-Docs/MASTER-STATUS.md)
- [Xboard 部署记录](Xboard/docs-private/DEPLOYMENT.md)
- [灾备恢复记录](Xboard/docs-private/DISASTER-RECOVERY.md)

## 文档

### Deployment Guides

部署指南：

- [Ubuntu 原生安装教程](Xboard/docs/en/installation/ubuntu-native.md) - 可执行的 PHP 8.2、MariaDB、Redis、Nginx 和 PHP-FPM 安装步骤
- [Deploy with aaPanel](Xboard/docs/en/installation/aapanel.md) - aaPanel + PHP 8.3、MariaDB、Redis 和 Xboard 内网部署教程
- [Ubuntu 原生部署记录](Xboard/docs-private/DEPLOYMENT.md) - 当前验证机的实际部署结果和状态
- [生产部署规划](Project-Docs/PRODUCTION-DEPLOYMENT-PLAN.md) - 生产环境的资源、安全和发布边界
- [Docker 部署规划](Project-Docs/IMAGE-RECOVERY-PLAN.md) - Docker 镜像、Compose 和离线恢复资料
- [Xboard-Node 部署记录](Xboard-Node/docs-private/DEPLOYMENT.md) - 节点端部署边界和待验证事项

本项目当前只将 IP 访问的原生 Ubuntu 部署作为已验证路径。域名、HTTPS、DNS 和 443 端口不在当前阶段范围内。

### Recovery Guides

- [灾备恢复记录](Xboard/docs-private/DISASTER-RECOVERY.md)
- [恢复清单](private-assets/RECOVERY-CHECKLIST.md)
- [数据库恢复规划](Project-Docs/DATABASE-RECOVERY-PLAN.md)
- [完整恢复测试规划](Project-Docs/CLEAN-ROOM-RECOVERY-TEST.md)

恢复演练已按当前安排暂缓；项目最终完成前需要再次确认是否执行。

### Development Guides

- [项目操作规则](Project-Docs/PROJECT-INSTRUCTIONS.md)
- [Xboard 项目记录](Xboard/docs-private/PROJECT.md)
- [Xboard-Node 项目记录](Xboard-Node/docs-private/PROJECT.md)

## 技术栈

- 面板：Laravel 12、PHP 8.2、PHP-FPM
- 用户端：Xboard 官方前端资源
- 管理端：Xboard 官方管理端资源
- 数据库：MariaDB 10.6
- 缓存与队列：Redis 6
- Web 服务：Ubuntu Nginx
- 节点端：Xboard-Node 官方发行资产

## 恢复资产

仓库中保存的恢复资料包括：

- Xboard-Node 安装脚本和 amd64 / arm64 发行文件
- GeoIP / GeoSite 数据
- Composer PHAR
- Xboard 管理端静态资源
- 校验清单和依赖恢复规划

服务器数据库、`.env` 和应用归档位于本地私有备份目录，不进入 GitHub：

```text
private-assets/backups/xboard-current/
```

该目录必须使用加密磁盘、加密压缩包或私有云盘保存。

## 当前状态

- IP 部署：已完成
- 普通用户登录和用户中心：已验证
- 管理员登录与核心后台页面：已验证
- Xboard-Node 真实节点联调：待后续推进
- clean-room 恢复演练：按用户要求暂缓
- 域名和 HTTPS：明确不在当前阶段范围内

## 免责声明

本项目用于私有部署验证、学习和恢复准备。使用者需要自行确认服务器安全、数据合规、访问控制和备份策略，并对实际运行结果负责。

## 贡献与后续推进

项目进度、部署事实和恢复边界请优先记录在 `Project-Docs/` 与各组件的 `docs-private/` 目录。后续继续推进时，先阅读 [项目总状态](Project-Docs/MASTER-STATUS.md) 和 [恢复清单](private-assets/RECOVERY-CHECKLIST.md)。

官方上游项目：<https://github.com/cedar2025/Xboard>
