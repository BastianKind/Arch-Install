#!/bin/bash

online=$(ping -q -c1 google.com &>/dev/null && echo online || echo offline)

if [[ $online == "offline" ]]; then
    echo "Please connect to the internet"
    exit 69
fi

echo You are on a $(cat /sys/firmware/efi/fw_platform_size)-bit system

echo "on which drive do you want your system to be? (example: (/dev/sda)"

read targetDisk

echo "create an efi partition (EFI format) (min. 1Gib)"
echo "create a swap partition (swap format) (min. 4GiB)"
echo "create a file system partition (Linux format) (Rest of diskspace (min. 32GiB))"

echo "Press enter when you are ready to set up your partitions"
read

cfdisk $targetDisk

echo "do you know where your partitions are? (example: /dev/sda1, /dev/sda2, /dev/sda3)"
echo "(y|yes|y|Yes|YES)"

read confirmation
pattern="[^(y|Y)]"
if [[ $confirmation =~ $pattern ]]; then
    vim <(fdisk -l)
fi
echo "What is your efi partition? example: /dev/sda1"
read efi_partition

echo "What is your swap partition? example: /dev/sda2"
read swap_partition

echo "What is your filesystem partition? example: /dev/sda3"
read filesystem_partition

mkfs.ext4 "$filesystem_partition"

mkswap "$swap_partition"

mkfs.fat -F 32 "$efi_partition"

echo "Sucessfully created filesystems (mkfs)"

echo "Mounting filesystems"

mount "$filesystem_partition" /mnt

mount --mkdir "$efi_partition" /mnt/boot

swapon "$swap_partition"

echo "Partitions successfully mounted"

echo "Proceeding with installation"

# https://wiki.archlinux.org/title/Installation_guide#Installation

echo "Proceeding with installation"

echo "What packages do you want to install?"
echo "example: vim neovim nano man-db tree fastfetch intel-ucode man-pages"
#read packages
packages="7-zip alacritty aws-cli-v2 base base-devel blueman bluez bluez-utils catfish dotnet-sdk drun-gtk3 fastfetch firefox git hyprland intel-ucode iwd linux linux-firmware neovim networkmanager nwg-look pavucontrol pipewire-pulse pulseaudio-alsa refind rofi steam sudo swaylock-effects thunar tree ttf-font-awesome-5 ttf-jetbrains-mono ttf-jetbrains-mono-nerd vesktop-bin vim visual-studio-code-bin waybar yay yay-debug zsh"
echo "installing: " $packages
pacstrap -K /mnt base linux linux-firmware $packages

echo "generating fstab"

genfstab -U /mnt >>/mnt/etc/fstab

cp install.sh /mnt/install.sh
cp rEFInd.sh /mnt/rEFInd.sh
chmod 777 /mnt/install.sh

echo "chrooting into /mnt"
echo "Please run /install.sh"
echo "$efi_partition" >/mnt/partitions.tmp
echo "$swap_partition" >>/mnt/partitions.tmp
echo "$filesystem_partition" >>/mnt/partitions.tmp
arch-chroot /mnt
