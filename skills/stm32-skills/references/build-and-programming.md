# Build, Programming, and Troubleshooting

Use for toolchain discovery, target builds, compile/link failures, and authorized firmware programming. Reuse the current project and tools; a command-line workflow does not require migrating Keil to GCC, installing STM32CubeCLT, or replacing the build system. These are command templates and diagnostic guidance, not bundled build/flash wrappers.

## 1. Identify the build and programming environment

- Locate the actual project: `.uvprojx`/`.uvproj` and its target, an existing CMSIS solution, or the current CMake/Make configuration. Inspect existing scripts before running them, including pre/post-build hooks that could flash or change files. Building and programming remain separate operations.
- Resolve executable paths from the current environment and confirmed installations. `Get-Command UV4, armclang, fromelf, arm-none-eabi-gcc, STM32_Programmer_CLI -ErrorAction SilentlyContinue` is useful on PowerShell; absence from `PATH` does not prove a tool is uninstalled. Quote paths containing spaces and use PowerShell's call operator `&` for native CLIs.
- Record tool versions and the selected compiler. Arm Compiler 5 uses `armcc`; Arm Compiler 6 uses `armclang`. Both use Arm tools such as `armlink` and `fromelf`, but compiler/assembler flags and supported syntax differ. GCC flags, `.ld` linker scripts, and GCC startup assembly are not interchangeable with Arm compiler settings, scatter files (`.sct`), and startup files.
- In Keil, inspect the target's compiler selection (including `uAC6`/`pCCUsed` when present), device/DFP, source groups, include paths, macros, CPU/FPU/ABI, startup/system files, memory layout, and output locations. Verify the selected version is installed and licensed. An unavailable compiler is an environment/configuration issue; do not silently switch compiler families or edit project selectors to make it build.
- STM32CubeCLT can provide GNU tools and programming/debug components. Discover its actual layout/version rather than copying a versioned example path. With an existing GCC project, use its preset/build command, device macro, HAL configuration, startup, and linker script; do not replace them with a generic F4 template.

Host-only version/help queries do not connect to a target:

```powershell
# Substitute confirmed executable paths before use.
& 'C:\path\to\Keil\ARM\ARMCLANG\bin\armclang.exe' --version
& 'C:\path\to\Keil\ARM\ARMCLANG\bin\fromelf.exe' --vsn
& 'C:\path\to\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe' --version
& 'C:\path\to\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe' --help
```

### Verify the development chain

Before business debugging or a timed development task, establish which parts of the actual chain work: required documents/archive access -> selected target build -> authorized image download and verification -> device startup -> a known input/output check. Use an existing suitable known-good project/image when available; do not replace the current configuration or overwrite a fault state merely to run a generic example.

- Check each stage independently and record its result. An installed tool does not prove compilation, a build does not prove programming, and a verified image does not prove startup or correct peripheral scaling.
- For the affected measurement/output, use a documented known input or existing observation to check the expected units, sign, and order of magnitude before connecting business logic. Keep physical operations within the task's authorization; unavailable device checks remain pending.
- On failure, preserve the exact error, selected tool/target, attempted actions, and blocked stage. In a timed event, report environment problems through the permitted process and record time lost instead of repeating unsuccessful installation steps. Allowed setup time, reboot, tool installation, materials, and submission procedures come from the current event rules.

## 2. Build an existing Keil target

Prefer the project's inspected build script when one exists. Otherwise, select the exact target from the project rather than relying on the last target used by the GUI. The example assumes an existing project and an authorized build; replace the path and target name. A unique log avoids treating an old log as the result of this invocation.

```powershell
$uv4Path = 'C:\path\to\Keil\UV4\UV4.exe'
$projectPath = (Resolve-Path -LiteralPath '.\MDK-ARM\Project.uvprojx').Path
$targetName = 'Target 1'
$buildLog = Join-Path $env:TEMP ('stm32-build-' + [guid]::NewGuid().ToString('N') + '.log')
$buildArguments = @('-b', ('"' + $projectPath + '"'), '-t', ('"' + $targetName + '"'), '-o', ('"' + $buildLog + '"'), '-j0', '-sg')
$buildProcess = Start-Process -FilePath $uv4Path -ArgumentList $buildArguments -Wait -PassThru -WindowStyle Hidden
if (-not (Test-Path -LiteralPath $buildLog)) {
    throw "Keil produced no build log; exit code: $($buildProcess.ExitCode)"
}
Get-Content -LiteralPath $buildLog
if ($buildProcess.ExitCode -notin @(0, 1)) {
    throw "Keil build failed; exit code: $($buildProcess.ExitCode)"
}
```

