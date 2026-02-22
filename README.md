# tbw

A small Unix-style utility that calculates **Terabytes Written (TBW)** for SATA and NVMe drives using `smartctl`.

It prints a machine-friendly numeric value by default, making it ideal for scripting and monitoring.

---

## Features

- Supports SATA (`Total_LBAs_Written`)
- Supports NVMe (`Data Units Written`)
- Clean pipe-friendly output
- Optional verbose mode (`-v`)
- No embedded sudo (run as root explicitly)
- No external dependencies except `smartctl`

---

## Requirements

- Linux
- smartmontools (`smartctl`)
- Root privileges (required by smartctl)

Install smartmontools:

Debian/Ubuntu:
```
sudo apt install smartmontools
```

RHEL/CentOS:
```
sudo yum install smartmontools
```

---

## Usage

Basic (machine-friendly output):

```
sudo ./tbw sda
```

Output:
```
37.41
```

Verbose mode:

```
sudo ./tbw -v sda
```

Example verbose output:

```
Drive: /dev/sda
Type: SATA
Sector size: 512 bytes
LBAs written: 73063745570
Terabytes written: 37.41 TB
```

---

## Examples

Use in scripts:

```
TBW=$(sudo ./tbw sda)
```

Check threshold:

```
sudo ./tbw sda | awk '$1 > 200'
```

Scan all drives:

```
lsblk -ndo NAME,TYPE | awk '$2=="disk"{print $1}' | \
while read d; do
    sudo ./tbw "$d"
done
```

---

## Philosophy

`tbw` follows Unix principles:

- Does one thing
- Prints clean output
- Sends errors to stderr
- Composable via pipes
- No hidden privilege escalation

---

## License

GNU GPL