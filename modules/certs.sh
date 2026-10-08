install_dpi_certificates() {
  log_info "Installation des certificats racines du département (DPI)..."

  cp modules/certs/*.crt /usr/local/share/ca-certificates/
  
  update-ca-certificates >/dev/null 2>&1
  log_success "Certificats racines installés avec succès."
}
