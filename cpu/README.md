# CPU Widget — moniteur processeur pour le bureau

Widget léger qui affiche, **ancré sur le bureau**, la consommation **CPU** en temps
réel : charge globale, moyenne, fréquence, uptime et les processus les plus gourmands.

Pas d'historique (contrairement au widget `disk`) : Conky lit le CPU **nativement**,
donc **aucun script, aucun service système, aucun `sudo`** ne sont nécessaires.

```
PROCESSEUR
Charge globale                12 %
[███░░░░░░░░░░░░░░░░░░░░░░░░░]
Moyenne (1m) 0.42        Freq 2.3 GHz
Uptime                     3d 4h
Top processus (CPU)
firefox                       18 %
gnome-shell                    6 %
conky                          1 %
...
```

## Prérequis

- Linux + **session X11** (Ubuntu 24.04 / GNOME testé).
- `conky-all` : `sudo apt install conky-all` (déjà installé si tu as posé le widget `disk`).

## Installation

```bash
cd ~/Documents/dev/widgets/cpu
./install.sh        # pas besoin de sudo
conky -c ~/.config/conky/cpu-widget.conf &
```

Démarrage automatique à chaque session (autostart).

## Désinstallation

```bash
cd ~/Documents/dev/widgets/cpu
./uninstall.sh
```

## Configuration

Tout est dans `~/.config/conky/cpu-widget.conf` :

- `alignment`, `gap_x`, `gap_y` : position (défaut : milieu-droit, pour ne pas
  chevaucher le widget `disk` en haut-droit).
- `own_window_argb_value` : transparence (0–255).
- `update_interval` : fréquence de rafraîchissement (défaut 2 s).
- `own_window_type` : si invisible / au-dessus des fenêtres, essayer `'desktop'` ou `'override'`.

## Arborescence

```
cpu/
├── install.sh
├── uninstall.sh
├── README.md
└── src/
    ├── conky/cpu-widget.conf          → ~/.config/conky/
    └── autostart/
        └── conky-cpu-widget.desktop   → ~/.config/autostart/
```
