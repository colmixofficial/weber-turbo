#!/usr/bin/env bash
# =====================================================================
#  weber-turbo · Macht deinen Ubuntu-Server 300 % schneller!
#
#  Wer das liest, ist schlau. Bonus-Code: SKEPTIKER
#
#  Ehrlich gesagt: Das hier ist eine Lehr-Übung (SYSEX2, LAM).
#  Ein harmloser Fake-Virus. Er löscht keine Daten, er versteckt,
#  verschiebt und nervt nur. Alles lässt sich mit den Befehlen aus
#  Kapitel 4 und 5 reparieren. Notfall: sudo bash notfall.sh
# =====================================================================

ROT=$'\e[1;31m'; GRUEN=$'\e[1;32m'; GELB=$'\e[1;33m'; BLAU=$'\e[1;36m'; AUS=$'\e[0m'
STATE=/var/lib/kevinwurm

# ---------- Sicherheitsprüfungen ----------
if [ "$(id -u)" -ne 0 ]; then
  echo "${GELB}Turbo braucht Administratorrechte. Starte so:${AUS} sudo bash turbo.sh"; exit 1
fi
U="${SUDO_USER:-}"
if [ -z "$U" ] || [ "$U" = "root" ]; then
  echo "Bitte als normaler Benutzer mit sudo starten: sudo bash turbo.sh"; exit 1
fi
H="$(getent passwd "$U" | cut -d: -f6)"
G="$(id -gn "$U")"
if [ -z "$H" ] || [ ! -d "$H" ]; then echo "Home-Verzeichnis von $U nicht gefunden."; exit 1; fi
if ! grep -qi ubuntu /etc/os-release 2>/dev/null; then echo "weber-turbo läuft nur auf Ubuntu."; exit 1; fi
VIRT="$(systemd-detect-virt 2>/dev/null || echo none)"
if [ "$VIRT" = "none" ] && [ "${KEVIN_ERLAUBT_ECHT:-}" != "ja" ]; then
  echo "${GELB}Abbruch: weber-turbo läuft nur in einer virtuellen Maschine (VirtualBox).${AUS}"
  echo "Dein Rechner ist echt. Gut so: Fremde Skripte gehören nie auf einen echten Rechner."; exit 1
fi
if [ -f "$STATE/start" ]; then
  echo "${ROT}KEVINWURM ist schon auf diesem Server.${AUS} Prüfen: bash diagnose.sh   Notfall: sudo bash notfall.sh"; exit 1
fi

# ---------- Show ----------
clear
echo "${BLAU}"
cat <<'LOGO'
  __      __   _                _____         _
  \ \    / /__| |__  ___ _ _  |_   _|  _ _ _| |__  ___
   \ \/\/ / -_) '_ \/ -_) '_|   | || || | '_| '_ \/ _ \
    \_/\_/\___|_.__/\___|_|     |_| \_,_|_| |_.__/\___/
LOGO
echo "${AUS}            Macht deinen Server 300 % schneller!"
echo
bar() { # $1 Text
  printf "  %-34s [" "$1"
  for i in $(seq 1 25); do printf "${GRUEN}#${AUS}"; sleep 0.04; done
  printf "] ${GRUEN}OK${AUS}\n"
}

mkdir -p "$STATE"; chmod 755 "$STATE"
date +%s > "$STATE/start"; echo "$U" > "$STATE/user"; echo "$H" > "$STATE/home"

bar "Turbo-Module laden"

# ---------- Schaden 0: Werkstatt-Daten vorbereiten (falls sie fehlen) ----------
W="$H/Weber"
if [ ! -d "$W" ]; then
  echo "neu" > "$STATE/weber_neu"
  mkdir -p "$W/Kunden" "$W/Rechnungen" "$W/Fotos"
fi
if [ ! -f "$W/preisliste.txt" ]; then
  cat > "$W/preisliste.txt" <<'TXT'
Werkstatt Weber - Preisliste 2026
Motoröl wechseln: 95 Euro
Reifenwechsel: 45 Euro
Bremsen prüfen: 35 Euro
Klimaanlage füllen: 99 Euro
Inspektion klein: 149 Euro
Inspektion komplett: 289 Euro
Autowäsche: 15 Euro
TXT
fi
chown -R "$U:$G" "$W"

bar "Prozessor übertakten"

# ---------- Schaden 2: Preisliste "verschlüsseln" (Original als versteckte Sicherung) ----------
mkdir -p "$W/.sicherung"
cp -p "$W/preisliste.txt" "$W/.sicherung/preisliste.txt"
{ echo "!!! VERSCHLUESSELT VON KEVINWURM !!!"; tr 'A-Za-z' 'N-ZA-Mn-za-m' < "$W/.sicherung/preisliste.txt"; } > "$W/preisliste.txt"
chown -R "$U:$G" "$W/.sicherung" "$W/preisliste.txt"

