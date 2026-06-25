#!/usr/bin/env bash
# Installe le widget processeur (Conky, lecture native — pas de service, pas de sudo).
# Usage :  ./install.sh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/src"

if ! command -v conky >/dev/null 2>&1; then
  echo "Conky n'est pas installe."
  echo "Installe-le d'abord :  sudo apt install conky-all"
  echo "(le widget 'disk' du meme depot l'installe automatiquement)"
  exit 1
fi

mkdir -p "$HOME/.config/conky" "$HOME/.config/autostart"
cp "$SRC/conky/cpu-widget.conf" "$HOME/.config/conky/cpu-widget.conf"
sed "s#/home/sikander#$HOME#g" "$SRC/autostart/conky-cpu-widget.desktop" \
  > "$HOME/.config/autostart/conky-cpu-widget.desktop"

echo "OK. Lance le widget :"
echo "    conky -c $HOME/.config/conky/cpu-widget.conf &"
echo "Il se relancera ensuite a chaque connexion (autostart)."
