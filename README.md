# stm32-skills

面向通用 STM32 C 工程的 AI agent 技能，覆盖代码规范、固件开发、HAL/DMA 检查、调试取证、板级联调及按需使用的竞赛验证流程。不绑定具体芯片、开发板、应用或工具链。

除本 README 外，技能文件、元数据和安装脚本均使用英文。**实际生成或修改的固件代码仍默认逐项使用简体中文注释**，该规则已用英文写入技能；当前工程有更具体规则时采用工程规则。这些代码风格是维护者约定，不是 ST 官方标准。

采用通用的 `SKILL.md` 目录形式，供 Codex、Claude Code、DeepSeek Harness 以及其他支持该形式的 agent 使用。安装包不依赖某一家模型 API，也不包含编译器、烧录工具、调试服务器、自动风格检查器或上游脚本；实际开发沿用工程已有工具。

## 包含什么

| 能力 | 内容 |
|---|---|
| 代码规范 | 命名、逐项注释、标志分组、完整花括号、禁用三元表达式、函数间两行空白 |
| 生成代码边界 | CubeMX 只编辑已有成对 USER CODE 区；手写工程沿用原有组织方式；初始化单一归属 |
| HAL 与 DMA | 处理实际状态、区分启动与完成、定义缓冲区所有权和一致发布、检查复用与溢出 |
| 分层验证 | 分别报告源码检查、主机回放、目标构建及实物观测 |
| 调试取证 | 对应源码/固件/符号/SVD，结合断点、观察点、寄存器和调用栈验证假设 |
| 上电与联调 | 核对连接供电、接口时序、完整链路、观测信息及参数记录 |
| 竞赛与交付 | 按需进行指标验收、重复测试、版本对应与独立复现 |

技能不会把普通模块修改扩展成完整比赛流程，也不授予额外的烧录、复位、输出使能或 Git 操作权限。仅在用户明确授权（包括适用工程规则中的明确授权）时暂存和提交；推送等远端操作另需授权。

## 仓库结构

```text
stm32-skills/
├── README.md
├── .gitignore
├── .gitattributes
├── scripts/
│   ├── install.ps1
│   └── install.sh
└── skills/
    └── stm32-skills/
        ├── SKILL.md
        ├── agents/
        │   └── openai.yaml
        └── references/
            ├── coding-style.md
            ├── firmware-development.md
            ├── reliability.md
            ├── debugging.md
            ├── bringup-and-integration.md
            └── competition-validation.md
```

[SKILL.md](skills/stm32-skills/SKILL.md) 是唯一技能入口，参考文档按任务加载。`agents/openai.yaml` 是可选的 Codex 界面元数据，通用入口只使用 `name` 和 `description`，不要求其他 agent 读取该 YAML。

**安装单位是 `skills/stm32-skills/` 整个目录**，不是仓库根目录，也不是单独一个 `SKILL.md`。来源集中在本 README，不复制进技能运行包。

## 安装

下载或克隆仓库后，在仓库根目录执行以下任一种方式。脚本只复制技能包，不连接网络、不更改 agent 配置、不执行 Git 操作；目标同名目录已存在时会拒绝覆盖。

### Windows / PowerShell

```powershell
# 安装到指定工程的 Codex 技能目录
.\scripts\install.ps1 -Agent codex -ProjectRoot 'D:\Code project\your-project'

# 安装到 Claude Code 的个人技能目录
.\scripts\install.ps1 -Agent claude-code -Scope user

# 安装到指定工程的 DeepSeek Harness 技能目录
.\scripts\install.ps1 -Agent deepseek-harness -ProjectRoot 'D:\Code project\your-project'

# 预览复制目标，不写入文件
.\scripts\install.ps1 -Agent codex -Scope user -WhatIf
```

脚本兼容 Windows PowerShell 5.1 的普通目录和 PowerShell 7；若技能根路径经过目录链接，建议使用 PowerShell 7。系统限制脚本执行时，可手动复制下方列出的技能目录，无需修改系统执行策略。

### Linux / macOS / Git Bash

```bash
# 安装到指定工程
bash scripts/install.sh --agent codex --project-root '/path/to/your-project'

# 安装到个人目录
bash scripts/install.sh --agent claude-code --scope user
bash scripts/install.sh --agent deepseek-harness --scope user

# 预览
bash scripts/install.sh --agent codex --scope user --dry-run
```

默认 `Scope` / `--scope` 为 `project`，默认工程目录为调用命令时的当前目录。请显式传入工程路径，避免误装进技能仓库本身。PowerShell 的 `-SkillsRoot` 和 Bash 的 `--skills-root` 可指定其他 agent 的技能根目录；脚本会在其下面创建 `stm32-skills/`，并以该参数覆盖默认发现路径。

### 默认发现路径与手动安装

