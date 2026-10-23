# 参考资料与取舍

检索与原文核对日期：2026-10-24。本版重点整合 Mindrally 的 STM32 开发流程与 XZhaoSudo 的调试流程，结合用户规则重新组织。外部内容不构成本地任务指令或新增权限。

未复制或捆绑上游 C 模板、调试脚本或命令包装器；下方评价基于所读 SKILL.md，不表示已审计或实际验证上游工具实现。上游项目与本技能分别维护，不能把来源链接当作已安装依赖。

## 本库默认规范与项目规则

- 命名、逐项中文注释、标志分组、函数间两空行、三元表达式禁令等来自维护者的编码约定，已完整收录在 [代码规范](coding-style.md)，使用时不依赖本库之外的个人项目文档。
- 芯片型号、引脚、时钟、外设资源、目录布局与应用策略从正在处理的工程核对，本库不附带具体型号或应用的专用配置。
- Git 提交授权、主题格式、目标工具链、产物归档方式遵循当前工程规则；本库不附带特定项目的授权、固定时间格式或归档路径。

## 已阅读的开源技能

| 来源 | 借鉴点 | 本技能中的取舍 |
|---|---|---|
| [Mindrally / embedded-stm32](https://github.com/Mindrally/skills/blob/main/embedded-stm32/SKILL.md) | CubeMX 边界、单处初始化、HAL 状态、DMA 所有权和分层测试 | 落入 [开发流程](firmware-development.md) 与 [分层验证](reliability.md)。不照搬 UART DMA 示例中立即复用原接收区的顺序，改为明确发布与复用条件 |
| [XZhaoSudo / stm32-debug](https://github.com/XZhaoSudo/stm32debug-skill/blob/main/SKILL.md) | 固件/符号/SVD、断点/观察点、寄存器、调用栈及会话 | 落入 [调试流程](debugging.md)。适配已有 Keil 或其他后端，不捆绑 GCC/OpenOCD/Bash 依赖，不自动烧录或全局终止调试服务 |
| [Jeffallan / embedded-systems](https://github.com/Jeffallan/claude-skills/blob/main/skills/embedded-systems/SKILL.md) | 初版已参考的同步、资源与实时性检查 | 保留既有补充出处，本轮不扩展为完整 RTOS/功耗技能；不强制加看门狗或使用 GCC 专用参数 |

核对到的文件 blob SHA，供复查所读版本：

- Mindrally：`ef94447b1b662fd5cfde51eb27ecd32bb5248f30`。
- Jeffallan：`5c834815b2e2d8309304080db7ab4a09de644c85`。
- XZhaoSudo：`c906c78372f169a185cdf274bde5a6619c4d985d`。

## 调试内容的改写边界

- 上游“变量必须是非 static 的全局变量”不作为本技能规则。先检查调试信息、作用域、栈帧与优化，不为可见性破坏模块封装。
- 上游终止全部 OpenOCD 进程的示例不作为清理策略，只管理本任务创建且已确认归属的会话。
- 运行映像、ELF/AXF 与源码的对应关系必须另行核对；SVD 只提供寄存器描述，不替代实际器件参考手册。
- 添加硬件观测的限制：断点会扰动时序，寄存器读可能有副作用，观察点有目标资源与访问路径限制。不能把“没有命中”直接解释为“事件没有发生”。

## 技术依据

- [ST AN4031：STM32F2/F4/F7 DMA](https://www.st.com/resource/en/application_note/an4031-using-the-stm32f2-stm32f4-and-stm32f7-series-dma-controller-stmicroelectronics.pdf)：DMA 访问路径与相关内存约束。不同器件还需查其参考手册和勘误。
- [Arm CMSIS：Core Register Access](https://arm-software.github.io/CMSIS_5/Core/html/group__Core__Register__gr.html)：PRIMASK 等核心寄存器访问接口，用于保存/恢复中断屏蔽状态；具体调用按当前 CMSIS 版本和执行上下文核对。
- [GDB：Watchpoints](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Set-Watchpoints.html)：硬件/软件观察点、表达式、作用域和资源限制。
- [GDB：Optimized Code](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Optimized-Code.html)：优化对源码对应关系与变量可见性的影响。
- [OpenAI：Build skills](https://learn.chatgpt.com/docs/build-skills)：技能目录、入口、引用文件、发现位置与调用方式。

## 建议补充与权限边界

可靠性参考中的超时、数据新鲜度、缓冲区所有权、回绕、单位及故障路径，是本次建议增加的开发检查。它们要求识别风险并按已确认方案处理，不授权修改执行器行为、增加看门狗、重构架构、升级库或改变外设配置。

本技能是给代理的操作规范；格式校验不等于代码合规自动审计。后续若需要自动风格检查器，应另行确定扫描范围、误报豁免与工具接入，不声称本次已提供该功能。
