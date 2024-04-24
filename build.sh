#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1







# fedora repos
rpm-ostree install tmux
rpm-ostree install zsh zsh-autosuggestions zsh-syntax-highlighting
rpm-ostree install bat
rpm-ostree install tealdeer
rpm-ostree install ncdu
rpm-ostree install bpytop
rpm-ostree install ripgrep

# rpmfusion
rpm-ostree install vlc

# custom repo
wget https://pkgs.tailscale.com/stable/fedora/tailscale.repo -P /etc/yum.repos.d/
rpm-ostree install tailscale

#### Example for enabling a System Unit File

#systemctl enable podman.socket
