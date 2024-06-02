#!/bin/bash
clear

# Functions
# Check if package is installed
_isInstalledPacman() {
    package="$1";
    check="$(sudo pacman -Qs --color always "${package}" | grep "local" | grep "${package} ")";
    if [ -n "${check}" ] ;then
        echo 0; # '0' is 'True' in bash
        return;
    fi
    echo 1;
    return;
}

# Install requirments
_installPackagesPacman() {
    toInstall=();
    for pkg; do
        if [[ $(_isInstalledPacman "${pkg}") == 0 ]];then
            echo "${pkg} is already installed.";
            continue;
        fi;
        toInstall+=("${pkg}");
    done;
    if [[ "${toInstall[@]}" == "" ]] ; then
        return;
    fi;
    printf "Package not installed:\n%s\n" "${toInstall[@]}";
    sudo pacman --noconfirm -S "${toInstall[@]}";
}

# Check for VM
_isKVM() {
    iskvm=$(sudo dmesg  grep "Hypervisor detected")
    if [[ "$iskvm" =~ "KVM" ]] ;then
        echo 0
    else
        echo 1
    fi
}

# Check for yay and install if not present
_installYay() {
    if sudo pacman -Qs yay > /dev/null ; then
        echo "yay is already installed!"
    else
        echo "yay was not found, installation starts now!"
        _installPackagesPacman "base-devel"
        SCRIPT=$(realpath "$0")
        temp_path=$(dirname "$SCRIPT")
        echo $temp_path
        git clone https://aur.archlinux.org/yay-git.git ~/yay-git
        cd ~/yay-git
        makepkg -si
        cd $temp_path
        echo "yay has been installed."
    fi
}

# Req packages for the installer
installer_packages=(
    "wget"
    "unzip"
    "gum"
    "rsync"
    "figlet"
)

# Sync package data
sudo pacman -Sy
echo

# Install req packages
echo ":: Checking that req. packages are installed.."
_installPackagesPacman "${installer_packages[@]}";
echo

# Check rsync
if ! command -v rsync &> /dev/null; then
    echo ":: Force rsync installation"
    sudo pacman -S rsync --noconfirm
else
    echo ":: rsync double checked"
fi
echo

# Confirm start
echo -e "${GREEN}"
figlet "Installation"
echo -e "${NONE}"
echo "This script will isntall the core packages for a Hyprland base config:"
echo "hyprland waybar rofi-wayland kitty alacritty dunst dolphin xdg-desktop-portal-hyprland qt5-wayland qt6-wayland hyprpaper hyprlock chromium ttf-font-awesome vim"
echo
echo "IMPORTANT: Backup your .config if needed"
echo "No official support for NVIDIA GPU..."
if gum confirm "DO YOU WANT TO START THE INSTALLATION NOW?" ;then
    echo
    echo ":: Installation Hyprland and additional packages"
    echo
elif [ $? -eq 130 ]; then
    exit 130
else
    echo
    echo ":: Installation canceled."
    exit;
fi

# Install packages feel free to add packages to the list
sudo pacman -S hyprland waybar rofi-wayland kitty alacritty dunst dolphin xdg-desktop-portal-hyprland qt5-wayland qt6-wayland hyprpaper hyprlock chromium ttf-font-awesome vim
# You can also add yay packages here if you wish.. >> 'yay -S fastfetch' for example

# Copy config
if gum confirm "DO YOU WANT TO COPY THE PREPARED dotfiles INTO .config? (You can also do this manually)" ;then
    rsync -a -I . ~/.config/
    echo
    echo ":: Config files successfully copied to ~/.config/"
    echo
elif [ $? -eq 130 ]; then
    exit 130
else
    echo
    echo ":: Installation canceled."
    echo "PLEASE NOTE: Open ~/.config/hypr/hyprland.conf to change your keyboard layout (default is us..)"
    echo "Then reboot your system!"
    exit;
fi

if [ -f ~/.config/hypr/hyprland.conf ] ;then

    # Setup keyboard layout
    echo -e "${GREEN}"
    figlet "Keyboard"
    echo -e "${NONE}"
    echo "Please select your keyboard layout. Can be changed later in ~/.config/hypr/hyprland.conf"
    echo "Start typing = Search, RETURN = Confirm, CTRL-C = Cancel"
    echo
    keyboard_layout=$(localectl list-x11-keymap-layouts | gum filter --height 15 --placeholder "Find your keyboard layout...")
    echo
    if [ -z $keyboard_layout ] ;then
        keyboard_layout="us"
    fi
    SEARCH="kb_layout = us"
    REPLACE="kb_layout = $keyboard_layout"
    sed -i -e "s/$SEARCH/$REPLACE/g" ~/.config/hypr/hyprland.conf
    echo ":: Keyboard layout changed to $keyboard_layout"
    echo

    # Set initial screen resolution
    echo -e "${GREEN}"
    figlet "Monitor"
    echo -e "${NONE}"
    echo "Please select your initial screen resolution, can be changed later in ~/.config/hypr/hyprland.conf"
    echo
    screenres=$(gum choose --height 15 "1024x768" "1280x720" "1280x800" "1440x900" "1280x1024" "1680x1050" "1280x1440" "1600x1200" "1920x1080" "1920x1200" "2560x1440")
    SEARCH="monitor=,preferred,auto,auto"
    REPLACE="monitor=,$screenres,auto,1"
    sed -i -e "s/$SEARCH/$REPLACE/g" ~/.config/hypr/hyprland.conf
    echo ":: Initial screen resolution set to $screenres"

    # VM handling
    if [ $(_isKVM) == "0" ] ;then
        echo -e "${GREEN}"
        figlet "KVM VM"
        echo -e "${NONE}"
        if gum confirm "Are you running this script in a KVM virtual machine?" ;then
            SEARCH="# env = WLR_NO_HARDWARE_CURSORS"
            REPLACE="env = WLR_NO_HARDWARE_CURSORS"
            sed -i -e "s/$SEARCH/$REPLACE/g" ~/.config/hypr/hyprland.conf

            SEARCH="# env = WLR_RENDERER_ALLOW_SOFTWARE"
            REPLACE="env = WLR_RENDERER_ALLOW_SOFTWARE"
            sed -i -e "s/$SEARCH/$REPLACE/g" ~/.config/hypr/hyprland.conf

            echo ":: Environment settings set for KVM cursor support."
        fi
    fi
fi

echo "Open ~/.config/hypr/hyprland.conf to check your new initial Hyprland configuration."
echo
echo "DONE! Please reboot your system!"
