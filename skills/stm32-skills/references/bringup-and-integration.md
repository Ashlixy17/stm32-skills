# Bring-up and Integration

Use for PCB interconnect selection/assembly review, initial power-up, connected modules, whole-system integration, or field tuning. For source-only reviews, list pending hardware checks rather than claiming power-up inspection. Connections, power, outputs, and tests remain subject to task authorization. No chip, board, wiring, or default parameter is prescribed here.

## 1. Define the path to validate

- Identify actual input, intervening modules, final output, and the acceptance observation. Establish a simple, testable complete path early, then improve performance.
- Distinguish implemented modules, physically tested modules, and integrated system behavior. Mock input/interfaces validate only the corresponding software path.
- Verify and reuse current resource/interface documentation. Fill affected gaps without duplicating documents or restructuring directories.
- Before reusing a prepared module, identify its hardware/configuration, dependencies, interface/resource use, tested supply/load/timing range, and known limits; include a build/test entrypoint where software is involved. Mark missing evidence; a working example under other conditions does not establish suitability here.
- For driver, IRQ, and DMA internals use [Firmware development](firmware-development.md); this reference concerns cooperation between modules.

## 2. Check connections and power

### FPC selection and assembly

This is the skill author's strong design recommendation and assembly requirement, not a claim that every FPC design is unsuitable.

- Avoid FPC ribbon-cable interconnects where practical. Before selecting them, assess alternatives against the actual connector pitch, assembly capability, retention, motion/strain, and maintenance needs; do not choose FPC solely for compactness.
- If FPC is selected, **include SMT assembly for its PCB-side connectors/terminations when placing the PCB fabrication order. Do not plan or instruct the user to hand-solder them.** Check that these parts and their assembly are included in the order before treating it as ready to submit.
- Keep the board-side assembly requirement distinct from inserting a cable into an assembled connector. Missing SMT assembly remains an unresolved ordering item; do not silently substitute hand soldering.

### Mandatory two-pass wiring check

Apply the entrypoint's mandatory rules to wiring inspections and any connection, measurement, power-up, or output-enable step that could damage components. These are two documented verification passes, not two generic requests for permission.

| Pass | Verify and record |
|---|---|
| 1. Design compatibility | Exact board/device revision and connector view; source-to-load pin mapping; polarity, operating voltage/current limits, signal levels, input/output roles, power paths, and grounding/isolation against the actual device documentation and schematic |
| 2. Point-to-point recheck | Trace each relevant connection again from the receiving end back to its source; compare with current physical evidence and any necessary measurements, checking connector orientation, pin numbering, supply settings, shorts/misconnections, and probe/reference connections |

- State the result and evidence for each pass separately. If only documents are available, report the design review and mark physical verification pending; ask for the necessary connection details, photos, or measurements rather than claiming the hardware was checked.
- If a potentially damaging connection remains uncertain or evidence conflicts, stop before giving an instruction to make/energize it or performing the affected operation, and ask the user to resolve the specific point. Wire colors, mating connectors, a similar board, and an earlier working setup cannot settle the current pinout. User approval alone does not establish electrical compatibility.
- Before rewiring, require relevant supplies to be disconnected and stored energy to be discharged and verified according to the actual equipment/design procedure. Account for other power paths, including USB/debugger connections and signal backfeed; do not assume switching off one supply removes all energy. Live connection is permitted only when explicitly supported by the actual interface and authorized procedure.
- Before power-up or output enable, verify the intended supply settings, applicable current limiting/protection, expected initial output state, and a way to stop the operation. Derive limits from the actual design; do not invent universal values or bypass protection to complete a test.
- Relevant changes to wiring, board revision, supply, load, probe connections, or output configuration invalidate the affected checks; repeat both passes before the next affected operation. Keep the verified connection record aligned with the current hardware.
- If unexpected current, heating, smoke, odor, rail collapse, or unintended output appears, stop the test and use the established shutdown procedure. Preserve the observation and inspect the cause before another authorized attempt; do not repeatedly power-cycle to see whether it clears.

