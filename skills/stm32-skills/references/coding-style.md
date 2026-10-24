# Default Coding Style

Apply these defaults to new or actually modified handwritten business code. More specific current project rules take precedence. Do not reformat untouched code, generated sections, or vendor libraries merely to match this style. The conventions are maintainer preferences, not an official ST coding standard.

## Identifiers and interfaces

| Item | Form | Examples |
|---|---|---|
| Variables, parameters, and structure members | Lowercase first word; subsequent words start uppercase; separate every word with `_` | `sample_Frame_Ready`, `sample_Period_Ms` |
| Business functions, including static functions | Capitalize every word and separate with `_` | `Sample_Get_Frame()`, `Buffer_Get_Count()` |
| Macros and enumeration constants | Uppercase with underscores; add a module prefix where needed | `SAMPLE_CHANNEL_COUNT`, `APP_RUNNING` |

- Separate every word: avoid `sampleFrameReady`, `sample_frame_ready`, and `sample_FrameReady`.
- Name the actual meaning and include units when useful. Keep names consistent with conversions. Format abbreviations similarly: `sample_Adc_Value`, `Sample_Adc_Start()`.
- Use fixed-width integers for hardware/protocol data. Make private state and internal functions `static`; publish interfaces in module headers rather than exposing arbitrary writable globals.
- Write `(void)` for functions without arguments and use header guards. Retain the project's type/structure naming convention instead of inventing one.
- Preserve required names such as `main`, `SystemClock_Config`, `MX_*_Init`, peripheral handles, HAL callbacks, IRQ handlers, and library fields.

## Control flow and formatting

- Do not use the ternary conditional operator `?:` in new or modified business code or macros, including arguments and return expressions. Use explicit `if/else` branches.
- Use braces for every conditional and loop body, even a single statement. A clear `switch` is appropriate for state dispatch.
- Combine conditions with `&&` or `||` when useful, but do not replace required business branches with short-circuit side effects.
- Use four spaces for indentation and Allman braces: opening braces on their own lines for functions and control statements. Put spaces around operators and after commas.
- Separate includes, macros, ordinary variables, flags, declarations, and implementations with at least one empty line. Separate local declarations from execution and distinct processing phases similarly.
- Put exactly two completely empty lines between adjacent functions. Keep function documentation directly attached to its function.
- Empty lines contain no spaces or tabs. Do not move user-region markers to satisfy formatting.

## Per-item comments and flag grouping

Write comments in generated or edited project firmware in the **language chosen by the user**. A current explicit user choice overrides older project conventions. When the user has not specified a language, follow the project's existing comment-language convention. The language of this instruction package does not determine the firmware comment language.

- Give every new or modified business variable declaration/definition and macro an individual purpose comment in the required firmware language. This includes module/global/local variables, constant objects, arrays, pointers, structure fields, function parameters, and header guards.
- Declare one variable per declaration. Use a trailing `//` comment for ordinary declarations and macros. Split parameters across lines with individual `/* ... */` comments when needed. Keep multiline macro continuations valid; use a function when clearer.
- State purpose, relevant units/range/order, or the pointed-to object. Explain a flag's values, such as `0 = invalid, 1 = valid`. Avoid empty descriptions such as "variable" or "temporary flag".
- A group heading does not replace per-item comments. Do not mechanically repeat declaration comments on later assignments. Explain non-obvious computations, hardware boundaries, and reasons for state transitions.
- In a scope, declare ordinary values, counters, timestamps, and arrays first. Then separate flags with an empty line and a group comment in the required language. Apply this to module state, locals, and structure fields; do not create empty groups.
- Classify flags by semantics: readiness, enable, validity, completion, and requests are flags; an 8-bit index or percentage is an ordinary value. Keep parameter order meaningful rather than changing signatures to group flags.
- Follow the ownership and synchronization design for interrupt-shared data. `volatile` does not replace critical sections, atomics, or consistent snapshots.

## Layout example

The example uses English comments for illustration. When writing actual project firmware, use the comment language selected above. The sample shows layout, not a complete interrupt-safe publication protocol or real hardware parameters.

```c
#include <stdint.h>

#define SAMPLE_FRAME_INVALID 0U // Frame is invalid

// Ordinary values
static uint32_t sample_Frame_Seq; // Sequence of the latest published frame

// Flags
static uint8_t sample_Frame_Valid; // Frame validity: 0 = invalid, 1 = valid

void Sample_Init(void)
{
    sample_Frame_Seq = 0U;
    sample_Frame_Valid = SAMPLE_FRAME_INVALID;
}


void Sample_Publish(
    uint8_t frame_Valid) /* Incoming frame validity: 0 = invalid, 1 = valid */
{
    if (frame_Valid == SAMPLE_FRAME_INVALID)
    {
        sample_Frame_Valid = SAMPLE_FRAME_INVALID;
        return;
    }

    sample_Frame_Seq++;
    sample_Frame_Valid = 1U;
}
```

Declare public interfaces in the corresponding header and register the module in the real build. In generated files, use existing permitted extension regions; this example does not authorize insertion outside them. Handwritten files do not need fabricated user-region markers. Do not use this sample as a DMA/ISR data handoff without a synchronization design.
