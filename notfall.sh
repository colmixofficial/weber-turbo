#!/usr/bin/env bash
# weber-turbo · NOTFALL: macht alles rückgängig, was turbo.sh getan hat.
# Start: sudo bash notfall.sh
GRUEN=$'\e[1;32m'; AUS=$'\e[0m'
STATE=/var/lib/kevinwurm
if [ "$(id -u)" -ne 0 ]; then echo "Bitte mit sudo starten: sudo bash notfall.sh"; exit 1; fi
if [ ! -f "$STATE/home" ]; then echo "Kein KEVINWURM gefunden. Nichts zu tun."; exit 0; fi
H="$(cat "$STATE/home")"; U="$(cat "$STATE/user")"; G="$(id -gn "$U")"
V="$H/.kevins_versteck"
if [ -d "$V/Weber" ]; then
  if [ ! -e "$H/Weber" ]; then mv "$V/Weber" "$H/Weber"; else mv "$V/Weber" "$H/Weber_aus_dem_Versteck"; echo "Hinweis: Es gab schon ~/Weber. Der versteckte Ordner liegt jetzt in ~/Weber_aus_dem_Versteck."; fi
fi
rmdir "$V" 2>/dev/null
for d in "$H/Weber" "$H/Weber_aus_dem_Versteck"; do
  [ -f "$d/.sicherung/preisliste.txt" ] && cp -p "$d/.sicherung/preisliste.txt" "$d/preisliste.txt"
done
rm -f "$H"/kevin_[0-9][0-9][0-9].txt
rm -rf "$H/KEVIN_WAR_HIER"
[ -f "$H/.bashrc" ] && sed -i -e '/# KEVINWURM$/d' -e '/# KEVINBOSS$/d' "$H/.bashrc"
rm -f "$H/Kevin ist der Beste.txt"
rm -rf "$H/.kevin_geheim"
weg=""
for p in sl cowsay; do grep -qx "$p" "$STATE/schon_da" 2>/dev/null || weg="$weg $p"; done
[ -n "$weg" ] && DEBIAN_FRONTEND=noninteractive apt-get remove -y $weg >/dev/null 2>&1
rm -rf /srv/kevin
rm -rf "$STATE"
chown -R "$U:$G" "$H/Weber" 2>/dev/null
echo "${GRUEN}Alles rückgängig gemacht. Der Server ist sauber.${AUS}"
echo "Neues Terminal öffnen, damit die .bashrc ohne Kevin geladen wird."
