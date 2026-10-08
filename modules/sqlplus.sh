setup_oracle() {
  log_info "Configuration de SQLPlus / SQLcl..."
  
  apt-get install -y unzip
  apt-get install -y libaio1 || {
    apt-get install -y libaio1t64
    ln -sf /usr/lib/x86_64-linux-gnu/libaio.so.1t64 /usr/lib/x86_64-linux-gnu/libaio.so.1 || true
  }

  if [ ! -d "/opt/oracle/instantclient_21_15" ]; then
    wget -qO /tmp/instantclient.zip "https://download.oracle.com/otn_software/linux/instantclient/2115000/instantclient-basic-linux.x64-21.15.0.0.0dbru.zip"
    wget -qO /tmp/sqlplus.zip "https://download.oracle.com/otn_software/linux/instantclient/2115000/instantclient-sqlplus-linux.x64-21.15.0.0.0dbru.zip"
    
    mkdir -p /opt/oracle
    unzip -q /tmp/instantclient.zip -d /opt/oracle/
    unzip -q /tmp/sqlplus.zip -d /opt/oracle/
    
    echo "/opt/oracle/instantclient_21_15" > /etc/ld.so.conf.d/oracle-instantclient.conf
    ldconfig
    
    rm -f /tmp/instantclient.zip /tmp/sqlplus.zip
  fi

  rm -f /usr/local/bin/sqlplus
  ln -sf /opt/oracle/instantclient_21_15/sqlplus /usr/local/bin/sqlplus

  mkdir -p /etc/oracle
  
  cat <<'EOF' > /etc/oracle/tnsnames.ora
dbetu =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = inf-oracle.univ-rouen.fr)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SID = dbetu)
    )
  )
EOF

  cat <<'EOF' > /etc/profile.d/oracle.sh
export TNS_ADMIN=/etc/oracle
export TWO_TASK="dbetu"
EOF
  chmod +x /etc/profile.d/oracle.sh

  log_success "Configuration Oracle terminée."
}
