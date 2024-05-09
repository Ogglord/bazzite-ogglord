#!/usr/bin/env bash
## CREDITS: https://github.com/blue-build/modules/blob/main/modules/fonts/sources/nerd-fonts.sh
set -euo pipefail


URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
DEST="/usr/share/fonts/nerd-fonts"

echo "Installation of nerd-fonts started"
rm -rf "$DEST"

mkdir -p /tmp/fonts

  
while [[ $# -gt 0 ]]; do
  
  FONT=${1// /}
  if [ ${#FONT} -gt 0 ]; then
        mkdir -p "${DEST}/${FONT}"

        echo "Downloading ${FONT} from ${URL}/${FONT}.tar.xz"
        
        curl "${URL}/${FONT}.tar.xz" -s -L -o "/tmp/fonts/${FONT}.tar.xz"
        tar -xf "/tmp/fonts/${FONT}.tar.xz" -C "${DEST}/${FONT}"
  fi
  shift
done


rm -rf /tmp/fonts

fc-cache -f "${DEST}"