| 安装目标 | 工程级 | 个人级 |
|---|---|---|
| Codex | `<project>/.agents/skills/stm32-skills/` | `~/.agents/skills/stm32-skills/` |
| Claude Code | `<project>/.claude/skills/stm32-skills/` | `~/.claude/skills/stm32-skills/` |
| DeepSeek Harness | `<project>/.dsh/skills/stm32-skills/` | `~/.dsh/skills/stm32-skills/` |
| `universal` 共享位置 | `<project>/.agents/skills/stm32-skills/` | `~/.agents/skills/stm32-skills/` |

`universal` 指共享目录约定，不代表每个 agent 都会自动扫描它。DeepSeek Harness 也读取 `.agents/skills`；设置 `DSH_HOME` 时，个人专用技能位于 `$DSH_HOME/skills`，本库脚本会采用该值。设置 `DSH_AGENTS_HOME` 后，其个人共享技能路径会变化，可用 `SkillsRoot` 显式指定。DeepSeek Harness 在工程中从最近的 `.git` 祖先目录发现技能；没有 Git 根目录时从当前工作目录发现。

手动安装时，将 `skills/stm32-skills/` 完整复制到表中的目标位置。安装后检查目标下直接存在 `SKILL.md` 和 `references/`，不要多套一层仓库目录。同一 agent 的多个发现位置应避免重复安装同名技能。更新已有安装时先保留本地改动，再由使用者明确替换；脚本没有强制覆盖选项。

