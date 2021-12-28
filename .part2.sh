#!/bin/bash

# Installing the Kernel
echo "Installing the kernel."
echo
sleep 3s
clear
git clone https://github.com/linux-xertz/xertz-kernel
cd xertz-kernel
make
make modules_install
make install
cp -v arch/x86/boot/bzImage /boot/vmlinuz-5.15.11-linux-xertz
mkinitcpio -k 5.15.11 -c /etc/mkinitcpio.conf -g /boot/initramfs-5.15.11-linux-xertz
System.map /boot/System.map-5.15.11-linux-xertz
clear

# Installing the bootloader
echo "Installing the bootloader..."
grub-install --target=x86_64-efi --bootloader-id=linux-xertz --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
clear

# Post install
echo "Installing gui and network utils..."
pacman -S lightdm lightdm-gtk-greeter xorg exo garcon thunar thunar-volman tumbler xfce4-appfinder xfce4-panel xfce4-power-manager xfce4-session xfce4-settings xfce4-terminal xfconf xfdesktop xfwm4 xfwm4-themes
systemctl enable lightdm
systemctl enable NetworkManager
