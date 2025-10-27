#!/usr/bin/env bash
# author: somniaum
# description: Setting keyboard shortcuts for GNOME support

set_shortcut(){
    # Configure the shortcuts
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_on/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_off/']"

    # On settings
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_on/ name 'Keyboard Backlight on'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_on/ command "/usr/local/bin/backlight.sh on"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_on/ binding '<Super><Shift>Return'

    # Off settings
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_off/ name 'Keyboard Backlight off'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_off/ command "/usr/local/bin/backlight.sh off"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_off/ binding '<Super><Ctrl>Return'
}
