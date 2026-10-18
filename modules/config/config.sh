#!/bin/bash

# Se placer automatiquement dans le dossier du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

if [ -n "$SUDO_USER" ]; then
  REAL_USER="$SUDO_USER"
  REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
  REAL_USER="$USER"
  REAL_HOME="$HOME"
fi

for cmd in "geany" "gcc" "uncrustify"; do
  type -P $cmd &> /dev/null
  if [ $? != 0 ]; then
    echo "*** "$cmd" not installed"
    exit 1
  fi
done
#
cmd="geany"
if pgrep -u "$REAL_USER" -x $cmd &> /dev/null; then
  echo "*** geany should not be running"
  exit 1
fi

#
uvers=$(uncrustify --version | grep -Eo '([0-9]+\.[0-9]+)')
case "$uvers" in
  0.72|0.73)
    ucfg=".uncrustify072_c.cfg" ;;
  0.74|0.75|0.76|0.77)
    ucfg=".uncrustify074_c.cfg" ;;
  0.78|0.79)
    ucfg=".uncrustify078_c.cfg" ;;
  *)
    ucfg=".uncrustify078_c.cfg" ;;
esac
#
cp .config/geany/geany_with_uncrustify_missing.conf .config/geany/geany.conf
echo 'custom_commands=bash -c "uncrustify -c $HOME/'$ucfg' -lc -q";' >> .config/geany/geany.conf
cp -r .config/ $REAL_HOME
cp $ucfg $REAL_HOME
rm $REAL_HOME/.config/geany/geany_with_uncrustify_missing.conf

chown -R "$REAL_USER:" "$REAL_HOME/.config/geany"
chown "$REAL_USER:" "$REAL_HOME/$ucfg"

echo "--- Done"
