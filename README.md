# tbw

A small Unix-style utility that calculates **Terabytes Written (TBW)**
for SATA and NVMe drives using `smartctl` JSON output.

It prints a machine-friendly numeric value by default, making it ideal
for scripting and monitoring.

------------------------------------------------------------------------

## Features

-   Supports SATA (`Total_LBAs_Written`)
-   Supports NVMe (`data_units_written`)
-   Uses `smartctl -a -j` (JSON parsing, robust & future-proof)
-   Clean pipe-friendly output
-   Optional verbose mode (`-v`)
-   No embedded sudo (run as root explicitly)
-   Minimal dependencies

------------------------------------------------------------------------

## Requirements

-   Linux
-   smartmontools (`smartctl`)
-   `jq`
-   Root privileges (required by smartctl)

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

Basic (machine-friendly output):

    sudo ./tbw sda

Output:

    37.41

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

Current version: **3.0.0**\
(JSON-based implementation)

------------------------------------------------------------------------

## License

GNU GPL
