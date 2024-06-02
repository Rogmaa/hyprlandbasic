#!/bin/bash
clear

# For a better look
GREEN='/0330[0;32m'
NONE='/033[0m'

# Headers
echo -e "${GREEN}"
cat <<"EOF"
 ____       _               
/ ___|  ___| |_ _   _ _ __  
\___ \ / _ \ __| | | | '_ \ 
 ___) |  __/ |_| |_| | |_) |
|____/ \___|\__|\__,_| .__/ 
                     |_|    

EOF
echo "for ML4W Hyprland Starter"
echo
echo -e "${NONE}"


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
if [ -d ~/Downloads/Hyprland-starter ] ;then
    rm -rf ~/Downloads/Hyprland-starter
    echo ":: Existing installation folder removed."
fi

# Clone packages
git clone --depth 1 https://github.com/Rogmaa/hyprlandbasic
echo ":: Installation files cloned into Downloads."

cd hyprlandbasic

./install.sh