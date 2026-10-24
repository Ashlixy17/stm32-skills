<h1 align="center">stm32-skills</h1>

<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/Platform-STM32-03234B?logo=stmicroelectronics&logoColor=white">
</p>

<p align="center">
  A general-purpose STM32 skill library for AI agents
  <br>
  <strong>Coding conventions · Firmware development · Evidence-based debugging · Competition experience</strong>
</p>
<p align="center">
  <a href="README.md">简体中文</a> | English
</p>

## Features

- **Coding conventions**: Consistent naming, per-item comments, flag grouping, and formatting; braces for all control statements and no ternary expressions.
- **Firmware development**: Respect CubeMX USER CODE boundaries, keep initialization in one place, and check HAL status handling, IRQ callbacks, and DMA buffer handoff.
- **Build and programming**: Keep the existing Keil/Arm or GCC toolchain, use STM32CubeProgrammer CLI, and isolate compile, link, connection, and programming failures.
- **Debugging with evidence**: Match source, ELF/AXF, running firmware, and SVD; investigate faults with breakpoints, watchpoints, registers, and call stacks.
- **Bring-up and integration**: Check power, wiring, command-to-physical-response mappings, and complete data paths; integrate incrementally, regress existing functions, and record calibration and parameter changes.
- **Mandatory wiring rules**: Complete two verification passes for wiring inspections and operations that could damage components. Stop the affected step and ask the user when a potentially damaging connection is uncertain. Recheck after changes to wiring, boards, or relevant power/output configuration.
- **Competition validation**: Map tasks into acceptance and state-transition tables; select development-chain checks, repeated tests, recovery checks, field-deployment rehearsals, and delivery procedures.
- **Layered validation**: Distinguish source inspection, host tests, target builds, and physical results, with evidence for each conclusion.

Supports CubeMX and handwritten projects using existing HAL/LL libraries, build systems, and debug tools, without targeting a specific chip or board. Skill files are in English; firmware comments use the language chosen by the user, or the project's existing comment language when unspecified. Other coding conventions follow the current project rules. See [Coding style](skills/stm32-skills/references/coding-style.md).

## Quick start

Requires Node.js 22.20 or later. Run the appropriate command from your target project's root directory:

<details>
<summary><strong>Claude Code</strong></summary>

```bash
npx skills@latest add Ashlixy17/stm32-skills --skill stm32-skills -a claude-code
```

Invoke with `/stm32-skills` after installation.

</details>

<details>
<summary><strong>Codex</strong></summary>

```bash
npx skills@latest add Ashlixy17/stm32-skills --skill stm32-skills -a codex
```

Invoke with `$stm32-skills` after installation.

</details>

<details>
<summary><strong>DeepSeek Harness</strong></summary>

```bash
npx skills@latest add Ashlixy17/stm32-skills --skill stm32-skills -a universal
```

Installs to the project's shared `.agents/skills/` directory. Ask the agent to use `stm32-skills`.

</details>

<details>
<summary><strong>Other agents</strong></summary>

```bash
npx skills@latest add Ashlixy17/stm32-skills --skill stm32-skills
```

Follow the prompts to select your agent.

</details>

<details>
<summary>Local installation</summary>

Download or clone the repository, then run from its root directory. Replace `codex` with `claude-code` or `deepseek-harness` to install to that agent's directory.

```powershell
.\scripts\install.ps1 -Agent codex -ProjectRoot 'D:\Code project\your-project'
```

```bash
bash scripts/install.sh --agent codex --project-root '/path/to/your-project'
```

Use `-Scope user` or `--scope user` for personal installation, and `-WhatIf` or `--dry-run` to preview. For manual installation, copy the entire `skills/stm32-skills/` directory into your agent's skills directory.

</details>

## Q&A: Why these skills exist

