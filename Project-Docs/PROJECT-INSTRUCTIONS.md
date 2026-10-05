# Xboard Independent 项目长期指令

## 1. 项目定义

这是一个仅供我个人使用的私有项目，现按用户决定转为与原始维护者断开同步关系的独立孤儿项目。

代码来源仍保留为以下两个历史基线：

### Xboard

官方上游仓库：

https://github.com/cedar2025/Xboard

历史仓库地址（仅供来源识别，不得作为 fetch/pull/submodule/install/update 目标）：

https://github.com/cedar2025/Xboard.git

### Xboard-Node

官方上游仓库：

https://github.com/cedar2025/Xboard-Node

历史仓库地址（仅供来源识别，不得作为 fetch/pull/submodule/install/update 目标）：

https://github.com/cedar2025/Xboard-Node.git

除非经过实际核实，否则不要把其他同名项目、Fork、镜像仓库或历史项目当成这里所指的 Xboard / Xboard-Node。

如果上述仓库未来不可访问，应以我已经保存的 baseline、Git 历史和项目文档确定项目身份，而不是擅自寻找其他同名项目代替。

---

# 2. 核心目标

从 2026-10-05 起，不再跟随 cedar2025 的任何分支、release、安装脚本、子模块或更新 API。保留原始 Git 历史、baseline tag、License 和必要的来源记录；这表示独立维护，不表示抹除来源或建立无历史的 Git orphan branch。更新只允许来自本地验证资产和用户控制的私有维护路径。

本项目不是品牌重命名项目。

本项目的核心目标是：

在尽可能保持原始 Xboard 和 Xboard-Node 功能、协议、数据库、插件生态和升级兼容性的前提下，建立一套由我自己控制的私有源码、构建、镜像、部署、备份和灾难恢复体系。

最终要求：

即使未来原作者停止维护，或者原作者控制的 GitHub 仓库、GitHub Release、Container Registry、安装脚本、前端资源、子模块及其他相关资源全部不可访问，我仍然能够依靠自己保存的资产完成：

1. 获取源码；
2. 构建 Xboard；
3. 构建 Xboard-Node；
4. 构建或恢复必要前端资源；
5. 部署数据库及相关基础服务；
6. 执行数据库 migration；
7. 启动 Xboard；
8. 启动 Xboard-Node；
9. 完成 Xboard 与 Xboard-Node 的正常连接；
10. 正常使用核心业务功能；
11. 升级自己的稳定版本；
12. 从备份恢复现有系统；
13. 在全新服务器完成从零灾难恢复。

---

# 3. 私有使用原则

本项目仅供我自己使用。

不要以公开发行、社区 Fork、重新品牌化或对外商业发行作为默认设计目标。

优先考虑：

- 稳定性
- 可恢复性
- 可重复部署
- 上游失效后的生存能力
- 最低长期维护成本

而不是：

- 品牌修改
- UI 名称修改
- 大规模代码重构
- 为了代码“看起来属于自己”而修改内部标识

---

# 4. 上游兼容原则

原则上尽可能保持原版代码结构与运行协议，但不再保持与上游仓库的同步关系。

不要仅仅因为代码、类、目录、配置、数据库、API 或协议中包含 `Xboard`、`xboard` 等名称就修改它们。

任何可能影响以下内容的修改都必须谨慎：

- 数据库兼容性
- migration
- API
- Xboard 与 Xboard-Node 通信
- 插件接口
- 配置格式
- 用户数据
- 订阅格式
- 更新路径
- Docker volume
- 环境变量
- 第三方集成

优先采用“移除上游运行依赖、替换为已验证的本地资产”而不是“修改内部业务结构”的方案。不得因断开同步而删除 License、历史或协议兼容性。

---

# 5. 上游依赖审计

必须系统检查所有可能造成单点故障的外部资源，包括但不限于：

