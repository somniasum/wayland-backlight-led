#!/usr/bin/env bash
#Author: somniasum
#Title: Wayland LED Manager
#Date Modified: 19.04.2025
#Description: Main script to install and handle needed files to use keyboard LED in Wayland

### Begin
## Call alias script
source Main/alias.sh
source Main/gnome_shortcuts.sh

## Variables
main_script_path="/usr/local/bin"

## Moving needed files
echo "[*] Copying needed files to system"
sudo cp Main/backlight.sh "$main_script_path" || { echo "[*] Error: Failed to copy backlight.sh to $main_script_path"; }

## Permission setting if needed
echo "[*] Setting permissions for alias.sh and backlight.sh"
sudo chmod +x "$main_script_path/backlight.sh"
sudo chmod +x Main/alias.sh
sudo chmod +x Main/gnome_shortcuts.sh

## Set Aliases to shell config
shell_config

## Set Gnome Shortcuts
set_shortcut

### End
echo "[*] Installation complete!"
