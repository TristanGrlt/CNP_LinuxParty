#!/usr/bin/env bash

# =============================================================================
# Setup Script - Ceci n'est pas une Linux Party
# =============================================================================

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# =============================================================================
# Configuration & State Variables
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
export TUI_CHOICES=""

export NEWT_COLORS="
  root=white,black
  window=white,black
  border=cyan,black
  shadow=black,black
  title=cyan,black
  button=black,cyan
  actbutton=white,cyan
  checkbox=cyan,black
  actcheckbox=black,cyan
  entry=cyan,black
  label=white,black
  listbox=white,black
  actlistbox=black,cyan
  sellistbox=white,black
  actsellistbox=black,cyan
  textbox=white,black
  acttextbox=black,cyan
"

# Format: "ID|Function_Name|Description|Default_State|Requires_Credentials(1/0)"
TASKS=(
  "apt|install_apt|Mettre a jour et installer les paquets|ON|0"
  "eduroam|setup_eduroam|Configurer le reseau Eduroam|ON|1"
  "certs|install_dpi_certificates|Installer les certificats DPI|ON|0"
  "vpn|setup_vpn|Configurer le VPN du DPI|ON|1"
  "oracle|setup_oracle|Configurer Oracle SQLPlus|ON|0"
  "timesync|setup_local_rtc|Configurer l'horloge locale (Dual-boot Windows)|ON|0"
  "nosnap|disable_snapd|Desactiver et bloquer Snap|ON|0"
  "clean|clean_system|Nettoyer le systeme|ON|0"
)

# =============================================================================
# Utilities
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
  echo -e "${BLUE}=== Script de Post-Installation Etudiant ===${NC}\n"
}

check_root() {
  if [ "$EUID" -ne 0 ]; then
    log_error "This script must be executed as root (sudo)."
    exit 1
  fi
}

load_modules() {
  local module_dir="./modules"
  local files=("packages.sh" "eduroam.sh" "certs.sh" "vpn.sh" "sqlplus.sh" "time_sync.sh" "nosnap.sh")

  for file in "${files[@]}"; do
    if [[ -f "$module_dir/$file" ]]; then
      source "$module_dir/$file"
    fi
  done
}

ensure_whiptail() {
  if ! command -v whiptail &> /dev/null; then
    log_info "Installation de whiptail pour l'interface TUI..."
    apt-get update -y >/dev/null 2>&1
    apt-get install -y whiptail >/dev/null 2>&1
  fi
}

# =============================================================================
# Core System Functions (Fallbacks for script internals)
# =============================================================================

clean_system() {
  log_info "Nettoyage des paquets orphelins..."
  apt-get autoremove -y >/dev/null 2>&1
  apt-get clean >/dev/null 2>&1
  log_success "Nettoyage termine."
}

# =============================================================================
# CLI & Argument Parsing
# =============================================================================

