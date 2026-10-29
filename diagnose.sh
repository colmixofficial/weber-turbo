#!/usr/bin/env bash
# weber-turbo · Diagnose: Welche Schäden von KEVINWURM sind schon repariert?
# Darf ohne sudo laufen. Ändert nichts.
ROT=$'\e[1;31m'; GRUEN=$'\e[1;32m'; GELB=$'\e[1;33m'; AUS=$'\e[0m'
STATE=/var/lib/kevinwurm
if [ ! -f "$STATE/start" ]; then echo "Kein KEVINWURM gefunden. Dein Server ist sauber (oder turbo.sh lief noch nicht)."; exit 0; fi
H="$(cat "$STATE/home")"; U="$(cat "$STATE/user")"
CODE="SNAPSHOT"
pk() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"; }
ok=(); txt=()
# 1 Weber zurück an seinem Platz, Versteck weg
txt+=("Der Ordner Weber ist zurück im Home-Verzeichnis, das leere Versteck ist weg")
[ -d "$H/Weber" ] && [ ! -e "$H/.kevins_versteck" ] && ok+=(1) || ok+=(0)
# 2 Preisliste wiederhergestellt
txt+=("Die Preisliste ist wieder lesbar (Original aus der Sicherung)")
[ -f "$H/Weber/preisliste.txt" ] && [ -f "$H/Weber/.sicherung/preisliste.txt" ] && cmp -s "$H/Weber/preisliste.txt" "$H/Weber/.sicherung/preisliste.txt" && ok+=(1) || ok+=(0)
# 3 Müll-Dateien
txt+=("Die 100 Dateien kevin_001.txt bis kevin_100.txt sind gelöscht")
n=$(ls "$H" 2>/dev/null | grep -c '^kevin_[0-9]*\.txt$'); [ "$n" -eq 0 ] && ok+=(1) || ok+=(0)
# 4 root-Ordner im Home
txt+=("Der Ordner KEVIN_WAR_HIER ist weg")
[ ! -e "$H/KEVIN_WAR_HIER" ] && ok+=(1) || ok+=(0)
# 5 sl
txt+=("Das Programm sl (der Zug) ist entfernt")
if [ -f "$STATE/kein_netz" ] || grep -qx sl "$STATE/schon_da" 2>/dev/null; then ok+=(1); else ! pk sl && ok+=(1) || ok+=(0); fi
# 6 cowsay
txt+=("Das Programm cowsay ist entfernt")
if [ -f "$STATE/kein_netz" ] || grep -qx cowsay "$STATE/schon_da" 2>/dev/null; then ok+=(1); else ! pk cowsay && ok+=(1) || ok+=(0); fi
# 7 .bashrc
txt+=("Kevins Gruß ist aus der Datei .bashrc entfernt")
! grep -q 'KEVINWURM' "$H/.bashrc" 2>/dev/null && ok+=(1) || ok+=(0)
# 8 /srv/kevin
txt+=("Der Ordner /srv/kevin mit dem Speicherfresser ist gelöscht")
[ ! -e /srv/kevin ] && ok+=(1) || ok+=(0)

fertig=0; for i in 0 1 2 3 4 5 6 7; do [ "${ok[$i]}" = 1 ] && fertig=$((fertig+1)); done
if [ "$1" = "--still" ]; then exit $((8-fertig)); fi
echo; echo "  ${GELB}KEVINWURM-Diagnose für $U${AUS}"; echo "  ----------------------------------------------------------------"
wort=""; fertig=0
for i in 0 1 2 3 4 5 6 7; do
  b="${CODE:$i:1}"
  if [ "${ok[$i]}" = 1 ]; then printf "  ${GRUEN}✔ %d  %s${AUS}  %s\n" $((i+1)) "$b" "${txt[$i]}"; wort+="$b"; fertig=$((fertig+1))
  else printf "  ${ROT}✘ %d  _${AUS}  %s\n" $((i+1)) "${txt[$i]}"; wort+="_"; fi
done
echo "  ----------------------------------------------------------------"
start=$(cat "$STATE/start"); jetzt=$(date +%s); rest=$(( 30*60 - (jetzt-start) ))
if [ "$fertig" -eq 8 ]; then
  echo "  ${GRUEN}Alle 8 Schäden repariert! Dein Code für die Flucht: $wort${AUS}"
  echo "  Gib ihn in Academy im Notfall-Handbuch ein."
  echo "  Gebraucht: $(( (jetzt-start)/60 )) min $(( (jetzt-start)%60 )) s"
  if [ ! -f "$STATE/boss" ]; then echo; echo "  ${ROT}Noch Kraft? Kevin wartet auf dich: sudo bash boss.sh${AUS}  (Boss-Level, freiwillig)"; fi
else
  echo "  Repariert: $fertig von 8     Code bis jetzt: ${GELB}$wort${AUS}"
  if [ "$rest" -gt 0 ]; then echo "  Kevin lacht noch $(( rest/60 )) min $(( rest%60 )) s lang."; else echo "  ${ROT}Die 30 Minuten sind um. Kevin lacht. Mach trotzdem weiter!${AUS}"; fi
  echo "  Hilfe: Notfall-Handbuch in Academy."
fi
echo
# ---------- Boss-Level ----------
if [ -f "$STATE/boss" ]; then
  BC="TUX"; bo=(); bt=()
  bt+=("Der Befehl ls macht wieder ls (kein Zug mehr)")
  ! grep -q 'KEVINBOSS' "$H/.bashrc" 2>/dev/null && bo+=(1) || bo+=(0)
  bt+=("Die Datei mit Leerzeichen im Namen ist gelöscht")
  [ ! -e "$H/Kevin ist der Beste.txt" ] && bo+=(1) || bo+=(0)
  bt+=("Kevins versteckter Ordner von root im Home-Verzeichnis ist weg")
  [ ! -e "$H/.kevin_geheim" ] && bo+=(1) || bo+=(0)
  echo "  ${ROT}BOSS-LEVEL: Kevin schlägt zurück${AUS}"; echo "  ----------------------------------------------------------------"
  bw=""; bf=0
  for i in 0 1 2; do b="${BC:$i:1}"
    if [ "${bo[$i]}" = 1 ]; then printf "  ${GRUEN}✔ B%d %s${AUS}  %s\n" $((i+1)) "$b" "${bt[$i]}"; bw+="$b"; bf=$((bf+1))
    else printf "  ${ROT}✘ B%d _${AUS}  %s\n" $((i+1)) "${bt[$i]}"; bw+="_"; fi
  done
  echo "  ----------------------------------------------------------------"
  if [ "$bf" -eq 3 ] && [ "$fertig" -eq 8 ]; then echo "  ${GRUEN}Boss besiegt! Boss-Code: $bw${AUS}  Zeig ihn deinem Lehrer."
  elif [ "$bf" -eq 3 ]; then echo "  Boss-Code: ${GELB}$bw${AUS}, aber oben ist wieder etwas kaputt. Kevin hat nachgelegt."
  else echo "  Boss-Code bis jetzt: ${GELB}$bw${AUS}"; fi
  echo
fi
