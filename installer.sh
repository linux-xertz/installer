#!/bin/bash

# Welcoming
clear
echo "Welcome to Linux Xertz!"
sleep 1s
echo
echo "The aim for Xertz was to make a simple, arch based system which doesn't come with any unneeded things."
sleep 1s
echo
echo "This operating system was made for fun by some kid but if enough people come to support it I will continue to develop it or maybe get some friends to help me with it."
sleep 4s
echo
echo "Enough of me flabbing my gums through your light up metal box let's get into it"
sleep 3s
clear

# Choosing correct disk
echo "Now we will be picking the drive to install the OS on."
sleep 2s
clear
echo "Pick a drive below. Type in the full name of the drive listed."
echo
lsblk -o name,type,size | grep disk | uniq
read DRIVE

# User verification
echo "$DRIVE has been selected. type 'yes please' to wipe the drive."
read YES
if [ $YES = "yes please" ]
	then
		echo "sounds like a plan"
fi

# Following through
wipefs -a /dev/$DRIVE
sleep 1s
parted /dev/$DRIVE mklabel gpt
sleep 1s
parted /dev/$DRIVE unit mib
sleep 1s
parted /dev/$DRIVE mkpart primary 1 512
sleep 1s
parted /dev/$DRIVE name 1 boot
sleep 1s
parted /dev/$DRIVE mkpart primary 512 4227
parted /dev/$DRIVE name 2 swap
parted /dev/$DRIVE mkpart primary 4227 100%
parted /dev/$DRIVE name 3 filesystem
mkfs.fat -F32 /dev/"$DRIVE"1
mkswap /dev/"$DRIVE"2
swapon /dev/"$DRIVE"2
mkfs.ext4 /dev/"$DRIVE"3

# Mounting the drives and installing the system
mount /dev/"$DRIVE"3 /mnt
pacstrap /mnt base base-devel bc linux-firmware vim nano git networkmanager grub efibootmgr 

genfstab -U /mnt >> /mnt/etc/fstab

# Kernel installation
chroot /mnt git clone https://github.com/linux-xertz/xertz-kernel
chroot /mnt cd kernel
chroot /mnt make
chroot /mnt make modules_install
chroot /mnt make install
chroot /mnt cp -v arch/x86/boot/bzimage /boot/vmlinuz-5.15.11-linux-xertz
chroot /mnt mkinitcpio -k 5.15.11 -c /etc/mkinitcpio.conf -g /boot/initramfs-5.15.11-linux-xertz
chroot /mnt cp System.map /boot/System.map-5.15.11-linux-xertz

# Network setup
chroot /mnt echo $HOSTNAME > /etc/hostname


# Grub setup
chroot /mnt mkdir /boot/efi
chroot /mnt mount /dev/"$DRIVE"1 /boot/efi
chroot /mnt grub-install --target=x86_64-efi --bootloader-id=linux-xertz --efi-directory=/boot/efi
chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg


# Post setup
chroot /mnt pacman -S lightdm lightdm-gtk-greeter xorg exo garcon thunar thunar-volman tumbler xfce4-appfinder xfce4-panel xfce4-power-manager xfce4-session xfce4-settings xfce4-terminal xfconf xfdesktop xfwm4 xfwm4-themes
chroot /mnt systemctl enable lightdm
chroot /mntsystemctl enable NetworkManager

