#!/usr/bin/env bash
set -euo pipefail

## modified https://github.com/blue-build/modules/blob/8c0e8fa7760707112480981c019df0a542e1e286/modules/fonts/fonts.sh
## this script had a bug, yq deserialization didnt work correctly

get_yaml_array() {
    # creates array $1 with content at key $2 from $3
    readarray "$1" < <(yq -I=0 "$2" "$3")
}

MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"
for SOURCE in "$MODULE_DIRECTORY"/fonts/sources/*.sh; do
   
    chmod +x "${SOURCE}"

    # get array of fonts for current source
    FILENAME=$(basename -- "${SOURCE}")
    echo "Calling $FILENAME"

    get_yaml_array FONTS ".fonts.${FILENAME%.*}[]" "$1"

    if [ ${#FONTS[@]} -gt 0 ]; then
        bash "${SOURCE}" "${FONTS[@]}"
    fi
done