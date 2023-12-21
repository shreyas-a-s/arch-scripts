#!/bin/sh

# Install basic xorg packages
sudo pacman -S --noconfirm xorg xorg-drivers

# Install driver stuff
sudo pacman -S --noconfirm acpid

# Enable acpid, cronie and thermald on boot
sudo systemctl enable acpid

