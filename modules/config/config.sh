#!/bin/bash
for cmd in "geany" "gcc" "uncrustify"; do
  type -P $cmd &> /dev/null
  if [ $? != 0 ]; then
    echo "*** "$cmd" not installed"
    exit 1
  fi
done
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
cp .config/geany/geany_with_uncrustify_missing.conf .config/geany/geany.conf
echo 'custom_commands=bash -c "uncrustify -c $HOME/'$ucfg' -lc -q";' >> .config/geany/geany.conf
cp -r .config/ ~/
cp $ucfg ~/
rm ~/.config/geany/geany_with_uncrustify_missing.conf
echo "--- It’s in the bag!"
