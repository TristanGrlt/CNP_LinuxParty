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

setup_eduroam
