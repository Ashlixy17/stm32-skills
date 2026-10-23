# STM32 Firmware Skill

面向通用 STM32 C 工程的中文 AI 协作技能，将日常开发检查与有证据的调试流程整合在一起，不绑定具体芯片型号、开发板或应用项目。

支持 CubeMX 生成工程与独立手写工程，沿用项目已有的库、构建系统、IDE、编译器和调试环境。代码风格采用本库的默认约定，不是 ST 官方编码标准；项目已有更具体且有效的用户规则时，以当前约定为准。

## 包含什么

- **代码规范**：命名、逐项中文注释、标志分组、完整花括号、禁用三元表达式、函数之间两行空白。
- **生成代码边界**：CubeMX 文件只编辑指定 USER CODE 区，其他工程遵守各自生成与手写边界；外设初始化有单一归属。
- **HAL 与 DMA**：处理失败/忙/超时，区分请求接受与传输完成，明确缓冲区所有权、发布和复用条件。
- **分层验证**：分别报告源码检查、主机回放、实际目标构建及实物观测。
- **调试取证**：核对源码、ELF/AXF、烧录映像和运行版本，结合 SVD、断点、观察点、寄存器与调用栈逐项检验假设。

这是指令与参考文件组成的技能，不包含编译器、烧录工具、调试服务器、自动代码拦截器或上游项目脚本。使用已配置的工具，不要求安装全部调试后端。

## 目录

```text
stm32-firmware/
├── README.md
├── SKILL.md
├── agents/
│   └── openai.yaml
└── references/
    ├── coding-style.md
    ├── firmware-development.md
    ├── reliability.md
    ├── debugging.md
    └── sources.md
```

[SKILL.md](SKILL.md) 是代理入口，参考文件按任务加载。具体型号、引脚、时钟、外设资源、应用策略、提交规则与构建归档规则从正在处理的工程读取，本库不附带项目专用配置。

## 安装与使用

将完整 `stm32-firmware` 目录放到以下一个位置，并保留内部结构：

- 当前项目：`<项目根目录>/.agents/skills/stm32-firmware/`。
- 个人目录：`~/.agents/skills/stm32-firmware/`。

不要只复制 `SKILL.md`，也不要在多个发现目录重复安装同名技能。具体发现位置和调用方式以 [OpenAI 官方技能文档](https://learn.chatgpt.com/docs/build-skills) 为准。

在支持技能的 Codex 环境中，可用以下请求：

```text
使用 $stm32-firmware 只读检查这个 ADC DMA 模块，重点检查缓冲区交接和错误路径，不修改代码。

使用 $stm32-firmware 按已经确认的设计实现驱动，遵守当前工程的生成与手写代码边界，并运行实际目标构建。

使用 $stm32-firmware 根据这份 AXF、构建日志和故障快照分析卡死；目前只做离线分析，不连接设备。
```

技能按任务匹配使用，也支持明确提及。需要实际连接、复位、烧录或修改配置时，按已有任务授权执行；安装技能本身不授予这些权限。

## 整合来源

本版重点整合：

- [Mindrally / embedded-stm32](https://github.com/Mindrally/skills/blob/main/embedded-stm32/SKILL.md)：生成代码边界、单处初始化、HAL 状态处理、DMA 管理和分层测试。
- [XZhaoSudo / stm32-debug](https://github.com/XZhaoSudo/stm32debug-skill/blob/main/SKILL.md)：固件产物与符号、SVD、断点/观察点、寄存器、调用栈和调试会话的组合使用。

内容结合用户约定重新编写，未复制或捆绑上述仓库的代码模板与工具脚本。来源版本、既有补充参考与未照搬内容见 [sources.md](references/sources.md)。

## 上传 GitHub

本目录可作为独立仓库内容，建议仓库名 `stm32-firmware`。将本目录中的 `README.md`、`SKILL.md`、`agents/`、`references/` 放在仓库根目录；不需要附带具体固件工程、编译产物、调试缓存或个人配置。

使用本项目发布包时先解压再上传其中的文件，不要只将 ZIP 作为仓库唯一内容。提交远端、创建仓库与许可证选择由发布者决定。
