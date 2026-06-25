#!/usr/bin/env bash
# Desinstalle le widget disque (Conky lui-meme n'est PAS retire).
# Usage :  sudo ./uninstall.sh
set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "A lancer avec sudo :  sudo $0"
  exit 1
fi

TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

echo "==> Arret du widget Conky"
sudo -u "$TARGET_USER" pkill -f "conky -c .*disk-widget.conf" 2>/dev/null || true

echo "==> Desactivation du timer systemd"
systemctl disable --now disk-widget.timer 2>/dev/null || true
rm -f /etc/systemd/system/disk-widget.service /etc/systemd/system/disk-widget.timer
systemctl daemon-reload

echo "==> Suppression des fichiers"
rm -f /usr/local/bin/disk-widget-collect.sh
rm -rf /var/lib/disk-widget
rm -f "$TARGET_HOME/.config/conky/disk-widget.conf"
rm -f "$TARGET_HOME/.config/autostart/conky-disk-widget.desktop"

echo "==> Termine. Pour retirer Conky aussi :  sudo apt remove conky-all"
