---
name: stm32-skills
description: Develop, review, and debug STM32 C firmware in CubeMX or handwritten projects. Check generated-code boundaries, HAL errors, DMA ownership, and target builds; diagnose faults with firmware symbols, SVD, breakpoints, registers, and call stacks. Use integration and competition guidance when those tasks are requested.
---

# STM32 Firmware Development and Debugging

Deliver changes that follow the current project's rules, can be verified with its toolchain, and remain maintainable. These instructions define checks for the agent; they do not provide an automatic code enforcement tool or establish hardware validation.

## Establish facts and authority

1. Read the task, applicable repository instructions, project rules, Git status, and relevant configuration, build files, and source. A source-only review does not authorize edits, builds, or commits; run validation when the task authorizes it.
2. Identify the working project versus reference inputs, exact MCU, HAL/LL or other library, compiler, target configuration, directories, handles, and interfaces. Do not introduce CubeMX into a handwritten project without an IOC.
3. Before business-code edits, explain the intended behavior, affected files, interfaces, configuration impact, and validation. Obtain design confirmation unless the relevant design and implementation are already authorized. Skill invocation does not grant additional permission to flash, push, migrate configuration, or enable outputs.
4. Current explicit user instructions override older conventions. Follow more specific, still-applicable project rules over this skill's defaults and state material differences. Pause only the part affected by an unresolved conflict; continue independent authorized work.
5. Surface mismatches between documentation, device identity, configuration, and the build target. Treat style preferences separately from hardware facts. Do not transfer pin, clock, register, library, or example parameters across STM32 families without checking the actual device documentation.

## Read only the relevant references

| Task | Required reference |
|---|---|
| Add or modify C/H files, or review code style | [Coding style](references/coding-style.md) |
| Drivers, initialization, HAL, IRQ, DMA, or sampling interfaces | [Firmware development](references/firmware-development.md) |
| Scheduling, control, recovery, or validation | [Reliability and validation](references/reliability.md) |
| Hangs, faults, peripheral failures, incorrect values, or timing investigations | [Debugging with evidence](references/debugging.md) |
| Initial power-up, module connections, system integration, or field tuning | [Bring-up and integration](references/bringup-and-integration.md) |
| Requested competition preparation, system acceptance, or reproducible delivery | [Competition validation and delivery](references/competition-validation.md) |

For firmware edits, also select validation layers from the reliability reference. Offline fault analysis does not require every development reference. An ordinary module edit does not automatically become a competition or whole-system acceptance task.

## Respect editing boundaries

- Change only task-related content. Preserve unrelated user changes, deliberate deletions, reference code, and vendor libraries. Avoid incidental refactoring and repository-wide formatting.
- Edit source and build files directly. Do not write or run scripts that bulk-rewrite source or project configuration. Existing read-only checks, tests, and build scripts may be used after inspecting their effects.
- In CubeMX-generated files, edit only inside existing paired `USER CODE BEGIN/END` regions. Do not move, enlarge, or fabricate markers around generated content. Follow other generators' extension mechanisms. Handwritten files follow their project conventions without fabricated user regions.
- For CubeMX-managed pins, alternate functions, clocks, ADC, DMA, timers, NVIC, or generation settings, explain the affected file/setting, current value, proposed value, and impact. Obtain configuration authorization, regenerate through CubeMX, and review the result. Do not bypass this boundary with duplicate initialization or register overrides in a user region.
- If an insertion point or required generation tool is unavailable, stop that dependency and explain the limitation. Do not edit first and ask afterward. Existing authorization for the specific change does not need to be requested again.
- Keep handwritten projects' existing configuration mechanisms and libraries. LL and register operations must follow the approved design and actual device documentation.
- Register new modules and include paths in the real build target using its existing project metadata. Build registration does not authorize edits to protected generated sections.
- Preserve required HAL/CMSIS/CubeMX symbols, handle names, callbacks, and IRQ signatures. Give each peripheral initialization and IRQ/callback entry one owner; do not duplicate handles or definitions.

## Work and verify

- Retain existing directories, dependencies, and initialization/application responsibilities. Add focused modules when needed; do not force an RTOS, CMSIS solution, or new architecture.
- Derive parameters from the current project, device documentation, and measurements. Record units, ranges, evidence, and unresolved assumptions for new parameters.
- During integration, check interface contracts and the complete data path before tuning. Record conditions, changes, and results. Use measured criteria and repeatable tests for system or competition acceptance.
- Before debugging, match source, executable image, symbols, and device description. Preserve the fault state before choosing observations. HEX/BIN files do not replace debug symbols in ELF/AXF; SVD does not replace the reference manual.
- Use the project's actual build and debug tools. Do not migrate the toolchain to run an example command. Clearly identify anything not connected, flashed, or observed.
- Review the actual diff for naming, the required firmware comment language, flag grouping, two empty lines between functions, generated-code boundaries, build registration, and error paths. Distinguish manual review from automated checks.
- Build firmware changes with the real target toolchain; a host build is not a target firmware build. Address new warnings. Report existing diagnostics or external blockers without suppressing checks or changing unrelated code.
- Stage and commit only when explicitly authorized by the user, including a still-applicable project rule granting that authority. Implementation, validation, or version preservation alone is not commit authorization. Before an authorized commit, inspect status, staged files, the staged diff, and `git diff --cached --check`. Include only task-related files; do not reset or clean away user work. Pushes and other remote mutations require their own authorization.

## Report the actual evidence

Explain the behavior change, affected files, and the result at each applicable layer:

| Layer | Supported conclusion |
|---|---|
| Source/static inspection | Style, boundaries, interfaces, and resource/build registration |
| Host tests or replay | Algorithm, state, failure, and boundary behavior for the tested inputs |
| Target firmware build | Compilation/linking for the named target/configuration, diagnostics, and resource use |
| Physical hardware | Actual device, running image, conditions, and observed behavior |

State unperformed or inapplicable layers. An old image is not evidence of a new build; build success does not prove flashing; replay does not prove physical behavior. Fault reports also need symptoms, hypotheses, observations, conclusions, and evidence limits. Report commit IDs or archived artifact paths only when those actions actually occurred. Commit conventions and build artifact archiving follow the current project's rules; do not create empty commits.