### Electrical and assembly checks

- From device documentation, schematics, and actual wiring, verify supply range, polarity, interface levels, pin direction, and power/signal references. Mating connectors do not prove compatibility. Respect isolated-interface designs instead of requiring every module to share ground.
- Match supply capability to startup/load demands. Derive current limits and staged power-up sequences from the design, not universal example values.
- Verify reset, boot mode, debug access, and initial output state. Confirm the device is running the intended image/state before authorized output actions.
- Observe relevant rails, reset, and signals during load switching. Preserve failures rather than masking power or connection problems with parameter changes.
- Check connector retention, pin order, and signal integrity. Check cable strain, pinching, abrasion, and looseness across motion only when moving mechanisms are present.
- Without actual wiring or measurement evidence, mark the condition unconfirmed. Schematics and source inspection do not establish correct physical assembly.

For instrument-based validation, establish the test point, reference, and actual load. Record relevant instrument/probe model, attenuation, coupling, input termination, bandwidth, sampling, and signal-source load settings. Select only settings that affect the measurement; use the actual equipment documentation and ratings. Check probe loading and grounding/isolation before connection. A signal source's amplitude setting or a firmware-displayed value alone does not establish the signal at the device input.

## 3. Agree on interface contracts

Check only relevant fields and reuse existing definitions; a protocol replacement is not required. Where mechanical, electrical, and firmware/control work meet, have the relevant owners agree on the same interface record rather than maintaining separate, inconsistent mappings.

| Category | Facts to agree on |
|---|---|
| Data interpretation | Type, dimensions, units, range, scaling, invalid representation |
| Order/direction | Physical device/channel identity, channel order, positive direction, active polarity, coordinate frame, zero/limits, transformation owner |
| Command/physical mapping | Command quantity/range, conversion and scaling, transmission or speed ratios where applicable, physical actuator, feedback source/quantity |
| Timing | Acquisition/publication timestamp, period, allowed latency, expiry |
| Communication | Framing, length, endianness, message ID, validation, boundary detection |
| Handoff | Producer, consumer, buffer ownership, consistent publication |
| State/errors | Not-ready, invalid, busy, timeout, disconnected, recovery notifications |
| Actions | When commands take effect, acknowledgement, repeated/stale-command handling |

- State the timebase. Confirm synchronization or conversion before comparing clocks from different devices/processors; do not directly subtract unrelated counters.
- Use sequence numbers, checksums, and timeouts according to protocol needs. A valid checksum proves neither freshness nor a correct sender state.
- When changing units, frame layout, or state semantics, check both endpoints; local compilation is insufficient.
- For affected output paths, trace command -> conversion -> physical channel/mechanism -> observed response. Compare expected and measured direction, quantity, range, and feedback under the relevant conditions/load. A setpoint display or communication acknowledgement does not establish the delivered motion/output. Record the image/configuration, conditions, expected versus observed response, and any unmeasured facts; do not absorb an unverified mapping into tuning gains.
- If device numbering, direction, scaling, ratios, limits, or feedback mapping changes, identify which earlier calibration, tuning, and performance results depended on it. Preserve those records with their original conditions, mark the affected conclusions as pending revalidation, and repeat the relevant checks before reusing them for the changed configuration. Unaffected evidence remains applicable within its recorded scope.

## 4. Integrate incrementally, then validate the complete path

