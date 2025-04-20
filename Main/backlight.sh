#!/usr/bin/env bash
# Author: somniasum
# Date Modified: 23.01.2025
# Title: Wayland LED Manager
# Description: Script that monitors and manages keyboard LED

### Begin
## Auto-detect the scroll lock that controls keyboard backlight (LED)
detect_scroll_lock() {
    scroll_lock_1=$(brightnessctl -l | grep scrolllock | awk 'NR==1 {print $2}' | tr -d "'")
    scroll_lock_2=$(brightnessctl -l | grep scrolllock | awk 'NR==2 {print $2}' | tr -d "'")
    [[ $scroll_lock_1 == "input2::scrolllock" ]] && echo "$scroll_lock_2" || echo "$scroll_lock_1"
}


## On and off control functions
backlight_on() {
    brightnessctl -d "$scroll_lock" s +100% > /dev/null
}

backlight_off() {
    brightnessctl -d "$scroll_lock" s 100%- > /dev/null
}

## Validate user input, post-installation
validate_input() {
    if [[ "$1" != "on" && "$1" != "off" ]]; then
        echo "[-] Error: Usage: $0 [on|off]"
        exit 1
    fi
}

## Controlling backlight option(s)
backlight_control() {

	## Detect scroll_lock error handle
    	scroll_lock=$(detect_scroll_lock)
    	if [[ -z "$scroll_lock" ]]; then
        	echo "[-] Error: No scroll lock device found!"
        	exit 1
    	fi

	echo "[*] Setting backlight $option"

	## Main script logic
    	if [[ "$option" == "on" ]]; then
       		backlight_on
    	elif [[ "$option" == "off" ]]; then
        	backlight_off
    	fi

}

## Main function calls
main() {
	validate_input "$1"
	option="$1"
	backlight_control

}
### End
main "$1"
