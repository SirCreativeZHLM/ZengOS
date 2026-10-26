# Live session: start the Zolt desktop on tty1; the installer opens on top of it.
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then
  export XDG_RUNTIME_DIR=/run/user/0 XDG_SESSION_TYPE=wayland XDG_CURRENT_DESKTOP=Zolt
  mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"
  exec labwc -C /usr/share/zengos-live/labwc
fi
