#!/usr/bin/env bash
# Author: somniasum
# Description: keyboard backlight state controller

STATE_FILE="/tmp/kbd_backlight_state"
PID_FILE="/tmp/kbd_backlight_monitor.pid"

## Auto-detect the scroll lock that controls keyboard backlight (LED)
detect_scroll_lock() {
    scroll_lock_1=$(brightnessctl -l | grep scrolllock | awk 'NR==1 {print $2}' | tr -d "'")
    scroll_lock_2=$(brightnessctl -l | grep scrolllock | awk 'NR==2 {print $2}' | tr -d "'")
    [[ $scroll_lock_1 == "input2::scrolllock" ]] && echo "$scroll_lock_2" || echo "$scroll_lock_1"
}

## Set LED state
set_led() {
    local state=$1
    local scroll_lock=$2
    local led_path="/sys/class/leds/$scroll_lock"

    # Disable trigger
    if [[ -w "$led_path/trigger" ]]; then
        echo "none" > "$led_path/trigger" 2>/dev/null
    fi

    # Set brightness
    if [[ -w "$led_path/brightness" ]]; then
        echo "$state" > "$led_path/brightness" 2>/dev/null
    else
        # Fallback to brightnessctl
        if [[ "$state" -eq 1 ]]; then
            brightnessctl -d "$scroll_lock" s +100% > /dev/null 2>&1
        else
            brightnessctl -d "$scroll_lock" s 100%- > /dev/null 2>&1
        fi
    fi
}

## Monitor and restore LED state continuously
monitor_led_state() {
    local scroll_lock=$1
    local desired_state=$2
    local led_path="/sys/class/leds/$scroll_lock/brightness"

    while true; do
        if [[ -r "$led_path" ]]; then
            current_state=$(cat "$led_path" 2>/dev/null)
            if [[ "$current_state" != "$desired_state" ]]; then
                set_led "$desired_state" "$scroll_lock"
            fi
        fi
        sleep 0.1
    done
}

## Stop any existing monitor
stop_monitor() {
    if [[ -f "$PID_FILE" ]]; then
        old_pid=$(cat "$PID_FILE")
        if ps -p "$old_pid" > /dev/null 2>&1; then
            kill "$old_pid" 2>/dev/null
        fi
        rm -f "$PID_FILE"
    fi
}

## Start background monitor
start_monitor() {
    local scroll_lock=$1
    local state=$2

    stop_monitor

    # Start monitor in background
    monitor_led_state "$scroll_lock" "$state" &
    echo $! > "$PID_FILE"
}

## Validate user input
validate_input() {
    if [[ "$1" != "on" && "$1" != "off" ]]; then
        echo "[-] Error: Usage: $0 [on|off]"
        exit 1
    fi
}

## Control function
backlight_control() {
    local option=$1

    ## Detect scroll_lock
    scroll_lock=$(detect_scroll_lock)
    if [[ -z "$scroll_lock" ]]; then
        echo "[-] Error: No Keyboard detected!"
        exit 1
    fi

    case "$option" in
        on)
            echo "[*] Setting backlight [ ON ]"
            echo "1" > "$STATE_FILE"
            set_led 1 "$scroll_lock"
            start_monitor "$scroll_lock" 1
            echo "[+] Backlight enabled. Monitor running [ PID: $(cat $PID_FILE) ]"
            ;;
        off)
            echo "[*] Setting backlight [ OFF ]"
            echo "0" > "$STATE_FILE"
            set_led 0 "$scroll_lock"
            stop_monitor
            echo "[+] Backlight disabled. Monitor stopped."
            ;;
    esac
}

## Main
main() {
    validate_input "$1"
    backlight_control "$1"
}

main "$1"
