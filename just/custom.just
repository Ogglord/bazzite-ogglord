# Set shell (back) to bash
bash:
  ujust chsh /bin/bash

# Switch to the fish shell
fish:
  ujust chsh /usr/bin/fish

# Switch to the zsh shell
zsh:
  ujust chsh /usr/bin/zsh

docker:
  sudo systemctl enable --now docker
  sudo usermod -aG docker $USER
  newgrp docker