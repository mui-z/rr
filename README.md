# rr
[![Swift](https://img.shields.io/badge/Swift-6-orange?style=for-the-badge&logo=swift)](https://github.com/apple/swift)
[![License](https://img.shields.io/badge/License-MIT--SUSHI--WARE--🍣-blue?style=for-the-badge)](https://github.com/mui-z/neko/blob/main/LICENSE)
[![X](https://img.shields.io/badge/X-@mui__z__-000000?style=for-the-badge&logo=x)](https://x.com/mui_z_)

The simple cli qr code generator.

Your can show code on terminal and copy clipboard!

## Usage

```bash
rr <text> [--copy] [--level <level>]
```

### Examples

Open a URL on your phone:

```bash
rr https://github.com/mui-z/rr
```

Share WiFi credentials:

```bash
rr "WIFI:T:WPA;S:MyCafeWiFi;P:secretpass;;"
```

Copy the QR image to clipboard for sharing in chat apps:

```bash
rr -c https://github.com/mui-z/rr
```

Use high error correction so the QR stays scannable even if partly damaged:

```bash
rr -l H "WIFI:T:WPA;S:MyCafeWiFi;P:secretpass;;"
```

### Options

| Option | Description |
| --- | --- |
| `<text>` | Text to encode into the QR code. |
| `-c`, `--copy` | Copy the QR code image to the clipboard. |
| `-l`, `--level <level>` | QR Code error correction level (L, M, Q, or H). Default: M. |
| `-h`, `--help` | Show help information. |

## Installation

```bash
mise use -g github:mui-z/rr
```