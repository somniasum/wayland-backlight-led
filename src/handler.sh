#!/usr/bin/env bash
# Author: somniasum
# Description: A script to handle errors and logs.

set -u

## Variables
main_script_path="/usr/local/bin/"

# Script configuration
LOG_FILE="/tmp/wayland-backlight-led_$(date +%Y%m%d_%H%M%S).log"

# Color definitions
declare -A COLORS=(
    [RED]='\033[0;31m'
    [GREEN]='\033[0;32m'
    [BLUE]='\033[0;34m'
    [PURPLE]='\033[0;35m'
    [YELLOW]='\033[1;33m'
    [CYAN]='\033[0;36m'
    [BOLD]='\033[1m'
    [NC]='\033[0m'
)

# Log level configurations
declare -A LOG_LEVELS=(
    [INFO]="${COLORS[BLUE]}[ - ]${COLORS[NC]}"
    [SUCCESS]="${COLORS[GREEN]}[ + ]${COLORS[NC]}"
    [NOTICE]="${COLORS[PURPLE]}[ # ]${COLORS[NC]}"
    [ERROR]="${COLORS[RED]}[ ! ]${COLORS[NC]}"
    [WARN]="${COLORS[YELLOW]}[ * ]${COLORS[NC]}"
    [PROMPT]="${COLORS[PURPLE]}[ ? ]${COLORS[NC]}"
)

# Logging functions
log() {
    local level="$1"
    shift
    local message="$*"
    echo -e "${LOG_LEVELS[$level]} $message"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_FILE"
}

log_error() {
    local message="$*"
    echo -e "${LOG_LEVELS[ERROR]} $message" >&2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $message" >> "$LOG_FILE"
}

# Progress indicator for operations
run_with_progress() {
    local message="$1"
    shift

    log INFO "$message"
    if "$@" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Banner
show_banner() {
    echo -e "${COLORS[PURPLE]}"
    cat << 'EOF'
╔════════════════════════════════════════╗
║              W4Y-BAC-L3D               ║
║                 v.1.10                 ║
╚════════════════════════════════════════╝
EOF
    echo -e "${COLORS[NC]}"
    log NOTICE "Log file: $LOG_FILE"
    echo
}

# Check prerequisites
check_prerequisites() {
    ## set package_manager
    local package_manager=$(echo $(command -v apt || command -v pacman || command -v dnf ) | awk -F '/' '{print $NF}')

    if [[ $EUID -eq 0 ]]; then
        log_error "Do not run as root."
        exit 1
    fi

    if ! sudo -v; then
        log_error "Use sudo."
        exit 1
    fi

    if ! command -v brightnessctl &>/dev/null; then
        log_error "[ brightnessctl ] not found."
        echo -ne "${LOG_LEVELS[PROMPT]} Install [ brightnessctl ]? [${COLORS[GREEN]}Y${COLORS[NC]}/${COLORS[RED]}n${COLORS[NC]}]: "
        read -r response

       if [[ $response =~ ^[Yy]$ ]]; then
          case "$package_manager" in
            apt)
              sudo apt install brightnessctl && \
              log SUCCESS "[ brightnessctl ] installed."
              ;;
            pacman)
              sudo pacman -S brightnessctl && \
              log SUCCESS "[ brightnessctl ] installed."
              ;;
            dnf)
              sudo dnf install brightnessctl && \
              log SUCCESS "[ brightnessctl ] installed."
              ;;
          esac
        else
            log WARN "[ brightnessctl ] needed."
            exit 1
        fi
    fi

}

file_management() {
    ## Setting needed files for persistence
    if [[ ! -f "/etc/sudoers.d/keyboard-led" ]]; then
        echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/leds/*/trigger, /usr/bin/tee /sys/class/leds/*/brightness" | sudo tee /etc/sudoers.d/keyboard-led &> /dev/null && \
        sudo udevadm control --reload-rules && \
        sudo udevadm trigger && \
        log SUCCESS "$(sudo visudo -c -f /etc/sudoers.d/keyboard-led)" || log ERROR "Failed to set permissions on [ /etc/sudoers.d/keyboard-led ]"
    else
        log NOTICE "Sudoers file configuration already exists [ /etc/sudoers.d/keyboard-led ]"
    fi

    ## Systemd user directory
    if [[ ! -d ~/.config/systemd/user ]]; then
        mkdir -p ~/.config/systemd/user
    else
        log NOTICE "Systemd user directory already exists [ ~/.config/systemd/user ]"
    fi

    ## Systemd service configuration
    if [[ ! -f ~/.config/systemd/user/kbd-backlight.service ]]; then
        tee ~/.config/systemd/user/kbd-backlight.service > /dev/null << 'EOF'
[Unit]
Description=Keyboard Backlight Monitor

[Service]
Type=forking
ExecStart=/usr/local/bin/backlight.sh on
ExecStop=/usr/local/bin/backlight.sh off
Restart=on-failure

[Install]
WantedBy=default.target
EOF
        systemctl --user enable --now kbd-backlight.service &> /dev/null && \
        systemctl --user start kbd-backlight.service &> /dev/null && \
        log SUCCESS "Systemd LED Monitor service started [ kbd-backlight.service ]" || log ERROR "Failed to start systemd LED Monitor service [ kbd-backlight.service ]"
    else
        log NOTICE "Systemd service configuration already exists [ ~/.config/systemd/user/kbd-backlight.service ]"
    fi
}

# Gnome shortcut configuration
set_shortcut(){
    # Configure the shortcuts
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_on/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_off/']"

    # On settings
    log INFO "Configuring keyboard backlight on shortcut"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_on/ name 'Keyboard Backlight on' && \
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_on/ command "/usr/local/bin/backlight.sh on" && \
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_on/ binding '<Super><Shift>Return'

    # Off settings
    log INFO "Configuring keyboard backlight off shortcut"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_off/ name 'Keyboard Backlight off' && \
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_off/ command "/usr/local/bin/backlight.sh off" && \
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom_off/ binding '<Super><Ctrl>Return'

}
