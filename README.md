# ZengOS

**Screw Windows.**

ZengOS is an operating system built on Arch Linux, with a new desktop (Zolt),
an installer designed to feel effortless, and no bloat. It replaces the earlier
ZoltOS and ZengOS experiments.

- **ZengOS** — the Zolt desktop, a terminal, files, Firefox, image and media viewers.
- **ZengOS Mini** — the Zolt desktop and a terminal. Nothing else.
- **Optional add-ons**, chosen in the installer: [ZengAV](https://github.com/SirCreativeZHLM/ZengAV)
  (on-demand antivirus) and ZengSuite.

Website: <https://zengbot.com/os>

## Status

Early preview. What has been verified, and what has not:

| Part | State |
| --- | --- |
| ISOs (`iso/`) | Built for both editions by GitHub Actions in an Arch container. |
| Live boot | ZengOS Mini boots under UEFI in QEMU straight into the installer. |
| Installer UI + backend | Clicked through in the booted Mini ISO, which installed to an encrypted virtual disk. |
| Installed system | Rebooted from that disk: unlock prompt, login, Zolt desktop (bar, clock, dock), ZengAV 0.2.1 installed. |
| ZengOS (Normal) ISO | Built and checksummed. Not yet booted. |
| ZengSuite add-on | Not packaged yet; the installer shows it as coming soon. |
| Real hardware | Untested. |

All boot tests ran in QEMU on emulated x86_64. Do not install on a computer you care about.

## Layout

| Path | What |
| --- | --- |
| `installer/` | Qt Quick installer: `qml/` (UI), `src/` (C++ bridge), `backend/` (Python install steps), `tests/`. |
| `shell/zolt/` | The Zolt shell for Quickshell: top bar, magnifying dock, launcher. |
| `shell/labwc/` | labwc configuration, theme and key bindings. |
| `packages/` | PKGBUILDs: `zengos-base`, `zolt-desktop`, `zengos-apps`, `zengos-installer`. |
| `iso/` | archiso overlay, package lists and `build.sh`. |
| `website/` | The site published at zengbot.com/os. |
| `docs/` | Design notes and screenshots. |

## Build the ISO without a VM

GitHub Actions builds both editions in an Arch Linux container. Run the
**Build ISO** workflow, or push a `v*` tag to attach ISOs to a release.

On an x86_64 Arch machine you can build directly:

```sh
sudo iso/build.sh normal   # or: mini
```

## Develop the installer on any OS

```sh
cd installer
cmake -S . -B build -G Ninja && cmake --build build
./build/zengos-installer --windowed          # demo mode on non-Linux
python3 -m unittest discover -s tests -v     # backend tests
```

On Linux the UI runs `/usr/lib/zengos/zeng-install-backend`; elsewhere it plays
a scripted demo and never touches a disk.

## Design principles

1. Zero bloat. If a package is not on the list in `packages/` and `iso/packages/`, it is not installed.
2. No telemetry, no accounts, no background services you did not start.
3. Honest status. A feature is not "done" until it has run on real hardware.

## Licence

MIT. ZengOS is independent and is not affiliated with Arch Linux, Apple or Microsoft.
