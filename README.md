# linux-widget

Collection de widgets **Conky** légers, ancrés sur le bureau (façon fond d'écran),
pour surveiller sa machine Linux d'un coup d'œil. Pensés pour Ubuntu / GNOME en
session **X11**.

| Widget | Dossier | Ce qu'il affiche | Historique | Service / sudo |
|--------|---------|------------------|:----------:|:--------------:|
| **Disque**     | [`disk/`](disk/) | Occupation de `/`, top dossiers, **ce qui a grossi** | ✅ | ✅ (collecteur root + timer systemd) |
| **Processeur** | [`cpu/`](cpu/)   | Charge CPU, moyenne, fréquence, top processus | ❌ | ❌ |
| **Mémoire**    | [`ps/`](ps/)     | RAM, swap, top processus | ❌ | ❌ |

Le widget **disque** embarque un collecteur (scan `du` en `root`, espacé et en
priorité basse) pour bâtir un historique et révéler *quels dossiers grossissent* —
y compris dans `/var/lib` (Docker, snap…), invisibles sans droits root. Les widgets
**cpu** et **mémoire** se contentent des compteurs natifs de Conky : aucun script,
aucun service, pas de `sudo`.

## Prérequis communs

- Linux en **session X11** (Conky a besoin de X11 pour s'ancrer au bureau).
- `conky-all` :
  ```bash
  sudo apt install conky-all
  ```
  (le widget `disk` l'installe automatiquement.)

## Installation rapide (les 3 d'un coup)

```bash
cd ~/Documents/dev/widgets
./install-all.sh              # SANS sudo — il appelle sudo lui-même pour le disque
```

`install-all.sh` installe et lance les 3 widgets (il ne demande le mot de passe
`sudo` que pour le widget disque). 

<details>
<summary>Ou bien, manuellement, widget par widget</summary>

```bash
cd ~/Documents/dev/widgets

sudo disk/install.sh          # widget disque (service + timer)
cpu/install.sh                # widget CPU
ps/install.sh                 # widget mémoire

# lancer tout de suite
conky -c ~/.config/conky/disk-widget.conf &
conky -c ~/.config/conky/cpu-widget.conf &
conky -c ~/.config/conky/ps-widget.conf &
```
</details>

Chaque widget redémarre ensuite automatiquement à la connexion (autostart).
Positions par défaut : `disk` en haut-droit, `cpu` au milieu-droit, `ps` en
bas-droit, pour ne pas se chevaucher. Voir le `README.md` de chaque dossier pour
les réglages (position, transparence, fréquence).

## Désinstallation

```bash
sudo disk/uninstall.sh
cpu/uninstall.sh
ps/uninstall.sh
sudo apt remove conky-all     # optionnel
```
