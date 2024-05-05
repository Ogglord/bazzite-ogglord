# Ogglord's Bazzite spin

# Purpose

This is my custom Bazzite image. This concept of Bazzite and Universal Blue images are a somewhat semi-immutable distro. The image is built like an OCI container using Github Actions. This template is the recommended way to make customizations to any image published by the Universal Blue Project:
- [Bazzite](https://bazzite.gg/)


⚠️ Note: This is based on bazzite:testing ⚠️

# What's added on top of Bazzite
This image includes additional useful apps that I like and use on a daily basis:

- 1password
- alacritty
- autojump
- bat
- bpytop
- curl
- eza
- firefox
- fzf
- google chrome
- ncdu
- rclone
- ripgrep
- rsync
- starship
- tailscale
- tealdeer
- tmux
- vlc
- visual studio code
- zoxide
- zsh
- +fonts (powerline, nerd fonts, mozilla fira mono)
  

# Prerequisites

Install an existing Universal Blue distro (e.g. Bazzite or Aurora)

# Switch to my base image
```
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ogglord/bazzite-ogglord:latest
```
