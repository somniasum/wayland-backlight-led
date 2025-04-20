#!/usr/bin/env bash
#Author: somniasum
#Title: Wayland LED Manager
#Date Modified: 19.04.2025
#Description: Script to handle setting aliases [on/off] to current shell config.

### Begin
## Variables
home=$1
shell=$2

## Shell indentifier
shell_set() {
	case "$shell" in
		bash)
			echo "$home/.bashrc"
			;;
		fish)
			echo "$home/.config/fish/config.fish"
			;;
		zsh)
			echo "$home/.zshrc"
			;;
		*)
			echo "[-] Error: Current shell is unsupported. Please edit shell config manually."
			exit 1
	esac
}

## Set shell config name
shell_set_value=$(shell_set)

echo "[*] Configuring $shell_set_value with needed aliases [on/off]"
## To check if there is an alias matching that of the script
shell_config() {

	if ! grep -Eq "^alias (on|off)=" "$shell_set_value"; then

		## Inserts the alias to the current shell being used
		echo "#Alias for backlight" >> "$shell_set_value"
		echo "alias on='$main_script_path/backlight.sh on'" >> "$shell_set_value"
		echo "alias off='$main_script_path/backlight.sh off'" >> "$shell_set_value"
		echo "[*] Aliases added to $shell_set_value."

	else
		echo "[-] Error: Alias [on/off] is already set. Please review $shell_set_value config."
		exit 1
	fi
}

### End
