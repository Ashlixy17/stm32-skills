<h1 align="center">stm32-skills</h1>


<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/Platform-STM32-03234B?logo=stmicroelectronics&logoColor=white">
</p>

<p align="center">
  适用于 STM32 的电赛技能库
  <br>
  <strong>代码规范 · 固件开发 · 调试取证 · 竞赛经验</strong>
</p>
<p align="center">
  简体中文 | <a href="README.en.md">English</a>
</p>

## 功能

- **代码规范**：统一命名、逐项注释、标志分组和排版，完整使用花括号，禁用三元表达式。
- **固件开发**：遵守 CubeMX USER CODE 边界，保持单处初始化，检查 HAL 状态、IRQ 回调与 DMA 缓冲区交接。
- **构建与烧录**：沿用 Keil/Arm 或 GCC 工具链，提供 STM32CubeProgrammer CLI 用法，逐层排查编译、链接、连接与烧录失败。
- **调试取证**：核对源码、ELF/AXF、运行固件与 SVD，结合断点、观察点、寄存器和调用栈定位问题。
- **上电联调**：检查供电、接线、指令到物理响应的接口映射与完整数据链，增量联调并回归已有功能，记录标定和参数调整结果。
- **接线强制规则**：接线检查和可能损坏元件的操作必须完成两轮核对；危险接线存在不确定项时，停止相关步骤并询问用户。换线、换板或相关供电与输出配置变化后重新核对。
- **竞赛验证**：将赛题转为验收点和状态转换表，按任务检查开发链、重复测试、故障恢复、现场部署演练与版本交付。
- **分层验证**：区分源码检查、主机测试、目标构建和实物结果，保留结论对应的证据。

> [!TIP]
> 支持 CubeMX 与手写工程，沿用已有 HAL/LL、构建系统和调试工具，不绑定具体芯片或开发板。其他代码规范遵循当前工程要求，详见 [代码规范](skills/stm32-skills/references/coding-style.md)。

## 快速上手

> [!WARNING]
> 需要 Node.js 22.20 或更高版本。在目标工程根目录执行对应命令：

<details>
<summary><strong>Claude Code</strong></summary>

```bash
npx skills@latest add Ashlixy17/stm32-skills --skill stm32-skills -a claude-code
```

安装后使用 `/stm32-skills` 调用。

</details>

<details>
<summary><strong>Codex</strong></summary>

```bash
npx skills@latest add Ashlixy17/stm32-skills --skill stm32-skills -a codex
```

安装后使用 `$stm32-skills` 调用。

</details>

<details>
<summary><strong>DeepSeek Harness</strong></summary>

```bash
npx skills@latest add Ashlixy17/stm32-skills --skill stm32-skills -a universal
```

安装到工程的 `.agents/skills/` 共享目录，在请求中指定使用 `stm32-skills`。

</details>

<details>
<summary><strong>其他 Agent</strong></summary>

```bash
npx skills@latest add Ashlixy17/stm32-skills --skill stm32-skills
```

按提示选择 Agent。

</details>

<details>
<summary>本地安装</summary>

下载或克隆仓库，在仓库根目录运行。将 `codex` 替换为 `claude-code` 或 `deepseek-harness` 可安装到对应 Agent 的目录。

```powershell
.\scripts\install.ps1 -Agent codex -ProjectRoot 'D:\Code project\your-project'
```

```bash
bash scripts/install.sh --agent codex --project-root '/path/to/your-project'
```

个人安装使用 `-Scope user` 或 `--scope user`，预览使用 `-WhatIf` 或 `--dry-run`。手动安装时，完整复制 `skills/stm32-skills/` 到对应 Agent 的技能目录。

</details>

## Q&A 为什么制作了这个技能库？

