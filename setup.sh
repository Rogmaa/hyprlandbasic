#!/bin/bash
clear

while true; do
    read -p "DO YOU WANT TO START THE INSTALLATION NOW? (Yy/Nn): " yn
    case $yn in
        [Yy]* )
            echo "Installation started."
            echo
        break;;
        [Nn]* ) 
            echo "Installation canceled."
            exit;
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done

if [ ! -d ~/Downloads ] ;then
    mkdir ~/Downloads
    echo ":: Downloads folder created"
fi

# Remove existing folder
if [ -d ~/Downloads/hyprlandbasic ] ;then
    rm -rf ~/Downloads/hyprlandbasic
    echo ":: Existing installation folder removed."
fi

# Clone packages
git clone --depth 1 https://github.com/Rogmaa/hyprlandbasic ~/Downloads/hyprlandbasic
echo ":: Installation files cloned into Downloads."

cd ~/Downloads/hyprlandbasic

# Change permission for the install script
chmod +x install.sh

./install.sh
