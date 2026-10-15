#!/usr/bin/env bash
#
# Fix /run/usbmuxd directory vs. Unix socket issues.
#

set -Eeuo pipefail

SOCKET="/run/usbmuxd"
PID_FILE="/run/usbmuxd.pid"
SERVICE="usbmuxd.service"

# Require root privileges.
if [[ "$EUID" -ne 0 ]]; then
    echo "🔐 Please run this script with sudo:"
    echo "   sudo $0"
    exit 1
fi

echo "🔧 Repairing usbmuxd runtime socket..."

# Stop usbmuxd before modifying runtime files.
echo "🛑 Stopping $SERVICE..."
systemctl stop "$SERVICE" || true

# Remove stale PID file.
if [[ -e "$PID_FILE" ]]; then
    echo "🧹 Removing stale PID file: $PID_FILE"
    rm -f -- "$PID_FILE"
fi

# Remove the incorrect runtime directory or stale socket.
if [[ -d "$SOCKET" && ! -L "$SOCKET" ]]; then
    echo "🧹 Removing incorrect directory: $SOCKET"
    rm -rf -- "$SOCKET"
elif [[ -e "$SOCKET" || -L "$SOCKET" ]]; then
    echo "🧹 Removing existing runtime path: $SOCKET"
    rm -f -- "$SOCKET"
fi

# Clear systemd's failed state.
echo "🔄 Resetting service failure state..."
systemctl reset-failed "$SERVICE" || true

# Start usbmuxd again.
echo "▶️ Starting $SERVICE..."
systemctl start "$SERVICE"

# Sleep
sleep 2

# Verify that the service is running.
if ! systemctl is-active --quiet "$SERVICE"; then
    echo "❌ ERROR: $SERVICE failed to start."
    systemctl status "$SERVICE" --no-pager || true
    journalctl -u "$SERVICE" -n 30 --no-pager || true
    exit 1
fi

# Verify that the runtime path is a Unix socket.
if [[ -S "$SOCKET" ]]; then
    echo "✅ Success! $SOCKET is a Unix socket."
    ls -l "$SOCKET"
else
    echo "❌ ERROR: $SOCKET is not a Unix socket."
    echo "Service status:"
    systemctl status "$SERVICE" --no-pager || true
    echo "Recent logs:"
    journalctl -u "$SERVICE" -n 30 --no-pager || true
    exit 1
fi

echo
echo "📱 usbmuxd repair completed successfully."
echo "💡 Test your connected iOS device with: idevice_id -l"
