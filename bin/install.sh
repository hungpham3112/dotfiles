#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles/"
CONFIG_DIR="$HOME/.config/"
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

function install_curl() {
    if command -v curl > /dev/null; then
        echo -e "${GREEN}Curl is installed ${CHECK_DONE}${NC}"
    else
        echo -e "${GREEN}Curl is not installed. Installing curl...${NC}"
        sudo apt install curl
        echo -e "${GREEN}Install curl done ${CHECK_DONE}${NC}"
    fi
}

function install_vide() {
    bash <(curl -s https://raw.githubusercontent.com/hungpham3112/vide/main/bin/install.sh)
}

function clone_dotfiles() {
    if [[ -d "$DOTFILES_DIR" ]]; then
      sudo rm -rf $DOTFILES_DIR
    fi
    if git clone https://github.com/hungpham3112/dotfiles.git ~/.dotfiles; then
        echo -e "${GREEN}Clone dotfiles folder successfully ${CHECK_DONE}${NC}"
    else
        echo -e "${RED}Clone dotfiles folder fail ${NC}"
    fi
}

function load_gnome_shell_settings() {
    # dconf dump /org/gnome/terminal/ > $DOTFILES_DIR
    if cat "${DOTFILES_DIR}/gterminal.preferences" | dconf load /org/gnome/terminal/legacy/profiles:/; then
        echo -e "${GREEN}Loading gnome shell settings successfully ${CHECK_DONE}${NC}"
    else
        echo -e "${RED}Loading gnome shell settings fail ${NC}"
    fi
}

function symlink_autostart_program() {
    SWAPKEY_FILE="${CONFIG_DIR}/autostart/swapkey.desktop"
    if [[ -f "$SWAPKEY_FILE" ]]
    then
        sudo rm $SWAPKEY_FILE -f
        sudo ln "${DOTFILES_DIR}/swapkey.desktop" $SWAPKEY_FILE --force
        echo -e "${GREEN}Symlink swapkey autostart file successfully ${CHECK_DONE}${NC}"
    else
        sudo ln "${DOTFILES_DIR}/swapkey.desktop" $SWAPKEY_FILE --force
        echo -e "${GREEN}Symlink swapkey autostart file successfully ${CHECK_DONE}${NC}"
    fi
}

function install_themes() {
    THEME_DIR="/usr/share/themes/Sweet/"
    if [[ -d $THEME_DIR ]]; then
      sudo rm -rf $THEME_DIR
    fi
    if sudo git clone --single-branch --branch nova https://github.com/EliverLara/Sweet.git $THEME_DIR; then
        echo -e "${GREEN}Install theme successfully ${CHECK_DONE}${NC}"
    else
        echo -e "${RED}Install theme fail ${NC}"
    fi
}

function install_icons() {
    ICON_DIR="/usr/share/icons/candy-icons/"
    if [[ -d $ICON_DIR ]]; then
      sudo rm -rf $ICON_DIR
    fi
    if sudo git clone https://github.com/EliverLara/candy-icons.git $ICON_DIR; then
        echo -e "${GREEN}Install icon successfully ${CHECK_DONE}${NC}"
    else
        echo -e "${RED}Install icon fail ${NC}"
    fi
}

function symlink_xmodmap() {
    if sudo ln "${DOTFILES_DIR}/.Xmodmap" "${CONFIG_DIR}/.Xmodmap" --force; then
        echo -e "${GREEN}Symlink .Xmodmap file successfully ${CHECK_DONE}${NC}"
    else
        echo -e "${RED}Symlink .Xmodmap file fail ${NC}"
    fi
}

function symlink_alacritty_settings() {
    ALACRITTY_DIR="${CONFIG_DIR}/alacritty/"
    if [[ -d "$ALACRITTY_DIR" ]]
    then
        true
    else
        sudo mkdir $ALACRITTY_DIR
    fi
    if sudo ln "${DOTFILES_DIR}/alacritty/alacritty.toml" "${CONFIG_DIR}/alacritty/alacritty.toml" --force; then
        echo -e "${GREEN}Symlink alacritty settings successfully ${CHECK_DONE}${NC}"
    else
        echo -e "${RED}Symlink alacritty settings fail ${NC}"
    fi
}

function symlink_bashrc() {
    if sudo ln $DOTFILES_DIR/.bashrc ~/.bashrc --force; then
        echo -e "${GREEN}Symlink .bashrc successfully ${CHECK_DONE}${NC}"
    else
        echo -e "${RED}Symlink .bashrc settings fail ${NC}"
    fi
}

function install_ble() {
    BLE_DIR="$HOME/ble.sh/"
    if [[ -d $BLE_DIR ]]; then
        echo -e "${GREEN}ble.sh already exist ${CHECK_DONE}${NC}"
    else
        if git clone --recursive https://github.com/akinomyoga/ble.sh.git $HOME/ble.sh; then
            sudo apt install -y gawk
            make -C ble.sh install PREFIX=~/.local
            echo -e "${GREEN}Install ble.sh successfully ${CHECK_DONE}${NC}"
        else
            echo -e "${RED}Install ble.sh fail ${NC}"
        fi
    fi
}

function install_mamba() {
    MINIFORGE3_DIR="$HOME/miniforge3/"
    if [[ -d $MINIFORGE3_DIR ]]; then
        echo -e "${GREEN}Mamba already exist ${CHECK_DONE}${NC}"
    else
        if curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"; then
            bash Miniforge3-$(uname)-$(uname -m).sh
            rm Miniforge3-$(uname)-$(uname -m).sh -f
            echo -e "${GREEN}Install mamba successfully ${CHECK_DONE}${NC}"
        else
            echo -e "${RED}Install mamba fail ${NC}"
        fi
    fi
}


function main() {
    print_logo
    update_system
    install_curl
    install_vide
    clone_dotfiles
    symlink_autostart_program
    install_themes
    install_icons
    install_ble
    load_gnome_shell_settings
    symlink_xmodmap
    symlink_alacritty_settings
    symlink_bashrc
    install_mamba
}

main
