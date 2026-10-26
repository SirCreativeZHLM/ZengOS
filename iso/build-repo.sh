#!/usr/bin/env bash
# Build all ZengOS packages into $ZENG_OUT/repo as the pacman repository "zengos".
# Run as root in an Arch container. Used by CI and by iso/build.sh.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
build=${ZENG_BUILD:-/var/tmp/zengos-build}
repo=${ZENG_REPO:-${ZENG_OUT:-$root/out}/repo}

pacman -Sy --noconfirm --needed base-devel sudo git cmake ninja qt6-declarative rust
mkdir -p "$repo" "$build/pkgs" "$build/src" "$build/makepkg"
id builder &>/dev/null || useradd -m builder
echo 'builder ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/builder

for pkg in zengos-base zolt-desktop zengos-apps zengos-installer zengav; do
  rm -rf "$build/pkgs/$pkg" && cp -r "$root/packages/$pkg" "$build/pkgs/$pkg"
  chown -R builder "$build" "$repo"
  (cd "$build/pkgs/$pkg" && sudo -u builder env ZENG_ROOT="$root" PKGDEST="$repo" SRCDEST="$build/src" \
     BUILDDIR="$build/makepkg" CARGO_HOME="$build/cargo" makepkg -f --nodeps --noconfirm)
done
rm -f "$repo"/zengos.db* "$repo"/zengos.files*
repo-add "$repo/zengos.db.tar.gz" "$repo"/*.pkg.tar.zst
# GitHub release assets cannot be symlinks; pacman wants plain zengos.db / zengos.files.
for f in zengos.db zengos.files; do rm -f "$repo/$f"; cp "$repo/$f.tar.gz" "$repo/$f"; done
ls -l "$repo"
