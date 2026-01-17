#!/usr/bin/env bash
#Author: somniasum
#Description: Script to handle setting aliases [on/off] to current shell config.

source src/handler.sh

## Variables
home=$(echo $HOME)
shell="${SHELL##*/}"

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
			log ERROR "Current shell is unsupported. Please edit shell config manually."
	esac
}

## Set shell config name
shell_set_value=$(shell_set)

## To check if there is an alias matching that of the script
shell_config() {

    log INFO "Configuring $shell_set_value with needed aliases [on/off]"

	if ! grep -Eq "^alias (on|off)=" "$shell_set_value"; then

		## Inserts the alias to the current shell being used
		echo "#Alias for backlight" >> "$shell_set_value"
		echo "alias on='$main_script_path/backlight.sh on'" >> "$shell_set_value"
		echo "alias off='$main_script_path/backlight.sh off'" >> "$shell_set_value"
		log SUCCESS "Aliases added to $shell_set_value."

	else
		log NOTICE "Alias [on/off] is already set. Please review $shell_set_value"
	fi
}
