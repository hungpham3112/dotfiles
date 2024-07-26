#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"
GREEN='\033[0;32m' # Green Color
RED='\033[0;31m' # Red Color
NC='\033[0m' # No Color
CHECK_DONE='\xE2\x9C\x94'

function print_logo() {
    cat << 'EOF'

     $$$$$$\                                      $$$$$$\                       $$\               $$\ $$\                     
    $$  __$$\                                     \_$$  _|                      $$ |              $$ |$$ |                    
    $$ /  $$ | $$$$$$\   $$$$$$\   $$$$$$$\         $$ |  $$$$$$$\   $$$$$$$\ $$$$$$\    $$$$$$\  $$ |$$ | $$$$$$\   $$$$$$\  
    $$$$$$$$ |$$  __$$\ $$  __$$\ $$  _____|        $$ |  $$  __$$\ $$  _____|\_$$  _|   \____$$\ $$ |$$ |$$  __$$\ $$  __$$\ 
    $$  __$$ |$$ /  $$ |$$ /  $$ |\$$$$$$\          $$ |  $$ |  $$ |\$$$$$$\    $$ |     $$$$$$$ |$$ |$$ |$$$$$$$$ |$$ |  \__|
    $$ |  $$ |$$ |  $$ |$$ |  $$ | \____$$\         $$ |  $$ |  $$ | \____$$\   $$ |$$\ $$  __$$ |$$ |$$ |$$   ____|$$ |      
    $$ |  $$ |$$$$$$$  |$$$$$$$  |$$$$$$$  |      $$$$$$\ $$ |  $$ |$$$$$$$  |  \$$$$  |\$$$$$$$ |$$ |$$ |\$$$$$$$\ $$ |      
    \__|  \__|$$  ____/ $$  ____/ \_______/       \______|\__|  \__|\_______/    \____/  \_______|\__|\__| \_______|\__|      
              $$ |      $$ |                                                                                                  
              $$ |      $$ |                                                                                                  
              \__|      \__|    
Welcome to Apps Installer <3

EOF
}

function update_system() {
    sudo apt update && sudo apt upgrade
}

function install_package() {
    local package="$1"
    if command -v "$package" > /dev/null; then
        printf "${GREEN}%s is installed ${CHECK_DONE}${NC}\n" "$package"
    else
        printf "${GREEN}%s is not installed. Installing %s...${NC}\n" "$package" "$package"
        sudo apt install -y "$package"
        printf "${GREEN}Install %s done ${CHECK_DONE}${NC}\n" "$package"
    fi
}

function install_vide() {
    bash <(curl -s https://raw.githubusercontent.com/hungpham3112/vide/main/bin/install.sh)
}

function clone_dotfiles() {
    if [[ -d "$DOTFILES_DIR" ]]; then
        sudo rm -rf "$DOTFILES_DIR"
    fi
    if git clone https://github.com/hungpham3112/dotfiles.git "$DOTFILES_DIR"; then
        printf "${GREEN}Clone dotfiles folder successfully ${CHECK_DONE}${NC}\n"
    else
        printf "${RED}Clone dotfiles folder fail ${NC}\n"
    fi
}

function load_gnome_shell_settings() {
    if dconf load /org/gnome/terminal/legacy/profiles:/ < "${DOTFILES_DIR}/gterminal.preferences"; then
        printf "${GREEN}Loading gnome shell settings successfully ${CHECK_DONE}${NC}\n"
    else
        printf "${RED}Loading gnome shell settings fail ${NC}\n"
    fi
}

function symlink_file() {
    local src="$1"
    local dest="$2"
    local dest_dir
    dest_dir=$(dirname "$dest")
    mkdir -p "$dest_dir"
    if [[ -f "$dest" ]]; then
        sudo rm "$dest"
    fi
    if sudo ln -s "$src" "$dest"; then
        printf "${GREEN}Symlink %s to %s successfully ${CHECK_DONE}${NC}\n" "$src" "$dest"
    else
        printf "${RED}Symlink %s to %s fail ${NC}\n" "$src" "$dest"
    fi
}

function install_themes() {
    local theme_dir="/usr/share/themes/Sweet/"
    if [[ -d "$theme_dir" ]]; then
        sudo rm -rf "$theme_dir"
    fi
    if sudo git clone --single-branch --branch nova https://github.com/EliverLara/Sweet.git "$theme_dir"; then
        printf "${GREEN}Install theme successfully ${CHECK_DONE}${NC}\n"
    else
        printf "${RED}Install theme fail ${NC}\n"
    fi
}

function install_icons() {
    local icon_dir="/usr/share/icons/candy-icons/"
    if [[ -d "$icon_dir" ]]; then
        sudo rm -rf "$icon_dir"
    fi
    if sudo git clone https://github.com/EliverLara/candy-icons.git "$icon_dir"; then
        printf "${GREEN}Install icon successfully ${CHECK_DONE}${NC}\n"
    else
        printf "${RED}Install icon fail ${NC}\n"
    fi
}

function install_ble() {
    local ble_dir="$HOME/ble.sh/"
    if [[ -d "$ble_dir" ]]; then
        printf "${GREEN}ble.sh already exist ${CHECK_DONE}${NC}\n"
    else
        if git clone --recursive https://github.com/akinomyoga/ble.sh.git "$ble_dir"; then
            sudo apt install -y gawk
            make -C ble.sh install PREFIX=~/.local
            printf "${GREEN}Install ble.sh successfully ${CHECK_DONE}${NC}\n"
        else
            printf "${RED}Install ble.sh fail ${NC}\n"
        fi
    fi
}

function install_mamba() {
    local miniforge_dir="$HOME/miniforge3/"
    if [[ -d "$miniforge_dir" ]]; then
        printf "${GREEN}Mamba already exist ${CHECK_DONE}${NC}\n"
    else
        if curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"; then
            bash "Miniforge3-$(uname)-$(uname -m).sh"
            rm "Miniforge3-$(uname)-$(uname -m).sh" -f
            printf "${GREEN}Install mamba successfully ${CHECK_DONE}${NC}\n"
        else
            printf "${RED}Install mamba fail ${NC}\n"
        fi
    fi
}

function setup_swapkey() {
    # Install required packages
    install_package inotify-tools
    install_package x11-xserver-utils
    install_package xkbset

    # Enable and start the custom keymap service
    systemctl --user enable custom_keymap.service
    systemctl --user start custom_keymap.service
}

function main() {
    print_logo
    update_system
    install_package curl
    install_vide
    clone_dotfiles
    symlink_file "${DOTFILES_DIR}/swapkey.desktop" "${CONFIG_DIR}/autostart/swapkey.desktop"
    install_themes
    install_icons
    install_ble
    load_gnome_shell_settings
    symlink_file "${DOTFILES_DIR}/.Xmodmap" "${CONFIG_DIR}/.Xmodmap"
    symlink_file "${DOTFILES_DIR}/alacritty/alacritty.toml" "${CONFIG_DIR}/alacritty/alacritty.toml"
    symlink_file "${DOTFILES_DIR}/.bashrc" "$HOME/.bashrc"
    symlink_file "${DOTFILES_DIR}/custom_keymap/custom_keymap.service" "${CONFIG_DIR}/systemd/user/custom_keymap.service"
    symlink_file "${DOTFILES_DIR}/custom_keymap/keymap_monitor.sh" "${CONFIG_DIR}/custom_keymap/keymap_monitor.sh"
    symlink_file "${DOTFILES_DIR}/custom_keymap/custom_keymap.xkb" "${CONFIG_DIR}/custom_keymap/custom_keymap.xkb"
    install_mamba
    setup_swapkey
}

main
