# Disk Widget — moniteur d'espace disque pour le bureau

Widget léger qui affiche, **ancré sur le bureau** (façon fond d'écran), l'occupation
du disque `/` en temps réel **avec un historique** permettant de comprendre *quels
dossiers ont grossi* et expliquent la consommation d'espace.

Pensé pour être **ultra léger** : l'affichage (Conky) ne fait que lire de petits
fichiers déjà calculés ; le scan disque tourne en tâche de fond, espacé et en
priorité basse.

```
DISQUE  /
Occupation                    20 %
[██████░░░░░░░░░░░░░░░░░░░░░░░]
Utilisé 36Go            Libre 146Go
Total                        192Go
Historique (occupation %)
▁▂▃▄▅▆▇  (18%-23%)
24h : 33Go -> 36Go  (Δ +3,2Go)
Top consommateurs
   19Go  /home/sikander
  8,5Go  /var/lib/snapd
A grossi (24 h)
+2,1Go  /var/lib/docker
+340Mo  /home/sikander/.cache
MAJ scan : 13:02 (25/06)
```

## Prérequis

- **Linux + session X11** (testé sur Ubuntu 24.04 / GNOME). Ne fonctionne pas en
  Wayland (Conky a besoin de X11 pour s'ancrer au bureau).
- `conky-all` (installé automatiquement par `install.sh`).
- `sudo` pour l'installation (service système + paquet).

## Installation

```bash
cd ~/Documents/dev/widgets/disk
sudo ./install.sh
```

Puis lance le widget tout de suite (sans sudo) :

```bash
conky -c ~/.config/conky/disk-widget.conf &
```

Il redémarrera automatiquement à chaque connexion (entrée autostart).

> Les lignes **« 24h »** et **« A grossi »** affichent « en cours… » au début :
> il faut ~24 h d'historique pour qu'elles deviennent parlantes. La sparkline se
> remplit dès les premières mesures.

## Désinstallation

```bash
cd ~/Documents/dev/widgets/disk
sudo ./uninstall.sh        # retire widget, service, données (pas Conky)
sudo apt remove conky-all  # optionnel : retirer Conky aussi
```

## Comment ça marche

Deux composants découplés :

1. **Collecteur** (`src/disk-widget-collect.sh`) — exécuté par un **timer systemd**
   (`disk-widget.timer`, toutes les 15 min) en **root** (pour voir aussi `/var/lib`,
   Docker, snap… invisibles sans droits). Tourne en `nice 19` + `ionice idle`.
   Il écrit de petits fichiers dans `/var/lib/disk-widget/` :

   | Fichier        | Contenu                                             |
   |----------------|-----------------------------------------------------|
   | `usage.log`    | historique brut `epoch used total pct` (7 jours)    |
   | `spark.txt`    | sparkline unicode de l'occupation %                 |
   | `delta.txt`    | évolution sur ~24 h (`33Go -> 36Go (Δ +3,2Go)`)     |
   | `top.txt`      | top 8 des dossiers les plus volumineux              |
   | `growth.txt`   | dossiers ayant grossi de >100 Mo sur ~24 h          |
   | `scantime.txt` | horodatage du dernier scan                          |
   | `snaps/*.tsv`  | instantanés `du` horodatés (pour les diffs, 7 jours)|

2. **Affichage** (`src/conky/disk-widget.conf`) — Conky, ancré sur le bureau.
   Lit `df` nativement (occupation live) et `cat` les fichiers ci-dessus toutes
   les 2 min. Empreinte mémoire ~5–15 Mo.

```
timer systemd ──(15 min)──> collecteur (root, du) ──> /var/lib/disk-widget/*.txt
                                                              │
                                              Conky (lecture) ┘ ──> bureau
```

## Configuration

**Apparence / position** — `~/.config/conky/disk-widget.conf` :

- `alignment`, `gap_x`, `gap_y` : coin et marges (défaut : haut-droit).
- `own_window_argb_value` : transparence (0 = transparent, 255 = opaque).
- `update_interval` : fréquence de rafraîchissement de l'affichage (s).
- `own_window_type` : si le widget ne s'affiche pas ou passe **au-dessus** des
  fenêtres, essayer `'desktop'` ou `'override'` au lieu de `'normal'`.

**Fréquence de collecte** — `/etc/systemd/system/disk-widget.timer`, ligne
`OnUnitActiveSec` :

```bash
sudoedit /etc/systemd/system/disk-widget.timer
sudo systemctl daemon-reload && sudo systemctl restart disk-widget.timer
```

**Seuil de détection « a grossi »** — variable `104857600` (100 Mo) dans
`src/disk-widget-collect.sh`, à réinstaller ensuite (`sudo ./install.sh`).

## Dépannage

| Symptôme                          | Piste                                                        |
|-----------------------------------|-------------------------------------------------------------|
| Widget invisible / au-dessus      | changer `own_window_type` (voir Configuration)              |
| Rien dans Top/Historique          | `systemctl status disk-widget.timer` ; lancer le collecteur à la main : `sudo /usr/local/bin/disk-widget-collect.sh` |
| « en cours… » persistant          | normal tant que <24 h d'historique                          |
| Caractères ▁▂▃ en carrés          | police manquante : `sudo apt install fonts-dejavu`          |

## Arborescence

```
disk/
├── install.sh                         # installation (sudo, relocalisable)
├── uninstall.sh                       # désinstallation (sudo)
├── README.md
└── src/
    ├── disk-widget-collect.sh         # collecteur -> /usr/local/bin/
    ├── disk-widget.service            # -> /etc/systemd/system/
    ├── disk-widget.timer              # -> /etc/systemd/system/
    ├── conky/disk-widget.conf         # -> ~/.config/conky/
    └── autostart/
        └── conky-disk-widget.desktop  # -> ~/.config/autostart/
```
