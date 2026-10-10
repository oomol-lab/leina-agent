# OOMOL Hermes Agent 依赖升级报告

核对日期：2026 年 10 月 10 日。项目基线：`39237f5`。

建议升级到 Hermes `0.21.6` 和 OO CLI `1.9.5`，但拆成独立变更交付。先升级 OO CLI 并修复 Connector 身份选择兼容性，再迁移 Hermes 的 Python、构建和版本识别方式，最后升级文档依赖与 CI 工具。

Hermes 升级属于构建兼容性迁移，不能只改版本号：现有版本断言、Skill 补丁和四个白名单路径都会阻止新版本构建。Connector 的基础命令及现有 14 个 Fusion API action 仍存在，但旧组织/个人参数和新增异步等待功能需要单独处理。

## 当前版本与候选版本

| 项目 | 当前锁定或来源 | 已核对的候选 | 建议 |
| --- | --- | --- | --- |
| Hermes | `0.20.2`，`df4b65147d7ddd74dd449f9067aabbca5aef0ec7` | `0.21.6`，`818c13be1dc4fd28987e1e881a9408224afd4535` | 高优先级，需迁移构建 |
| OO CLI | `1.7.4` | `1.9.5` | 第一阶段升级 |
| Hermes 运行 Python | 基础镜像 Python `3.11` | 上游 `.python-version` 为 `3.14`；PM 锁定 `3.14.7+20260901` | 随 Hermes 迁移 |
| uv | 基础镜像 `0.11.6` | uv 最新 release `0.13.0`；Hermes PM 锁定 `0.12.3` | Hermes 构建优先服从 PM，避免两套版本权威 |
| Node.js | Debian trixie 的 `nodejs`，未单独锁定 | Hermes PM 锁定 `26.7.0` | 明确构建和运行时使用哪一套 Node |
| OO framework Skills | 从 OO CLI 构建时导出 | `1.9.5` 仍导出四个框架 Skill | 跟随 CLI，同步核对说明内容 |
| OOMOL provider Plugins | 仓库自有代码 | 无独立上游包可直接升级 | 按 Hermes ABC 和 Connector schema 做适配 |

Hermes `0.21.6` 发布于 2026-10-08；OO CLI `1.9.5` 二进制报告构建时间为 2026-10-09、提交 `d80e0ff8`。本机原有 `oo` 是 `1.9.0`，与镜像锁定版本不同，不能用它代替新版本验收。

