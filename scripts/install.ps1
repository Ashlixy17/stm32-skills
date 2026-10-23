# Install the skill bundle without changing agent configuration or Git state.
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet('codex', 'claude-code', 'deepseek-harness', 'universal')]
    [string]$Agent = 'codex',

    [ValidateSet('project', 'user')]
    [string]$Scope = 'project',

    [string]$ProjectRoot = (Get-Location).Path,

    [string]$SkillsRoot
)

$ErrorActionPreference = 'Stop'
$skillName = 'stm32-skills'
$bundlePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../skills/$skillName"))
if (-not (Test-Path -LiteralPath (Join-Path $bundlePath 'SKILL.md') -PathType Leaf)) {
    throw "Skill bundle is missing: $bundlePath"
}

if (-not $SkillsRoot) {
    if ($Scope -eq 'project') {
        $basePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ProjectRoot)
        switch ($Agent) {
            'claude-code' { $SkillsRoot = Join-Path $basePath '.claude/skills' }
            'deepseek-harness' { $SkillsRoot = Join-Path $basePath '.dsh/skills' }
            default { $SkillsRoot = Join-Path $basePath '.agents/skills' }
        }
    }
    else {
        $userPath = [Environment]::GetFolderPath('UserProfile')
        switch ($Agent) {
            'claude-code' { $SkillsRoot = Join-Path $userPath '.claude/skills' }
            'deepseek-harness' {
                if ($env:DSH_HOME) {
                    $SkillsRoot = Join-Path $env:DSH_HOME 'skills'
                }
                else {
                    $SkillsRoot = Join-Path $userPath '.dsh/skills'
                }
            }
            default { $SkillsRoot = Join-Path $userPath '.agents/skills' }
        }
    }
}

$requestedRoot = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($SkillsRoot)
$rootPath = [IO.Path]::GetPathRoot($requestedRoot)
$relativeParts = $requestedRoot.Substring($rootPath.Length) -split '[/\\]'
# Resolve each existing directory link before checking for a nested copy.
foreach ($part in $relativeParts) {
    if (-not $part) {
        continue
    }
    $rootPath = Join-Path $rootPath $part
    if (Test-Path -LiteralPath $rootPath) {
        $directoryItem = Get-Item -LiteralPath $rootPath -Force
        if (-not $directoryItem.PSIsContainer) {
            throw "Skills root has a non-directory ancestor: $rootPath"
        }
        if ($directoryItem.LinkType) {
            if (-not ($directoryItem.PSObject.Methods.Name -contains 'ResolveLinkTarget')) {
                throw 'Use PowerShell 7 or a skills root without a directory link.'
            }
            $rootPath = $directoryItem.ResolveLinkTarget($true).FullName
        }
    }
}
$destinationPath = [IO.Path]::GetFullPath((Join-Path $rootPath $skillName))
$comparison = [StringComparison]::Ordinal
if ([IO.Path]::DirectorySeparatorChar -eq '\') {
    $comparison = [StringComparison]::OrdinalIgnoreCase
}
$bundlePrefix = $bundlePath.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
if ($destinationPath.Equals($bundlePath, $comparison) -or $destinationPath.StartsWith($bundlePrefix, $comparison)) {
    throw 'The destination must not be inside the source skill bundle.'
}
if (Test-Path -LiteralPath $destinationPath) {
    throw "Destination already exists; no files were overwritten: $destinationPath"
}

if ($PSCmdlet.ShouldProcess($destinationPath, 'Install stm32-skills')) {
    New-Item -ItemType Directory -Path $rootPath -Force | Out-Null
    New-Item -ItemType Directory -Path $destinationPath | Out-Null
    Get-ChildItem -LiteralPath $bundlePath -Force | Copy-Item -Destination $destinationPath -Recurse
    Write-Output "Installed $skillName to $destinationPath"
}
