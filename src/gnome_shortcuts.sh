#!/usr/bin/env bash
# Author: somniaum
# Description: Setting keyboard shortcuts for GNOME support

source src/handler.sh

set_shortcut(){
    # Configure the shortcuts
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_on/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_off/']"

    # On settings
    log INFO "Configuring keyboard backlight on shortcut"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_on/ name 'Keyboard Backlight on'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_on/ command "/usr/local/bin/backlight.sh on"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_on/ binding '<Super><Shift>Return'

    # Off settings
    log INFO "Configuring keyboard backlight off shortcut"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_off/ name 'Keyboard Backlight off'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_off/ command "/usr/local/bin/backlight.sh off"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_off/ binding '<Super><Ctrl>Return'

}
