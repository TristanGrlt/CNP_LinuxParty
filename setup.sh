#!/usr/bin/env bash

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# =============================================================================
# Variables & Couleurs
# =============================================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' 

UNIV_USER=""
UNIV_PASS=""
ASK_CRED=false
VPN_ONLY=false

# =============================================================================
# Utilis 
# =============================================================================
log_info()    { echo -e "${BLUE}[INFO]   ${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]  ${NC} $1"; }

export -f log_info log_success log_error

print_banner() {
  echo -e "${CYAN}"
  cat <<"EOF"
   ____     __  __  ____            __                                         
  /\  _`\  /\ \/\ \/\  _`\         /\ \       __                               
  \ \ \/\_\\ \ `\\ \ \ \L\ \       \ \ \     /\_\    ___   __  __  __  _       
   \ \ \/_/_\ \ , ` \ \ ,__/        \ \ \  __\/\ \ /' _ `\/\ \/\ \/\ \/'\      
    \ \ \L\ \\ \ \`\ \ \ \/          \ \ \L\ \\ \ \/\ \/\ \ \ \_\ \/>  </      
     \ \____/ \ \_\ \_\ \_\           \ \____/ \ \_\ \_\ \_\ \____//\_/\_\     
      \/___/   \/_/\/_/\/_/            \/___/   \/_/\/_/\/_/\/___/ \//\/_/     
                                                                               
                                                                               
   ____                 __                  ___       __      ___      ____    
  /\  _`\              /\ \__             /'___`\   /'__`\  /'___`\   /'___\   
  \ \ \L\ \ __     _ __\ \ ,_\  __  __   /\_\ /\ \ /\ \/\ \/\_\ /\ \ /\ \__/   
   \ \ ,__/'__`\  /\`'__\ \ \/ /\ \/\ \  \/_/// /__\ \ \ \ \/_/// /__\ \  _``\ 
    \ \ \/\ \L\.\_\ \ \/ \ \ \_\ \ \_\ \    // /_\ \\ \ \_\ \ // /_\ \\ \ \L\ \
     \ \_\ \__/.\_\\ \_\  \ \__\\/`____ \  /\______/ \ \____//\______/ \ \____/
      \/_/\/__/\/_/ \/_/   \/__/ `/___/> \ \/_____/   \/___/ \/_____/   \/___/ 
                                    /\___/                                     
                                    \/__/                                      
EOF
  echo -e "${NC}"
  echo -e "${BLUE}=== Script de Post-Installation Étudiant ===${NC}\n"
}

print_recap() {
  echo -e "\n${GREEN}=============================================================================${NC}"
  echo -e "${CYAN}  INSTALLATION TERMINÉE ! Voici les outils désormais disponibles :${NC}"
  echo -e "${GREEN}=============================================================================${NC}"
  
  printf "${BLUE}%-30s${NC} | %s\n" "LOGICIEL" "DESCRIPTION"
  echo -e "-------------------------------|---------------------------------------------"
  
  for item in "${APT_APPS[@]}" "${CUSTOM_APPS[@]}"; do
    local pkg="${item%%:*}"
    local desc="${item#*:}"
    printf "${GREEN}%-30s${NC} | %s\n" "$pkg" "$desc"
  done
  
  echo -e "${GREEN}=============================================================================${NC}"
}

show_help() {
  echo "Setup script for Debian-based systems"
  echo "Usage: sudo ./setup.sh [OPTIONS]"
  echo ""
  echo "Options :"
  echo "  -h, --help               Affiche l'aide"
  echo "  -u, --user <login>       Identifiant universitaire/multipass"
  echo "  -p, --password <pass>    Mot de passe universitaire/multipass"
  echo "  -a, --ask                Demande le login et mot de passe interactivement"
  echo "      --vpn-only           Exécute uniquement la configuration du VPN"
  echo ""
}

check_root() {
  if [ "$EUID" -ne 0 ]; then
    log_error "This script must be executed as root (sudo)."
    exit 1
  fi
}

parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_help
        exit 0
        ;;
      -u|--user)
        UNIV_USER="$2"
        shift 2
        ;;
      -p|--password)
        UNIV_PASS="$2"
        shift 2
        ;;
      -a|--ask)
        ASK_CRED=true
        shift
        ;;
      --vpn-only)
        VPN_ONLY=true
        shift
        ;;
      *)
        log_error "Argument inconnu: $1"
        echo ""
        show_help
        exit 1
        ;;
    esac
  done
}

