# Structured Sampling Records

Use when repeated variable/register observations, intermittent-fault captures, or before/after comparisons need a reusable history. Follow [Debugging with evidence](debugging.md) for image matching, tool selection, device-operation authorization, and register-read semantics. This reference defines a record format, not an automatic sampler. Keep an existing export format when it preserves equivalent information; do not create a log for every single inspection.

## Choose the capture

- Select targets that distinguish the current hypotheses. Establish their addresses, types, widths, byte order, and units from the actual symbols/device documentation. A display format or an address alone does not establish the value's type.
- Choose a bounded duration or sample count and a suitable requested interval. Reuse the current debugger, CLI, or exported trace; do not introduce a backend, firmware logging, or repeated reset/flash operations merely to produce this format.
- Record whether the CPU was running, halted, or unknown for each observation. Running reads still need backend/device support and may affect bus timing or peripheral state. Check read side effects before polling registers.
- Record host capture time with a UTC offset. Distinguish it from target time. Record actual elapsed time or read duration when timing matters; a requested interval and host timestamp do not prove the target's update rate or real-time performance.
- Sequential reads of several variables are not an atomic snapshot. Multiword values can also change during a read. Record a coherence limitation unless an existing, verified snapshot/sequence mechanism establishes consistency. Do not add halts or firmware synchronization without the relevant authorization.

## Record format

For a new file, use UTF-8 JSONL: one complete JSON object per line, without surrounding prose, arrays, or Markdown fences. Emit one `session` record followed by `sample` records linked by `session_id`. Existing exports can carry session metadata in a companion record instead. Keep diagnostic text outside machine-readable output.

Use the following fields; record unavailable facts as `null` or an explicit unknown/unverified state rather than guessing. Context that is necessary to interpret the observation must remain visible even when unavailable.

| Record | Fields and meaning |
|---|---|
| Both | `schema_version`: `1`; `record_type`: `session` or `sample`; `session_id`: identifier shared by this capture |
| Session | `evidence_source`: `hardware`, `offline`, `replay`, or `synthetic`; `target`: MCU/board identity; `backend`: tool and version when known |
| Session | `source_revision`, `source_dirty`: source identity and whether uncommitted changes exist; preserve the relevant diff/configuration separately when needed for reproduction |
| Session | `image`: executable path/identifier, SHA-256 when available, and `running_match`: `verified`, `unverified`, or `not_applicable`; record the verification basis in `match_evidence`. An image hash alone does not verify the running firmware |
| Session | `svd`: device-description identity/version when used; `conditions`: relevant trigger, supply/load, configuration, and coherence limitations |
| Session | `requested_interval_ms`, `max_samples`, `duration_limit_ms`: chosen collection bounds; use at least one finite count/duration bound |
| Sample | `sequence`: increasing observation index; `captured_at`: host ISO 8601 time with offset; `elapsed_ms`: monotonic time since capture start when available |
| Sample | `cpu_state`: `running`, `halted`, `unknown`, or `not_applicable`; offline/replay records must not imply a live observation. Preserve original capture state separately in `conditions` if known |
| Sample | `target`: expression/register name; `kind`: `variable`, `register`, `field`, or `address`; `address`: resolved address as a hex string, or `null` |
| Sample | `value_type`, `width_bits`, `byte_order`, `unit`: decoding context; for fields also retain `bit_offset` and `bit_width` |
| Sample | `raw_value`: exact bytes or integer as a string with an unambiguous encoding; `decoded_value`: typed value; `display_value`: readable rendering; optional `interpretation`: state/enum meaning with its source in session conditions |
| Sample | `status`: `ok` or `error`; `error`: failure detail or `null`. Failed reads have `null` value fields and must not reuse an earlier value |

Preserve precision: use strings for integers that downstream JSON consumers cannot represent exactly and for non-finite floating-point values. Do not emit JSON `NaN` or `Infinity`. Record bytes for values that cannot be reliably decoded; leave the decoded value unknown. For bitfields, retain the full raw register value as well as the decoded field value.

The following JSONL is a **synthetic format example**, not hardware evidence. The two samples illustrate a successful read followed by a timeout; the requested interval is not a measured interval:

```jsonl
{"schema_version":1,"record_type":"session","session_id":"example-001","evidence_source":"synthetic","target":null,"backend":"format example","source_revision":null,"source_dirty":null,"image":{"path":"build/example.elf","sha256":null,"running_match":"unverified","match_evidence":null},"svd":null,"conditions":"Illustrative running reads; no coherent snapshot established; counter unit is count.","requested_interval_ms":100,"max_samples":2,"duration_limit_ms":null}
{"schema_version":1,"record_type":"sample","session_id":"example-001","sequence":1,"captured_at":"2026-10-24T10:00:00.000+08:00","elapsed_ms":0,"cpu_state":"running","target":"sample_Count","kind":"variable","address":"0x20000000","value_type":"uint32_t","width_bits":32,"byte_order":"little","unit":"count","raw_value":"0x0000002A","decoded_value":42,"display_value":"42","status":"ok","error":null}
{"schema_version":1,"record_type":"sample","session_id":"example-001","sequence":2,"captured_at":"2026-10-24T10:00:00.125+08:00","elapsed_ms":125,"cpu_state":"unknown","target":"sample_Count","kind":"variable","address":"0x20000000","value_type":"uint32_t","width_bits":32,"byte_order":"little","unit":"count","raw_value":null,"decoded_value":null,"display_value":null,"status":"error","error":"Read timed out; CPU state was not confirmed."}
```

## Compare and retain evidence

- Start a new session when the image, decoding context, target, backend, or relevant test conditions change. Do not combine unrelated sessions into one trend. Before/after comparisons must identify both versions and any changed conditions.
- Compute ranges, trends, and state transitions only from compatible, successfully decoded samples. Report failed/missing reads and actual coverage separately; missing data is not zero or a repeated last value. Raw float bit patterns are not numeric float measurements.
- Interpret counter wrap, reset, timing gaps, and units before calculating rates. Use original capture timing for replay when available, not replay execution time. Do not infer cross-variable ordering or causality from sequential polling alone.
- Retain original tool output or its location when interpretation depends on it. Link the session/file in the fault report with findings and limits. Record known truncation or dropped samples. Keep capture paths and retention consistent with the project, and exclude unrelated dumps or personal paths from public reports.
