#!/usr/bin/env bash
# weber-turbo · BOSS-LEVEL: Kevin schlägt zurück (freiwillig, erst nach allen 8 Reparaturen)
# Harmlos wie turbo.sh. Notfall: sudo bash notfall.sh
ROT=$'\e[1;31m'; GRUEN=$'\e[1;32m'; GELB=$'\e[1;33m'; AUS=$'\e[0m'
STATE=/var/lib/kevinwurm
DIR="$(cd "$(dirname "$0")" && pwd)"
if [ "$(id -u)" -ne 0 ]; then echo "Der Boss braucht sudo: sudo bash boss.sh"; exit 1; fi
if [ ! -f "$STATE/start" ]; then echo "Zuerst kommt turbo.sh. Der Boss wartet."; exit 1; fi
if [ -f "$STATE/boss" ]; then echo "Der Boss ist schon da. Prüfen: bash diagnose.sh"; exit 1; fi
if ! bash "$DIR/diagnose.sh" --still; then echo "${GELB}Noch nicht alle 8 Schäden repariert. Erst dann darfst du zum Boss.${AUS} Prüfen: bash diagnose.sh"; exit 1; fi
H="$(cat "$STATE/home")"; U="$(cat "$STATE/user")"; G="$(id -gn "$U")"
date +%s > "$STATE/boss"

# B1: ls wird zum Zug (und sl kommt zurück)
DEBIAN_FRONTEND=noninteractive apt-get install -y sl >/dev/null 2>&1
echo "alias ls='sl' # KEVINBOSS" >> "$H/.bashrc"
# B2: Datei mit Leerzeichen im Namen
echo "Kevin ist der Beste. Lösch mich, wenn du kannst." > "$H/Kevin ist der Beste.txt"; chown "$U:$G" "$H/Kevin ist der Beste.txt"
# B3: versteckter Ordner von root im Home-Verzeichnis
mkdir -p "$H/.kevin_geheim"; echo "Kevin war auch hier." > "$H/.kevin_geheim/notiz.txt"
fallocate -l 20M "$H/.kevin_geheim/.noch_mehr_muell.bin" 2>/dev/null || dd if=/dev/zero of="$H/.kevin_geheim/.noch_mehr_muell.bin" bs=1M count=20 status=none
chown -R root:root "$H/.kevin_geheim"; chmod 700 "$H/.kevin_geheim"

clear
echo "${ROT}"
cat <<'B'
   _  _______ _   _ _____ _   _   ____   ____ _   _ _        _    _____ ____ _____
  | |/ / ____| | | |_   _| \ | | / ___| / ___| | | | |      / \  |  ___/ ___|_   _|
  | ' /|  _| | | | | | | |  \| | \___ \| |   | |_| | |     / _ \ | |_  \___ \ | |
  | . \| |___| |_| | | | | |\  |  ___) | |___|  _  | |___ / ___ \|  _|  ___) || |
  |_|\_\_____|\___/  |_| |_| \_| |____/ \____|_| |_|_____/_/   \_\_|   |____/ |_|
                                                    ... ZURÜCK!
B
echo "${AUS}"
echo "  Du dachtest, du bist mich los? Ich habe 3 neue Fallen versteckt."
echo "  Und eine alte Sache ist wieder da. Viel Spaß mit ls ..."
echo
echo "  Öffne ein ${GELB}neues Terminal${AUS}. Prüfen wie immer: ${GRUEN}bash diagnose.sh${AUS}"
echo
