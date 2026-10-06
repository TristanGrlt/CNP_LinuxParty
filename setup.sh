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

clean_system() {
  log_info "Cleaning up unused packages..."
  apt-get autoremove -y
  apt-get clean
  log_success "Cleaning complete."
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
  ./modules/eduroam.sh
  ./modules/vpn.sh
  ./modules/sqlplus.sh
  clean_system

  log_success "Done!"
  # print_recap
}

main "$@"
