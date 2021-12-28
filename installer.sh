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
sleep 1s
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
parted /dev/$DRIVE mklabel gpt
parted /dev/$DRIVE unit mib
parted /dev/$DRIVE mkpart primary 1 512
parted /dev/$DRIVE name 1 boot
parted /dev/$DRIVE mkpart primary 512 4227
parted /dev/$DRIVE name 2 swap
parted /dev/$DRIVE mkpart primary 4227 -1
parted /dev/$DRIVE name 3 filesystem
mkfs.fat -F32 /dev/"$DRIVE"1
mkswap /dev/"$DRIVE"2
swapon /dev/"$DRIVE"2
mkfs.ext4 /dev/"$DRIVE"3

# Mounting the drives and installing the system
mount /dev/"$DRIVE"3 /mnt
pacstrap /mnt base base-devel bc linux-firmware vim nano git networkmanager grub efibootmgr 

genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

# Kernel installation
git clone https://github.com/linux-xertz/xertz-kernel
cd kernel
make
make modules_install
make install
cp -v arch/x86/boot/bzimage /boot/vmlinuz-5.15.11-linux-xertz
mkinitcpio -k 5.15.11 -c /etc/mkinitcpio.conf -g /boot/initramfs-5.15.11-linux-xertz
cp System.map /boot/System.map-5.15.11-linux-xertz

# Network setup
echo $HOSTNAME > /etc/hostname


# Grub setup
mkdir /boot/efi
mount /dev/"$DRIVE"1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=linux-xertz --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg


# Post setup
pacman -S lightdm lightdm-gtk-greeter xorg exo garcon thunar thunar-volman tumbler xfce4-appfinder xfce4-panel xfce4-power-manager xfce4-session xfce4-settings xfce4-terminal xfconf xfdesktop xfwm4 xfwm4-themes
systemctl enable lightdm
systemctl enable NetworkManager