show_help() {
  echo "Setup script for Debian-based systems"
  echo "Usage: sudo ./setup.sh [OPTIONS]"
  echo ""
  echo "Options :"
  echo "  -h, --help               Affiche l'aide"
  echo "  -u, --user <login>       Identifiant universitaire/multipass"
  echo "  -p, --password <pass>    Mot de passe universitaire/multipass"
  echo "  -a, --ask                Demande le login et mot de passe interactivement"
  echo "  -i, --interactive        Lance l'interface de selection (TUI)"
  echo "      --vpn-only           Execute uniquement la configuration du VPN"
  echo ""
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

# =============================================================================
# TUI & Credential Handling
# =============================================================================

prompt_credentials_cli() {
  echo -e "\n${CYAN}=== Configuration des identifiants ===${NC}"
  read -p "Entrez l'identifiant universitaire/multipass : " UNIV_USER </dev/tty
  read -s -p "Entrez le mot de passe (laisser vide pour demander a la connexion) : " UNIV_PASS </dev/tty
  echo ""
  echo -e "${CYAN}======================================================${NC}\n"
}

prompt_credentials_tui() {
  UNIV_USER=$(whiptail --title "Ceci n'est pas un identifiant" \
    --inputbox "Entrez l'identifiant universitaire (multipass) :" 10 60 3>&1 1>&2 2>&3)
  if [ $? -ne 0 ]; then log_info "Annule par l'utilisateur."; exit 0; fi

  UNIV_PASS=$(whiptail --title "Ceci n'est pas un mot de passe" \
    --passwordbox "Entrez le mot de passe (laisser vide pour demander a la connexion) :" 10 60 3>&1 1>&2 2>&3)
  if [ $? -ne 0 ]; then log_info "Annule par l'utilisateur."; exit 0; fi
}

selection_requires_credentials() {
  local selection="$1"
  
  for task in "${TASKS[@]}"; do
    IFS='|' read -r id func desc state req_cred <<< "$task"
    if [[ " $selection " =~ " $id " ]] && [[ "$req_cred" == "1" ]]; then
      return 0
    fi
  done
  
  return 1
}

run_tui_selection() {
  local whiptail_args=()
  
  for task in "${TASKS[@]}"; do
    IFS='|' read -r id func desc state req_cred <<< "$task"
    whiptail_args+=("$id" "$desc" "$state")
  done

  local raw_choices
  raw_choices=$(whiptail --title "Ceci n'est pas une Linux Party" \
    --backtitle "Post-Installation Etudiant - Configuration systeme" \
    --checklist "\nSelectionnez les composants a configurer.\nUtilisez [Espace] pour cocher, et [Entree] pour valider (Apply)." \
    22 80 12 "${whiptail_args[@]}" 3>&1 1>&2 2>&3)

  if [ $? -ne 0 ]; then
    log_info "Installation annulee par l'utilisateur."
    exit 0
  fi

  TUI_CHOICES=$(echo "$raw_choices" | tr -d '"')
}

# =============================================================================
# Execution Engine
# =============================================================================

execute_selected_tasks() {
  local selection="$1"
  
  echo -e "\n${CYAN}=== Debut de l'installation ===${NC}\n"

  for task in "${TASKS[@]}"; do
    IFS='|' read -r id func desc state req_cred <<< "$task"
    
    if [[ " $selection " =~ " $id " ]]; then
      if type "$func" &>/dev/null; then
        echo -e "${CYAN}-> Execution : ${desc}${NC}"
        $func
      else
        log_error "Fonction $func introuvable. Module non charge."
      fi
    fi
  done
  
  echo -e "\n${CYAN}=== Installation terminee ===${NC}\n"
}

# =============================================================================
# Main Entry Point
# =============================================================================

main() {
  parse_arguments "$@"
  check_root
  
  if [[ "$INTERACTIVE" == true ]]; then
    ensure_whiptail
  else
    print_banner
  fi

  load_modules

  if [[ "$VPN_ONLY" == true ]]; then
    log_info "Mode VPN uniquement active."
    if [[ -z "$UNIV_USER" ]]; then
      if [[ "$INTERACTIVE" == true ]]; then prompt_credentials_tui; else prompt_credentials_cli; fi
    fi
    setup_vpn
    log_success "Configuration VPN terminee."
    exit 0
  fi

  # Interactive Flow
  if [[ "$INTERACTIVE" == true ]]; then
    run_tui_selection
    
    if [[ -z "$TUI_CHOICES" ]]; then
      log_info "Aucune action selectionnee. Sortie."
      exit 0
    fi

    if selection_requires_credentials "$TUI_CHOICES"; then
      prompt_credentials_tui
    fi
    
    execute_selected_tasks "$TUI_CHOICES"
    
  # CLI Flow
  else
    local all_tasks=""
    for task in "${TASKS[@]}"; do
      IFS='|' read -r id func desc state req_cred <<< "$task"
      all_tasks+="$id "
    done
    
    if [[ "$ASK_CRED" == true ]] && selection_requires_credentials "$all_tasks"; then
      prompt_credentials_cli
    fi
    
    execute_selected_tasks "$all_tasks"
  fi
}

main "$@"
