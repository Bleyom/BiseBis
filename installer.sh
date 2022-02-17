#!/bin/bash
os="$(grep -m1 "NAME=" </etc/os-release | cut -d '"' -f 2)"
server="$(echo "$XDG_SESSION_TYPE")"
help() {
    echo "usage: $0 Install [-i] Help menu [-h]" >&2
    exit 1
}

welcome-msg() {
    echo -ne "┌─> Github: https://github.com/Bleyom/ \n"
    echo -ne "└────────> The script only works for Arch Linux, Void Linux (Working in Debian and another distros support)\n"
}

check_server() {
    if [ "$server" == x11 ]; then
        echo -ne "[*] You are using X11"
        if [ "$os" == "Arch Linux" ]; then
            paru -Sy eww --noconfirm
        elif [ "$os" == "void" ]; then
            cp -r eww-template/eww srcpkgs/eww
        fi
    else
        echo -ne "[*] You are using Wayland or idk"
        if [ "$os" == "Arch Linux" ]; then
            paru -Sy eww-wayland-git --noconfirm
        elif [ "$os" == "void" ]; then
            cp -r eww-template/eww-wayland srcpkgs/eww
        fi
    fi
}

detect_os() {
    if [ "$os" == "void" ]; then
        echo -ne "[*] Welcome to BiseBis (My dotfiles) Installer\n"
        echo -ne "Os used is Void Linux\n"
        echo -ne "Proceding with Void Linux installation\n"
        install-void
    elif [ "$os" == "Arch Linux" ]; then
        echo -ne "[*] Welcome to BiseBis (My dotfiles) Installer\n"
        echo -ne "Os used is Arch Linux\n"
        echo -ne "Proceding with Arch Linux installation\n"
        install-arch
    elif [ "$os" == "Debian" ]; then
        # working on this //
        echo -ne "[*] Welcome to BiseBis (My dotfiles) Installer\n"
        echo -ne "Os used is Debian Linux\n"
        echo -ne "Proceding with Debian installation\n"
        echo -ne "Working in that ...\n"
    else
        echo -ne "[*] Welcome to BiseBis (My dotfiles) Installer\n"
        echo -ne "It's not a supported distro proceding with default installation (Packages doesn't get installed) \n"
        install-common
    fi
}

install-paru() {
    if pacman -Qs git base-devel fakeroot >/dev/null; then
        echo -ne "[*] Git and another dependencies are installed, cloning and installing AUR Helper(paru)\n"
        git clone https://aur.archlinux.org/paru-bin.git
        cd paru-bin || exit
        makepkg -si
    else
        echo -ne "[*] Git and another depedencies are not installed, Installing dependencies and cloning and installing AUR Helper(paru)\n"
        sudo pacman -S git base-devel fakeroot --noconfirm
        git clone https://aur.archlinux.org/paru-bin.git
        cd paru-bin || exit
        makepkg -si
    fi
}

copy-config() {
    cp -r configs/{bspwm,polybar,kitty,fish,picom,sxhkd,rofi,dunst,neofetch} ~/.config
    chmod +x ~/.config/bspwm/*
    chmod +x ~/.config/polybar/launch.sh
}

install-common() {
    copy-config
}

install-void() {
    echo -ne "[*] Installing Dependencies\n"
    sudo xbps-install xtools git polybar sxhkd bspwm kitty rofi picom dunst neofetch nerd-fonts-ttf
    echo -ne "[*] Cloning eww template repositorie\n"
    git clone https://github.com/void-linux/void-packages
    cd void-packages || exit
    git clone https://github.com/monke0192/eww-template
    ./xbps-src binary-bootstrap
    check_server
    ./xbps-src pkg eww
    xi eww
}

install-arch() {
    install-paru
    echo -ne "[*] Installing dependencies\n"
    paru -Sy polybar sxhkd bspwm kitty rofi picom dunst neofetch nerd-fonts-complete
    check_server
    copy-config
}

start-install() {
    echo -ne "Press enter to start script ( Control + C For exit )\n"
    read -n 1 -s -r
    welcome-msg
    detect_os
}

while getopts ":h:i" arg; do
    case $arg in
    h)
        help
        ;;
    i)
        start-install
        ;;
    \?)
        help
        ;;
    esac
done

trap ctrl_c INT

function ctrl_c() {
        echo "[*] Ciao ^^"
}

help
