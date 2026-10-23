<h1 align="center">stm32-skills</h1>

<p align="center">
  <a href="README.md">简体中文</a> | English
</p>

<p align="center">
  <img alt="Platform" src="https://img.shields.io/badge/Platform-STM32-03234B?logo=stmicroelectronics&logoColor=white">
</p>

<p align="center">
  A general-purpose STM32 skill library for AI agents
  <br>
  <strong>Coding conventions · Firmware development · Evidence-based debugging · Competition practice</strong>
</p>

## Features

- **Coding conventions**: Consistent naming, per-item comments, flag grouping, and formatting; braces for all control statements and no ternary expressions.
- **Firmware development**: Respect CubeMX USER CODE boundaries, keep initialization in one place, and check HAL status handling, IRQ callbacks, and DMA buffer handoff.
- **Debugging with evidence**: Match source, ELF/AXF, running firmware, and SVD; investigate faults with breakpoints, watchpoints, registers, and call stacks.
- **Bring-up and integration**: Check power, wiring, module interfaces, and complete data paths; record calibration and parameter changes.
- **Competition validation**: Select acceptance criteria, repeated tests, recovery checks, and delivery procedures for the task.
- **Layered validation**: Distinguish source inspection, host tests, target builds, and physical results, with evidence for each conclusion.

Supports CubeMX and handwritten projects using existing HAL/LL libraries, build systems, and debug tools, without targeting a specific chip or board. Skill files are in English; firmware comments default to Simplified Chinese. Existing project rules take precedence. See [Coding style](skills/stm32-skills/references/coding-style.md).

## Quick start

Requires Node.js 22.20 or later. Run the appropriate command from your target project's root directory:

<details>
<summary>Claude Code</summary>

```bash
npx skills@latest add Ashlixy17/stm32-skills --skill stm32-skills -a claude-code
```

Invoke with `/stm32-skills` after installation.

</details>

<details>
<summary>Codex</summary>

```bash
npx skills@latest add Ashlixy17/stm32-skills --skill stm32-skills -a codex
```

Invoke with `$stm32-skills` after installation.

</details>

<details>
<summary>DeepSeek Harness</summary>

```bash
npx skills@latest add Ashlixy17/stm32-skills --skill stm32-skills -a universal
```

Installs to the project's shared `.agents/skills/` directory. Ask the agent to use `stm32-skills`.

</details>

<details>
<summary>Other agents</summary>

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

## Why these skills exist

