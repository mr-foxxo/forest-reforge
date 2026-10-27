#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
for item in vkvm.jnlp avctDRAC5Viewer.jar avctKVMIOLinux.jar; do
  [[ -s /runtime/$item ]] || { printf 'Missing private runtime file: %s\n' "$item" >&2; exit 1; }
done
[[ -s /run/secrets/vnc_password ]] || { printf 'A private VNC password file is required.\n' >&2; exit 1; }
mkdir -p /tmp/native
native=$(unzip -Z1 /runtime/avctKVMIOLinux.jar | grep -E '(^|/)libavctKVMIO.so$')
[[ -n $native && $native != *$'\n'* ]] || { printf 'Expected exactly one KVM JNI library.\n' >&2; exit 1; }
unzip -p /runtime/avctKVMIOLinux.jar "$native" > /tmp/native/libavctKVMIO.so
file /tmp/native/libavctKVMIO.so | grep -q 'ELF 32-bit.*Intel 80386' || { printf 'JNI is not i386.\n' >&2; exit 1; }
pids=()
cleanup() { for pid in "${pids[@]}"; do kill "$pid" 2>/dev/null || true; done; }
trap cleanup EXIT
trap 'exit 143' TERM
trap 'exit 130' INT
Xvfb :99 -screen 0 1280x1024x24 -nolisten tcp > /tmp/xvfb.log 2>&1 & pids+=("$!")
for ((attempt=0; attempt<50; attempt++)); do
  [[ ! -S /tmp/.X11-unix/X99 ]] || break
  sleep 0.1
done
[[ -S /tmp/.X11-unix/X99 ]] || { printf 'Virtual display failed.\n' >&2; exit 1; }
fluxbox > /tmp/fluxbox.log 2>&1 & pids+=("$!")
x11vnc -display :99 -forever -shared -rfbport 5900 \
  -passwdfile /run/secrets/vnc_password -o /tmp/x11vnc.log & pids+=("$!")
java -Duser.home=/state -Djava.library.path=/tmp/native \
  -cp '/opt/viewer:/runtime/avctDRAC5Viewer.jar:/runtime/avctKVMIOLinux.jar' \
  JnlpLauncher /runtime/vkvm.jnlp & pids+=("$!")
wait "${pids[${#pids[@]}-1]}"