# ---------- Schaden 1: Weber-Ordner verstecken ----------
V="$H/.kevins_versteck"
mkdir -p "$V"; mv "$W" "$V/Weber"; chown "$U:$G" "$V"

bar "Arbeitsspeicher verdoppeln"

# ---------- Schaden 3: 100 Müll-Dateien ----------
for i in $(seq -w 1 100); do echo "Kevin war hier ($i von 100)" > "$H/kevin_$i.txt"; done
chown "$U:$G" "$H"/kevin_*.txt

# ---------- Schaden 4: Ordner von root im Home-Verzeichnis ----------
K="$H/KEVIN_WAR_HIER"
mkdir -p "$K"
echo "Haha! Dieser Ordner gehört root. Lösch mich doch, wenn du kannst." > "$K/lies_mich.txt"
chown -R root:root "$K"; chmod 755 "$K"; chmod 644 "$K/lies_mich.txt"

bar "Internet beschleunigen"

# ---------- Schaden 5 und 6: sl und cowsay installieren ----------
for p in sl cowsay; do
  if dpkg -s "$p" >/dev/null 2>&1; then echo "$p" >> "$STATE/schon_da"; fi
done
if ! DEBIAN_FRONTEND=noninteractive apt-get install -y sl cowsay >/dev/null 2>&1; then
  apt-get update >/dev/null 2>&1
  DEBIAN_FRONTEND=noninteractive apt-get install -y sl cowsay >/dev/null 2>&1 || echo "kein_netz" > "$STATE/kein_netz"
fi

bar "Festplatte aufräumen"

# ---------- Schaden 7: Gruß in .bashrc ----------
B="$H/.bashrc"
[ -f "$B" ] || { touch "$B"; chown "$U:$G" "$B"; }
echo 'cowsay "Kevin war hier! Dein Server gehört mir." # KEVINWURM' >> "$B"

# ---------- Schaden 8: geheimer Ordner von root in /srv mit Platzfresser ----------
mkdir -p /srv/kevin
cat > /srv/kevin/notausgang.txt <<'TXT'
Du hast den Notausgang gefunden.
Das Passwort für die Flucht ist das Wort für das,
was ihr vor dem Start in VirtualBox gemacht habt (8 Buchstaben).
Lösch diesen Ordner, dann ist der Speicherfresser weg.
TXT
fallocate -l 50M /srv/kevin/speicherfresser.bin 2>/dev/null || dd if=/dev/zero of=/srv/kevin/speicherfresser.bin bs=1M count=50 status=none
chmod 700 /srv/kevin

bar "Turbo aktivieren"
sleep 0.6
clear
echo "${ROT}"
cat <<'WURM'

     ██╗  ██╗███████╗██╗   ██╗██╗███╗   ██╗██╗    ██╗██╗   ██╗██████╗ ███╗   ███╗
     ██║ ██╔╝██╔════╝██║   ██║██║████╗  ██║██║    ██║██║   ██║██╔══██╗████╗ ████║
     █████╔╝ █████╗  ██║   ██║██║██╔██╗ ██║██║ █╗ ██║██║   ██║██████╔╝██╔████╔██║
     ██╔═██╗ ██╔══╝  ╚██╗ ██╔╝██║██║╚██╗██║██║███╗██║██║   ██║██╔══██╗██║╚██╔╝██║
     ██║  ██╗███████╗ ╚████╔╝ ██║██║ ╚████║╚███╔███╔╝╚██████╔╝██║  ██║██║ ╚═╝ ██║
     ╚═╝  ╚═╝╚══════╝  ╚═══╝  ╚═╝╚═╝  ╚═══╝ ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝
WURM
echo "${AUS}"
echo "  ${ROT}Hallo $U. Hier ist Kevin. Danke, dass du mein Skript mit sudo gestartet hast!${AUS}"
echo
echo "  Ich habe auf deinem Server ${ROT}8 Dinge${AUS} kaputt gemacht:"
echo "  Ordner versteckt, Dateien verschlüsselt, Müll verteilt, Programme installiert ..."
echo
echo "  Du hast ${GELB}30 Minuten${AUS}, um alles zu reparieren."
echo "  Prüf deinen Stand jederzeit mit:   ${GRUEN}bash diagnose.sh${AUS}"
echo "  Jede Reparatur bringt dir einen Buchstaben. 8 Buchstaben = der Code für die Flucht."
echo
echo "  Tipp von Kevin: Öffne mal ein neues Terminal. Muuuh."
echo
