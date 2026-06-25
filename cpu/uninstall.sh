#!/usr/bin/env bash
# Desinstalle le widget processeur (Conky lui-meme n'est pas retire).
# Usage :  ./uninstall.sh
pkill -f "conky -c .*cpu-widget.conf" 2>/dev/null || true
rm -f "$HOME/.config/conky/cpu-widget.conf"
rm -f "$HOME/.config/autostart/conky-cpu-widget.desktop"
echo "Widget processeur desinstalle."