prompt_credentials() {
  if [[ "$ASK_CRED" == true ]]; then
    echo -e "\n${CYAN}=== Configuration des identifiants ===${NC}"
    read -p "Entrez l'identifiant universitaire/multipass : " UNIV_USER </dev/tty
    read -s -p "Entrez le mot de passe (laisser vide pour demander à la connexion) : " UNIV_PASS </dev/tty
    echo ""
    echo -e "${CYAN}======================================================${NC}\n"
  fi
}

# =============================================================================
# VPN
# =============================================================================
setup_vpn() {
  log_info "Configuration du VPN L2TP du département..."

  apt-get update -y >/dev/null 2>&1
  apt-get install -y network-manager-l2tp-gnome

  mkdir -p /etc/strongswan.d/
  cat <<'EOF' > /etc/strongswan.d/99-dpi-vpn.conf
libstrongswan {
    integrity_test = no
}
EOF

  local nm_file="/etc/NetworkManager/system-connections/VPN_DPT_INFO.nmconnection"
  
  cat <<EOF > "$nm_file"
[connection]
id=VPN DPT INFO
type=vpn
autoconnect=false

[vpn]
service-type=org.freedesktop.NetworkManager.l2tp
gateway=srv-dpi-vpn.univ-rouen.fr
ipsec-enabled=yes
ipsec-ike=aes256-sha1-modp2048!
ipsec-esp=aes128-sha1!
EOF

  if [[ -n "$UNIV_USER" ]]; then
    echo "user=$UNIV_USER" >> "$nm_file"
  fi

  if [[ -n "$UNIV_PASS" ]]; then
    echo "password-flags=0" >> "$nm_file"
  else
    echo "password-flags=1" >> "$nm_file"
  fi

  cat <<EOF >> "$nm_file"

[vpn-secrets]
ipsec-psk=ZqYP3Dmex09aqc0UIJ0I
EOF

  if [[ -n "$UNIV_PASS" ]]; then
    echo "password=$UNIV_PASS" >> "$nm_file"
  fi

  cat <<EOF >> "$nm_file"

[ipv4]
method=auto

[ipv6]
method=auto
EOF

  chmod 600 "$nm_file"
  systemctl restart NetworkManager
  log_success "VPN configuré."
}

# =============================================================================
# Eduroam
# =============================================================================
setup_eduroam() {
  log_info "Configuration du Wi-Fi Eduroam..."

  local nm_file="/etc/NetworkManager/system-connections/eduroam.nmconnection"

  cat <<EOF > "$nm_file"
[connection]
id=eduroam
type=wifi
autoconnect=true

[wifi]
ssid=eduroam

[wifi-security]
key-mgmt=wpa-eap

[802-1x]
eap=peap;
phase2-auth=mschapv2
system-ca-certs=true
EOF

  if [[ -n "$UNIV_USER" ]]; then
    echo "identity=$UNIV_USER" >> "$nm_file"
  fi

  if [[ -n "$UNIV_PASS" ]]; then
    echo "password-flags=0" >> "$nm_file"
    echo "password=$UNIV_PASS" >> "$nm_file"
  else
    echo "password-flags=1" >> "$nm_file"
  fi

  chmod 600 "$nm_file"
  systemctl restart NetworkManager
  log_success "Profil Eduroam configuré."
}

