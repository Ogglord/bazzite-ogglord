if test "$(id -u)" -gt "0" && test -d "$HOME"; then
    # Add default settings when there are no settings
    if test ! -e "$HOME"/.config/starship.toml; then
        mkdir -p "$HOME"/.config/
        cp -f /etc/skel.d/.config/starship.toml "$HOME"/.config/starship.toml
    fi

    # Add default settings when there are no settings
    if test ! -e "$HOME"/.bashrc.d/bash_ogge.sh; then
        mkdir -p "$HOME"/.bashrc.d/
        cp -f /etc/skel.d/.bashrc.d/bash_ogge.sh "$HOME"/.bashrc.d/bash_ogge.sh
    fi
fi