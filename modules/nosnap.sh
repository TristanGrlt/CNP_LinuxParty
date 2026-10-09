disable_snapd() {
  log_info "Suppression et blocage de Snapd..."

  if command -v snap &> /dev/null; then
    log_info "Desinstallation des paquets snap existants (cela peut prendre un moment)..."
    
    while [ "$(snap list 2>/dev/null | wc -l)" -gt 1 ]; do
      snap list 2>/dev/null | awk 'NR>1 {print $1}' | xargs -I{} snap remove {} >/dev/null 2>&1 || true
    done
    
    apt-get purge -y snapd >/dev/null 2>&1
    rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/.snap
  fi

  # Create an APT preference file to prevent snapd from being installed as a dependency
  # This mimics Linux Mint's default behavior
  cat <<EOF > /etc/apt/preferences.d/nosnap.pref
# To prevent repository packages from triggering the installation of snap,
# this file forbids snapd from being installed by APT.
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

  log_success "Snapd est completement desactive et bloque."
}
