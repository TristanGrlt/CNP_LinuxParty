setup_local_rtc() {
  log_info "Configuration de l'horloge materielle en heure locale (compatibilite Windows)..."
  
  if command -v timedatectl &> /dev/null; then
    timedatectl set-local-rtc 1 --adjust-system-clock >/dev/null 2>&1
    log_success "Horloge systeme configuree en heure locale."
  else
    log_error "La commande timedatectl est introuvable."
  fi
}