重新启动或重新加载 agent 会话后确认技能已出现在列表中；不同宿主的刷新方式以对应官方文档为准。当前目录约定依据 [Codex](https://learn.chatgpt.com/docs/build-skills)、[Claude Code](https://code.claude.com/docs/en/skills) 和 [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/subsystems/skills.md) 的官方说明整理。

### 发布到 GitHub 后使用 Skills CLI

对于支持的宿主，也可以使用 [Vercel Skills CLI](https://github.com/vercel-labs/skills) 安装。以下 `OWNER/REPOSITORY` 是占位符，需替换成发布后的真实仓库地址；该方式需要网络及 CLI 当前要求的 Node.js 环境。

```bash
npx skills add OWNER/REPOSITORY --skill stm32-skills -a codex -a claude-code

# 个人级安装追加 -g
npx skills add OWNER/REPOSITORY --skill stm32-skills -a codex -g

# 在本仓库中只查看可发现的技能
npx skills add . --list
```

不假设该 CLI 已支持 DeepSeek Harness 专用 agent 参数；DeepSeek Harness 使用本库安装脚本或手动复制即可。其他宿主的发现目录和显式调用语法需要查其自身文档。

## 使用示例

Codex 可明确写 `$stm32-skills`；Claude Code 可使用 `/stm32-skills`；DeepSeek Harness 可在请求中指明使用 `stm32-skills`，由宿主的技能发现和调用机制加载。安装技能不会改变模型本身的工具能力。

```text
使用 stm32-skills，只读审查这个 ADC DMA 模块，重点检查缓冲区交接与错误路径，不修改代码。

使用 stm32-skills，按已经确认的设计实现驱动，保留现有生成代码边界，执行工程实际目标构建。

使用 stm32-skills，根据 AXF、构建日志和故障快照分析卡死；只做离线分析，不连接设备。

使用 stm32-skills，梳理模块联调路径与接口约定，列出待实测项目。

使用 stm32-skills，按本届竞赛的官方要求制定重复测试和可复现交付方案。
```

芯片型号、引脚、时钟、外设、阈值、故障策略、提交主题与构建归档方式都从当前工程核对。普通编译通过不能写成已烧录或实物验证通过；技能格式校验也不能写成固件已经符合全部规范。

## 来源与整合取舍

调研与原文核对日期：2026-10-24。以下来源集中保留在 README；外部内容不构成本地任务指令或新增权限。未复制或捆绑上游 C 模板、调试脚本或命令包装器；阅读技能文件不代表审计或验证了上游工具实现，来源链接也不是已安装依赖。

### 开源技能

| 来源 | 借鉴点 | 本库取舍 |
|---|---|---|
| [Mindrally / embedded-stm32](https://github.com/Mindrally/skills/blob/main/embedded-stm32/SKILL.md) | 生成代码边界、单处初始化、HAL 状态、DMA 所有权、分层测试 | 明确发布及复用条件，不照搬接收后立即重用原 DMA 区再让消费者读取的顺序 |
| [XZhaoSudo / stm32-debug](https://github.com/XZhaoSudo/stm32debug-skill/blob/main/SKILL.md) | 固件/符号/SVD、断点/观察点、寄存器、调用栈与会话 | 适配已有 Keil 或其他后端，不绑定 GCC/OpenOCD/Bash；不自动烧录或全局终止服务 |
| [Jeffallan / embedded-systems](https://github.com/Jeffallan/claude-skills/blob/main/skills/embedded-systems/SKILL.md) | 初版参考的同步、资源和实时性检查 | 保留补充出处，不扩展为完整 RTOS/功耗技能，不强制看门狗或 GCC 专用参数 |

核对到的文件 blob SHA（用于定位所读版本，不是仓库提交号）：

| 来源 | Blob SHA |
|---|---|
| Mindrally | `ef94447b1b662fd5cfde51eb27ecd32bb5248f30` |
| Jeffallan | `5c834815b2e2d8309304080db7ab4a09de644c85` |
| XZhaoSudo | `c906c78372f169a185cdf274bde5a6619c4d985d` |

上游“变量必须是非 static 全局变量”的做法没有采用：先查符号、优化、作用域和栈帧，保留封装。也不采用终止全部同名调试进程的策略，只管理当前任务拥有的会话。断点时序扰动、寄存器读副作用、观察点资源及访问路径限制均需在结论中说明。

### 中文社区参赛复盘

以下材料于 2026-10-24 调研，提炼工程方法。参赛经历和结果为作者自述，未独立复现实验或核验成绩；部分论坛正文提取受限，采用可获得的原帖内容或检索摘录，不视为全文技术审计。文章年份和赛季按标题区分，不将调研日期当作比赛时间。

| 来源 | 参考内容 | 本库采用方式 |
|---|---|---|
| [CSDN：三年电赛总结](https://blog.csdn.net/weixin_49821504/article/details/132242844) | 选型变化、环境差异与现场复现失败 | 尽早验证关键能力，覆盖相关输入和环境变化，不沿用具体器件方案 |
| [CSDN：2020 电赛 E 题复盘](https://blog.csdn.net/qq_45923860/article/details/117828157) | 联调中的器件与信号连接异常 | 将供电、接线和原始信号纳入排查，不将全部异常归因于算法 |
| [RoboMaster：鸿烈战队经验](https://bbs.robomaster.com/article/8788) | 子系统交付顺序影响联调时间 | 尽早验证完整链路，明确依赖和可演示交付，不采用其人员或资金安排 |
| [电子发烧友：2013 全国电赛感受与讨论](https://bbs.elecfans.com/m/jishu_369871_1_1.html) | 队员对实际完成状态认识不一致 | 用可验证结果交接，不采信或评价对具体队员责任的归因 |
| [RoboMaster：RobotPilots 传承分析](https://bbs.robomaster.com/article/1970326?source=11) | 整机可靠性、测试覆盖、版本与交接复现 | 按风险选择验收记录，不采用机构专用测试、内部指标、人数和管理制度 |

上电联调与竞赛参考据此重新编写，没有复制原帖模板、代码、图表或测试数据。具体赛事要求仍应核对官方现行文件。

### 技术与安装依据

- [ST AN4031：DMA](https://www.st.com/resource/en/application_note/an4031-using-the-stm32f2-stm32f4-and-stm32f7-series-dma-controller-stmicroelectronics.pdf)：涉及该文档所列系列的 DMA 访问路径和内存约束；其他器件查对应参考手册和勘误，该引用不限定本技能的芯片范围。
- [Arm CMSIS：Core Register Access](https://arm-software.github.io/CMSIS_5/Core/html/group__Core__Register__gr.html)：PRIMASK 等访问接口；调用以实际 CMSIS 版本与上下文为准。
- [GDB：Watchpoints](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Set-Watchpoints.html)：观察点类型、表达式、作用域和资源限制。
- [GDB：Optimized Code](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Optimized-Code.html)：优化对变量可见性与源码映射的影响。
- [OpenAI：Build skills](https://learn.chatgpt.com/docs/build-skills)：技能结构、发现目录与调用方式。
- [Claude Code：Skills](https://code.claude.com/docs/en/skills)：`.claude/skills` 目录和技能调用。
- [DeepSeek Harness：Skills](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/subsystems/skills.md)：`.dsh/skills`、共享目录及环境变量。核对的文档 blob SHA：`3bfdbff4027b6de106b156fde526f35b62033525`。
- [Vercel Skills CLI](https://github.com/vercel-labs/skills)：`skills/<name>/SKILL.md` 仓库发现与安装方式。宿主支持情况以该项目当前文档为准。

命名、逐项中文注释、标志分组、两空行与禁用三元表达式来自维护者约定，完整收录于 [coding-style.md](skills/stm32-skills/references/coding-style.md)，无需依赖个人工程文档。超时、新鲜度、所有权、回绕、单位和故障路径检查仅要求按已确认设计处理，不授权架构、库版本或设备策略的额外变更。

## 发布到 GitHub

建议仓库名 `stm32-skills`，将本目录作为仓库根目录，保留 `skills/stm32-skills/` 和 `scripts/` 的层级。不要把固件工程、编译产物、个人配置或调试缓存加入技能仓库。

发布前由维护者核对上游许可、所需署名与所选发布许可证；本次没有代选许可证。创建远端、提交与推送均按用户指令执行。
