#!/bin/bash

DOTFILES_DIR=~/.dotfiles/
CONFIG_DIR=~/.config/
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
        echo -e "${GREEN}Curl is installed ${CHECK_DONE}"
    else
        echo -e "${GREEN}Curl is not installed. Installing curl..."
        sudo apt install curl
        echo -e "${GREEN}Install curl done ${CHECK_DONE}"
    fi
}

function install_vide() {
    bash <(curl -s https://raw.githubusercontent.com/hungpham3112/vide/main/bin/install.sh)
}

function clone_dotfiles() {
    if [ -d "/path/to/folder" ]; then
      rm -r "/path/to/folder"
    fi
    if sudo git clone https://github.com/hungpham3112/.dotfiles.git; then
        echo -e "${GREEN}Clone dotfiles folder successfully${CHECK_DONE}"
    else
        echo -e "${RED}Clone dotfiles folder fail"
    fi
}

function load_gnome_shell_settings() {
    # dconf dump /org/gnome/terminal/ > $DOTFILES_DIR
    if cat $DOTFILES_DIR/gterminal.preferences | dconf load /org/gnome/terminal/legacy/profiles:/; then
        echo -e "${GREEN}Loading gnome shell settings successfully${CHECK_DONE}"
    else
        echo -e "${RED}Loading gnome shell settings fail"
    fi
}

function load_autostart_program() {
    SWAPKEY_FILE=$CONFIG_DIR/autostart/swapkey.desktop
    if [[ -f $SWAPKEY_FILE ]]
    then
        rm $SWAPKEY_FILE -f
        sudo cp $DOTFILES_DIR/swapkey.desktop $SWAPKEY_FILE
        echo -e "${GREEN}Copy swapkey autostart file successfully ${CHECK_DONE}"
    else
        sudo cp $DOTFILES_DIR/swapkey.desktop $SWAPKEY_FILE
        echo -e "${RED}Copy swapkey autostart file fail"
    fi
}

function install_themes() {
    THEME_DIR=/usr/share/themes/
    if sudo git clone --single-branch --branch nova https://github.com/EliverLara/Sweet.git $THEME_DIR; then
        echo -e "${GREEN}Install theme successfully ${CHECK_DONE}"
    else
        echo -e "${RED}Install theme fail "
    fi
}

function install_icons() {
    ICON_DIR=/usr/share/icons/
    if sudo git clone https://github.com/EliverLara/candy-icons.git $ICON_DIR; then
        echo -e "${GREEN}Install icon successfully ${CHECK_DONE}"
    else
        echo -e "${RED}Install icon fail "
    fi
}

function copy_xmodmap() {
    if sudo cp $DOTFILES_DIR/.Xmodmap $CONFIG_DIR/.Xmodmap; then
        echo -e "${GREEN}Copy .Xmodmap file successfully ${CHECK_DONE}"
    else
        echo -e "${RED}Copy .Xmodmap file fail"
    fi
}

function main() {
    print_logo
    update_system
    install_curl
    install_vide
    clone_dotfiles
    load_gnome_shell_settings
    load_autostart_program
    install_themes
    install_icons
    copy_xmodmap
}
main
