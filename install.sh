#!/usr/bin/env bash 
#Author: somniasum 
#Title: Wayland LED Manager
#Date Modified: 25.01.2025
#Description: Main script to install and handle needed files to use keyboard LED in Wayland

### Begin
## Call alias script 
source Main/alias.sh

## Variables
main_script_path="/usr/local/bin"
service_path="/etc/systemd/system/"

## Moving needed files
echo "[*] Copying needed files to system"
sudo cp Main/backlight.sh "$main_script_path" || { echo "[*] Error: Failed to copy backlight.sh to $main_script_path"; exit 1; }
sudo cp Main/backlight@.service "$service_path" || { echo "[*] Error: Failed to copy backlight@.service to $service_path"; exit 1; }

## Permission setting
echo "[*] Setting permissions for alias.sh and backlight.sh"
sudo chmod +x "$main_script_path/backlight.sh"
sudo chmod +x Main/alias.sh

## Set Aliases to shell config
shell_config

### End
echo "[*] Installation complete!"

