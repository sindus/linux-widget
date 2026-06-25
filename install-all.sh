#!/usr/bin/env bash
# Installe ET lance les 3 widgets (disk + cpu + ps).
# A lancer SANS sudo (le script appelle sudo lui-meme pour la partie disque).
# Usage :  ./install-all.sh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"

if [ "$(id -u)" -eq 0 ]; then
  echo "Ne lance PAS ce script avec sudo."
  echo "Lance-le en tant que toi :  ./install-all.sh"
  echo "(il demandera le mot de passe sudo uniquement pour le widget disque)"
  exit 1
fi

echo "==> 1/3 Widget disque (necessite sudo : service + timer systemd)"
sudo "$HERE/disk/install.sh"

echo "==> 2/3 Widget processeur"
"$HERE/cpu/install.sh"

echo "==> 3/3 Widget memoire"
"$HERE/ps/install.sh"

echo "==> Lancement des widgets"
for c in disk cpu ps; do
  pkill -f "conky -c .*${c}-widget.conf" 2>/dev/null || true
done
nohup conky -c "$HOME/.config/conky/disk-widget.conf" >/dev/null 2>&1 &
nohup conky -c "$HOME/.config/conky/cpu-widget.conf"  >/dev/null 2>&1 &
nohup conky -c "$HOME/.config/conky/ps-widget.conf"   >/dev/null 2>&1 &

echo
echo "======================================================================"
echo " Termine. Les 3 widgets sont installes et lances."
echo " Ils redemarreront automatiquement a chaque connexion (autostart)."
echo "======================================================================"
