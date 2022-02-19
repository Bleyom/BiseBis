#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
MAGENTA='\033[1;35m'
GREY='\033[1;37m'
ORANGE='\033[33m'

os="$(grep -m1 "NAME=" </etc/os-release | cut -d '"' -f 2)"
server="$(echo "$XDG_SESSION_TYPE")"
help() {
    echo -ne "${BLUE}usage: $0 Install [-i] Help menu [-h]${NC}\n" >&2
    exit 1
}

welcome-msg() {
    echo -ne "${GREEN}┌─> Github: ${MAGENTA}https://github.com/Bleyom/ ${NC}\n"
    echo -ne "${GREEN}└────────>${NC} The script only works for ${BLUE}Arch Linux${NC}, ${ORANGE}Void Linux${NC} ${GREY}(Working in Debian and another distros support)${NC}\n"
}

check_server() {
    if [ "$server" == x11 ]; then
        echo -ne "${RED}[*] You are using X11${NC}"
        if [ "$os" == "Arch Linux" ]; then
            paru -Sy eww --noconfirm
        elif [ "$os" == "void" ]; then
            cp -r eww-template/eww srcpkgs/eww
        fi
    else
        echo -ne "${GREEN}[*] You are using Wayland or idk${NC}"
        if [ "$os" == "Arch Linux" ]; then
            paru -Sy eww-wayland-git --noconfirm
        elif [ "$os" == "void" ]; then
            cp -r eww-template/eww-wayland srcpkgs/eww
        fi
    fi
}

detect_os() {
    if [ "$os" == "void" ]; then
        echo -ne "${GREEN}[*] Welcome to BiseBis (My dotfiles) Installer\n"
        echo -ne "${RED}Os used is ${RED}Void Linux${NC}\n"
        echo -ne "${GREEN}Proceding with Void Linux installation${NC}\n"
        install-void
    elif [ "$os" == "Arch Linux" ]; then
        echo -ne "${GREEN}[*] Welcome to BiseBis (My dotfiles) Installer\n"
        echo -ne "${RED}Os used is ${RED}Arch Linux${NC}\n"
        echo -ne "${GREEN}Proceding with Arch Linux installation${NC}\n"
        install-arch
    elif [ "$os" == "Debian" ]; then
        # working on this //
        echo -ne "${GREEN}[*] Welcome to BiseBis (My dotfiles) Installer\n"
        echo -ne "${RED}Os used is ${RED}Debian${NC}\n"
        echo -ne "${GREEN}Proceding with Debian installation${NC}\n"
        echo -ne "${RED}Working in that ...${NC}\n"
    else
        echo -ne "[*] Welcome to BiseBis (My dotfiles) Installer\n"
        echo -ne "It's not a supported distro proceding with default installation (Packages doesn't get installed) \n"
        install-common
    fi
}

install-paru() {
    if pacman -Qs git base-devel fakeroot >/dev/null; then
        echo -ne "[*] Git and another dependencies are installed, cloning and installing AUR Helper (paru)\n"
        git clone https://aur.archlinux.org/paru-bin.git
        cd paru-bin || exit
        makepkg -si
        cd ..
    else
        echo -ne "[*] Git and another depedencies are not installed, Installing dependencies and cloning and installing AUR Helper (paru)\n"
        sudo pacman -S git base-devel fakeroot --noconfirm
        git clone https://aur.archlinux.org/paru-bin.git
        cd paru-bin || exit
        makepkg -si
        cd ..
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
    echo -ne "${GREEN}[*] Installing Dependencies${NC}\n"
    sudo xbps-install xtools git polybar sxhkd bspwm kitty rofi picom dunst neofetch nerd-fonts-ttf
    echo -ne "${GREEN}[*] Cloning eww template repositorie${NC}\n"
    git clone https://github.com/void-linux/void-packages
    cd void-packages || exit
    git clone https://github.com/monke0192/eww-template
    ./xbps-src binary-bootstrap
    check_server
    ./xbps-src pkg eww
    cd ..
    xi eww
}

install-arch() {
    install-paru
    echo -ne "${GREEN}[*] Installing dependencies${NC}\n"
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
        echo "${RED}[*] Ciao ^^${NC}"
}

