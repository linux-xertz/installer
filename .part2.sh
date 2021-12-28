#!/bin/bash

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