- github.com/cedar2025/*
- raw.githubusercontent.com/cedar2025/*
- 原作者 GitHub Release
- 原作者 Container Registry / GHCR
- Git submodule
- 前端构建产物
- Admin 前端资源
- 安装脚本
- 更新脚本
- Dockerfile
- Docker Compose
- GitHub Actions
- Composer dependency
- npm/pnpm/yarn dependency
- Go module
- 外部二进制下载
- CDN
- 主题
- 插件
- Release artifact

发现外部依赖以后，不允许直接全部 Fork。原始维护者控制的资源现按“不得再连接”的孤儿项目策略处理；通用生态和第三方运行依赖仍须按风险分类。

首先分类。

---

# 6. 依赖分类

每个重要外部依赖必须归入以下类别之一：

## UPSTREAM_CRITICAL

由原 Xboard 项目或原作者控制。

一旦消失可能导致构建、部署、运行、更新或恢复失败。

原则上需要：

- 私有镜像
- 私有 Git mirror
- 本地备份
- 替换下载地址
- 或其他可恢复措施

具体措施根据依赖类型决定。

## PUBLIC_INFRASTRUCTURE

成熟公共开源基础设施或生态依赖。

例如通用 PHP、Composer、npm、数据库、Redis 等生态资源。

通常不需要自己 Fork，但应该：

- 固定必要版本
- 保留 lock 文件
- 记录恢复方法
- 评估关键依赖是否需要缓存

## OPTIONAL_EXTERNAL

非核心外部服务。

失效不会导致核心系统无法运行。

记录即可，根据实际需要决定是否本地化。

## UNKNOWN

暂时无法确认风险。

继续调查，不要擅自修改。

---

# 7. 版本固定原则

生产部署尽量避免依赖不确定版本，例如：

- latest
- 未固定的 master
- 未固定的 main
- 未固定的 dev
- 会变化的远程安装脚本
- 未记录 digest 的关键镜像

自己的稳定版本应该能够明确关联：

- Git commit
- Git tag
- Container image tag
- 必要时的 image digest
- 配置版本
- 数据库 migration 状态
- Xboard-Node 对应版本

---

# 8. 备份原则

核心资产不能只有原作者一份，也不能只有我的 GitHub 一份。

需要逐步建立：

- 私有 Git repository
- 本地 Git repository / bundle 或其他离线 Git 备份
- Container Registry
- Docker image 离线备份
- 数据库备份
- 配置模板
- 必要二进制文件
- 前端构建产物
- Git submodule 镜像
- Release artifact
- 部署文档
- 灾难恢复文档

重要密钥、Token、密码等秘密信息不得写入 Git 仓库中的 Markdown 文档。

---

# 9. Codex 工作规则

Codex 不要一次性完成整个项目。

所有重要工作采用：

调查
→ 分类
→ 风险分析
→ 提出最小修改方案
→ 修改
→ 测试
→ 检查 Git diff
→ 更新文档
→ Commit

每次尽量保持一个明确目标。

修改前先阅读相关代码。

如果只需要修改一个 URL，就不要顺便重构整个模块。

---

# 验证范围与延期策略

- 功能表现正常时，采用与变更风险相称的最小验证：优先验证刚修改的功能路径和必要的语法/配置加载，不重复已通过且未受影响的检查，也不为追求测试数量扩大范围。
- 任何未执行的测试或检查都必须记录为“未验证/延期”，注明原因和计划恢复的阶段；不得把未运行的检查表述为通过。
- 不影响当前必要部署和核心功能的扩展验证，统一延期到项目完成上线后继续验证并修复。上线前若发现核心功能异常、数据风险或更新/恢复安全门槛未满足，则暂停对应变更并处理根因。
- 用户明确要求跳过的验证，在延期阶段也不得自动执行；需要再次征得用户授权后才能开展。
- 宣布项目完成前，列出仍延期的验证并提醒用户；不得因延期而将整体恢复能力或生产就绪状态标为已验证。

---

# 10. 禁止操作

未经我明确确认，不要：

1. 大规模全局字符串替换；
2. 修改数据库表名；
3. 修改数据库字段名；
4. 修改 Xboard 与 Xboard-Node 的协议；
5. 修改公开 API 标识；
6. 删除 migration；
7. 删除兼容代码；
8. 删除原项目 License；
9. 删除第三方版权声明；
10. 大规模重构；
11. 强制升级大型依赖；
12. 修改生产数据库；
13. 删除生产数据；
14. 覆盖生产环境配置；
15. 删除 Git branch；
16. 删除 Git tag；
17. force push；
18. reset --hard 到未经确认的位置；
19. 把密码、Token、Private Key 等秘密提交进 Git。

---

# 11. 文档优先原则

项目的重要知识不能只存在于 ChatGPT/Codex 对话。

即使未来所有 AI 对话记录全部丢失，仅凭：

- Git repository
- AGENTS.md
- docs-private
- Project-Docs

也应该能够恢复项目上下文。

因此，每次发现重要架构、依赖、部署方法或风险，都应该更新相应 Markdown。

但是：

不要为了写文档而猜测。

必须区分：

- VERIFIED：已经实际验证
- DISCOVERED：从代码确认，但尚未运行验证
- PLANNED：计划实施
- UNKNOWN：尚待调查

禁止把计划中的方案写成已经完成。

---

# 12. 最终灾难恢复测试

最终必须执行一次“上游完全消失测试”。

测试假设：

cedar2025 控制的所有资源均不可访问。

准备一台干净服务器。

不得访问任何 cedar2025 控制的：

- Git repository
- Release
- Container image
- raw GitHub script
- submodule
- frontend artifact
- binary

仅允许使用：

1. 我的私有资产；
2. 我的离线备份；
3. 通用公共开源基础设施。

然后从零完成整个系统部署。

只有实际通过该测试，项目才可以被标记为：

`INDEPENDENTLY RECOVERABLE`

---

# 13. 当前启动阶段

原始 Phase 0 baseline、镜像与依赖初审已完成。当前阶段是孤儿化：断开官方 Git remotes、移除上游子模块和在线更新入口、转成本地固定资产与私有维护流程。保留 baseline 和 Git 历史。

第一阶段不要修改业务代码。

首先：

1. 核实两个官方上游仓库；
2. 获取未经修改的原始源码；
3. 建立我的 Private repository；
4. 正确配置 upstream 和 origin；
5. 保存 upstream baseline；
6. 创建 baseline tag；
7. 检查 submodule；
8. 审计源码中的外部 URL；
9. 审计 Docker / Compose；
10. 审计安装和更新脚本；
11. 审计 Composer / npm / Go 等依赖；
12. 建立第一版 DEPENDENCIES.md。

完成审计以后，再决定哪些依赖真正需要私有化。

不要在 Phase 0 直接开始大规模修改。