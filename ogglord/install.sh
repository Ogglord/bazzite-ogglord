#!/bin/sh

set -ouex pipefail

export OS_VERSION=40
export PACKAGE_LIST="ogglord"

## CONDITIONAL: install sanoid if ZFS
#if [[ "-zfs" == "${ZFS_TAG}" ]]; then
#    rpm-ostree install sanoid
#fi

## ADD: 
wget https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora-40/atim-starship-fedora-40.repo -O /etc/yum.repos.d/_copr-atim-starship.repo

# INSTALL packages stuff
/tmp/packages-install.sh
/tmp/google-chrome-install.sh
chmod +x /tmp/1password-install.sh && \
ONEPASSWORD_RELEASE_CHANNEL=beta \
/tmp/1password-install.sh

## INSTALL packages direct from github
#/tmp/github-release-install.sh trapexit/mergerfs fc.x86_64
/tmp/nerd-fonts-install.sh "FiraCode" "Hack" "SourceCodePro" "Terminus" "JetBrainsMono" "NerdFontsSymbolsOnly"


# ADD custom just commands (e.g. "ujust zsh")
find /tmp/just -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >> /usr/share/ublue-os/just/60-custom.just 

## ENABLE user level install services
chmod +x /usr/bin/bazzite-og-user-vscode
systemctl enable --global bazzite-og-user-vscode.service
chmod +x /usr/bin/bazzite-og-user-bash
systemctl enable --global bazzite-og-user-bash.service

# tweak os-release
#sed -i '/^PRETTY_NAME/s/(uCore.*$/(uCore)"/' /usr/lib/os-release

rm -f /etc/yum.repos.d/tailscale.repo* && \
rm -f /etc/yum.repos.d/vscode.repo && \
rm -f /etc/yum.repos.d/_copr-atim-starship.repo