My competition experience and this [three-year electronics competition retrospective](https://blog.csdn.net/weixin_49821504/article/details/132242844) taught me that experience, effort, and a successful trial do not replace validation of the current design. AI can speed up implementation, but it also needs to explain design choices, known faults, and physical test results.

<details>
<summary>#1: Validate feasibility before building the full solution</summary>

Problem: Familiar hardware and a working example do not establish that a design meets this task's performance, interface, and environmental requirements. Discovering a critical limitation after implementation leaves little time to adapt.

Approach: [Competition validation](skills/stm32-skills/references/competition-validation.md) starts with actual requirements and small checks of unproven capabilities. AI-proposed hardware choices and parameters need supporting evidence and explicit pending measurements.

</details>

<details>
<summary>#2: Investigate faults that have already appeared</summary>

Problem: Moving the device, adjusting a threshold, or adding a delay may hide a symptom while leaving its original trigger available to recur in the field.

Approach: [Debugging with evidence](skills/stm32-skills/references/debugging.md) preserves trigger conditions and tests causes using raw data, registers, and call paths. Record the limits of temporary workarounds and retest fixes under the original conditions.

</details>

<details>
<summary>#3: Check which conditions a successful run depends on</summary>

Problem: A successful lab run may depend on fixed lighting, power, placement, or startup order. Results may change when those conditions do.

Approach: [Bring-up and integration](skills/stm32-skills/references/bringup-and-integration.md) checks the complete path, while [Competition validation](skills/stm32-skills/references/competition-validation.md) selects repeated tests based on actual risks. AI must distinguish build success, host tests, and physical results, and state the conditions covered.

</details>

<details>
<summary>#4: Locate the failing stage before changing the design</summary>

Problem: A fault in communication, wiring, data interpretation, or algorithms can appear as a system failure. Replacing the design before finding the cause can carry the unresolved problem into the next implementation.

Approach: [Firmware development](skills/stm32-skills/references/firmware-development.md) and [Integration](skills/stm32-skills/references/bringup-and-integration.md) inspect signals, drivers, data, business logic, and outputs in stages. Decide whether to change the design using fault evidence, implementation cost, and remaining time.

</details>

<details>
<summary>#5: Leave reusable evidence after each debugging session</summary>

Problem: Remembering only that a previous change worked, without its version, parameters, and test conditions, forces the next maintainer to investigate again after a handoff or restart.

Approach: [Coding style](skills/stm32-skills/references/coding-style.md) keeps implementations readable, and [Reliability checks](skills/stm32-skills/references/reliability.md) make validity and error paths explicit. Record the relationship between source, parameters, hardware, and validation results so future changes have a reliable baseline.

</details>

## File reference

### Skill entrypoint

- [SKILL.md](skills/stm32-skills/SKILL.md): Defines task scope, workflow, and editing boundaries, and routes to relevant references.
- [agents/openai.yaml](skills/stm32-skills/agents/openai.yaml): Sets the skill's Codex display name, description, and default prompt.

### Reference documents

- [coding-style.md](skills/stm32-skills/references/coding-style.md): Naming, comments, flag grouping, control flow, and formatting.
- [firmware-development.md](skills/stm32-skills/references/firmware-development.md): Resource ownership, initialization, HAL status, IRQ callbacks, and DMA buffers.
- [reliability.md](skills/stm32-skills/references/reliability.md): Data validity, shared state, tick wraparound, numeric boundaries, peak resource and timing budgets, and layered validation.
- [debugging.md](skills/stm32-skills/references/debugging.md): Source/image correspondence, tool selection, fault preservation, and evidence records.
- [bringup-and-integration.md](skills/stm32-skills/references/bringup-and-integration.md): Power-up checks, module operating ranges, measurement conditions, complete-path integration, actuator response, and calibration.
- [competition-validation.md](skills/stm32-skills/references/competition-validation.md): Competition criteria, independent acceptance samples, range coverage, repeated tests, field-operation rehearsals, version correspondence, and reproducible delivery.

## Sources

- [Mindrally / embedded-stm32](https://github.com/Mindrally/skills/blob/main/embedded-stm32/SKILL.md): Generated-code boundaries, single initialization ownership, HAL errors, DMA management, and layered tests.
- [XZhaoSudo / stm32-debug](https://github.com/XZhaoSudo/stm32debug-skill/blob/main/SKILL.md): Debugging with firmware symbols, SVD, breakpoints, watchpoints, registers, and call stacks.
- [Jeffallan / embedded-systems](https://github.com/Jeffallan/claude-skills/blob/main/skills/embedded-systems/SKILL.md): Shared-state synchronization, resource use, and timing checks.

<details>
<summary>Community competition experience</summary>

These retrospectives inform development and validation practices. Check their parameters, technical explanations, and competition requirements against current device documentation, measurements, and the applicable event rules.

- [CSDN: Three-year electronics competition retrospective](https://blog.csdn.net/weixin_49821504/article/details/132242844)
- [CSDN: 2020 competition, Problem E retrospective](https://blog.csdn.net/qq_45923860/article/details/117828157)
- [RoboMaster: Honglie team experience](https://bbs.robomaster.com/article/8788)
- [Elecfans: 2013 national electronics competition reflections and discussion](https://bbs.elecfans.com/m/jishu_369871_1_1.html)
- [RoboMaster: RobotPilots knowledge transfer analysis](https://bbs.robomaster.com/article/1970326?source=11)
- [EEWORLD: 2025 electronics competition retrospective](https://bbs.eeworld.com.cn/thread-1323525-1-1.html): Limited coverage with fixed component combinations, memory limits during feature expansion, and field wiring problems.
- [21ic: 2011 national electronics competition retrospective](https://www.21ic.com/chongdian/zhenxin/2017-06-13/724273.html): Limits of testing only a few frequency points and operating measurement instruments.
- [Cnblogs: 2023 competition, Problem E design and retrospective](https://www.cnblogs.com/switch-swq/p/18704875): Communication timing, autostart, repeated operation, and changes near delivery.
- [Cnblogs: October 2022 competition retrospective](https://www.cnblogs.com/sosoeeee/p/16820505.html): Module acceptance and preserving complete dependencies and parameters.
- [Fun_Cheong: How my competition entry failed](https://funcheong.cn/index.php/archives/27/): Intermittent startup failures, recovery after restart, and an unconfirmed root cause.
- [HongLiu: 2025 competition, Problem A retrospective](https://hongliu.icu/2025/08/Diansai_25/): Prepared modules' tested operating ranges, supply limits, and integration problems.
- [Suyan: 2025 competition retrospective](https://suyanblog.cn/25_elc/index.html): Reflections on control performance and low-level drive capability; the drive explanation remains the author's hypothesis.
- [CSDN: 2025 competition, Problem C retrospective](https://aiot.csdn.net/69df604354b52172bc6a10a3.html): Field measurement procedures, assembly, and connection checks after transport.

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
