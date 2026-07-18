# rr
[![Swift](https://img.shields.io/badge/Swift-6-orange?style=for-the-badge&logo=swift)](https://github.com/apple/swift)
[![License](https://img.shields.io/badge/License-MIT--SUSHI--WARE--🍣-blue?style=for-the-badge)](https://github.com/mui-z/neko/blob/main/LICENSE)
[![X](https://img.shields.io/badge/X-@mui__z__-000000?style=for-the-badge&logo=x)](https://x.com/mui_z_)

A simple CLI QR code generator.

You can display the QR code in your terminal and copy it to the clipboard!

<img width="500" height="566" alt="スクリーンショット 2026-07-14 0 30 41" src="https://github.com/user-attachments/assets/8a9002b6-65d4-4b35-9eb7-77e173c3bb9e" />


## Usage

```bash
rr <text> [--copy] [--quiet] [--size <size>] [--title <title>] [--level <level>] [--output <output>]
```

## Installation

```bash
# Homebrew
brew tap mui-z/tap
brew install mui-z/tap/rr

# Mint
mint install mui-z/rr

# Mise
mise use -g spm:mui-z/rr
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

Save the QR code image to a file:

```bash
rr -o qr.png https://github.com/mui-z/rr
```


### Options

| Option | Description |
| --- | --- |
| `<text>` | Text to encode into the QR code. |
| `-c`, `--copy` | Copy the QR code image to the clipboard. |
| `-q`, `--quiet` | Suppress QR code display in terminal. |
| `-s`, `--size <size>` | Max clipboard image dimension in pixels. Default: 400. |
| `-t`, `--title <title>` | Title text to overlay on the QR code image. |
| `-l`, `--level <level>` | QR Code error correction level (L, M, Q, or H). Default: M. |
| `-o`, `--output <output>` | Output file path for the QR code image. Supported formats: PNG, JPEG, TIFF, BMP, GIF. |
| `-h`, `--help` | Show help information. |


