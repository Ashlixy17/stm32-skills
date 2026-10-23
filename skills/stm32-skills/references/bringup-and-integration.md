# Bring-up and Integration

Use for initial power-up, connected modules, whole-system integration, or field tuning. For source-only reviews, list pending hardware checks rather than claiming power-up inspection. Connections, power, outputs, and tests remain subject to task authorization. No chip, board, wiring, or default parameter is prescribed here.

## 1. Define the path to validate

- Identify actual input, intervening modules, final output, and the acceptance observation. Establish a simple, testable complete path early, then improve performance.
- Distinguish implemented modules, physically tested modules, and integrated system behavior. Mock input/interfaces validate only the corresponding software path.
- Verify and reuse current resource/interface documentation. Fill affected gaps without duplicating documents or restructuring directories.
- For driver, IRQ, and DMA internals use [Firmware development](firmware-development.md); this reference concerns cooperation between modules.

## 2. Check connections and power

- From device documentation, schematics, and actual wiring, verify supply range, polarity, interface levels, pin direction, and power/signal references. Mating connectors do not prove compatibility. Respect isolated-interface designs instead of requiring every module to share ground.
- Match supply capability to startup/load demands. Derive current limits and staged power-up sequences from the design, not universal example values.
- Verify reset, boot mode, debug access, and initial output state. Confirm the device is running the intended image/state before authorized output actions.
- Observe relevant rails, reset, and signals during load switching. Preserve failures rather than masking power or connection problems with parameter changes.
- Check connector retention, pin order, and signal integrity. Check cable strain, pinching, abrasion, and looseness across motion only when moving mechanisms are present.
- Without actual wiring or measurement evidence, mark the condition unconfirmed. Schematics and source inspection do not establish correct physical assembly.

## 3. Agree on interface contracts

Check only relevant fields and reuse existing definitions; a protocol replacement is not required.

| Category | Facts to agree on |
|---|---|
| Data interpretation | Type, dimensions, units, range, scaling, invalid representation |
| Order/direction | Channel order, positive direction, coordinate frame, zero, transformation owner |
| Timing | Acquisition/publication timestamp, period, allowed latency, expiry |
| Communication | Framing, length, endianness, message ID, validation, boundary detection |
| Handoff | Producer, consumer, buffer ownership, consistent publication |
| State/errors | Not-ready, invalid, busy, timeout, disconnected, recovery notifications |
| Actions | When commands take effect, acknowledgement, repeated/stale-command handling |

- State the timebase. Confirm synchronization or conversion before comparing clocks from different devices/processors; do not directly subtract unrelated counters.
- Use sequence numbers, checksums, and timeouts according to protocol needs. A valid checksum proves neither freshness nor a correct sender state.
- When changing units, frame layout, or state semantics, check both endpoints; local compilation is insufficient.

## 4. Inspect stages, then the complete path

- Narrow the fault through physical signal/connection -> driver/transport -> decoding -> business calculation -> output, adapting the order to existing evidence.
- Compare raw and processed values at boundaries: changing input, complete messages, correct units, valid state, and actual output execution.
- Describe progress with demonstrable results such as validated received messages, measured outputs, or a completed task. "Should work" is not integration evidence.
- Record the blocked stage, excluded causes, and next observation. Use [Debugging with evidence](debugging.md) for live-state inspection.

## 5. Expose enough information

- Use existing debuggers, serial channels, or host tools. Do not add a logging system, screen, or command interface by default.
- Select observations for the fault: raw/processed input, target/feedback/output, validity, data age, error counts, and actual processing period.
- Distinguish uninitialized state, absent input, invalid input, failed transactions, and deliberate upper-layer inhibition when relevant. Follow current interface naming/encoding without imposing a new enum framework.
- Bound logging rate and buffering. Avoid blocking ISR/control paths, and check whether observation changes the original timing or fault.

## 6. Record tuning and calibration

- Before tuning, verify direction, zero, units, actual period, and output range. Report raw quantities when calibration is unavailable instead of compensating with control parameters.
- Record parameter name, units, old/new value, reason, conditions, results, and associated source/configuration. Change one test factor at a time when practical; explain necessary coupled changes.
- Preserve a complete validated parameter set that can be restored. After restart, board replacement, or firmware changes, confirm which set actually loaded.
- Persistence, storage, and write timing are design decisions. Recording parameters does not authorize Flash writes, a configuration protocol, or an online tuning feature.
- Label untested parameters as candidates or pending validation, not "optimal" or universally applicable.

For requested repeatable system acceptance or delivery, continue with [Competition validation and delivery](competition-validation.md). Ordinary integration does not trigger a full competition workflow.
