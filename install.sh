#!/usr/bin/env bash
#Author: somniasum
#Description: Main script to install and handle needed files to use keyboard LED in Wayland

## Call script functions
source src/alias.sh
source src/gnome_shortcuts.sh
source src/handler.sh

## Start
show_banner
check_prerequisites

## Permission setting if needed
log INFO "Setting permissions"
chmod +x src/* 2>/dev/null && \
log SUCCESS "Permissions set successfully" || log ERROR "Failed to set permissions. [ chmod +x src/* ]"

## Moving needed files
if [ ! -f "$main_script_path/backlight.sh" ]; then
    log INFO "Copying needed files to system"
    sudo cp src/backlight.sh "$main_script_path" && \
    log SUCCESS "backlight.sh copied successfully" || log ERROR "Failed to copy backlight.sh to $main_script_path"
else
    log NOTICE "backlight.sh already exists on $main_script_path"
fi

## File management
file_management

## Set Aliases to shell config
log INFO "Setting aliases to shell config"
shell_config && \
log SUCCESS "Aliases set successfully" || log ERROR "Failed to set aliases"

## Set Gnome Shortcuts
if [[ $XDG_CURRENT_DESKTOP == "GNOME" ]]; then
    log INFO "Configuring keyboard shortcuts"
    set_shortcut && \
    log SUCCESS "Keyboard shortcuts configured successfully" || log ERROR "Failed to configure keyboard shortcuts"
fi

log SUCCESS "Installation complete!"