# =============================================================================
# Certificats
# =============================================================================
install_dpi_certificates() {
  log_info "Installation des certificats racines du département (DPI)..."

  cat <<'EOF' > /usr/local/share/ca-certificates/DPI-RootCA-V2.crt
-----BEGIN CERTIFICATE-----
MIIGDjCCA/agAwIBAgIURdTAPR641aRSLtfVcBjeFS4NBzIwDQYJKoZIhvcNAQEL
BQAwgZ0xCzAJBgNVBAYTAkZSMRIwEAYDVQQIDAlOb3JtYW5kaWUxITAfBgNVBAcM
GFNhaW50IEV0aWVubmUgZHUgUm91dnJheTEcMBoGA1UECgwTVW5pdmVyc2l0ZSBk
ZSBSb3VlbjEhMB8GA1UECwwYRGVwYXJ0ZW1lbnQgSW5mb3JtYXRpcXVlMRYwFAYD
VQQDDA1EUEktUm9vdENBLVYyMCAXDTI1MDgwNDA5MzkyNVoYDzIwNTUwODA0MDkz
OTI0WjCBnTELMAkGA1UEBhMCRlIxEjAQBgNVBAgMCU5vcm1hbmRpZTEhMB8GA1UE
BwwYU2FpbnQgRXRpZW5uZSBkdSBSb3V2cmF5MRwwGgYDVQQKDBNVbml2ZXJzaXRl
IGRlIFJvdWVuMSEwHwYDVQQLDBhEZXBhcnRlbWVudCBJbmZvcm1hdGlxdWUxFjAU
BgNVBAMMDURQSS1Sb290Q0EtVjIwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIK
AoICAQDSnMOFfJ1zRZoE7uSM3rYgV3YriFRaMnacf7eYA+SQyPDZ1W84LXwSJ3o1
5yplYL0ANiF/ELgGBMqeN/p0zn1pdUrXwnybftfg/2K/FRjiaA3mw/h5NAupRqMF
vHXNCoCPDAySFhTfTb+rcX96QQYOBqUO5Kd4XYul8yWtWwMPRJMOH8QUH6alslxR
33U67Q8rcBtittMLeQa2v/XbbDCyFpbyysJRu3QhAd/2F2lLKexdxXcLuxGwh2sX
jblERYHHldQnYiuHbhAc5Q+YAwJnBevDSsud8vvTVpLIkt3ozxJjgETVjeUjsCB/
7+zJDQ6FtK/EPVkk7Qkbz1jd2248pHoVQYh3JUf+VlMu61LjKKT/oLT5kRWOWnve
p49IQWZhDz7O7cgSywpG6kp5ggooMgPdluJhaRCMWI7rnUxzB//9VP6I0nHEZPdn
ZJ+EcwHpPLc94UcFAkBaEqJrqboXHSCAcUpmjQ9FaHeXr82y8t1gzdbFx5CeWeek
GC1K4zYV5F6LuxcHDYJ6J8X/Dzs3XRkNylhJotk9IW3jZk8/c3N1clJNjzUcbFxz
GVqLmd7Ucqwd059BMVEX5mmcCYOVapckI6dxIcx/ctbI0HKygoCos7jDPY+t/m/+
JjAoRajDJyP3fdmRfAemEFCFuRYZYmFhxO+kiKxNJ1bYVucrZQIDAQABo0IwQDAP
BgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTkduT1uP+74O47Bt4jsn9NVN4D8TAO
BgNVHQ8BAf8EBAMCAYYwDQYJKoZIhvcNAQELBQADggIBAKxuALSe4A0gy8Wknkx6
B8phRMiyy1HBlL611L4CVAENrgVkE2Vu9CMvg+eOKOVf3qzA6URDGajXKn2vDOxt
qamifPhWRC3iPBKB9/EhsAL9gnJNBlpNqNd7t7BYSBao3dNuWbvsgwKY9LHa1MRo
t1g26RxdDUFwg/xh3DObIsuFikOZT0ZARL4DIAad1U75x+JvSCELHghSJqM9SKtS
GHhe68BgLQYfOnLS1yr88YSgkCUkQecjCxISfMhSqo0dhgzBmcndES4vkTo/wQ/1
VfRCIZxbboyStN5mg4+Cf+Ecd772EV4GfCMYcnITDYKIPu6xoDPDcdrabAJAVnAe
3b79aXAuh18g5vhAvQfBf0E+MvRJg06fTFfKKupMIIVqu2R9hgeeVLUVuXDMQbXj
SMJR38d0fM/XXGnrSnZIeAUtb+zc/6YIC9W0zs8qnk5dEiTWJKAFT9InTohs1sYX
eXoJOW41HBgaPT0n7OdyZNzrskPJ6I+6JtesWfu/Dk2hlSRNJ743SneH2vMhfRil
t8rKWE+O8s+kR8PDcLKBcex76ZHM58m9up1XA1hrDsmfB+M9lHdHINDBHv4sguK3
l9tfIhqGqYPpVrRvsSSwNMx0fiRHeh/pnpqbgZLJzgElwWfEFLl0fN2m/N4pMb49
QjcLeYhRZ58x1KG/1Tqo0qQj
-----END CERTIFICATE-----
EOF

  cat <<'EOF' > /usr/local/share/ca-certificates/DPI-RootCA.crt
-----BEGIN CERTIFICATE-----
MIIKHTCCBgWgAwIBAgIIGeND3NAeFrUwDQYJKoZIhvcNAQENBQAwgZsxFDASBgNV
BAMMC0RQSSBSb290IENBMSEwHwYDVQQLDBhEZXBhcnRlbWVudCBJbmZvcm1hdGlx
dWUxHDAaBgNVBAoME1VuaXZlcnNpdGUgZGUgUm91ZW4xITAfBgNVBAcMGFNhaW50
IEV0aWVubmUgZHUgUm91dnJheTESMBAGA1UECAwJTm9ybWFuZGllMQswCQYDVQQG
EwJGUjAeFw0xODA0MTIxNDUwMTJaFw0zODA0MDcxNDUwMTJaMIGbMRQwEgYDVQQD
DAtEUEkgUm9vdCBDQTEhMB8GA1UECwwYRGVwYXJ0ZW1lbnQgSW5mb3JtYXRpcXVl
MRwwGgYDVQQKDBNVbml2ZXJzaXRlIGRlIFJvdWVuMSEwHwYDVQQHDBhTYWludCBF
dGllbm5lIGR1IFJvdXZyYXkxEjAQBgNVBAgMCU5vcm1hbmRpZTELMAkGA1UEBhMC
RlIwggQiMA0GCSqGSIb3DQEBAQUAA4IEDwAwggQKAoIEAQDOKWgHrHWSfKpxOQ6c
OO5kZK674ZmifH8H49pQctg2ELjeM02qNGpfCOzqLHKT54QYAZdutfWDsduQkXF7
7tpIH7oTJVuSuKidOLZ+nar9fve2ruFzv8K0xHaqyJLcP6CiO6n3lCt8q9EADaOc
XxK4fiVmyxYoUasOQlQc3T/PfnmLArmgfdT2ydasm5lCWukX+RgLG1jmeJ/RW8jT
ge7+jq/5YFXlI/GX92pJQ1o8LypYZWVNb6t269Swe5D5VW9u0ylcxIUvKNDwdH77
KVdjsffxJBsvjfhRFwv8irDQpCUPQ7BvNzgOkazZV2UYWTy4nqkq/74EvHlQt3EM
rcgAyb0W9JXN9Q/K4ytC6zVcHFyv38BbuX49knPYy3VL1CEM6V6KK2+eaAyStQiH
L8NmiR4DZyu3axwoxKuDk5V6q6BFy9H+kgrTfgjacssH7/xIiyWSMUhVVstI4e2u
uKhqv5KD2xdMT2SR4OwvygOQ81RGoLHmc1db2L9fV51Nbupxf6HNfVXxNfEu4jFp
P/26YnbTp2ykJmLsxalImtbxrKOzo7hRN/FPcCxmTTanuaVpkpc58BwV/pzyfzuL
fWDsuOXYQk8fJ5k4klXdzMequhka895hKKVWgaFONOyjLxXaAv4LYvH29WSsgIFb
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
iA==
-----END CERTIFICATE-----
EOF

  update-ca-certificates >/dev/null 2>&1
  log_success "Certificats racines installés avec succès."
}
# =============================================================================
# Oracle
# =============================================================================
setup_oracle() {
  log_info "Configuration de SQLPlus / SQLcl..."
  
  apt-get install -y unzip
  apt-get install -y libaio1 || {
    apt-get install -y libaio1t64
    ln -sf /usr/lib/x86_64-linux-gnu/libaio.so.1t64 /usr/lib/x86_64-linux-gnu/libaio.so.1 || true
  }

  if [ ! -d "/opt/oracle/instantclient_21_15" ]; then
    wget -qO /tmp/instantclient.zip "https://download.oracle.com/otn_software/linux/instantclient/2115000/instantclient-basic-linux.x64-21.15.0.0.0dbru.zip"
    wget -qO /tmp/sqlplus.zip "https://download.oracle.com/otn_software/linux/instantclient/2115000/instantclient-sqlplus-linux.x64-21.15.0.0.0dbru.zip"
    
    mkdir -p /opt/oracle
    unzip -q /tmp/instantclient.zip -d /opt/oracle/
    unzip -q /tmp/sqlplus.zip -d /opt/oracle/
    
    echo "/opt/oracle/instantclient_21_15" > /etc/ld.so.conf.d/oracle-instantclient.conf
    ldconfig
    
    rm -f /tmp/instantclient.zip /tmp/sqlplus.zip
  fi

  rm -f /usr/local/bin/sqlplus
  ln -sf /opt/oracle/instantclient_21_15/sqlplus /usr/local/bin/sqlplus

  mkdir -p /etc/oracle
  
  cat <<'EOF' > /etc/oracle/tnsnames.ora
dbetu =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = inf-oracle.univ-rouen.fr)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SID = dbetu)
    )
  )
EOF

  cat <<'EOF' > /etc/profile.d/oracle.sh
export TNS_ADMIN=/etc/oracle
export TWO_TASK="dbetu"
EOF
  chmod +x /etc/profile.d/oracle.sh

  log_success "Configuration Oracle terminée."
}

# =============================================================================
# Main
# =============================================================================
main() {
  parse_arguments "$@"
  check_root
  
  print_banner
  prompt_credentials

  if [[ "$VPN_ONLY" == true ]]; then
    log_info "Mode VPN uniquement activé."
    setup_vpn
    log_success "Configuration VPN terminée."
    exit 0
  fi

  log_info "Starting setup..."

  ./modules/packages.sh
  setup_eduroam
  setup_vpn
  install_dpi_certificates
  setup_oracle
  clean_system

  print_recap
}

main "$@"