- `-b` builds changed files; `-r` rebuilds the selected target when a full rebuild is needed. `-t` selects the target; `-o` saves build output; `-j0` hides the GUI; `-sg` avoids saving user GUI-layout changes. Do not run broad clean/rebuild operations merely to inspect an existing artifact.
- Wait for the process and read its exit code and complete log. Keil build codes are `0`: no errors/warnings, `1`: warnings only, `2`: errors, `3`: fatal errors; other codes can indicate project/device/import failures. Code `1` is not an error-free/warning-free result. Apply the project's warning policy, inspect new warnings, and do not normalize all nonzero codes to success.
- The example only checks basic process/log failure. Confirm the log names the requested target/compiler, completes with zero errors, and produces the expected current AXF/HEX/map outputs. A successful up-to-date build may reuse artifacts; verify their provenance rather than requiring every timestamp to change. After compiler/linker/startup changes, perform a full target build.
- Build or project hooks can have side effects. Inspect the resulting diff/status for unintended project changes. A timed-out or incomplete process is not build success; investigate only the task-owned process without closing other IDE sessions.

Keil can also program using `UV4.exe -f <project> -t <target> -o <log> -j0`. Use that route only when the project's configured probe, flash algorithm, memory ranges, and reset/run policy are confirmed and programming is authorized. It uses project programming settings; it is not a substitute for the build command.

## 3. Inspect and convert Arm images

Keep the AXF/ELF with symbols for offline analysis and debugging. Prefer the target's existing HEX generation when configured. Create the chosen output directory first and avoid overwriting a user artifact. `fromelf` can inspect an Arm image or create a programming artifact without connecting hardware:

```powershell
$fromelfPath = 'C:\path\to\Keil\ARM\ARMCLANG\bin\fromelf.exe'
$imagePath = (Resolve-Path -LiteralPath '.\MDK-ARM\Objects\Project.axf').Path
& $fromelfPath --text -s $imagePath
if ($LASTEXITCODE -ne 0) { throw 'Arm image inspection failed.' }
& $fromelfPath --i32 --output '.\build\firmware.hex' $imagePath
if ($LASTEXITCODE -ne 0) { throw 'HEX conversion failed.' }
```

`--text -s` prints symbols; `--text -c` disassembles code; `--i32` emits Intel HEX; `--bin` emits raw binary. Inspect the actual load regions before choosing a format: multi-load-region images may produce multiple output files and need a format/combination strategy supported by the installed tool. Do not concatenate region files blindly or assume one output filename covers the entire image.

| Artifact | Programming interpretation |
|---|---|
| AXF/ELF | Contains load regions and may contain debug symbols; confirm the programmer supports the actual file format/extension. Conversion does not add missing symbols |
| Intel HEX | Carries addresses; inspect its ranges against the approved memory layout and use those addresses |
| BIN | Has no embedded load address; specify the approved application address and check length/range before writing |

Do not infer a BIN address from its filename or universally use `0x08000000`: bootloaders, bank layouts, external memory, and application offsets can change the destination. Preserve the connection between source, build target, AXF/ELF, converted image, and hashes. Image conversion is not a firmware build or device verification.

## 4. Use STM32CubeProgrammer CLI deliberately

Inspect the installed CLI's help before using version-dependent options. The examples use the MCU SWD interface; UART/DFU bootloader entry, multicore/AP selection, external loaders, and secure programming require the actual device's documented procedure. This skill does not assume those modes are interchangeable.

### Discover probes and confirm the target

```powershell
$programmerPath = 'C:\path\to\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe'
& $programmerPath -l stlink-only
```

In versions supporting it, `stlink-only` lists ST-LINK probes without accessing the target. `-l stlink` is also available, but can inspect the attached target; do not treat it as equivalent to a host-only list. Record the intended probe serial number, especially with multiple probes. Probe enumeration does not establish the connected MCU, power integrity, or programming readiness.

