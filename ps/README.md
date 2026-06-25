# Memory Widget — moniteur mémoire pour le bureau

Widget léger qui affiche, **ancré sur le bureau**, la consommation **mémoire** en
temps réel : RAM, swap, et les processus les plus gourmands.

Pas d'historique (contrairement au widget `disk`) : Conky lit la mémoire
**nativement**, donc **aucun script, aucun service système, aucun `sudo`**.

> Le dossier s'appelle `ps` (process / mémoire) comme demandé.

```
MEMOIRE
RAM                           38 %
[██████████░░░░░░░░░░░░░░░░░░]
Utilisee 5.0Gio         Total 13Gio
Swap                           2 %
[█░░░░░░░░░░░░░░░░░░░░░░░░░░░]
Utilisee 80Mio          Total 4.0Gio
Top processus (RAM)
firefox                     1.20Gio
code                         640Mio
gnome-shell                  320Mio
...
```

## Prérequis

- Linux + **session X11** (Ubuntu 24.04 / GNOME testé).
- `conky-all` : `sudo apt install conky-all` (déjà installé si tu as posé le widget `disk`).

## Installation

```bash
cd ~/Documents/dev/widgets/ps
./install.sh        # pas besoin de sudo
conky -c ~/.config/conky/ps-widget.conf &
```

Démarrage automatique à chaque session (autostart).

## Désinstallation

```bash
cd ~/Documents/dev/widgets/ps
./uninstall.sh
```

## Configuration

Tout est dans `~/.config/conky/ps-widget.conf` :

- `alignment`, `gap_x`, `gap_y` : position (défaut : bas-droit, pour ne pas
  chevaucher `disk` et `cpu`).
- `own_window_argb_value` : transparence (0–255).
- `update_interval` : fréquence de rafraîchissement (défaut 3 s).
- `own_window_type` : si invisible / au-dessus des fenêtres, essayer `'desktop'` ou `'override'`.

## Arborescence

```
ps/
├── install.sh
├── uninstall.sh
├── README.md
└── src/
    ├── conky/ps-widget.conf           → ~/.config/conky/
    └── autostart/
        └── conky-ps-widget.desktop    → ~/.config/autostart/
```