- Establish an identifiable minimal working end-to-end combination and its validation layer. Integrate small functional changes when practical; when changes must be coupled, record the dependency so a regression can still be narrowed down.
- After each module addition or integration/merge, inspect affected shared resources: pins/alternate functions, clocks, timer channels, IRQ priorities/callbacks, DMA, buffer ownership, and processing time. Recheck existing dependent behavior such as display, input handling, outputs, startup, and error paths alongside the new function. Select checks by impact; a small module change does not require unrelated whole-system testing.
- Record the integrated source/configuration/parameter combination, changed resources, results, and last passing combination. Use source checks, host tests, and target builds where applicable; mark physical regression pending when hardware or authorization is unavailable. A successful merge/build does not establish that modules coexist on the device. Keeping this record does not require a new Git operation.
- If integration regresses behavior, preserve the failing case and observations, compare with the last passing combination, and narrow the changed modules/resources before altering unrelated code. Keep the user's work intact. After a fix, retest the original trigger and affected existing behavior.

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
- For control-performance problems, check achievable actuator speed, acceleration, resolution, deadband, saturation, and loaded response as relevant. Compare requested and executed commands, feedback, and sensing/communication delay before changing gains. Distinguish measured limits from hypotheses; do not silently change output limits, protection, or the control architecture to meet a target.
- Record parameter name, units, old/new value, reason, conditions, results, and associated source/configuration. Change one test factor at a time when practical; explain necessary coupled changes.
- Preserve a complete validated parameter set that can be restored. After restart, board replacement, or firmware changes, confirm which set actually loaded.
- Persistence, storage, and write timing are design decisions. Recording parameters does not authorize Flash writes, a configuration protocol, or an online tuning feature.
- Label untested parameters as candidates or pending validation, not "optimal" or universally applicable.

## 7. Reproduce installation and operating setup

Use when installation, a venue move, demonstrations, or field operation affects the task. Reuse the project's operating instructions and record only relevant setup dependencies.

- Make the operating sequence reproducible: actual mounting/placement, intended cables/accessories/load, host/network/adapter configuration where required, power/startup order, focus/calibration where applicable, readiness observations, task start, and shutdown/recovery. Describe permitted manual actions and expected states so another operator can follow the sequence.
- Rehearse the complete task in the intended installed configuration. Where relevant, check mounting geometry, field of view/focus, lighting, and cable clearance across the required motion range. Use measurements and permitted operating conditions; a pass with a different placement or a manually bypassed step does not establish the delivered setup.
- After transport, reassembly, component replacement, or relevant installation/environment changes, repeat affected checks before relying on earlier results. Apply the mandatory wiring recheck when its conditions are met, and confirm any setup-dependent calibration against the actual assembly.
- Validate each main/spare unit intended for substitution against its required role and operating range; another unit of the same model or batch passing is insufficient. Record unit identity, relevant configuration and installation, test conditions, results, and unresolved limitations so replacement does not silently inherit unrelated evidence.

For requested repeatable system acceptance or delivery, continue with [Competition validation and delivery](competition-validation.md). Ordinary integration does not trigger a full competition workflow.

## Experience sources

- [Blue Bridge Cup integration retrospective](https://developer.cloud.tencent.com/article/1477916) and [RoboMaster regional retrospective](https://blog.luonto.me/zh/posts/robomaster-26-regional/): module coexistence and regression after integrating changes. The reported symptoms do not establish a universal root cause or Git workflow.
- [RM2025 South China Tiger hero mechanical report](https://bbs-web-static.robomaster.com/07f510bc303a4da0a58713c1a29575771756092800041/RM2025-%E5%8D%8E%E5%8D%97%E7%90%86%E5%B7%A5%E5%A4%A7%E5%AD%A6-%E5%8D%8E%E5%8D%97%E8%99%8E-%E8%8B%B1%E9%9B%84%E6%9C%BA%E6%A2%B0%E7%BB%93%E6%9E%84%E8%AE%BE%E8%AE%A1%E6%8A%A5%E5%91%8A.pdf) and [TI-Cup2025-E task/control analysis](https://github.com/Thybing/TI-Cup2025-E/blob/main/doc/README.md): physical interface mapping and command-unit conversions. Example ratios, parameters, and hardware choices are not project defaults.
- [2023 electronics competition retrospective](https://www.dyldr.top/life/nuedc2023), [gimbal competition retrospective](https://cuifrost.cn/blog/nuedc-laser-target/), and [CIMC experience](https://www.cnblogs.com/tatazml/p/16099286.html): installation, individual component checks, cable motion, and host/network setup as part of delivery. These accounts do not establish a universal electrical diagnosis or software environment.
