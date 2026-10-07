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
  else
    log_info "WARN: No user defined"
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

setup_vpn
