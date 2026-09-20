#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ciq_dir="${HOME}/.Garmin/ConnectIQ"

if [[ -z "${CIQ_SDK_HOME:-}" ]]; then
    if [[ ! -f "$ciq_dir/current-sdk.cfg" ]]; then
        echo "Select an SDK in Garmin SDK Manager, or set CIQ_SDK_HOME." >&2
        exit 1
    fi
    CIQ_SDK_HOME="$(cat "$ciq_dir/current-sdk.cfg")"
fi

if [[ ! -x "$CIQ_SDK_HOME/bin/monkeyc" ]]; then
    echo "Compiler not found: $CIQ_SDK_HOME/bin/monkeyc" >&2
    exit 1
fi

if [[ ! -f "$ciq_dir/Devices/fr970/compiler.json" ]]; then
    echo "Download Forerunner 970 from the Devices tab in Garmin SDK Manager first." >&2
    exit 1
fi

developer_key="${DEVELOPER_KEY:-$project_dir/developer_key.der}"
if [[ ! -f "$developer_key" ]]; then
    echo "Signing key missing: $developer_key. See the README to generate one." >&2
    exit 1
fi

cd "$project_dir"
mkdir -p bin
exec "$CIQ_SDK_HOME/bin/monkeyc" \
    -f monkey.jungle -d fr970 -o bin/Quiet970.prg -y "$developer_key" -w "$@"
