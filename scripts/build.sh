#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ciq_dir="${CIQ_HOME:-$HOME/.Garmin/ConnectIQ}"

usage() {
    echo "Usage: $0 [project] [device] [monkeyc options...]"
    echo "       $0 --list"
    echo "Projects live under projects/. Defaults: quiet970 and its default-device.txt."
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
fi

if [[ "${1:-}" == "--list" ]]; then
    for jungle in "$repo_dir"/projects/*/monkey.jungle; do
        [[ -f "$jungle" ]] && basename "$(dirname "$jungle")"
    done
    exit 0
fi

project="quiet970"
if [[ $# -gt 0 && "$1" != -* ]]; then
    project="$1"
    shift
fi
if [[ ! "$project" =~ ^[a-z][a-z0-9_-]*$ ]]; then
    echo "Invalid project name: $project" >&2
    exit 1
fi

project_dir="$repo_dir/projects/$project"
if [[ ! -f "$project_dir/monkey.jungle" || ! -f "$project_dir/manifest.xml" ]]; then
    echo "Unknown project: $project. Run $0 --list." >&2
    exit 1
fi

device=""
if [[ $# -gt 0 && "$1" != -* ]]; then
    device="$1"
    shift
elif [[ -f "$project_dir/default-device.txt" ]]; then
    IFS= read -r device < "$project_dir/default-device.txt"
fi
if [[ ! "$device" =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Provide a device ID or add projects/$project/default-device.txt." >&2
    exit 1
fi

if [[ -z "${CIQ_SDK_HOME:-}" ]]; then
    if [[ ! -f "$ciq_dir/current-sdk.cfg" ]]; then
        echo "Select an SDK in Garmin SDK Manager, or set CIQ_SDK_HOME." >&2
        exit 1
    fi
    CIQ_SDK_HOME="$(< "$ciq_dir/current-sdk.cfg")"
fi
if [[ ! -x "$CIQ_SDK_HOME/bin/monkeyc" ]]; then
    echo "Compiler not found: $CIQ_SDK_HOME/bin/monkeyc" >&2
    exit 1
fi

devices_dir="${CIQ_DEVICES_HOME:-$ciq_dir/Devices}"
if [[ ! -f "$devices_dir/$device/compiler.json" ]]; then
    echo "Device $device is not installed in $devices_dir." >&2
    exit 1
fi

developer_key="${DEVELOPER_KEY:-$repo_dir/developer_key.der}"
if [[ ! -f "$developer_key" ]]; then
    echo "Signing key missing: $developer_key. See the README." >&2
    exit 1
fi

output_dir="$repo_dir/bin/$project"
mkdir -p "$output_dir"
cd "$project_dir"
exec "$CIQ_SDK_HOME/bin/monkeyc" \
    -f monkey.jungle -d "$device" -o "$output_dir/$device.prg" \
    -y "$developer_key" -w "$@"
