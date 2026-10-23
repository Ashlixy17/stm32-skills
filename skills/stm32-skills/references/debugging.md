# Debugging with Evidence

Use for fault analysis, runtime inspection, and authorized hardware debugging. Work with tools already installed and appropriate for the project; this bundle supplies no debug server, probe driver, or upstream command wrappers.

## 1. Separate artifact analysis from device operations

- Source, build logs, ELF/AXF symbols, and exported register snapshots support offline analysis. Do not describe them as physical observations.
- Connecting, halting, stepping, resetting, flashing, and writing memory/registers are distinct operations. Stay within existing task authorization without requesting it again. Source inspection alone does not authorize resetting or reflashing.
- Determine whether the first connection attaches or resets/loads. Preserve an existing fault state before restarting, reflashing, or starting another debug server.
- Check how halting the CPU affects peripherals, communications, watchdogs, and external outputs. Do not assume every peripheral stops with the CPU; choose observations according to the current design.

## 2. Match source, image, and symbols

| Object | Facts to establish |
|---|---|
| Source | Repository revision, uncommitted changes, relevant configuration, actual source paths |
| Build target | MCU, target/configuration, compiler version, optimization and debug-information settings |
| ELF/AXF | Correct executable, symbols, and link addresses for the target; not an old or different target's file |
| HEX/BIN | Corresponding programming image; not a substitute for source-level symbols |
| Running firmware | Correspondence through existing programming records, memory verification, or an existing build identifier; timestamps are clues only |
| SVD | Actual device/family and version; reference manual and errata still define behavior |

When running-image correspondence is unproven, state that limitation before interpreting source lines. Missing debug information limits variables, line mapping, and backtraces but does not necessarily prevent register inspection.

## 3. Use the existing tools

- Prefer the current project's debug target and available interfaces: its IDE, CMSIS debugger, GDB/OpenOCD, or probe tools as configured. Do not require every backend or a particular supplier.
- Check probe, device, power/connection, protocol, and current session ownership. Diagnose connection errors before acting. Do not globally kill similarly named processes, erase the chip, or lower protection settings by default.
- Example scripts, ports, SVD paths, CPU frequencies, and commands are not project defaults. Do not invent tool results when no tool was found or run.
- Start with the smallest observation that answers the hypothesis. Stop repeated connection attempts when the same error yields no new evidence; report the error, checks, and missing condition.

## 4. Turn symptoms into testable hypotheses

Record symptoms, trigger conditions, frequency, expected behavior, and recent relevant changes. Each observation should answer a concrete question, for example:

- Samples do not update: did start succeed, did DMA count advance, did the IRQ run, did the callback publish a new sequence, and did the consumer receive it?
- Execution hangs: where is PC, what ends the wait, does its timebase advance, is the handle busy, and is the core in an exception?
- Output is wrong: is the input valid, are units/direction consistent, what are the values before/after limiting, and who last wrote the command?

Follow symptom -> hypothesis -> observation -> result -> conclusion. A temporary delay, parameter change, or extra retry is not a proven root-cause fix.

## 5. Combine observations with their limitations

| Tool | Useful question | Limitations |
|---|---|---|
| Breakpoint/conditional breakpoint | Which call, state transition, or error path ran? | Halts execution and changes timing; stepping cannot prove real-time performance |
| Watchpoint | Which CPU access changed an address/object? | Verify hardware support, slots, width, and scope; no hit does not prove DMA did not write |
| Variables/expressions | Do input, state, counters, and output fit the hypothesis? | Check symbols, scope, frame, type, optimization, and read timing; avoid evaluations that call side-effecting target functions |
| SVD/registers | Are enable, count, status, interrupt, or error bits as expected? | Reads may clear flags or consume FIFO data; not every register is safe to poll |
| Call stack and PC/LR/SP | How did execution reach this point? | Corruption and optimization limit unwinding; record capture context |
| SWO/serial/logic analyzer | What happened during continuous execution, and when? | Use actual clocks/channels; bound logging; do not silently add an unconfigured logging channel |

- If a variable is invisible, inspect debug information, optimization, frame, and qualified symbol first. Do not remove `static`, expose private state globally, or add `volatile` everywhere for debugger visibility.
- Prefer small, explicitly addressed watchpoint objects. Narrow the range if resources are insufficient. Software watchpoints may drastically slow execution and cannot silently substitute for real-time measurements.
- Verify register addresses, access widths, and read/write semantics against actual device documentation. SVD decoding does not guarantee harmless repeated reads.
- Verify SWO frequency, pins, and availability on the actual hardware. An unavailable channel or silent output does not prove the code never ran.

## 6. Preserve exception evidence

- For HardFault and related exceptions, capture available PC/LR/SP, core state, call stack, and fault registers supported by that core. Read CFSR/HFSR where supported; interpret fault addresses only when their validity bits are set.
- Distinguish handler registers from the interrupted exception frame. Use exception-return information and the current core rules to identify MSP/PSP and frame layout, including applicable floating-point/security extensions; do not hardcode offsets from another target.
- State when the stack is unreadable, corrupt, or unreliable. A single register value needs its validity conditions, instruction, and accessed object before supporting a root cause.
- Reuse existing reset-cause, error-counter, and build-identifier mechanisms. New persistent logging, fault handlers, or generated-code changes still follow design and editing boundaries.

## 7. Recheck and close the investigation

- Compare before/after under the same trigger conditions. Remove only temporary breakpoints/watchpoints and unneeded sessions owned by this task. Do not take over or close the user's other sessions.
- Preserve existing logs/snapshots. Record only necessary evidence and exclude credentials, unrelated memory dumps, and personal machine paths from public reports.
- Use this compact evidence record in the task result when helpful; a new file is not mandatory:

| Field | Record |
|---|---|
| Symptom and conditions | Inputs, reproduction steps, expected versus observed behavior |
| Version and target | Source revision/changes, configuration, image/running-version correspondence |
| Tools and operations | Probe/backend, attach/reset/load behavior, halted versus continuous observation |
| Hypothesis and observations | Actual breakpoint, variable, register, and stack results with capture timing |
| Findings and limits | Proven, excluded, unresolved items; timing disturbance |
| Change and retest | Actual diff, same-condition results, build and physical validation scope |

If only offline analysis was completed or the fault was not reproduced, say so rather than declaring it solved.
