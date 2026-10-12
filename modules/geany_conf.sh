run_geany_config_script() {
  local geany_config="./modules/config/config.sh"

  apt-get update -y >/dev/null 2>&1
  apt upgrade -y
  apt-get install -y uncrustify geany valgrind

>>>>>>> b0919e2 (fix: use the right geany)
  if [[ -x "$geany_config" ]]; then
    log_info "Lancement de $geany_config..."
    "$geany_config"
    log_success "Script execute avec succes."
  elif [[ -f "$geany_config" ]]; then
    log_info "Execution via bash de $geany_config..."
    bash "$geany_config"
    log_success "Script execute avec succes."
  else
    log_error "Fichier introuvable : $geany_config"
    return 1
  fi
}
