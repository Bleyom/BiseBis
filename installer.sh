#!/bin/bash
os="$(grep -m1 "NAME=" </etc/os-release | cut -d '"' -f 2)"
server="$(echo $XDG_SESSION_TYPE)"
help() {
    echo "usage: $0 Install [-i] Help menu [-h]" >&2
    exit 1
}

check_server() {
    if [ "$server" == x11 ]; then
        echo -ne "[*] You are using X11"
        cp -r eww-template/eww srcpkgs/eww
    else
        echo -ne "[*] You are using Wayland or idk"
        cp -r eww-template/eww-wayland srcpkgs/eww
    fi
}

detect_os() {
    if [ "$os" == "void" ]; then
        echo -ne "[*] Welcome to BiseBis (My dotfiles) Installer\n"
        echo -ne "Os used is Void Linux\n"
        echo -ne "Proceding with Void Linux installation\n"
        install-void
    else
        echo -ne "[*] Welcome to BiseBis (My dotfiles) Installer\n"
        echo -ne "It's not Void proceding with default installation (Packages doesn't get installed) \n"
        install-common
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
    cd void-packages
    git clone https://github.com/monke0192/eww-template
    ./xbps-src binary-bootstrap
    check_server
    ./xbps-src pkg eww
    xi eww
}

start-install() {
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
    *)
        help
        ;;
    esac
done
