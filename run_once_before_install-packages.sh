#!/bin/bash
# chezmoi:template:left-delimiter="#" right-delimiter="#"

echo "Starting system package isntallation..."

# Update
sudo pacman -Sy --noconfirm

# Base applications
sudo pacman -S --needed --noconfirm \
  neovim \
  discord \
  chezmoi \
  git \
  fastfetch \
  github-cli \
  yay \
  lazygit

if command -v yay &>/dev/null; then
  echo "Installing AUR packages using yay..."
  # Add AUR packages
  # yay -S --needed --noconfirm example-aur-package
  yay -S --needed --noconfirm ticktick
else
  echo "yay not found. Skipping AUR step"
fi
