<div align="center">

# 🌌 Twilight OS

### An elegant, high-performance Arch Linux distribution featuring KDE Plasma 6.

[![Build Twilight OS ISO](https://github.com/ard-tube/twilight-os/actions/workflows/build.yml/badge.svg)](https://github.com/ard-tube/twilight-os/actions/workflows/build.yml)
[![GitHub Release](https://img.shields.io/github/v/release/ard-tube/twilight-os?include_prereleases&style=for-the-badge&color=89b4fa&label=Release)](https://github.com/ard-tube/twilight-os/releases)
[![Base](https://img.shields.io/badge/Base-Arch%20Linux-1793d1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org)
[![Desktop](https://img.shields.io/badge/Desktop-KDE%20Plasma%206-1d99f3?style=for-the-badge&logo=kde&logoColor=white)](https://kde.org/plasma-desktop/)
[![Platform](https://img.shields.io/badge/Arch-x86__64-cba6f7?style=for-the-badge)](https://github.com/ard-tube/twilight-os)
[![License](https://img.shields.io/badge/License-GPL%20v3-a6e3a1?style=for-the-badge)](LICENSE)

<br/>

**[Website](https://ard-tube.github.io/twilight-os/)** • **[Download ISO](https://github.com/ard-tube/twilight-os/releases)** • **[Features](#-key-features)** • **[Installation](#-installation-guide)** • **[GitHub Actions](#-github-actions-build)**

<br/>

<img src="docs/assets/wallpaper.png" alt="Twilight OS Preview" width="100%" style="border-radius: 12px; box-shadow: 0 8px 24px rgba(0,0,0,0.5);"/>

</div>

---

## 🌟 Overview

**Twilight OS** combines the bleeding-edge performance and rolling-release power of **Arch Linux** with the refined aesthetics of **KDE Plasma 6 (Wayland)**. Engineered for developers, gamers, and daily drivers who want an Arch-based system that works out of the box without the tedious setup.

Built from scratch using modern `archiso` standards, Twilight OS delivers universal GPU acceleration, curated essential application suites, custom GUI & TUI installers, and a cohesive dark twilight visual theme.

---

## ✨ Key Features

- **🚀 KDE Plasma 6 on Wayland**: Buttery-smooth desktop experience with modern fractional scaling, HDR readiness, and gesture navigation.
- **⚡ Universal Graphics Out-of-the-Box**:
  - **NVIDIA**: Pre-configured `nvidia-open` kernel modules, userspace utilities, and `nvidia-prime` for hybrid laptops.
  - **AMD & Intel**: High-performance `mesa` drivers with `vulkan-radeon` and `vulkan-intel` hardware video acceleration.
- **🛠️ Dual Installers (GUI + Terminal)**:
  - **Twilight OS Setup Assistant (Qt6 GUI)**: Beautiful graphical installer with disk partitioning, user setup, and software pack selectors.
  - **Terminal TUI Installer**: Keyboard-driven CLI installer for low-spec machines or terminal enthusiasts.
- **📦 50 Curated Essential Applications**: Pre-categorized packs for Office, Media, Gaming, Web, and System Utilities.
- **🌌 Twilight OS System Identity**: Fully branded `/etc/os-release`, SDDM login screen, custom wallpaper, and interactive Fastfetch terminal banner.
- **🔐 Out-of-the-Box Live Environment**: Automatic SDDM login for `liveuser` with full passwordless `sudo` privileges.

---

## 💻 Terminal Showcase (`fastfetch` / `neofetch`)

Every terminal session opens with the Twilight OS signature Night Horizon ASCII art:

```text
          *             .                 liveuser@twilight-os
               .---.           *          --------------------
              /     \                     OS: Twilight OS x86_64
             |   /\  \     .              Host: Standard PC / Laptop
             |  /  \  \                   Kernel: Linux (Rolling)
              \ '._ \  \                  Uptime: 5 mins
               '--'  `--'                 Packages: 850+ (pacman)
        ~~~~~~~~~~~~~~~~~~~~~~            DE: KDE Plasma 6 (Wayland)
             TWILIGHT OS                  WM: KWin
                                          Terminal: konsole
```

---

## 📦 Curated 50 Application Suites

The Twilight OS Setup Assistant allows you to install curated application packs with one click:

| Category | Highlights |
| :--- | :--- |
| **📝 Office & Productivity** | LibreOffice Fresh, Obsidian, Okular, VS Code (OSS), Thunderbird, Ghostwriter, Calibre, gImageReader |
| **🎨 Media & Creative** | VLC, MPV, OBS Studio, Audacity, Kdenlive, GIMP, Krita, Blender, Inkscape, Spotify (Flatpak) |
| **🎮 Gaming & Performance** | Steam (multilib), Lutris, Heroic, MangoHud, GameMode, Discord, Wine, RetroArch, Protontricks |
| **🌐 Web & Communication** | Mozilla Firefox, Chromium, qBittorrent, Telegram Desktop, Signal, Element Matrix, FileZilla |
| **🛠️ System Utilities** | Timeshift, GParted, KDE Partition Manager, btop, htop, Flameshot, Baobab, Fastfetch |

---

## 🚀 Download & Installation

### 1. Download the ISO
Download the pre-built bootable ISO directly from our official **[GitHub Releases Page](https://github.com/ard-tube/twilight-os/releases)** (`Twilight OS v0.1 Pre-Alpha`).

> [!TIP]
> **Multi-Part Download:** Because GitHub imposes a 2 GB file limit on release assets, the ~2.5 GB ISO is split into `twilight-os-*.iso.part00` and `part01`. Combine them easily:
> - **macOS / Linux**: `cat twilight-os-*.iso.part* > twilight-os-2026.10.18-x86_64.iso`
> - **Windows (cmd)**: `copy /b twilight-os-*.iso.part00 + twilight-os-*.iso.part01 twilight-os-2026.10.18-x86_64.iso`

### 2. Flash to USB

**Using Ventoy (Recommended):**
Simply copy the `twilight-os-*.iso` file onto your Ventoy USB drive.

**Using `dd` (Linux / macOS):**
```bash
sudo dd bs=4M if=twilight-os-*.iso of=/dev/sdX status=progress oflag=sync
```
*(Replace `/dev/sdX` with your target USB drive identifier).*

### 3. Launch the Installer
Once booted into the Twilight OS live environment:
- Double click **"Install Twilight OS"** on the desktop, or
- Run `twilight-installer` in the terminal for guided installation.

---

## 🖥️ Running in Virtual Machines (Windows & macOS)

You can run Twilight OS inside a virtual machine without touching your physical hard drive partitions:

### 🪟 Windows (Oracle VirtualBox & VMware)
1. **Create VM**: Choose Type: `Linux`, Version: `Arch Linux (64-bit)`.
2. **RAM & CPU**: Allocate at least **4096 MB (4 GB)** RAM and **2 to 4 CPU cores**.
3. **Enable EFI** *(Essential for KDE Plasma 6 Wayland)*: 
   - VirtualBox: `Settings` → `System` → `Motherboard` → Check **"Enable EFI (special OSes only)"**.
4. **Display**: Under `Display`, set **Video Memory** to `128 MB`, enable **3D Acceleration**, and set Graphics Controller to **`VMSVGA`**.
5. **Attach ISO**: Mount `twilight-os-*.iso` in the Storage Optical Drive and start!

### 🍎 macOS (Apple Silicon & Intel Macs)
- **Apple Silicon (M1 / M2 / M3 / M4)**: Download free [UTM](https://mac.getutm.app/). Click **+**, select **Emulate**, choose **Linux**, allocate 4 GB RAM + 4 CPU cores, and attach the ISO.
- **Intel Macs**: Use **VirtualBox** or **VMware Fusion** with EFI enabled and 3D Acceleration as described above.

---

## ⚙️ System Requirements

| Specification | Minimum | Recommended |
| :--- | :--- | :--- |
| **Processor** | 64-bit Dual Core x86_64 CPU | 64-bit Quad Core or better |
| **Memory (RAM)** | 2 GB RAM | 4 GB+ RAM |
| **Storage** | 20 GB free disk space | 50 GB+ SSD |
| **Graphics** | OpenGL 3.3 compatible | NVIDIA, AMD, or Intel GPU with Vulkan support |

---

## 🛠️ Building the ISO

The ISO is built automatically using GitHub Actions runners via [build.yml](.github/workflows/build.yml).

To build locally on any Linux host with Docker:
```bash
# Clone the repository
git clone https://github.com/ard-tube/twilight-os.git
cd twilight-os

# Run archiso build container
docker run --privileged --rm -v $(pwd):/repo -w /repo archlinux:latest bash -c "
  pacman -Syu --noconfirm archiso git
  cp -r /usr/share/archiso/configs/releng profile
  cat overlay/packages.extra >> profile/packages.x86_64
  cp -r overlay/airootfs/. profile/airootfs/
  mkarchiso -v -w /tmp/archiso-work -o out profile
"
```

---

## 👥 Credits & License

- **Founder & Maintainer**: [Arda](https://github.com/ard-tube)
- **Base Distribution**: [Arch Linux](https://archlinux.org) (`archiso` releng profile)
- **Desktop Environment**: [KDE Plasma](https://kde.org)
- **Default Artwork**: 5K Twilight Horizon by [xyproto](https://github.com/xyproto) (Alexander F. Rødseth, Arch Linux Package Maintainer), licensed under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) (Public Domain).
- **License**: GNU General Public License v3.0 ([GPL-3.0](LICENSE))
