#!/usr/bin/env bash
# Installe le widget disque : Conky + collecteur + timer systemd.
# Autonome et relocalisable : utilise son propre dossier et l'utilisateur courant.
# Usage :  sudo ./install.sh
set -e

HERE="$(cd "$(dirname "$0")" && pwd)"
SRC="$HERE/src"

if [ "$(id -u)" -ne 0 ]; then
  echo "A lancer avec sudo :  sudo $0"
  exit 1
fi

# Utilisateur proprietaire de la session graphique (pas root)
TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "$USER")}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
[ -n "$TARGET_HOME" ] || { echo "Impossible de determiner la home de $TARGET_USER"; exit 1; }
echo "==> Utilisateur cible : $TARGET_USER ($TARGET_HOME)"

echo "==> 1/5 Conky"
if ! command -v conky >/dev/null 2>&1; then
  apt-get update -qq && apt-get install -y conky-all
else
  echo "    deja installe"
fi

echo "==> 2/5 Collecteur -> /usr/local/bin"
install -m 0755 "$SRC/disk-widget-collect.sh" /usr/local/bin/disk-widget-collect.sh

echo "==> 3/5 systemd (service + timer)"
install -m 0644 "$SRC/disk-widget.service" /etc/systemd/system/disk-widget.service
install -m 0644 "$SRC/disk-widget.timer"   /etc/systemd/system/disk-widget.timer
systemctl daemon-reload
systemctl enable --now disk-widget.timer

echo "==> 4/5 Config Conky + autostart (home de $TARGET_USER)"
install -d -o "$TARGET_USER" -g "$TARGET_USER" \
  "$TARGET_HOME/.config/conky" "$TARGET_HOME/.config/autostart"
# adapte les chemins /home/... a l'utilisateur cible
sed "s#/home/sikander#$TARGET_HOME#g" "$SRC/conky/disk-widget.conf" \
  > "$TARGET_HOME/.config/conky/disk-widget.conf"
sed "s#/home/sikander#$TARGET_HOME#g" "$SRC/autostart/conky-disk-widget.desktop" \
  > "$TARGET_HOME/.config/autostart/conky-disk-widget.desktop"
chown "$TARGET_USER:$TARGET_USER" \
  "$TARGET_HOME/.config/conky/disk-widget.conf" \
  "$TARGET_HOME/.config/autostart/conky-disk-widget.desktop"

echo "==> 5/5 Premiere collecte (quelques secondes)"
/usr/local/bin/disk-widget-collect.sh || true
chmod -R a+rX /var/lib/disk-widget

echo
echo "======================================================================"
echo " Installation OK."
echo
echo " Lance le widget MAINTENANT (en tant que toi, SANS sudo) :"
echo "     conky -c $TARGET_HOME/.config/conky/disk-widget.conf &"
echo
echo " Il se relancera ensuite a chaque connexion (autostart)."
echo "======================================================================"
