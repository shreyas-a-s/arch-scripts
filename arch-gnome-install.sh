#!/bin/sh

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
  echo "You must NOT be a root user when running this script. Run it as a normal user." 2>&1
  exit 1
fi

# Make output of pacman better
sudo sed -i '/Color/c Color' /etc/pacman.conf
sudo sed -i '/VerbosePkgLists/c VerbosePkgLists' /etc/pacman.conf
sudo sed -i '/ParallelDownloads/c ParallelDownloads = 5' /etc/pacman.conf
sudo sed -i '/ParallelDownloads/a ILoveCandy' /etc/pacman.conf

# Do a system upgrade
sudo pacman -Syu --noconfirm

# Install basic xorg packages
sudo pacman -S --noconfirm xorg xorg-xinit xorg-drivers libinput

# Install driver stuff
sudo pacman -S --noconfirm acpid dbus cronie thermald pipewire-jack qjackctl

# Enable acpid, cronie and thermald on boot
sudo systemctl enable acpid cronie thermald

# Install bluetooth packages and make connecting to bluetooth sound devices better
sudo pacman -S --noconfirm bluez bluez-hid2hci
sudo sed "/FastConnectable/ c\FastConnectable = true" /etc/bluetooth/main.conf
if ! lsmod | grep -q btusb; then
  sudo modprobe btusb
fi
sudo systemctl enable bluetooth

# Install gnome-shell and other gnome programs that I use
sudo pacman -S --noconfirm gnome-shell gnome-tweaks gnome-console gnome-control-center gnome-keyring gnome-backgrounds gnome-calculator fragments gdm nautilus gvfs-mtp gvfs-gphoto2 qt6-wayland secrets baobab

# Enable gdm autostart on boot
sudo systemctl enable gdm

# Install GSConnect - KDEConnect implementation for Gnome
busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s gsconnect@andyholmes.github.io

# Load gnome ui tweaks
dconf load /org/gnome/ < gnome-dconf.conf

# Install xdg-base-directory packages
sudo pacman -S --noconfirm xdg-user-dirs xdg-desktop-portal xdg-desktop-portal-gnome

# Install programs I use on a daily basis
sudo pacman -S --noconfirm git base-devel vlc btop ufw zoxide xsel neovim zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search lsd curl bat neofetch trash-cli wget tldr fzf btop make github-cli noto-fonts noto-fonts-cjk noto-font-emoji obs-studio gparted ncdu pkgfile

# Update pkgfile database
sudo pkgfile -u

# Install yay - AUR helper
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin || exit
makepkg -si
yay -Y --gendb

# Install AUR programs that I use
yay -S --noconfirm brave-bin github-desktop-bin vscodium-bin joplin-appimage

# Install pacman-contrib meta-package that contains paccache program
sudo pacman -S --noconfirm pacman-contrib

# Enable auto clearing pacman cache using paccache program
echo "[Trigger]                              
Operation = Upgrade
Operation = Install
Operation = Remove
Type = Package
Target = *
[Action]
Description = Cleaning pacman cache...
When = PostTransaction
Exec = /usr/bin/paccache -r" | sudo tee /etc/pacman.d/hooks/clean-pkg-cache.hook > /dev/null

# Install auto-cpufreq - For better battery life on laptops
( cd .. &&\
  git clone https://github.com/AdnanHodzic/auto-cpufreq.git &&\
  cd auto-cpufreq &&\
  sudo ./auto-cpufreq-installer )
sudo auto-cpufreq --install

# Set auto-cpufreq config for i3-115G4
if [ "$(lscpu | sed -nr '/Model name/ s/.*:\s*(.*) @ .*/\1/p' | awk -F '-' '{print $NF}')" = "1115G4" ]; then
  echo "[charger]\
  \ngovernor = performance\
  \nturbo = auto\

  \n[battery]\
  \ngovernor = powersave\
  \nscaling_min_freq = 400000\
  \nscaling_max_freq = 1700000\
  \nturbo = never" | sudo tee /etc/auto-cpufreq.conf > /dev/null
else
  echo "[charger]\
  \ngovernor = performance\
  \nturbo = auto\

  \n[battery]\
  \ngovernor = powersave\
  \nturbo = never" | sudo tee /etc/auto-cpufreq.conf > /dev/null
fi

# Enable ufw and set rules
sudo systemctl enable ufw
if command -v kdeconnect-cli > /dev/null || gnome-extensions list | grep -q gsconnect; then
  sudo ufw allow 1714:1764/udp
  sudo ufw allow 1714:1764/tcp
  sudo ufw reload
fi

# Update tldr pages
tldr -u

# Lower swappiness value for better utilization of RAM
sudo sysctl vm.swappiness=10

# Add script to toggle wifi
echo '#!/bin/sh

if nmcli radio wifi | grep -q disabled; then
  nmcli radio wifi on
else
  nmcli radio wifi off
fi' | sudo tee /usr/local/bin/wifi-toggle > /dev/null
sudo chmod +x /usr/local/bin/wifi-toggle

# Add a cron-job to auto clear trash
if [ $(command -v trash-empty) ]; then
  echo "@reboot $USER $(command -v echo) | $(command -v sudo) $(command -v trash-empty) 10" | sudo tee /etc/cron.d/auto-trash-empty > /dev/null
fi

