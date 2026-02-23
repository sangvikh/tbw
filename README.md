# tbw

A small Unix-style utility that calculates **Terabytes Written (TBW)**
for SATA and NVMe drives using `smartctl`.

It prints clean, pipe-friendly numeric output by default, making it ideal
for scripting, monitoring, and logging SSD write life.

------------------------------------------------------------------------

## Features

-   Supports SATA (`Total_LBAs_Written`) and NVMe (`data_units_written`)
-   Reads SMART data via `smartctl -a -j`
-   Optional `--bytes` mode for raw numeric bytes (script-friendly)
-   Minimal dependencies (`smartctl`, `jq`)
-   Requires root privileges (run with `sudo`)
-   Follows Unix philosophy: single responsibility, composable, minimal interface

------------------------------------------------------------------------

## Requirements

-   Linux
-   smartmontools (`smartctl`)
-   `jq`
-   Root privileges

Install dependencies:

### Debian / Ubuntu

    sudo apt install smartmontools jq

### RHEL / CentOS / Rocky

    sudo yum install smartmontools jq

------------------------------------------------------------------------

## How It Works

`tbw` reads SMART data in JSON format:

    smartctl -a -j /dev/DEVICE

Then:

-   **NVMe**\
    Uses `nvme_smart_health_information_log.data_units_written`\
    Each unit = **512,000 bytes**

-   **SATA**\
    Uses SMART attribute `Total_LBAs_Written`\
    Multiplied by `logical_block_size`

The result is converted to **decimal terabytes (TB)**:

    1 TB = 1,000,000,000,000 bytes

------------------------------------------------------------------------

## Usage

Basic (TB, human-friendly):

    sudo ./tbw sda

Output:

    37.41

Raw bytes (script-friendly):

    sudo ./tbw --bytes /dev/nvme0n1

Output:

    37415580000000

Multiple devices:

    sudo ./tbw sda nvme0n1

Verbose mode:

    sudo ./tbw -v sda

Example verbose output:

    Drive: /dev/sda
    Type: SATA
    Bytes written: 37408157962240
    Terabytes written: 37.41 TB

------------------------------------------------------------------------

## Examples

Use in scripts:

    TBW=$(sudo ./tbw sda)

Check threshold:

    sudo ./tbw sda | awk '$1 > 200'

Scan all drives:

    lsblk -ndo NAME,TYPE | awk '$2=="disk"{print $1}' | while read d; do
        sudo ./tbw "$d"
    done

------------------------------------------------------------------------

## Design Philosophy

`tbw` follows Unix principles:

-   Does one thing well
-   Prints clean numeric output
-   Sends errors to stderr
-   Fully composable
-   No hidden privilege escalation
-   Uses structured JSON instead of brittle text parsing

------------------------------------------------------------------------

## Version

Current version: 5.1.0
(Minimal, TB-first implementation)

------------------------------------------------------------------------

## License

GNU GPL