Before a target connection or write, apply the entrypoint's [wiring checks](bringup-and-integration.md#mandatory-two-pass-wiring-check), confirm session ownership, and preserve any needed fault state. Check device identity, flash capacity, memory ranges, image provenance, and the impact on bootloader/calibration/user-data sectors. Programming can erase flash sectors as part of writing, even without an explicit erase command. A file's byte range is not a guarantee that neighboring data in the same erased sector survives.

Connection modes have different effects: `NORMAL`, `HOTPLUG`, and `UR` (under reset) are not interchangeable. Choose from the authorized operation and installed help. `UR` requires the actual reset connection and permitted reset behavior. A connection-only command can still affect execution; do not use a default attach as an unqualified way to preserve a live fault.

### Write and verify an addressed image

This example assumes target identity and the image/ranges are already confirmed, and programming is authorized. Replace the serial number and artifact path. It writes an Intel HEX using the addresses in that file and requests verification immediately after the write:

```powershell
$probeSerial = 'REPLACE_WITH_CONFIRMED_STLINK_SERIAL'
$firmwareHex = (Resolve-Path -LiteralPath '.\build\firmware.hex').Path
$programLog = Join-Path $env:TEMP ('stm32-program-' + [guid]::NewGuid().ToString('N') + '.log')
& $programmerPath -c port=SWD "sn=$probeSerial" -w $firmwareHex -v -log $programLog
$programExit = $LASTEXITCODE
if ($programExit -ne 0) {
    throw "Programming/verification failed; exit code: $programExit; log: $programLog"
}
```

For BIN, the corresponding write portion is `-w <binary-path> <confirmed-application-address> -v`. Do not add an arbitrary address to the HEX example. `-v` must follow the write operation; it is not a standalone assertion that an earlier command was verified. Capture the exit status and full output, including device identity, written ranges, and the explicit verification result. Do not reset/run after failure, a timeout, or an incomplete log.

### Reset or run only within the intended procedure

After confirmed write/verification, a software system reset can be requested separately when authorized:

```powershell
& $programmerPath -c port=SWD "sn=$probeSerial" -rst
if ($LASTEXITCODE -ne 0) { throw 'Reset command failed.' }
```

`-rst` requests a software system reset; `-hardRst` uses the physical reset line; `-g`/`--go` starts execution at an address. These are distinct operations. A successful reset command does not prove application startup; boot configuration and the actual runtime observations still matter. Do not substitute `-g 0x08000000` for a verified boot procedure.

Do not add mass erase (`-e all`), option-byte writes, read-unprotect (`-rdu`), protection changes, or probe-firmware upgrades as generic recovery steps. Some erase data or change security/boot behavior. Explain the specific device procedure and consequence, and stay within explicit authorization for that action. Do not bypass a busy session with shared mode or by globally killing debug processes.

## 5. Locate the first failing layer

Preserve the exact command, target/tool version, first relevant diagnostic, and full log. Treat the following as hypotheses to check, not one-to-one diagnoses. Make the smallest supported correction and retest the same layer before moving on. Configuration fixes still follow the project's generator and design boundaries.

