# Leina Agent 发布摘要背景

## 产品与读者

Leina Agent 是一个开源 Docker 分发项目，将固定版本的 NousResearch Hermes Agent、OO CLI、精选 Skills 和 provider Plugins 组装为可独立部署的运行时镜像。

发布摘要面向部署或维护 Leina Agent 的用户。项目名称统一使用 Leina Agent；Hermes Agent 指上游运行时，OOMOL 和 OO CLI 指服务与工具。仓库为 `oomol-lab/leina-agent`。

## 术语和组件

- `upstream.lock.json`：Hermes 与 OO CLI 的权威版本和校验记录。
- `scripts/`：镜像装配、启动、验证和发布相关脚本。
- Skills 和 OO CLI：Agent 调用工具或托管工作流的能力；只有明确改变可用能力、兼容性或体验时才在摘要中说明。
- Providers：通过 Hermes provider 扩展点接入语言模型、图片生成、视频生成和网页搜索的发行版组件。

## 摘要准则

- 优先描述用户可感知的能力、修复、可靠性、镜像行为或兼容性变化。
- CI、测试、格式调整和内部重构通常不写；只有会影响部署、升级或排障时才简要说明。
- 不要从目录名、提交前缀或项目背景推断未被本次变更数据支持的功能。
- 使用简洁中文；不列出 commit hash、内部实现细节或未确认的升级操作。
