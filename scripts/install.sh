#!/usr/bin/env bash
# Install the skill bundle without changing agent configuration or Git state.
set -euo pipefail

agent=codex
scope=project
project_root=$PWD
skills_root=
dry_run=false
skill_name=stm32-skills

usage() {
    printf '%s\n' 'Usage: bash scripts/install.sh [--agent codex|claude-code|deepseek-harness|universal]'
    printf '%s\n' '       [--scope project|user] [--project-root PATH] [--skills-root PATH] [--dry-run]'
}

while (($#)); do
    case "$1" in
        --agent|--scope|--project-root|--skills-root)
            if (($# < 2)) || [[ -z $2 ]]; then
                printf 'Missing value for %s\n' "$1" >&2
                exit 2
            fi
            case "$1" in
                --agent) agent=$2 ;;
                --scope) scope=$2 ;;
                --project-root) project_root=$2 ;;
                --skills-root) skills_root=$2 ;;
            esac
            shift 2
            ;;
        --dry-run) dry_run=true; shift ;;
        --help|-h) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
done

case "$agent" in
    codex|claude-code|deepseek-harness|universal) ;;
    *) printf 'Unsupported agent: %s\n' "$agent" >&2; exit 2 ;;
esac
case "$scope" in
    project|user) ;;
    *) printf 'Unsupported scope: %s\n' "$scope" >&2; exit 2 ;;
esac

# Resolve existing directory links and normalize missing path components too.
absolute_directory() {
    local input=$1 result=/ component
    local -a components
    if [[ $input != /* ]]; then
        input=$PWD/$input
    fi
    IFS=/ read -r -a components <<< "$input"
    for component in "${components[@]}"; do
        case "$component" in
            ''|.) continue ;;
            ..) result=${result%/*}; result=${result:-/} ;;
            *)
                result=${result%/}/$component
                if [[ -d $result ]]; then
                    result=$(cd -- "$result" && pwd -P)
                elif [[ -e $result || -L $result ]]; then
                    printf 'Not a directory: %s\n' "$result" >&2
                    return 1
                fi
                ;;
        esac
    done
    printf '%s\n' "$result"
}

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
bundle_path=$(absolute_directory "$script_dir/../skills/$skill_name")
if [[ ! -f $bundle_path/SKILL.md ]]; then
    printf 'Skill bundle is missing: %s\n' "$bundle_path" >&2
    exit 1
fi

if [[ -z $skills_root ]]; then
    if [[ $scope == project ]]; then
        case "$agent" in
            claude-code) skills_root=$project_root/.claude/skills ;;
            deepseek-harness) skills_root=$project_root/.dsh/skills ;;
            *) skills_root=$project_root/.agents/skills ;;
        esac
    else
        case "$agent" in
            claude-code) skills_root=$HOME/.claude/skills ;;
            deepseek-harness) skills_root=${DSH_HOME:-$HOME/.dsh}/skills ;;
            *) skills_root=$HOME/.agents/skills ;;
        esac
    fi
fi

root_path=$(absolute_directory "$skills_root")
destination_path=${root_path%/}/$skill_name
case "$destination_path/" in
    "$bundle_path/"*)
        printf '%s\n' 'The destination must not be inside the source skill bundle.' >&2
        exit 1
        ;;
esac
if [[ -e $destination_path || -L $destination_path ]]; then
    printf 'Destination already exists; no files were overwritten: %s\n' "$destination_path" >&2
    exit 1
fi

if [[ $dry_run == true ]]; then
    printf 'Would install %s to %s\n' "$skill_name" "$destination_path"
    exit 0
fi

mkdir -p -- "$root_path"
mkdir -- "$destination_path"
cp -R -- "$bundle_path/." "$destination_path/"
printf 'Installed %s to %s\n' "$skill_name" "$destination_path"
