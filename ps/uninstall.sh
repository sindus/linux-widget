#!/usr/bin/env bash
# Desinstalle le widget memoire (Conky lui-meme n'est pas retire).
# Usage :  ./uninstall.sh
pkill -f "conky -c .*ps-widget.conf" 2>/dev/null || true
rm -f "$HOME/.config/conky/ps-widget.conf"
rm -f "$HOME/.config/autostart/conky-ps-widget.desktop"
echo "Widget memoire desinstalle."