经过 **个人的电赛经历** 和CSDN上的 [三年电赛总结](https://blog.csdn.net/weixin_49821504/article/details/132242844) 意识到到：经验、投入和临时跑通，都不能代替对当前方案的验证。AI 能加快实现，也需要把选型依据、已知异常和实测结果交代清楚。

<details>
<summary><strong>#1：</strong>先确认方案能成立，再投入完整实现</summary>
<br>
Q：器件熟悉、例程能运行，还不足以证明它满足这次任务的性能、接口和环境要求。等完整代码写完才发现关键能力不够，留给调整的时间已经很少。

A：[竞赛验证](skills/stm32-skills/references/competition-validation.md) 要求先核对实际需求，把未证实的关键能力单独验证。AI 提出的选型和参数应说明依据，保留待实测项。

</details>

<details>
<summary><strong>#2：</strong>已经出现的异常，需要查到原因</summary>
<br>
Q：换个位置、调整阈值或增加延时之后，现象可能暂时消失，但原来的触发条件仍可能在现场重现。

A：[调试取证](skills/stm32-skills/references/debugging.md) 要求保留触发条件，用原始数据、寄存器和调用链验证原因。临时绕过要记录限制，修复后按原条件复测。

</details>

<details>
<summary><strong>#3：</strong>跑通之后，还要检查它依赖什么条件</summary>
<br>
Q：实验室里的一次成功，可能依赖固定光照、供电、摆放位置或启动顺序；这些条件变化后，结果未必成立。

A：[上电与联调](skills/stm32-skills/references/bringup-and-integration.md) 检查完整链路，[竞赛验证](skills/stm32-skills/references/competition-validation.md) 按实际风险选择重复测试。AI 需要区分编译通过、主机测试和实物结果，说明覆盖了哪些条件。

</details>

<details>
<summary><strong>#4：</strong>切换方案前，先定位失败发生在哪一层</summary>
<br>
Q：通信、接线、数据解释或算法中的任一环节出错，都可能表现为整机失效。原因未明就推翻方案，会把尚未解决的问题带进下一轮实现。

A：[固件开发](skills/stm32-skills/references/firmware-development.md) 与 [联调流程](skills/stm32-skills/references/bringup-and-integration.md) 沿信号、驱动、数据、业务和输出逐段检查。是否换方案，要结合故障证据、实现代价和剩余时间判断。

</details>

<details>
<summary><strong>#5：</strong>让每次调试都留下可复用的依据</summary>
<br>
Q：只记住“上次这样改就好了”，却没有保留版本、参数和测试条件，换人维护或重新上电时仍要从头摸索。

A：[代码规范](skills/stm32-skills/references/coding-style.md) 保持实现便于阅读，[可靠性检查](skills/stm32-skills/references/reliability.md) 明确有效性和错误路径，交付时记录源码、参数、硬件与验证结果的对应关系，让后续修改有据可查。

</details>

## 文件说明

### 技能入口

| 文件 | 说明 |
|---|---|
| [SKILL.md](skills/stm32-skills/SKILL.md) | 定义适用任务、工作流程和编辑边界，按需加载参考文档。 |
| [agents/openai.yaml](skills/stm32-skills/agents/openai.yaml) | 配置 Codex 的技能显示名称、简介和默认提示词。 |

### 参考文档

| 文件 | 说明 |
|---|---|
| [coding-style.md](skills/stm32-skills/references/coding-style.md) | 命名、注释、标志分组、控制语句和排版规范。 |
| [firmware-development.md](skills/stm32-skills/references/firmware-development.md) | 资源归属、单处初始化、HAL 状态、IRQ 回调和 DMA 缓冲区管理。 |
| [build-and-programming.md](skills/stm32-skills/references/build-and-programming.md) | 开发链验收、Keil/Arm 构建、映像转换、STM32CubeProgrammer CLI、烧录验证与分层故障排查。 |
| [reliability.md](skills/stm32-skills/references/reliability.md) | 数据有效性、共享状态、时间回绕、数值边界、峰值资源与时序预算和分层验证。 |
| [debugging.md](skills/stm32-skills/references/debugging.md) | 源码与映像对应、SVD 获取来源、调试工具选择、故障现场保留和证据记录。 |
| [sampling-records.md](skills/stm32-skills/references/sampling-records.md) | 结构化采样记录、JSONL 示例、读取失败与采样一致性边界。 |
| [bringup-and-integration.md](skills/stm32-skills/references/bringup-and-integration.md) | 上电检查、跨专业接口与物理响应核对、增量联调和回归、接口变化后的证据复核、安装与现场部署、标定记录。 |
| [competition-validation.md](skills/stm32-skills/references/competition-validation.md) | 赛题验收点与状态转换表、独立验收样本、范围与重复测试、现场测评和提交演练、版本对应与交付复现。 |


## 参考来源

<details>
<summary>GitHub Skills</summary>

- [Mindrally / embedded-stm32](https://github.com/Mindrally/skills/blob/main/embedded-stm32/SKILL.md)
- [XZhaoSudo / stm32-debug](https://github.com/XZhaoSudo/stm32debug-skill/blob/main/SKILL.md)
- [EricSun787 / stm32-development-workflow](https://github.com/EricSun787/stm32-development-workflow/blob/main/README_CN.md)
- [Jeffallan / embedded-systems](https://github.com/Jeffallan/claude-skills/blob/main/skills/embedded-systems/SKILL.md)

</details>

<details>
<summary>本人和社区参赛经验</summary>

以下复盘用于提炼开发与验证流程；帖子中的参数、技术归因和比赛要求仍需结合当前器件文档、实测和当届规则核对。

- **技能作者本人参赛经历**：有赛道或固定路径的比赛，赛前至少在比赛赛道上实跑两次，并记录参数或录制视频；已纳入本技能的强建议与竞赛验证要求。此项由作者直接提供，未附公开链接。
- [CSDN：三年电赛总结](https://blog.csdn.net/weixin_49821504/article/details/132242844)：先验证关键能力、追查已出现的异常，并覆盖实际环境条件，避免频繁换方案或凭少数成功测试判断稳定性。
- [CSDN：2020 电赛 E 题复盘](https://blog.csdn.net/qq_45923860/article/details/117828157)：模拟电路、采样计算与串口显示的完整链路，以及测评前器件、信号线和连接状态的检查。
- [RoboMaster：鸿烈战队经验](https://bbs.robomaster.com/article/8788)：机械、电控与视觉之间的任务依赖和进度衔接，以及整机设计、队员培训与经验交接。
- [电子发烧友：2013 全国电赛感受与讨论](https://bbs.elecfans.com/m/jishu_369871_1_1.html)：早期参赛经历与备赛讨论参考；当前正文访问受限，未据此补充具体技术结论。
- [RoboMaster：RobotPilots 传承分析](https://bbs.robomaster.com/article/1970326?source=11)：战队组织建设与经验传承参考；当前可读取页面仅包含标题和分类信息。
- [EEWORLD：2025 电赛参赛总结](https://bbs.eeworld.com.cn/thread-1323525-1-1.html)：固定元件组合的测试覆盖不足、功能扩展时的内存限制与现场接线问题。
- [21ic：2011 全国大学生电子设计竞赛经验总结](https://www.21ic.com/chongdian/zhenxin/2017-06-13/724273.html)：少数频点测试的局限与测量仪器操作。
- [博客园：2023 年电赛 E 题完整设计暨电赛全记录](https://www.cnblogs.com/switch-swq/p/18704875)：通信时序、自启动、重复执行与临近交付的改动。
- [博客园：2022 年 10 月电赛经验总结](https://www.cnblogs.com/sosoeeee/p/16820505.html)：模块验收与完整依赖、参数的版本保存。
- [Fun_Cheong：关于我的电赛是怎么寄掉的](https://funcheong.cn/index.php/archives/27/)：偶发启动异常、重启后恢复与尚未确认的根因。
- [HongLiu：2025 电赛 A 题复盘](https://hongliu.icu/2025/08/Diansai_25/)：准备模块的验证范围、供电范围与整机组合问题。
- [素颜：25 年电赛总结](https://suyanblog.cn/25_elc/index.html)：控制性能与底层驱动能力的反思，驱动归因仍属作者推测。
- [CSDN：2025 年 C 题电赛总结](https://aiot.csdn.net/69df604354b52172bc6a10a3.html)：现场测量操作、装配与运输后的接线检查。
- [NickQ：第九届蓝桥杯嵌入式比赛体会与备赛经验](https://www.cnblogs.com/NickQ/p/8721317.html)：资料、驱动、构建下载与板卡启动的开发链检查；旧届规则与板卡配置不直接沿用。
- [腾讯云：蓝桥杯嵌入式之比赛总结](https://developer.cloud.tencent.com/article/1477916)：精简需求拆解、模块叠加后的异常隔离与已有功能回归。
- [CSDN：嵌入式 16 届省赛复盘记录](https://openvela.csdn.net/694bbd6e5b9f5f31781a62ba.html)：业务调试前核对外设测量量级，关注负差值与跨档输入；赛后改进方案仍需验证。
- [CSDN：第十三届第一场蓝桥杯嵌入式主观题讲解](https://openvela.csdn.net/694a6edd5b9f5f31781a0569.html)：从真题训练中提炼状态转换、异常报文和界面恢复用例，不将示例代码视为已验收实现。
- [Yurun / RoboWalker：2026 RoboMaster 区域赛记录](https://blog.luonto.me/zh/posts/robomaster-26-regional/)：集成后的增量回归、调试与实赛条件差异，部分故障仍未解决。
- [华南虎：RM2025 英雄机械结构设计报告](https://bbs-web-static.robomaster.com/07f510bc303a4da0a58713c1a29575771756092800041/RM2025-%E5%8D%8E%E5%8D%97%E7%90%86%E5%B7%A5%E5%A4%A7%E5%AD%A6-%E5%8D%8E%E5%8D%97%E8%99%8E-%E8%8B%B1%E9%9B%84%E6%9C%BA%E6%A2%B0%E7%BB%93%E6%9E%84%E8%AE%BE%E8%AE%A1%E6%8A%A5%E5%91%8A.pdf)：跨专业转速配比核对，以及接口前提变化后对既有试验结果的复核。
- [Thybing：TI-Cup2025-E 题目分析与方案](https://github.com/Thybing/TI-Cup2025-E/blob/main/doc/README.md)：需求分解、控制量单位，以及角速度请求到步进脉冲的转换关系。
- [TATAzml：中国智能制造挑战赛（西门子杯）经验分享](https://www.cnblogs.com/tatazml/p/16099286.html)：将主机、虚拟机、网卡与设备连接纳入部署检查，按条件组织工艺动作。
- [DynamicLoader：2023 全国电赛寄录](https://www.dyldr.top/life/nuedc2023)：器件逐件验收、仪器排查，以及现场对焦和安装摆位；本次通过搜索缓存读取正文。
- [CuiFrost：云台瞄准系统电赛复盘](https://cuifrost.cn/blog/nuedc-laser-target/)：完整运动范围内的走线检查、现场逐层排查与参数/结构版本记录；本次通过搜索缓存读取正文。

</details>

<details>
<summary>官方技术文档与技能安装说明</summary>

- [ST AN4031：DMA](https://www.st.com/resource/en/application_note/an4031-using-the-stm32f2-stm32f4-and-stm32f7-series-dma-controller-stmicroelectronics.pdf)
- [Arm CMSIS：Core Register Access](https://arm-software.github.io/CMSIS_5/Core/html/group__Core__Register__gr.html)
- [GDB：Watchpoints](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Set-Watchpoints.html)
- [GDB：Optimized Code](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Optimized-Code.html)
- [OpenAI：Build skills](https://learn.chatgpt.com/docs/build-skills)
- [Claude Code：Skills](https://code.claude.com/docs/en/skills)
- [DeepSeek Harness：Skills](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/subsystems/skills.md)
- [Vercel Skills CLI](https://github.com/vercel-labs/skills)

</details>
