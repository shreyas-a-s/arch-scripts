#!/bin/sh

sudo pacman -S --noconfirm xorg xorg-xinit xorg-drivers libinput

sudo pacman -S --noconfirm acpid dbus cronie bluez thermald pipewire-jack qjackctl

sudo sed "/FastConnectable/ c\FastConnectable = true" /etc/bluetooth/main.conf

sudo pacman -S --noconfirm gnome-shell gnome-tweaks gnome-console gnome-control-center gnome-keyring gnome-backgrounds gnome-calculator fragments gdm nautilus gvfs-mtp gvfs-gphoto2 qt6-wayland secrets baobab

busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s gsconnect@andyholmes.github.io

dconf load /org/gnome/ < gnome-dconf.conf

sudo pacman -S --noconfirm xdg-user-dirs xdg-desktop-portal xdg-desktop-portal-gnome

sudo pacman -S --noconfirm git base-devel vlc btop ufw

sudo systemctl enable acpid gdm thermald

git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
yay -Y --gendb

yay -S --noconfirm brave-bin github-desktop-bin vscodium-bin joplin-appimage

pacman -S --noconfirm zoxide pacman-contrib xsel neovim zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting lsd curl bat neofetch trash-cli wget tldr fzf btop make github-cli noto-fonts noto-fonts-cjk noto-font-emoji

echo "[Trigger]                              
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *
[Action]
Description = Cleaning pacman cache...
When = PostTransaction
Exec = /usr/bin/paccache -r" | sudo tee /etc/pacman.d/hooks/clean-pkg-cache.hook

( cd .. &&\
  git clone https://github.com/AdnanHodzic/auto-cpufreq.git &&\
  cd auto-cpufreq &&\
  sudo ./auto-cpufreq-installer )
sudo auto-cpufreq --install

sudo ufw enable
if command -v kdeconnect-cli > /dev/null || gnome-extensions list | grep -q gsconnect; then
  sudo ufw allow 1714:1764/udp
  sudo ufw allow 1714:1764/tcp
  sudo ufw reload
fi

tldr -u

