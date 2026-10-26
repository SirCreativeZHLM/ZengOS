# Architecture

## Why this shape

- **Arch base.** Rolling release, small base, `pacstrap` and `archiso` are good tools.
- **labwc + Quickshell for the desktop.** labwc is a small wlroots compositor that owns windows, input and rendering. The visible desktop (bar, dock, launcher) is Zolt, written in QML with Quickshell. This is far less code than a compositor from scratch and far lighter than a full desktop environment. It is not Hyprland.
- **Qt Quick installer.** The installer is one full-screen QML app driven by a small C++ object (`Backend`). The UI never runs commands itself.
- **Python backend.** `installer/backend/zeng-install-backend` reads a JSON config on stdin and prints JSON progress lines. It validates everything, requires an explicit `confirm_erase`, and supports `--dry-run`, which is how it is tested without a disk.

## Install flow

1. Welcome → edition (ZengOS / Mini) + add-ons → disk (+ encryption) → account → install.
2. Backend steps: wipe, GPT (512 MB ESP + root), optional LUKS, ext4, `pacstrap`, `genfstab`, locale/hostname/user, `mkinitcpio`, `systemd-boot`.
3. Add-ons (`zengav`, `zengsuite`) are extra packages from a ZengOS repository that does not exist yet.

## Known gaps

- `quickshell` must be available in Arch's repositories at build time; if it is not, add an AUR build step to `iso/build.sh`.
- The login screen is `tuigreet`. A Zolt greeter is planned.
- No Secure Boot, no dual-boot, no manual partitioning, and no installer localisation yet.
- The ZengOS package repository (for `zengav` and `zengsuite`) must be published before add-ons can install.
