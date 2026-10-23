# Reliability and Validation

Inspect only affected paths. These checks do not authorize adding an RTOS, watchdog, logging system, fault framework, or new hardware policy. Peripheral-specific checks belong in [Firmware development](firmware-development.md); runtime diagnosis belongs in [Debugging with evidence](debugging.md).

## Data validity and output state

- Distinguish transaction success, complete data, and valid data. Do not present stale data, zeros, or defaults as valid new measurements. For intentional termination paths, explain output state and recovery.
- Preserve validity and freshness semantics. Consumers must recognize relevant lost frames, disconnection, missing calibration, and expired samples. Derive thresholds from the approved design.
- Follow the current output enable, fault, and recovery conditions. A successful build does not authorize changing existing protection. Confirm polarity, allowed ranges, and switching timing from the actual device/interface.
- Define how history, cached values, filters, and other state recover after an input fault. Prevent invalid data from perpetuating stale commands according to the approved application policy.

## Shared state

- Publish frame contents, length, sequence, and validity as one consistent transaction. Atomic access to individual fields does not make a structure or a check-then-clear operation consistent.
- Keep critical sections short. Save and restore the previous interrupt mask; do not unconditionally enable interrupts on exit. In an RTOS, use synchronization appropriate to the task/ISR context.
- Only for existing FreeRTOS projects, check FromISR APIs, interrupt priorities permitted to call kernel APIs, queue-full handling, timeouts, and stack use. Do not introduce an RTOS into bare-metal code by default.

## Time and numeric boundaries

- Handle unsigned tick wraparound. Usually compare an elapsed difference in the same unsigned width and state the maximum supported interval; avoid `now >= start + timeout` across wraparound.
- For cyclic-counter differences, verify width, modulus, and maximum change between reads. State the assumptions when using half-range direction detection.
- State units and ranges for samples, counts, time, and converted interfaces. Without valid calibration/conversion evidence, report raw values instead of claiming calibrated physical quantities.
- Check output ranges and relevant division-by-zero, negative-to-unsigned conversion, multiplication overflow, nonfinite floating-point values, and stateful algorithm boundaries.
- Calculate timer clocks and sample periods from the current clock tree, prescalers, and triggers. Do not assume timer clocks are always twice the bus clock. Recheck control and communication timing after changes.
- Evaluate floating point, heap allocation, stack arrays, and logging against the actual FPU, build options, RAM, and timing budget. Do not silently change the floating-point ABI, memory layout, or heap strategy during a small edit.

## Peak resources and complete-path timing

For changes that materially increase workload, buffering, or concurrent functions, establish a budget before full implementation and verify it during integration. Reuse existing map files, build reports, and runtime observations; a small unrelated edit does not require a system-wide budget.

| Budget | Account for |
|---|---|
| Memory | Flash, static RAM including static buffers, peak stack/interrupt nesting, dynamic buffers/heap, and allocation failures where applicable |
| Processing | Acquisition, decoding, algorithms, control, display/logging, and competing IRQ/task work under the relevant peak workload |
| Communication and data age | Actual frame sizes/rates, transfer and queue delays, bursts, and slow-consumer behavior along the complete path |

- State capacity, estimated or observed peak use, remaining margin, and evidence gaps for affected resources. Choose margins from task needs; do not impose a universal utilization percentage or sampling/control period.
- A linker fit does not establish runtime stack/heap headroom. Average execution time or nominal link rate does not establish worst observed latency, deadline compliance, or end-to-end response. Label estimates, measurements, and untested peak conditions separately.

## Select validation by impact

| Change | Relevant validation |
|---|---|
| Skill or documentation only | Format, links, consistency with current rules; no unrelated firmware build |
| Business C/H, macros, interfaces | Diff review, relevant existing or necessary host tests, real target build |
| State machine, protocol, control logic | Normal and affected failure/boundary inputs, target build, explicit hardware follow-up |
| IOC, clocks, pins, peripherals | Configuration authorization, CubeMX generation, configuration/output/resource review, target build |
| Linker, startup, compiler, build target | Actual full build; verify device, segments, startup, and diagnostics |
| DMA, IRQ timing, electrical behavior | Source/build prerequisites; physical conclusions require observations |
| Offline fault analysis only | Image/symbol correspondence and original records; state unconnected/unreproduced/unproven items |

- Test observable behavior and meaningful boundaries rather than function names or implementation text. Run checks proportionate to the change and add tests only when they provide useful coverage.
- Discover scripts in the current checkout and inspect them. Historical paths are not current facts; do not restore scripts the user deleted.
- Record target, configuration, actual command, time, exit status, and compile/link diagnostics. Verify that artifacts came from this build; old logs or images are not substitutes.
- Record missing environment/device conditions and unfinished checks. Fix validation failures before declaring success; do not weaken assertions, suppress warnings, or change unrelated targets to obtain a pass.
- Archive artifacts only when required by the task or project. Follow its artifact type, naming, and location. Report archival failures separately from compilation results.

For requested system acceptance, competition work, or reproducible delivery, select additional checks from [Competition validation and delivery](competition-validation.md). Logic tests and builds do not replace physical acceptance results.
