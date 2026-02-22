#!/usr/bin/env bash
set -euo pipefail

VERBOSE=0
VERSION="1.0.0"

usage() {
    cat <<EOF
tbw - calculate Terabytes Written (TBW) from SMART data

Usage:
  tbw [options] <device>

Options:
  -v            Verbose output
  -h, --help    Show this help
  -V, --version Show version

Examples:
  sudo tbw sda
  sudo tbw -v /dev/nvme0n1
EOF
}

# Handle long options first
case "${1:-}" in
    --help)
        usage
        exit 0
        ;;
    --version)
        echo "tbw $VERSION"
        exit 0
        ;;
esac

while getopts "vhV" opt; do
    case "$opt" in
        v) VERBOSE=1 ;;
        h) usage; exit 0 ;;
        V) echo "tbw $VERSION"; exit 0 ;;
        *) usage >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

[[ -z "$1" ]] && { echo "Usage: $0 [-v] <device>" >&2; exit 1; }
[[ $EUID -ne 0 ]] && { echo "Run as root" >&2; exit 1; }

[[ "$1" == /dev/* ]] && DEVICE="$1" || DEVICE="/dev/$1"
[[ -b "$DEVICE" ]] || { echo "Device not found: $DEVICE" >&2; exit 1; }

SMART=$(smartctl -a "$DEVICE")

# ---- NVMe ----
if echo "$SMART" | grep -q "NVMe"; then
    TYPE="NVMe"
    DATA_UNITS=$(echo "$SMART" | awk '/Data Units Written/ {print $4}' | tr -d ',')
    [[ -z "$DATA_UNITS" ]] && { echo "Could not read NVMe writes" >&2; exit 1; }
    BYTES=$((DATA_UNITS * 512000))

# ---- SATA ----
else
    TYPE="SATA"

    SECTOR_SIZE=$(echo "$SMART" | grep "Sector Size" | grep -o '[0-9]\+' | head -1)

    LBAS=$(echo "$SMART" | awk '/Total_LBAs_Written/ {print $NF}')

    [[ -z "$SECTOR_SIZE" || -z "$LBAS" ]] && {
        echo "Could not determine SATA write data" >&2
        exit 1
    }

    BYTES=$((LBAS * SECTOR_SIZE))
fi

TB=$(awk "BEGIN {printf \"%.2f\", $BYTES/1000000000000}")

if [[ $VERBOSE -eq 1 ]]; then
    echo "Drive: $DEVICE"
    echo "Type: $TYPE"
    [[ "$TYPE" == "SATA" ]] && echo "Sector size: $SECTOR_SIZE bytes"
    [[ "$TYPE" == "SATA" ]] && echo "LBAs written: $LBAS"
    [[ "$TYPE" == "NVMe" ]] && echo "Data units written: $DATA_UNITS"
    echo "Terabytes written: $TB TB"
else
    echo "$TB"
fi