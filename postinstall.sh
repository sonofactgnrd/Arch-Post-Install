#!/bin/bash

# Update and upgrade the system
sudo pacman -Syu --noconfirm

# Install essential packages
sudo pacman -S --noconfirm git yay neovim neofetch cowsay cava wofi waybar hyprland hyprlock hyprpaper hyprshot dolphin cryptsetup

# Install AUR apps
yay -S --noconfirm brave-bin steam minecraft-launcher spotify spicetify-git oh-my-posh-git

# Create a user with sudo privileges (no root password)
useradd -m -G wheel -s /bin/bash user
echo "Set password for user:"
passwd user
echo "user ALL=(ALL) ALL" > /etc/sudoers.d/user

# Enable SDDM for login manager
sudo systemctl enable sddm.service --now

# Enable required services (e.g., PipeWire)
sudo systemctl enable pipewire pipewire-pulse --now

# Set up encryption support for the root partition (cryptroot)
echo "Setting up encryption support..."
sudo mkinitcpio -P

# Clone dotfiles from Git repository
git clone --bare https://github.com/sonofactgnrd/archdots.git /home/user/.dotfiles
git --git-dir=/home/user/.dotfiles --work-tree=/home/user checkout
chown -R user:user /home/user/.dotfiles

# Set Hyprland as the default session
echo "exec hyprland" > /home/user/.xinitrc

# Set up Spicetify (without theme)
spicetify backup apply

# Set up Oh-My-Posh (Dracula theme)
echo 'eval "$(oh-my-posh init bash --config ~/.poshthemes/dracula.omp.json)"' >> /home/user/.bashrc

# Configure GRUB for encrypted root
echo "GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$(blkid -s UUID -o value /dev/sda2):cryptroot root=/dev/mapper/cryptroot\"" | sudo tee -a /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Install GRUB bootloader (assuming BIOS)
sudo grub-install --target=i386-pc /dev/sda  # Replace /dev/sda with your disk

# Ensure the system can prompt for the password to unlock the root partition
echo "GRUB_ENABLE_CRYPTODISK=y" | sudo tee -a /etc/default/grub

# Update initramfs
sudo mkinitcpio -P

# Enable and start NetworkManager
sudo systemctl enable NetworkManager.service --now

# Optional: Set a default terminal emulator (Kitty)
sudo ln -sf /usr/bin/kitty /usr/local/bin/x-terminal-emulator

# Reboot the system
echo "Installation complete. Rebooting..."
sudo reboot
