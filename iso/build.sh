#!/usr/bin/env bash
# Build a ZengOS live ISO. Run as root on x86_64 Arch Linux (or in an archlinux container):
#   iso/build.sh normal|mini
# CI runs exactly this; see .github/workflows/build-iso.yml.
set -euo pipefail

edition=${1:?usage: build.sh normal|mini}
[[ $edition == normal || $edition == mini ]] || { echo "edition must be normal or mini" >&2; exit 2; }
[[ $EUID -eq 0 && $(uname -m) == x86_64 ]] || { echo "run as root on x86_64 Arch Linux" >&2; exit 1; }

root=$(cd "$(dirname "$0")/.." && pwd)
build=${ZENG_BUILD:-/var/tmp/zengos-build}
repo=$build/repo
profile=$build/profile-$edition
work=$build/work-$edition
out=${ZENG_OUT:-$root/out}

pacman -Sy --noconfirm --needed archiso base-devel git cmake ninja qt6-declarative python
mkdir -p "$repo" "$out"

# 1. Build the ZengOS packages into a local repository (makepkg refuses to run as root).
id builder &>/dev/null || useradd -m builder
chown -R builder "$build"
mkdir -p "$build/pkgs" "$build/src" "$build/makepkg"
for pkg in zengos-base zolt-desktop zengos-apps zengos-installer; do
  rm -rf "$build/pkgs/$pkg" && cp -r "$root/packages/$pkg" "$build/pkgs/$pkg"
  chown -R builder "$build/pkgs/$pkg" "$build/src" "$build/makepkg" "$repo"
  (cd "$build/pkgs/$pkg" && sudo -u builder env ZENG_ROOT="$root" PKGDEST="$repo" SRCDEST="$build/src" \
     BUILDDIR="$build/makepkg" makepkg -f --nodeps --noconfirm)
done
repo-add "$repo/zengos-local.db.tar.gz" "$repo"/*.pkg.tar.zst

# 2. Profile: Arch's releng base, our package list, our live overlay.
rm -rf "$profile" "$work"
cp -r /usr/share/archiso/configs/releng "$profile"
{ cat "$root/iso/packages/live.txt" "$root/iso/packages/$edition.txt"; } | sed '/^$/d' | sort -u > "$profile/packages.x86_64"
cp -r "$root/iso/profile/airootfs/." "$profile/airootfs/"
chmod 600 "$profile/airootfs/root/.zlogin" 2>/dev/null || true

name=zengos; label=ZENGOS
[[ $edition == mini ]] && { name=zengos-mini; label=ZENGOSMINI; }
sed -i "s|^iso_name=.*|iso_name=\"$name\"|; s|^iso_label=.*|iso_label=\"$label\"|; s|^iso_publisher=.*|iso_publisher=\"ZengOS <https://zengbot.com/os>\"|; s|^iso_application=.*|iso_application=\"ZengOS Live and Installer\"|" "$profile/profiledef.sh"
sed -i "s|^file_permissions=(|file_permissions=(\n  [\"/root/.zlogin\"]=\"0:0:600\"|" "$profile/profiledef.sh"

cat >> "$profile/pacman.conf" <<EOF

[zengos-local]
SigLevel = Optional TrustAll
Server = file://$repo
EOF

# 3. Image.
mkarchiso -v -w "$work" -o "$out" "$profile"
(cd "$out" && for f in $name-*.iso; do sha256sum "$f" > "$f.sha256"; done)
echo "built: $(ls "$out"/$name-*.iso)"
