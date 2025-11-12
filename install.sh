#!/usr/bin/env bash
#Author: somniasum
#Title: Wayland LED Manager
#Date Modified: 19.04.2025
#Description: Main script to install and handle needed files to use keyboard LED in Wayland

### Begin
## Call alias script
source src/alias.sh
source src/gnome_shortcuts.sh
source src/handler.sh

show_banner
check_prerequisites

## Variables
main_script_path="/usr/local/bin"

## Moving needed files
log INFO "Copying needed files to system"
sudo cp src/backlight.sh "$main_script_path" || log ERROR "Failed to copy backlight.sh to $main_script_path"

## Permission setting if needed
log INFO "Setting permissions for alias.sh and backlight.sh"
sudo chmod +x "$main_script_path/backlight.sh"
sudo chmod +x src/alias.sh
sudo chmod +x src/gnome_shortcuts.sh
sudo chmod +x src/handler.sh
log SUCCESS "Permissions set successfully"

## Set Aliases to shell config
log INFO "Setting aliases to shell config"
shell_config && log SUCCESS "Aliases set successfully"

## Set Gnome Shortcuts
log INFO "Configuring keyboard shortcuts"
set_shortcut && log SUCCESS "Keyboard shortcuts configured successfully"

### End
log SUCCESS "Installation complete!"
