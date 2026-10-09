APT_APPS=(
  # Desktop & Web
  "thunderbird:Client de messagerie électronique"
  "firefox:Navigateur web (version libre)"
  "chromium:Navigateur web (version libre)"
  # Editors & IDEs
  "vim:Éditeur de code en ligne de commande"
  "geany:IDE léger et rapide"
  "emacs:Éditeur de texte extensible"
  "codium:Éditeur de code (VS Code sans télémétrie MS)"
  # Development
  "build-essential:Compilateur GCC et outils C/C++ de base"
  "gdb:Débogueur pour C/C++"
  "gcc:Compilateur C"
  "valgrind:Analyseur de fuites mémoire"
  "make:Outil d'automatisation de compilation"
  "git:Gestionnaire de versions de code"
  "manpages-dev:Documentation développeur (Man pages C)"
  "manpages-posix-dev:Documentation POSIX (Man pages)"
  # Languages & Parsing
  "python3:Interpréteur Python 3"
  "python3-pip:Gestionnaire de paquets Python"
  "python3-venv:Environnements virtuels Python"
  "default-jdk:Environnement de développement Java"
  # CLI & Monitoring
  "curl:Client HTTP en ligne de commande"
  "htop:Moniteur système interactif"
  "btop:Moniteur système avancé et esthétique"
  "tree:Affichage en arborescence des dossiers"
  # VPN
  "network-manager-l2tp-gnome:Plugin VPN L2TP pour NetworkManager"
)

CUSTOM_APPS=(
  "typst:Alternative moderne, rapide et simple à LaTeX"
  "sqlplus:Client Oracle SQL*Plus"
)

update_system() {
  log_info "Updating package lists and upgrading system..."
  apt-get update -y
  apt-get upgrade -y
  log_success "System is now up to date."
}

add_third_party_repos() {
  log_info "Ajout des depots tiers et PPAs..."
  
  apt-get install -y software-properties-common wget curl gpg apt-transport-https ca-certificates

  add-apt-repository -y ppa:xtradeb/apps
  add-apt-repository -y ppa:mozillateam/ppa

  cat <<EOF > /etc/apt/preferences.d/mozillateamppa
Package: thunderbird*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOF

  # VSCodium
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL "https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg" | gpg --dearmor --yes -o /etc/apt/keyrings/vscodium-archive-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/vscodium-archive-keyring.gpg] https://download.vscodium.com/debs vscodium main" > /etc/apt/sources.list.d/vscodium.list
  
  apt-get update -y >/dev/null 2>&1
  log_success "Depots tiers et PPAs configures."
}

print_recap() {
  echo -e "\n${GREEN}=============================================================================${NC}"
  echo -e "${CYAN}  Voici les outils désormais disponibles :${NC}"
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

install_apt() {
  log_info "Installing standard packages..."
  
  update_system
  add_third_party_repos

  local packages=()
  for item in "${APT_APPS[@]}"; do
    packages+=("${item%%:*}")
  done

  apt-get install -y "${packages[@]}"
  print_recap
}
