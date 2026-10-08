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

export UNIV_USER=""
export UNIV_PASS=""
export ASK_CRED=false
export VPN_ONLY=false
export INTERACTIVE=false

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

show_help() {
  echo "Setup script for Debian-based systems"
  echo "Usage: sudo ./setup.sh [OPTIONS]"
  echo ""
  echo "Options :"
  echo "  -h, --help               Affiche l'aide"
  echo "  -u, --user <login>       Identifiant universitaire/multipass"
  echo "  -p, --password <pass>    Mot de passe universitaire/multipass"
  echo "  -a, --ask                Demande le login et mot de passe interactivement"
  echo "  -i, --interactive        Demande pour chaque étape si on souhaite l'installer [O/n]"
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
      -h|--help)        show_help; exit 0 ;;
      -u|--user)        UNIV_USER="$2"; shift 2 ;;
      -p|--password)    UNIV_PASS="$2"; shift 2 ;;
      -a|--ask)         ASK_CRED=true; shift ;;
      -i|--interactive) INTERACTIVE=true; shift ;;
      --vpn-only)       VPN_ONLY=true; shift ;;
      *)                log_error "Argument inconnu: $1"; echo ""; show_help; exit 1;;
    esac
  done
}

prompt_credentials() {
  if [[ "$ASK_CRED" == true || "$INTERACTIVE" == true ]]; then
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

run_step() {
  local step_name="$1"
  local step_function="$2"

  if ! type "$step_function" &>/dev/null; then
    log_error "Fonction $step_function introuvable. Module manquant ?"
    return 1
  fi

  if [[ "$INTERACTIVE" == true ]]; then
    while true; do
      echo -en "${CYAN}Voulez-vous : ${step_name} ? [O/n]${NC}"
      read -r yn </dev/tty
      case $yn in
        [Nn]* ) log_info "Étape ignorée : ${step_name}"; return 0 ;;
        [Oo]* | [Yy]* | "" ) break ;;
        * ) echo "Veuillez répondre par O (Oui) ou n (non)." ;;
      esac
    done
  fi
  
  $step_function
}

# =============================================================================
# Main
# =============================================================================
main() {
  parse_arguments "$@"
  check_root
  
  print_banner
  prompt_credentials

  if [[ -f ./modules/packages.sh ]]; then source ./modules/packages.sh; fi
  if [[ -f ./modules/eduroam.sh ]];  then source ./modules/eduroam.sh;  fi
  if [[ -f ./modules/certs.sh ]];    then source ./modules/certs.sh;    fi
  if [[ -f ./modules/vpn.sh ]];      then source ./modules/vpn.sh;      fi
  if [[ -f ./modules/sqlplus.sh ]];  then source ./modules/sqlplus.sh;  fi

  if [[ "$VPN_ONLY" == true ]]; then
    log_info "Mode VPN uniquement activé"
    setup_vpn
    log_success "Configuration VPN terminée"
    exit 0
  fi

  log_info "Starting setup..."

  run_step "Mettre à jour et installer les paquets" install_apt
  run_step "Configurer le réseau Eduroam" setup_eduroam
  run_step "Installer les certificats DPI" install_dpi_certificates
  run_step "Configurer le VPN du DPI" setup_vpn
  run_step "Configurer Oracle SQLPlus" setup_oracle
  run_step "Nettoyer le système (autoremove/clean)" clean_system
}

main "$@"
