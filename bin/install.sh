#!/bin/bash

# Define constants
DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"
GREEN='\033[0;32m' # Green Color
RED='\033[0;31m' # Red Color
NC='\033[0m' # No Color
CHECK_DONE='\xE2\x9C\x94'

# Function to print the ASCII art logo
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

# Function to update and upgrade the system
function update_system() {
    sudo apt update && sudo apt upgrade
}

# Function to install system-wide packages if it's not already installed
function install_system_packages() {
    local packages_to_install=()
    local all_packages_installed=true

    if [ $# -eq 0 ]; then
        printf "${RED}Error: No packages specified for installation.${NC}\n"
        return 1
    fi

    printf "${GREEN}Checking system packages...${NC}\n"

    for package in "$@"; do
        if dpkg -s "$package" &> /dev/null; then
            printf "  ${GREEN}%s is already installed ${CHECK_DONE}${NC}\n" "$package"
        else
            printf "  ${GREEN}%s is NOT installed. Adding to queue.${NC}\n" "$package"
            packages_to_install+=("$package") # Add to the array
            all_packages_installed=false
        fi
    done

    if [ "$all_packages_installed" = false ]; then
        printf "${GREEN}Installing missing packages: %s...${NC}\n" "${packages_to_install[*]}"
        sudo apt install -y "${packages_to_install[@]}"
        printf "${GREEN}Package installation complete ${CHECK_DONE}${NC}\n"
    else
        printf "${GREEN}All packages are already installed. Nothing to do ${CHECK_DONE}${NC}\n"
    fi
}

function install_alacritty() {
    # Clone and build
    git clone https://github.com/alacritty/alacritty.git
    cd alacritty
    rustup override set stable
    rustup update stable
    cargo build --release

    # Install binary
    sudo cp target/release/alacritty /usr/local/bin
    sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    sudo desktop-file-install extra/linux/Alacritty.desktop
    sudo update-desktop-database

    # Install man doc
    sudo mkdir -p /usr/local/share/man/man1
    sudo mkdir -p /usr/local/share/man/man5
    scdoc < extra/man/alacritty.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null
    scdoc < extra/man/alacritty-msg.1.scd | gzip -c | sudo tee /usr/local/share/man/man1/alacritty-msg.1.gz > /dev/null
    scdoc < extra/man/alacritty.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty.5.gz > /dev/null
    scdoc < extra/man/alacritty-bindings.5.scd | gzip -c | sudo tee /usr/local/share/man/man5/alacritty-bindings.5.gz > /dev/null

    # install completion engine
    mkdir -p ~/.bash_completion
    cp extra/completions/alacritty.bash ~/.bash_completion/alacritty
}

# Function to install vide and nvide
function install_vide() {
    bash <(curl -s https://raw.githubusercontent.com/hungpham3112/vide/main/bin/install.sh)
}

function install_nvide() {
    git clone https://github.com/hungpham3112/NVIDE.git $HOME/.config/nvim
}

function install_spotify() {
    curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt-get update && sudo apt-get install spotify-client -y

    SPOTIFY_APPS_PATH="/usr/share/spotify"

    if [ ! -d "$SPOTIFY_APPS_PATH" ]; then
        sudo mkdir -p "$SPOTIFY_APPS_PATH"
    fi

    if [ ! -d "$SPOTIFY_APPS_PATH/Apps" ]; then
        sudo mkdir -p "$SPOTIFY_APPS_PATH/Apps"
    fi

    sudo chmod a+wr /usr/share/spotify
    sudo chmod a+wr /usr/share/spotify/Apps -R
}

function install_spicetify() {
    # Nov.17/2025: spicetify nó có cái bug ngu theo kiểu circular nên tạo prefs và markerplace trống
    mkdir -p $HOME/.config/spotify > /dev/null 2>&1 
    touch $HOME/.config/spotify/prefs > /dev/null 2>&1 
    mkdir -p $HOME/.config/spicetify/Themes/marketplace/ > /dev/null 2>&1
    curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
    spicetify clear && spicetify backup apply
}

# Function to clone the dotfiles repository
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

# Function to load GNOME shell settings
function load_gnome_shell_settings() {
    if dconf load /org/gnome/terminal/legacy/profiles:/ < "${DOTFILES_DIR}/gterminal.preferences"; then
        gsettings set org.gnome.mutter auto-maximize true
        gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
        gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
        printf "${GREEN}Loading gnome shell settings successfully ${CHECK_DONE}${NC}\n"
    else
        printf "${RED}Loading gnome shell settings fail ${NC}\n"
    fi
}

# Function to create a symlink
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

# Function to install themes
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

# Function to install icons
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

# Function to install ble.sh (Bash Line Editor)
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

# Function to install Mamba (a fast implementation of Conda)
function install_mamba() {
    local miniforge_dir="$HOME/miniforge3/"
    if [[ -d "$miniforge_dir" ]]; then
        printf "${GREEN}Mamba already exist ${CHECK_DONE}${NC}\n"
    else
        if curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"; then
            bash "Miniforge3-$(uname)-$(uname -m).sh" -b # Run in non-interactive mode
            rm "Miniforge3-$(uname)-$(uname -m).sh" -f
            printf "${GREEN}Install mamba successfully ${CHECK_DONE}${NC}\n"
        else
            printf "${RED}Install mamba fail ${NC}\n"
        fi
    fi
}

# Function to install packages for conda base env
function install_conda_base_packages() {
    # BASH array to hold the names of packages that NEED installation
    local packages_to_install=()
    # Flag to track if any packages are missing
    local all_packages_installed=true
    
    # Store the path to the Mamba executable
    local mamba_executable="$HOME/miniforge3/bin/mamba"
    if [ $# -eq 0 ]; then
        printf "${RED}Error: No packages specified for installation.${NC}\n"
        return 1
    fi

    # 2. PRE-CONDITION: Check if Mamba executable exists
    if [[ ! -f "$mamba_executable" ]]; then
        printf "${RED}Error: Mamba executable not found at %s${NC}\n" "$mamba_executable"
        printf "${RED}This function depends on the 'install_mamba' step.${NC}\n"
        return 1 # Exit with an error
    fi

    printf "${GREEN}Checking conda base packages: %s...${NC}\n" "$@"

    # 3. CHECK EACH PACKAGE
    # Get the list of installed packages *once* for efficiency.
    local installed_list
    installed_list=$($mamba_executable list)

    # Loop over all arguments passed to the function ("$@")
    for package in "$@"; do
        # Check if the package name appears at the start of a line
        if echo "$installed_list" | grep -qE "^$package\s+"; then
            # Package is already installed
            printf "  ${GREEN}%s is already installed ${CHECK_DONE}${NC}\n" "$package"
        else
            # Package is NOT installed
            packages_to_install+=("$package")
            all_packages_installed=false
        fi
    done

    # 4. INSTALL MISSING PACKAGES
    if [ "$all_packages_installed" = false ]; then
        printf "${GREEN}Installing missing conda base packages: %s...${NC}\n" "${packages_to_install[*]}"
        # Run mamba install ONE time
        if "$mamba_executable" install -y -c conda-forge "${packages_to_install[@]}"; then
            printf "${GREEN}Conda base packages installation complete ${CHECK_DONE}${NC}\n"
        else
            printf "${RED}Conda package installation failed.${NC}\n"
            return 1 # Report failure
        fi
    else
        printf "${GREEN}All specified conda packages are already installed. Nothing to do ${CHECK_DONE}${NC}\n"
    fi
}

# Function to set up key swapping
function setup_swapkey() {
    # Install required packages
    install_package inotify-tools
    install_package x11-xserver-utils
    install_package xkbset

    # Make keymap_monitor.sh executable
    sudo chmod +x "${CONFIG_DIR}/custom_keymap/keymap_monitor.sh"
    sudo chmod +x "${CONFIG_DIR}/custom_keymap/apply_keymap.sh"

    # Enable and start the custom keymap service
    systemctl --user daemon-reload
    systemctl --user enable custom_keymap.service
    systemctl --user start custom_keymap.service
}


function install_snap_apps() {
    sudo snap install notion-desktop
    sudo snap install discord
    sudo snap install nvim
}

# Main function to orchestrate the entire setup process
function main() {
    print_logo
    update_system
    install_system_wide_packages curl ibus-unikey neofetch libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev gzip scdoc snapd
    install_vide
    clone_dotfiles
    install_themes
    install_icons
    install_ble
    load_gnome_shell_settings
    symlink_file "${DOTFILES_DIR}/.Xmodmap" "${CONFIG_DIR}/.Xmodmap"
    symlink_file "${DOTFILES_DIR}/alacritty/alacritty.toml" "${CONFIG_DIR}/alacritty/alacritty.toml"
    # symlink_file "${DOTFILES_DIR}/spicetify/config-xpui.ini" "${CONFIG_DIR}/spicetify/config-xpui.ini"
    symlink_file "${DOTFILES_DIR}/.bashrc" "$HOME/.bashrc"
    symlink_file "${DOTFILES_DIR}/custom_keymap/custom_keymap.service" "${CONFIG_DIR}/systemd/user/custom_keymap.service"
    symlink_file "${DOTFILES_DIR}/custom_keymap/apply_keymap.sh" "${CONFIG_DIR}/custom_keymap/apply_keymap.sh"
    symlink_file "${DOTFILES_DIR}/custom_keymap/keymap_monitor.sh" "${CONFIG_DIR}/custom_keymap/keymap_monitor.sh"
    symlink_file "${DOTFILES_DIR}/custom_keymap/custom_keymap.xkb" "${CONFIG_DIR}/custom_keymap/custom_keymap.xkb"
    install_spotify
    install_spicetify
    install_mamba
    install_conda_base_packages cmake openssh curl
    setup_swapkey
    install_nvide # depend on cmake from mamba
    install_alacritty
    install_snap_apps
}

# Execute the main function
main
