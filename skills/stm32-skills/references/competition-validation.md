# Competition Validation and Reproducible Delivery

Use only for requested competition preparation, whole-system acceptance, demonstrations, or reproducible delivery. Ordinary code edits use [Reliability and validation](reliability.md). These are engineering practices, not current rules of any competition; use the actual task and official rules for hardware, materials, procedures, attempt counts, and scoring.

## 1. Turn requirements into acceptance criteria

- Identify the rule/requirement source, applicable edition/version, metrics, and conditions. Check current official rules and effective clarifications; old experience posts do not define current requirements.
- Map input conditions to expected behavior, error/time metrics, and measurement methods. Verify critical device/tool capabilities before full implementation; no part is assumed suitable for every event.
- Where useful, separate baseline and stretch goals using benefit, effort, dependencies, and stability. Do not impose fixed scores or time percentages.
- Arrange small feasibility checks for unproven critical capabilities and identify fallback options. Change direction using evidence and remaining resources without repeatedly discarding validated work.

## 2. Accept complete results

- Demonstrate a minimal complete task early. Separately passing subsystems do not prove their integrated result.
- Identify the responsible person/agent, dependencies, deliverable, and acceptance method. A solo project does not need invented team roles or approval layers.
- Hand off actual interfaces and demonstrable results with limitations and unfinished work. Verbal estimates are not tests.
- Add scheduling, reports, and operating rehearsals when the task needs them; do not impose a particular event's team size, tools, or organization.

## 3. Select representative repeated tests

Choose from relevant risks and define conditions, repetition count, duration, and acceptance criteria. Not every project needs every row.

| Scenario | Observe |
|---|---|
| Cold start, reset, power cycle | Intended state, loaded parameters, designed output behavior |
| Repeated tasks/long operation | Lost frames, backlog, drift, resource/temperature-related failures |
| Supply/load changes | Function and timing within permitted operating limits |
| Input/environment changes | Relevant lighting, background, position, amplitude, noise |
| Temporarily missing input/communication | Failure detection and designed expiry of stale data/commands |
| Recovery | Correct state restoration, required rearming or recalibration |
| Mechanical/connection disturbances | Retention, motion range, and connection integrity where applicable |

- Stay within authorized device operations and allowed conditions. Test suitable error paths through host replay/mocks first, but obtain physical evidence for physical conclusions. Do not perform unauthorized hardware fault injection.
- Record all attempts, successes, failure classes, key errors, and worst observed latency. Do not retain only the successful run. Sample success rates do not guarantee field reliability.
- Preserve failure conditions and raw records. After changes, retest the original trigger and affected paths. State required manual intervention, unreproduced faults, and coverage gaps.
- Keep the approved application recovery policy. This reference does not mandate universal disconnect-stop or reset-resume behavior.

## 4. Keep versions and results aligned

Save or reference enough material to reproduce the result using the project's existing storage conventions:

| Material | Establish |
|---|---|
| Source/dependencies | Revision, uncommitted changes, required libraries and versions |
| Build | Toolchain, target/configuration, key options, actual result |
| Parameters/calibration | Complete set, units, loading method, applicable hardware/conditions |
| Hardware/interfaces | Hardware revision, relevant wiring, resource configuration |
| Running image | Corresponding artifact and existing programming/verification evidence |
| Test records | Conditions, raw observations, results, limits, known issues |

- Preserving a version does not authorize Git mutations. Stage/commit only with explicit user authorization, including an applicable project rule; tagging/pushing require their own authorization. Exclude personal configuration, credentials, and unrelated data.
- Use existing identifiers, hashes, or build records. A delivery requirement does not justify silently adding a version subsystem to firmware.
- Distinguish validated stable configurations from candidates. Do not overwrite a demonstration/competition version with an unvalidated candidate or discard user work to roll back.
- If the task uses a freeze, record source, parameters, and hardware state. Assess subsequent relevant changes and repeat affected acceptance checks instead of reusing pre-change conclusions.

## 5. Reproduce and hand off

- For collaboration/handoff, have another user independently configure, build, flash, load parameters, and run a complete test when feasible. If nobody else performed it, state that independent reproduction is incomplete.
- Provide the necessary operating order, state meanings, limits, and recovery steps. Do not redesign the device UI or startup logic without scope for it.
- Collect measurement conditions, raw data, and results while testing for reports/demonstrations; never fabricate records afterward. Recommend spare parts/tools only from actual project needs, not a universal shopping list.
- Report met/unmet criteria, coverage, and remaining risks, separating offline, target-build, and physical results. Use the evidence record in [Debugging with evidence](debugging.md) for diagnostic findings.