来源：[Hermes release](https://github.com/NousResearch/hermes-agent/releases/tag/v0.21.6)、[OO CLI 最新发布元数据](https://static.oomol.com/release/apps/oo-cli/latest.json)、[OO CLI 官方安装脚本](https://cli.oomol.com/install.sh)、[Hermes PM lock](https://github.com/NousResearch/hermes-agent/blob/818c13be1dc4fd28987e1e881a9408224afd4535/pm/lock.json)、[uv release](https://github.com/astral-sh/uv/releases/tag/0.13.0)。

## Connector 升级分析

### 升级边界

本项目没有单独锁定一个 Connector SDK 或 Connector 服务端版本。相关依赖分为三层：

1. 可锁定的 OO CLI 二进制和随它导出的框架 Skills。
2. 仓库维护的 GPT Image 2、Nano Banana、Seedance、Jina 适配插件。
3. 运行时远端 Fusion API action 的输入输出契约。

升级 CLI 并不保证远端 action 契约固定，也不会自动让插件获得新模型能力。CLI 版本、schema 契约、插件支持范围需要分别验收。

### 已确认可沿用的接口

对下载到临时目录的 `1.9.5` 二进制实际检查了帮助输出与 Skill 导出：

- `oo connector run <service> --action <action> --data <json> --json` 仍存在。
- `oo auth login --api-key`、`oo auth status --json`、`oo file upload <path> --json` 仍存在。
- `oo skills install --out-dir <dir> --agent-format hermes` 导出成功，四个 Skill 均存在：`oo`、`oo-create-skill`、`oo-find-skills`、`oo-publish-skill`。
- 使用独立空配置目录检查认证状态，仍得到 `status: logged-out`。有效/无效 API key、已登录账户的字段仍需分别验收。
- 读取现有插件使用的全部 14 个 Fusion API action schema，均成功返回。

| 插件 | 已核对 action | 契约结论 |
| --- | --- | --- |
| GPT Image 2 | 文生图、改图的 submit/result，共 4 个 | `sessionId`、`sessionID`、`state`、`data` 的基本契约仍存在 |
| Nano Banana | 三个模型的 submit/result，共 6 个 | `imageUrls` 与 `imageURLs` 的大小写差异仍存在，应继续按 action 区分 |
| Seedance | submit/state/result，共 3 个 | 当前 2.0 两个模型仍在枚举中；schema 新增 2.5 型号 |
| Jina | `jina_reader_search` | `content` 输入仍存在；输出 schema 宽泛，文本结果解析需真实样本验证 |

Schema 检查只证明接口存在及声明契约，不证明生成、上传、搜索、账单身份与结果下载已端到端成功。

### 必须修复的兼容问题

**旧身份参数需要迁移。** GPT Image 2、Nano Banana、Seedance 的调用代码存在 `--organization` / `--personal` 分支。`1.9.5` 的公开命令帮助改为 `--team`，不再列出这两个旧参数。默认不传旧参数的调用路径具备继续使用的基础；设置旧环境变量的部署必须先适配。

建议明确团队语义并统一三个插件的身份选择方式。不能直接把个人模式改成“什么都不传”：新 CLI 的默认选择会受环境中的 `OO_TEAM_ID` / `OO_TEAM_NAME`、账户保存的默认团队及服务端默认团队影响，可能改变执行和计费归属。文件上传与 submit/result 也应保持相同身份。

**认证兼容不能只看命令存在。** 现有共享认证模块依赖 `status`、`envOverride.apiKeyStatus`，并从终端输出中匹配设备登录 URL。需验收 API key 优先级、无效 key、设备登录输出、30 秒启动登录超时，以及失败时清除旧身份的行为。认证失败仍应允许 Hermes 启动。

**新增等待功能适合后续评估。** 新 CLI 提供 `--wait` 和 `--wait-result`，可能简化插件重复轮询代码。第一阶段建议保留现有轮询并完成兼容升级；确认超时、取消、终态、返回 envelope 和错误脱敏后，再做独立重构。

**Seedance 2.5 是可选功能升级。** 当前 schema 已包含 `doubao-seedance-2-5-260628`；插件目前仅接受 2.0 与 fast 型号。可单独加入 2.5 并核对参数限制、能力及计费，先保留现有默认模型，避免把模型行为变化混入 CLI 升级。

### OO CLI 新版本制品

已下载官方 `1.9.5` 的两个 Linux 制品并计算 SHA-256：

| 项目架构 | 官方制品平台名 | 下载内容的 SHA-256 |
| --- | --- | --- |
| linux/amd64 | linux-x64 | `8d4f6e004f08e1bceba63171132d1669db17ae959a9dc6a5df5fa9ec9b13ac6c` |
| linux/arm64 | linux-arm64 | `00611657644ab56663f2bdf0e83e2c45986e0a0f76590dbff3492e8c11aaaf31` |

这些是本次对 HTTPS 下载内容计算的摘要，没有额外验证独立发布签名。实施时写入 `upstream.lock.json` 和 Docker 默认参数，保留构建时摘要校验；不要让构建动态跟随 `latest.json`。

## Hermes 升级分析

### 三个已确认会阻断构建的问题

**版本识别已变化。** `0.21.6` 对应源码的 `pyproject.toml` 中 `project.version` 是 `0.0.0`。现有 Dockerfile 要求它等于 `HERMES_VERSION`，因此改成 `0.21.6` 后该断言必然失败。上游通过 `install-stamp.json` 与 Git 信息识别运行版本。需使用上游 stamp 机制记录发行版本和完整 SHA，再校验运行身份；不能把项目对外版本改为 `0.0.0` 来绕过断言。

**Skill 描述补丁无法直接应用。** 对目标版本 `agent/skill_utils.py` 执行 `git apply --check`，结果为 `patch does not apply`。目标代码仍保留 60 字符默认截断，本次核对未发现当前补丁提供的 `prompt_description_max_chars` opt-in 逻辑。因此应重新生成最小补丁，保持普通 Skill 的 60 字符默认、显式例外及上限，并继续 fail closed。

**四个 Skill 白名单路径不存在。** 对目标 tag 查询现有六项白名单，结果如下：

| 当前路径 | 0.21.6 状态 | 处理方式 |
| --- | --- | --- |
| `autonomous-ai-agents/hermes-agent` | 存在 | 保留并审阅内容 |
| `creative/architecture-diagram` | 存在 | 保留并审阅内容 |
| `creative/excalidraw` | 不存在 | 重新选择替代项或明确移除 |
| `productivity/nano-pdf` | 不存在 | 评估 `productivity/pdf`，不能仅按名称替换 |
| `productivity/ocr-and-documents` | 不存在 | 重新评估能力与项目自有 Office/PDF Skill 的覆盖 |
| `software-development/plan` | 不存在 | 重新选择规划/开发 Skill 或明确移除 |

白名单组装会拒绝缺失路径，因此这项必须与 Hermes 升级一起完成。新版本存在 `productivity/docx`、`pdf`、`powerpoint`、`xlsx` 等目录，但依赖和运行假设仍需逐项阅读，不能导入整个 Skills 树。

### Python 与构建机制迁移

上游 `.python-version` 为 `3.14`；大量核心依赖带有 `python_version >= '3.14'` 条件。虽然 `requires-python` 仍允许 3.11，其注释说明这是供旧安装完成升级的兼容范围，不代表完整 3.11 运行支持。

当前发行版使用 `uv:0.11.6-python3.11-trixie` 与 `uv sync --frozen --extra messaging`；目标上游使用 PM 锁定工具链、`pm.build_env` 和 sealed 环境。建议采用上游公开构建接口，仅预装项目需要的运行依赖，保留发行版布局。无需为 CLI/gateway 引入完整 Desktop 构建。

需在镜像构建时准备好实际启用的 messaging/provider 依赖，避免新版的按需依赖准备在非 root、不可变代码层下失败。`/data` 状态、首次配置初始化和用户配置保留也需要覆盖。

仓库测试工具的 Python 约束当前为 `>=3.11,<3.14`。如果 `Dockerfile.test` 同步使用 3.14，必须更新这一约束并在 Docker 中重新锁定 `uv.lock`；也可保留独立测试环境，但要说明两套环境的用途。

来源：[目标 pyproject](https://github.com/NousResearch/hermes-agent/blob/818c13be1dc4fd28987e1e881a9408224afd4535/pyproject.toml)、[目标 Dockerfile](https://github.com/NousResearch/hermes-agent/blob/818c13be1dc4fd28987e1e881a9408224afd4535/Dockerfile)、[版本识别模块](https://github.com/NousResearch/hermes-agent/blob/818c13be1dc4fd28987e1e881a9408224afd4535/hermes_cli/version_info.py)。

### Provider 兼容性与升级收益

目标版本仍存在 image/video/web ABC、所用响应辅助函数、`ProviderProfile` 及 model-provider 插件目录。当前 OOMOL profile 使用的主要字段也仍存在。源码检查支持继续通过插件适配的方向，但不能替代导入、实例化与工具调用测试。新版本提及插件隔离机制，应验收跨插件共享认证模块与 `PYTHONPATH` 在真实加载模式下的行为。

Hermes `0.21.6` 包含仓库 Git filter 调用加固，以及 Dashboard、邮件网关相关修复。Git filter 加固与 agent 执行仓库操作较相关；其余修复的实际收益取决于是否启用对应功能。上游变化范围很大，GitHub compare 返回的文件列表上限为 300 项，不能将该列表视为完整变更审计。

## 文档依赖与开发工具

| Python 包 | 当前 | PyPI 当前版本 | 建议 |
| --- | --- | --- | --- |
| markitdown | 0.1.6 | 0.1.8 | 升级候选，核对转换 API 与文本提取 |
| python-docx | 1.2.0 | 1.2.0 | 保留 |
| openpyxl | 3.1.5 | 3.1.5 | 保留 |
| python-pptx | 1.0.2 | 1.0.2 | 保留 |
| defusedxml | 0.7.1 | 0.7.1 | 保留 |
| reportlab | 4.4.5 | 5.0.1 | 主版本升级，独立评估，初期保留现有版本 |
| pypdf | 6.14.2 | 6.20.0 | 升级候选，核对读写/合并/表单 |
| PyMuPDF | 1.28.0 | 1.28.2 | 升级候选，检查双架构 wheel 与渲染 |
| pyHanko | 0.32.0 | 0.37.0 | 与 CLI 成对升级 |
| pyhanko-cli | 0.2.1 | 0.5.0 | 0.5.0 要求 pyHanko `>=0.37.0,<0.38` |
| tzdata | 2026.2 | 2026.5 | 可升级，核对关键时区 |
| PyYAML | 6.0.3 | 6.0.3 | 保留 |
| pytest | 9.0.2 | 9.1.1 | 低优先级升级 |

Python 元数据允许安装不等于 3.14 上有可用 wheel。尤其 PyMuPDF、签名依赖及 Hermes 的原生扩展要在 amd64/arm64 实际解析和构建。文档 requirements 当前直接安装到 Hermes venv，会影响上游冻结环境；升级时需审查最终依赖图、冲突与哈希锁定，避免只看顶层版本。

来源为各项目 PyPI 元数据：[markitdown](https://pypi.org/project/markitdown/)、[python-docx](https://pypi.org/project/python-docx/)、[openpyxl](https://pypi.org/project/openpyxl/)、[python-pptx](https://pypi.org/project/python-pptx/)、[defusedxml](https://pypi.org/project/defusedxml/)、[reportlab](https://pypi.org/project/reportlab/)、[pypdf](https://pypi.org/project/pypdf/)、[PyMuPDF](https://pypi.org/project/PyMuPDF/)、[pyHanko](https://pypi.org/project/pyHanko/)、[pyhanko-cli](https://pypi.org/project/pyhanko-cli/)、[tzdata](https://pypi.org/project/tzdata/)、[PyYAML](https://pypi.org/project/PyYAML/)、[pytest](https://pypi.org/project/pytest/)。

| GitHub Action | 当前 | 最新 release |
| --- | --- | --- |
| actions/checkout | v4 | [v7.0.1](https://github.com/actions/checkout/releases/tag/v7.0.1) |
| docker/login-action | v3 | [v4.6.0](https://github.com/docker/login-action/releases/tag/v4.6.0) |
| docker/setup-qemu-action | v3 | [v4.4.0](https://github.com/docker/setup-qemu-action/releases/tag/v4.4.0) |
| docker/setup-buildx-action | v3 | [v4.4.1](https://github.com/docker/setup-buildx-action/releases/tag/v4.4.1) |
| docker/build-push-action | v6 | [v7.4.0](https://github.com/docker/build-push-action/releases/tag/v7.4.0) |

CI Actions 建议作为独立变更升级，核对 runner 要求、输入输出、缓存、provenance/SBOM 与发布摘要验证。版本选定后可固定完整 commit SHA。基础镜像也建议固定 digest。Debian apt 包当前未逐个锁定，固定基础镜像只能部分改善可重复构建，应保存最终 SBOM 并定期重建；本次未逐项核对所有 apt 包的最新版本。

## 建议实施顺序与验收

1. **建立 Docker 基线。** 在 Docker 环境完成当前仓库测试与双架构构建，记录版本、插件发现、认证和文档产物。`docs/handoff.md` 的“首次 amd64 构建”待办已与现有 CI amd64 build job 有时间差，实际完成情况应以构建结果为准。
2. **升级 OO CLI 到 1.9.5。** 更新锁定和双架构 SHA；修复旧身份参数；确认四个框架 Skill、认证持久化、文件上传与结果 envelope。保持现有默认模型和轮询行为。
3. **独立迁移 Hermes 到 0.21.6。** 锁定完整 commit；迁移 Python/PM 构建；实现可靠版本 stamp；重做最小 Skill 补丁；调整白名单；验收五个 provider 和两种主模型 API 模式。按仓库要求放在独立 `chore(upstream)` 提交。
4. **升级文档栈。** 优先小版本和补丁版本；pyHanko 与 CLI 配套；ReportLab 5 单独评估。产物必须读回或渲染验证，包括中文、字体、表格、PDF 页面及签名校验。
5. **升级 CI 并加强可重复构建。** 固定 Action SHA、基础镜像 digest，审查文档依赖的完整锁定与 SBOM。之后再评估共享 Connector client、CLI 等待功能与 Seedance 2.5。

发布前应覆盖：linux/amd64 和 linux/arm64；非 root UID 与 `/data`；首次及已有卷配置；离线启动；错误 key、登录超时及旧账户清理；普通 Skill 60 字符和显式长描述；五个 provider 的发现与代表性调用；图像生成/编辑、视频、搜索和文档生成；超时/失败脱敏；升级后旧卷与回滚镜像的兼容。

回滚前保存升级前镜像 digest，并对持久卷做快照。仅切回镜像不能保证新版写入的数据和配置可被旧版读取。

## 本次结论的验证范围

完成了仓库配置与源码分析、官方 release/版本元数据核对、目标版本关键源码检查、补丁应用预检、六个 Skill 路径核对、OO CLI 1.9.5 本机帮助与四项 Skill 导出、14 个远端 schema 查询及 Linux 制品摘要计算。临时下载和导出均位于仓库外；未执行生成、上传或搜索等业务 action。

当前主机未发现 `docker` 命令，因此未运行仓库测试、完整镜像构建或 Linux 二进制启动。报告中的版本是升级候选，不是已通过发行验收的组合。本次只新增报告，没有修改依赖锁定、Dockerfile、插件或发布配置。
