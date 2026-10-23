# STM32 Firmware Development

Use for drivers, peripheral interfaces, interrupts, DMA, and sampling. Apply the entrypoint's authorization and editing boundaries first. Respect CubeMX user regions when applicable; do not impose a generator or HAL on projects using other mechanisms.

## 1. Establish current resources and call paths

- Inspect current configuration, initialization source, and build targets. Record only relevant pins/alternate functions, peripheral instances, clock sources, trigger chains, DMA requests/channels, and interrupt entries/priorities.
- Identify each peripheral's configuration owner, starter, data producer, and consumer. Verify and reuse an existing resource table instead of maintaining a duplicate.
- Separate configuration, initialization, and runtime operations. For example, CubeMX `MX_*_Init()` configures a peripheral; business interfaces start/stop transfers or update outputs under the design. Preserve other projects' existing entrypoints. Do not silently reconfigure another module's resource inside a driver.

## 2. Keep initialization and module ownership explicit

- Reuse existing handles, MSP functions, IRQ handlers, and callbacks in HAL projects, or the corresponding mechanisms in other libraries. Do not duplicate resources or copy an entire reference project's initialization.
- Integrate through allowed generator extensions. Register independent business files in the real build target.
- Keep the current split between initialization and application entrypoints. Drivers handle device access and protocols; where practical, algorithms accept inputs and return results without direct register access so they can be replayed on a host.
- Preserve directories and interfaces. Add a focused interface only when the task needs a new module; layering alone is not a reason to restructure the project.

## 3. Check return states and waits

- Handle the actual possible statuses of status-returning HAL APIs, including `HAL_OK`, `HAL_ERROR`, `HAL_BUSY`, and `HAL_TIMEOUT` where applicable. Do not invent a return-status check for a `void` API.
- These status names apply to HAL. Use the actual return values, hardware flags, and completion conditions of LL, register-level, and other drivers.
- A successful IT/DMA start means the request was accepted. Confirm completion and errors through the current library version's callbacks/state; a successful start does not prove a complete received frame.
- Diagnose `HAL_BUSY` through handle state, concurrent callers, and transaction ownership. Do not hide conflicts with repeated DeInit/Init or forced handle-state changes.
- Bound blocking calls and hardware waits with a valid timebase and recovery path. An ISR or context where the tick cannot advance cannot rely on that tick for timeout progress.
- Propagate actual failures/timeouts. Do not treat output parameters as valid new data after failure. Define whether the path retains old values, publishes invalidity, discards a partial frame, or waits for recovery.
- Avoid unacceptable blocking on control-critical paths. Choose polling, interrupts, or DMA from throughput and timing needs; DMA is not mandatory for every short transaction.

## 4. Bound IRQs and callbacks

- Keep IRQ/callback work bounded: record state, perform necessary copies, and publish events. Defer parsing, display, and nonessential logging to the main loop/task.
- Verify that IRQs reach the library's required handlers, DMA resources are linked correctly, and callbacks filter the intended peripheral instance when that mechanism applies.
- Dispatch shared HAL callbacks through the existing entrypoint rather than defining the same symbol in multiple modules. Handle error, half-transfer, and completion events according to the enabled mode.
- Do not dynamically allocate in ISRs or use unbounded retries that block control. Use the synchronization rules in the reliability reference for shared state.

## 5. Define DMA buffer handoff

For each affected DMA path, establish:

| Concern | Required facts |
|---|---|
| Transfer configuration | Direction, mode, width, length units, address/alignment, accessible memory, trigger |
| Ownership | Which region DMA is reading/writing and which region the CPU may access now |
| Lifetime | Storage remains valid throughout the transfer; no expired local arrays |
| Publication | Which event completes which range, and how contents/length/sequence/status are published consistently |
| Reuse | When overwriting or handing back to DMA is allowed; behavior with a slow consumer |
| Failure | Dropped frames, overflow, partial frames, timeout, restart, and resynchronization |

- Do not modify TX bytes before DMA finishes reading them. Do not consume an actively written RX region as a stable complete frame.
- Consume/copy a single buffer before rearming it, or use the approved double-buffer/ring design. Define read/write positions and overrun detection for rings. Double buffering still needs a slow-consumer policy.
- A ready flag alone is not an ownership protocol. Rearming DMA to overwrite a buffer before the main loop consumes the old frame is not a valid handoff.
- A UART idle event does not automatically delimit a complete protocol message. Check framing, length, delimiters, and validation; verify the current HAL version before adopting stop/restart sequences.
- Verify that DMA can access the linked memory region. Apply cache maintenance only when the actual device and cache configuration require it; do not copy another core/family's scheme.

## 6. Verify the affected path

Select source, host, target-build, and hardware checks from [Reliability and validation](reliability.md). For runtime failures, use [Debugging with evidence](debugging.md) to locate the break in initialization/start/IRQ/callback/publication instead of guessing delays or timeouts.

For first power-up, multiple connected modules, or field tuning, also read [Bring-up and integration](bringup-and-integration.md). A single-driver edit does not automatically require whole-system delivery.