| Symptom/layer | Evidence to inspect and next useful action |
|---|---|
| Executable missing, compiler unavailable, or license failure | Resolve the actual installation and selected compiler/version/license; distinguish a missing PATH entry from a missing installation. Do not migrate compilers or change source to bypass an environment failure |
| Cannot find header / unknown HAL type such as `DMA2D_HandleTypeDef` | Inspect the failing translation unit's include paths, active `hal_conf.h`, device macro, module enable, and HAL version. Enable a module only if intended by the design; respect CubeMX ownership instead of adding arbitrary macros |
| `undefined reference` / Arm `L6218E` for `SystemCoreClock`, HAL, or LL symbols | Find the defining source/object/library and check real target membership, conditional compilation, library order where relevant, and version/ABI. `SystemCoreClock` often comes from the matching system source; an FMC symbol may need the matching LL source. Do not add dummy definitions |
| Duplicate symbol / Arm `L6200E` | Identify both defining objects, duplicate source registration, header definitions, and callback/IRQ ownership. Fix the duplicate owner rather than renaming required callbacks or weakening symbols blindly |
| Cannot open `.ld`/`.sct`, missing startup, or unknown assembly directive | Verify file existence, quoting, working directory, compiler family, startup syntax, and actual linker selection. Do not assume a pack template contains the project's linker script |
| ABI/FPU/CPU mismatch or invalid instructions | Compare every relevant object/library with the target CPU, FPU, float ABI, and compiler settings. A fresh source file does not repair an incompatible prebuilt library |
| Region overflow or section placement failure | Inspect map/load regions, memory device limits, section ownership, and actual static/buffer sizes. Do not enlarge RAM/Flash beyond hardware limits or move sections arbitrarily |
| Build says success but an old/missing image is selected | Check selected target, output paths, hooks, complete log, and AXF/HEX correspondence. Resolve a stale log/artifact or wrong configuration before programming |
| No ST-LINK detected / probe busy | Check host enumeration, USB data cable/driver, intended serial number, and existing session owner. A detected probe is a separate fact from a detected MCU; avoid repeated target retries |
| Probe detected but no target / connection fails | Check actual target supply/reference, common ground/isolation, SWDIO/SWCLK/NRST routing, device identity, and supported clock/mode. Lower SWD frequency only within the allowed interface settings; under-reset recovery needs confirmed NRST and reset authorization |
| Write/verification failure | Inspect the failing address, exact image/ranges, protection state, flash geometry, external-loader requirements, supply/load conditions, and full log. Stop automatic retries; do not reset/run or erase unrelated sectors to hide the error |
| Verification passes but firmware does not start or timing is wrong | Check boot selection, application offset/vector table, initial stack/reset vector, watchdog/reset cause, clock source/bypass/PLL, and `HSE_VALUE` against hardware. Derive conclusions from runtime evidence, not the presence of a macro. Continue with [Debugging with evidence](debugging.md) |

For runtime visibility, prefer existing debugger/register/trace observations. Adding LED toggles, `printf`, or a new logging channel changes source/timing and requires the relevant design/configuration authorization; do not adopt these as automatic first steps.

## 6. Report each result separately

Record source changes/revision, target/compiler, actual command, exit code, diagnostic summary, artifact identity/hash and memory ranges. For programming, also record CLI/probe/device identity, connection mode, verification output, and any reset/run operation. Link repeated observations through [Structured sampling records](sampling-records.md) when useful.

Distinguish tool/help inspection, successful target build, successful write, verified contents, reset/run request, and observed application behavior. Missing tools, unavailable devices, unsupported modes, and unperformed checks remain explicit limits; a build or verification result alone does not establish physical application behavior.

## Sources and version checks

- [EricSun787 / stm32-development-workflow](https://github.com/EricSun787/stm32-development-workflow/blob/c5df7ba0f5da28fc3de2b81992d16924e87d6c02/SKILL.md): workflow and compile/link/programming troubleshooting topics; example chip, clock, addresses, paths, and fixes are not project defaults.
- [NickQ's Blue Bridge Cup experience](https://www.cnblogs.com/NickQ/p/8721317.html) and [16th embedded provincial retrospective](https://openvela.csdn.net/694bbd6e5b9f5f31781a62ba.html): development-environment and peripheral-configuration checks before business debugging; old event rules and board settings are not current defaults.
- [Keil µVision command line](https://www.keil.com/support/man/docs/uv4/uv4_commandline.asp): build/program commands, options, and build exit codes.
- [Arm linker references and definitions](https://support.arm.com/documentation/101754/0624/armlink-Reference/Image-Structure-and-Generation/Weak-references-and-definitions): unresolved and multiply defined symbols, library resolution, and weak definitions.
- [Arm fromelf input files and load regions](https://support.arm.com/documentation/dui0805/i/fromelf-Command-line-Options/input-file): image conversion and multiple load regions; check the installed `fromelf --help` for supported options.
- [ST UM2237: STM32CubeProgrammer software description](https://www.st.com/resource/en/user_manual/dm00403500-stm32cubeprogrammer-stmicroelectronics.pdf): MCU connection, write/verify, reset/start, and protection commands. Check the installed `STM32_Programmer_CLI --help`; enumeration options such as `stlink-only` depend on version.
