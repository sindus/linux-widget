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

## Déplacer un widget sur le bureau

Les widgets se positionnent **par configuration** (Conky n'a pas de glisser-déposer).
Tout se règle dans le fichier `.conf` du widget, dans le bloc `conky.config` :

```lua
alignment = 'top_right',   -- coin / bord d'ancrage
gap_x = 28,                -- décalage horizontal depuis ce coin (px, vers l'intérieur)
gap_y = 48,                -- décalage vertical depuis ce coin (px, vers l'intérieur)
```

Fichiers concernés :

| Widget | Fichier |
|--------|---------|
| Disque | `~/.config/conky/disk-widget.conf` |
| CPU    | `~/.config/conky/cpu-widget.conf` |
| Mémoire| `~/.config/conky/ps-widget.conf` |

**Valeurs possibles pour `alignment`** :
`top_left`, `top_middle`, `top_right`,
`middle_left`, `middle_middle`, `middle_right`,
`bottom_left`, `bottom_middle`, `bottom_right`.

`gap_x` / `gap_y` = distance en pixels depuis le coin choisi, vers l'intérieur de
l'écran. Exemple — coller le widget disque en haut-à-gauche, légèrement décalé :

```lua
alignment = 'top_left',
gap_x = 40,
gap_y = 60,
```

**Appliquer le changement** : Conky lit sa config au démarrage, il faut donc le
relancer. Pour un seul widget :

```bash
pkill -f "conky -c .*disk-widget.conf"
conky -c ~/.config/conky/disk-widget.conf &
```

Pour les trois d'un coup :

```bash
pkill conky
conky -c ~/.config/conky/disk-widget.conf &
conky -c ~/.config/conky/cpu-widget.conf &
conky -c ~/.config/conky/ps-widget.conf &
```

> Astuce : lance un widget **sans le `&`** dans un terminal pour voir les erreurs
> et affiner `gap_x`/`gap_y` rapidement (Ctrl+C pour l'arrêter, ré-édite, relance).
>
> Tu édites ici la config **installée** (`~/.config/conky/…`). Pour figer ta
> disposition dans le dépôt, reporte les mêmes valeurs dans le `src/conky/*.conf`
> du widget concerné.

## Désinstallation

```bash
sudo disk/uninstall.sh
cpu/uninstall.sh
ps/uninstall.sh
sudo apt remove conky-all     # optionnel
```