**My electronics competition experience** and this [three-year electronics competition retrospective on CSDN](https://blog.csdn.net/weixin_49821504/article/details/132242844) taught me that experience, effort, and a successful trial do not replace validation of the current design. AI can speed up implementation, but it also needs to explain design choices, known faults, and physical test results.

<details>
<summary><strong>#1:</strong> Validate feasibility before building the full solution</summary>
<br>
Q: Familiar hardware and a working example do not establish that a design meets this task's performance, interface, and environmental requirements. Discovering a critical limitation after implementation leaves little time to adapt.

A: [Competition validation](skills/stm32-skills/references/competition-validation.md) starts with actual requirements and small checks of unproven capabilities. AI-proposed hardware choices and parameters need supporting evidence and explicit pending measurements.

</details>

<details>
<summary><strong>#2:</strong> Investigate faults that have already appeared</summary>
<br>
Q: Moving the device, adjusting a threshold, or adding a delay may hide a symptom while leaving its original trigger available to recur in the field.

A: [Debugging with evidence](skills/stm32-skills/references/debugging.md) preserves trigger conditions and tests causes using raw data, registers, and call paths. Record the limits of temporary workarounds and retest fixes under the original conditions.

</details>

<details>
<summary><strong>#3:</strong> Check which conditions a successful run depends on</summary>
<br>
Q: A successful lab run may depend on fixed lighting, power, placement, or startup order. Results may change when those conditions do.

A: [Bring-up and integration](skills/stm32-skills/references/bringup-and-integration.md) checks the complete path, while [Competition validation](skills/stm32-skills/references/competition-validation.md) selects repeated tests based on actual risks. AI must distinguish build success, host tests, and physical results, and state the conditions covered.

</details>

<details>
<summary><strong>#4:</strong> Locate the failing stage before changing the design</summary>
<br>
Q: A fault in communication, wiring, data interpretation, or algorithms can appear as a system failure. Replacing the design before finding the cause can carry the unresolved problem into the next implementation.

A: [Firmware development](skills/stm32-skills/references/firmware-development.md) and [Integration](skills/stm32-skills/references/bringup-and-integration.md) inspect signals, drivers, data, business logic, and outputs in stages. Decide whether to change the design using fault evidence, implementation cost, and remaining time.

</details>

<details>
<summary><strong>#5:</strong> Leave reusable evidence after each debugging session</summary>
<br>
Q: Remembering only that a previous change worked, without its version, parameters, and test conditions, forces the next maintainer to investigate again after a handoff or restart.

A: [Coding style](skills/stm32-skills/references/coding-style.md) keeps implementations readable, and [Reliability checks](skills/stm32-skills/references/reliability.md) make validity and error paths explicit. Record the relationship between source, parameters, hardware, and validation results so future changes have a reliable baseline.

</details>

## File reference

### Skill entrypoint

| File | Description |
|---|---|
| [SKILL.md](skills/stm32-skills/SKILL.md) | Defines task scope, workflow, and editing boundaries, and routes to relevant references. |
| [agents/openai.yaml](skills/stm32-skills/agents/openai.yaml) | Sets the skill's Codex display name, description, and default prompt. |

### Reference documents

| File | Description |
|---|---|
| [coding-style.md](skills/stm32-skills/references/coding-style.md) | Naming, comments, flag grouping, control flow, and formatting. |
| [firmware-development.md](skills/stm32-skills/references/firmware-development.md) | Resource ownership, initialization, HAL status, IRQ callbacks, and DMA buffers. |
| [build-and-programming.md](skills/stm32-skills/references/build-and-programming.md) | Development-chain checks, Keil/Arm builds, image conversion, STM32CubeProgrammer CLI, programming verification, and troubleshooting by layer. |
| [reliability.md](skills/stm32-skills/references/reliability.md) | Data validity, shared state, tick wraparound, numeric boundaries, peak resource and timing budgets, and layered validation. |
| [debugging.md](skills/stm32-skills/references/debugging.md) | Source/image correspondence, SVD sources, tool selection, fault preservation, and evidence records. |
| [sampling-records.md](skills/stm32-skills/references/sampling-records.md) | Structured sampling records, JSONL examples, read failures, and sampling consistency limits. |
| [bringup-and-integration.md](skills/stm32-skills/references/bringup-and-integration.md) | Power-up checks, cross-discipline physical interface verification, incremental integration and regression, evidence review after interface changes, installation/field setup, and calibration. |
| [competition-validation.md](skills/stm32-skills/references/competition-validation.md) | Task acceptance and state-transition tables, independent acceptance samples, range coverage, repeated tests, field assessment/submission rehearsals, version correspondence, and reproducible delivery. |

## Sources

<details>
<summary>GitHub skill repositories</summary>

- [Mindrally / embedded-stm32](https://github.com/Mindrally/skills/blob/main/embedded-stm32/SKILL.md): Generated-code boundaries, single initialization ownership, HAL errors, DMA management, and layered tests.
- [XZhaoSudo / stm32-debug](https://github.com/XZhaoSudo/stm32debug-skill/blob/main/SKILL.md): Debugging with firmware symbols, SVD, breakpoints, watchpoints, registers, and call stacks.
- [EricSun787 / stm32-development-workflow](https://github.com/EricSun787/stm32-development-workflow/blob/main/README_CN.md): Toolchain, compile/link troubleshooting, ST-LINK, and STM32CubeProgrammer CLI workflows; command details checked against official documentation.
- [Jeffallan / embedded-systems](https://github.com/Jeffallan/claude-skills/blob/main/skills/embedded-systems/SKILL.md): Shared-state synchronization, resource use, and timing checks.

</details>

<details>
<summary>Community competition experience</summary>

These retrospectives inform development and validation practices. Check their parameters, technical explanations, and competition requirements against current device documentation, measurements, and the applicable event rules.

- **Skill author's own competition experience**: Run at least twice on the competition track/fixed path before the event and record parameters or video. Incorporated into this skill's strong recommendations and competition validation requirements; supplied directly by the author, with no public link provided.
- [CSDN: Three-year electronics competition retrospective](https://blog.csdn.net/weixin_49821504/article/details/132242844): Verify critical capabilities, investigate observed anomalies, and test actual environmental conditions; avoid frequent design changes or inferring stability from a few successful runs.
- [CSDN: 2020 competition, Problem E retrospective](https://blog.csdn.net/qq_45923860/article/details/117828157): The complete analog-circuit, sampling/computation, and serial-display path, plus component, signal-cable, and connection checks before assessment.
- [RoboMaster: Honglie team experience](https://bbs.robomaster.com/article/8788): Dependencies and scheduling across mechanical, control, and vision work, along with whole-system design, member training, and knowledge handoff.
- [Elecfans: 2013 national electronics competition reflections and discussion](https://bbs.elecfans.com/m/jishu_369871_1_1.html): Background on earlier participation and preparation; the body is currently inaccessible, so no additional technical conclusions are attributed to it.
- [RoboMaster: RobotPilots knowledge transfer analysis](https://bbs.robomaster.com/article/1970326?source=11): Team organization and knowledge-transfer reference; the currently readable page provides only the title and category metadata.
- [EEWORLD: 2025 electronics competition retrospective](https://bbs.eeworld.com.cn/thread-1323525-1-1.html): Limited coverage with fixed component combinations, memory limits during feature expansion, and field wiring problems.
- [21ic: 2011 national electronics competition retrospective](https://www.21ic.com/chongdian/zhenxin/2017-06-13/724273.html): Limits of testing only a few frequency points and operating measurement instruments.
- [Cnblogs: 2023 competition, Problem E design and retrospective](https://www.cnblogs.com/switch-swq/p/18704875): Communication timing, autostart, repeated operation, and changes near delivery.
- [Cnblogs: October 2022 competition retrospective](https://www.cnblogs.com/sosoeeee/p/16820505.html): Module acceptance and preserving complete dependencies and parameters.
- [Fun_Cheong: How my competition entry failed](https://funcheong.cn/index.php/archives/27/): Intermittent startup failures, recovery after restart, and an unconfirmed root cause.
- [HongLiu: 2025 competition, Problem A retrospective](https://hongliu.icu/2025/08/Diansai_25/): Prepared modules' tested operating ranges, supply limits, and integration problems.
- [Suyan: 2025 competition retrospective](https://suyanblog.cn/25_elc/index.html): Reflections on control performance and low-level drive capability; the drive explanation remains the author's hypothesis.
- [CSDN: 2025 competition, Problem C retrospective](https://aiot.csdn.net/69df604354b52172bc6a10a3.html): Field measurement procedures, assembly, and connection checks after transport.
- [NickQ: Ninth Blue Bridge Cup embedded competition experience](https://www.cnblogs.com/NickQ/p/8721317.html): Check documents, drivers, builds/downloads, and device startup; old event rules and board settings are not current defaults.
- [Tencent Cloud: Blue Bridge Cup embedded competition retrospective](https://developer.cloud.tencent.com/article/1477916): Concise task decomposition, isolating failures after module integration, and regression checks for existing functions.
- [CSDN: 16th embedded provincial competition retrospective](https://openvela.csdn.net/694bbd6e5b9f5f31781a62ba.html): Check peripheral measurement scale before business debugging, negative differences, and transient inputs; proposed post-event improvements still need validation.
- [CSDN: 13th Blue Bridge Cup embedded task walkthrough](https://openvela.csdn.net/694a6edd5b9f5f31781a0569.html): State transitions, malformed-message cases, and page recovery from task practice; example code is not an accepted implementation.
- [Yurun / RoboWalker: 2026 RoboMaster regional retrospective](https://blog.luonto.me/zh/posts/robomaster-26-regional/): Incremental regression after integration and differences between debugging and competition conditions; some faults remain unresolved.
- [South China Tiger: RM2025 hero mechanical design report](https://bbs-web-static.robomaster.com/07f510bc303a4da0a58713c1a29575771756092800041/RM2025-%E5%8D%8E%E5%8D%97%E7%90%86%E5%B7%A5%E5%A4%A7%E5%AD%A6-%E5%8D%8E%E5%8D%97%E8%99%8E-%E8%8B%B1%E9%9B%84%E6%9C%BA%E6%A2%B0%E7%BB%93%E6%9E%84%E8%AE%BE%E8%AE%A1%E6%8A%A5%E5%91%8A.pdf): Cross-discipline speed-ratio verification and reviewing earlier test evidence after interface assumptions change.
- [Thybing: TI-Cup2025-E task and design analysis](https://github.com/Thybing/TI-Cup2025-E/blob/main/doc/README.md): Task decomposition, control units, and conversion from angular-velocity requests to stepper pulses.
- [TATAzml: Siemens Cup / CIMC experience](https://www.cnblogs.com/tatazml/p/16099286.html): Include the host, virtual machine, network adapter, and device connection in deployment checks; organize process actions by their conditions.
- [DynamicLoader: 2023 national electronics competition retrospective](https://www.dyldr.top/life/nuedc2023): Individual component acceptance, instrument-based diagnosis, field focus, and mounting position; the body was read through a search cache.
- [CuiFrost: Gimbal targeting competition retrospective](https://cuifrost.cn/blog/nuedc-laser-target/): Cable routing across the complete motion range, layered field diagnosis, and parameter/mechanical-version records; the body was read through a search cache.

</details>

<details>
<summary>Technical documentation and skill installation</summary>

- [ST AN4031: DMA](https://www.st.com/resource/en/application_note/an4031-using-the-stm32f2-stm32f4-and-stm32f7-series-dma-controller-stmicroelectronics.pdf)
- [Arm CMSIS: Core Register Access](https://arm-software.github.io/CMSIS_5/Core/html/group__Core__Register__gr.html)
- [GDB: Watchpoints](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Set-Watchpoints.html)
- [GDB: Optimized Code](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Optimized-Code.html)
- [OpenAI: Build skills](https://learn.chatgpt.com/docs/build-skills)
- [Claude Code: Skills](https://code.claude.com/docs/en/skills)
- [DeepSeek Harness: Skills](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/subsystems/skills.md)
- [Vercel Skills CLI](https://github.com/vercel-labs/skills)

</details>
