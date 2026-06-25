#!/usr/bin/env bash
# disk-widget-collect.sh — collecte légère pour le widget Conky (tourne en service root).
# Produit de petits fichiers dans /var/lib/disk-widget que Conky se contente de lire.
set -u
umask 022
OUT=/var/lib/disk-widget
SNAP="$OUT/snaps"
mkdir -p "$SNAP"
NOW=$(date +%s)

# Rester discret : priorité CPU basse + E/S en classe "idle"
renice -n 19 -p $$ >/dev/null 2>&1
ionice -c3 -p $$   >/dev/null 2>&1

# --- 1) Occupation globale (df, en Ko) : "epoch used total pct" ---
df -P / | awk -v t="$NOW" 'NR==2{gsub(/%/,"",$5); print t, $3, $2, $5}' >> "$OUT/usage.log"
awk -v c=$((NOW-7*86400)) '$1>=c' "$OUT/usage.log" > "$OUT/usage.log.tmp" && mv "$OUT/usage.log.tmp" "$OUT/usage.log"

# --- 2) Répartition par dossier (octets) : snapshot horodaté ---
du -x -B1 --max-depth=2 / 2>/dev/null | sort -rn > "$SNAP/$NOW.tsv"
# purge des snapshots de plus de 7 jours
for f in "$SNAP"/*.tsv; do
  [ -e "$f" ] || continue
  ts=$(basename "$f" .tsv)
  case "$ts" in *[!0-9]*) continue ;; esac
  [ "$ts" -lt $((NOW-7*86400)) ] && rm -f "$f"
done

# --- 3) Top consommateurs (lisible) ---
awk -F'\t' '$2!="/"' "$SNAP/$NOW.tsv" | head -8 | while IFS=$'\t' read -r b p; do
  printf '%8s  %s\n' "$(numfmt --to=iec --suffix=o "$b" 2>/dev/null)" "$p"
done > "$OUT/top.txt"

# --- 4) Ce qui a grossi sur ~24 h ---
ref=""
for f in $(ls "$SNAP"/*.tsv 2>/dev/null | sort); do
  ts=$(basename "$f" .tsv)
  [ "$ts" -le $((NOW-86400)) ] && ref="$f"
done
[ -z "$ref" ] && ref=$(ls "$SNAP"/*.tsv 2>/dev/null | sort | head -1)
if [ -n "$ref" ] && [ "$ref" != "$SNAP/$NOW.tsv" ]; then
  awk -F'\t' 'NR==FNR{o[$2]=$1; next}{d=$1-(o[$2]+0); if(d>104857600) printf "%d\t%s\n", d, $2}' \
      "$ref" "$SNAP/$NOW.tsv" | sort -rn | head -6 | while IFS=$'\t' read -r d p; do
        printf '+%-8s %s\n' "$(numfmt --to=iec --suffix=o "$d" 2>/dev/null)" "$p"
      done > "$OUT/growth.txt"
  [ -s "$OUT/growth.txt" ] || echo "rien de notable (>100 Mo)" > "$OUT/growth.txt"
else
  echo "historique en cours de constitution..." > "$OUT/growth.txt"
fi

# --- 5) Delta global vs ~24 h ---
cur=$(tail -1 "$OUT/usage.log" | awk '{print $2+0}')
past=$(awk -v t=$((NOW-86400)) '$1<=t{v=$2} END{print v+0}' "$OUT/usage.log")
if [ "${past:-0}" -gt 0 ]; then
  d=$((cur-past)); s="+"; [ "$d" -lt 0 ] && { s="-"; d=$((-d)); }
  printf '24h : %s -> %s  (D %s%s)\n' \
    "$(numfmt --to=iec --suffix=o $((past*1024)) 2>/dev/null)" \
    "$(numfmt --to=iec --suffix=o $((cur*1024)) 2>/dev/null)" \
    "$s" "$(numfmt --to=iec --suffix=o $((d*1024)) 2>/dev/null)" > "$OUT/delta.txt"
else
  echo "evolution 24h : en cours..." > "$OUT/delta.txt"
fi

# --- 6) Sparkline de l'occupation (%) ---
awk '{print $4}' "$OUT/usage.log" | tail -60 | awk '
  {a[NR]=$1+0; n=NR; if(NR==1||a[NR]>mx)mx=a[NR]; if(NR==1||a[NR]<mn)mn=a[NR]}
  END{
    B[1]="\342\226\201";B[2]="\342\226\202";B[3]="\342\226\203";B[4]="\342\226\204";
    B[5]="\342\226\205";B[6]="\342\226\206";B[7]="\342\226\207";B[8]="\342\226\210";
    if(n==0){print "-"; exit}
    s="";
    for(i=1;i<=n;i++){
      if(mx==mn) l=4; else l=int((a[i]-mn)/(mx-mn)*7)+1;
      if(l<1)l=1; if(l>8)l=8; s=s B[l];
    }
    printf "%s  (%d%%-%d%%)\n", s, mn, mx;
  }' > "$OUT/spark.txt"

# --- 7) Heure du dernier scan ---
date '+%H:%M (%d/%m)' > "$OUT/scantime.txt"

exit 0
