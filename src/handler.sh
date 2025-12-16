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
║                 v.0.6                  ║
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
        echo -ne "${LOG_LEVELS[PROMPT]} Install brightnessctl? [${COLORS[GREEN]}Y${COLORS[NC]}/${COLORS[RED]}n${COLORS[NC]}]: "
        read -r response

       if [[ $response =~ ^[Yy]$ ]]; then
          case "$package_manager" in
            apt)
              sudo apt install brightnessctl &> /dev/null && \
              log SUCCESS "[ brightnessctl ] installed."
              ;;
            pacman)
              sudo pacman -S brightnessctl &> /dev/null && \
              log SUCCESS "[ brightnessctl ] installed."
              ;;
            dnf)
              sudo dnf install brightnessctl &> /dev/null && \
              log SUCCESS "[ brightnessctl ] installed."
              ;;
          esac
        else
            log WARN "Brightness control tool is needed. [ brightnessctl ]"
            exit 1
        fi
    fi

}

file_management() {
    ## Setting needed files for persistence
    if [[ ! -f "/etc/sudoers.d/keyboard-led" ]]; then
        echo "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/class/leds/*/trigger, /usr/bin/tee /sys/class/leds/*/brightness" | sudo tee /etc/sudoers.d/keyboard-led && \
        sudo udevadm control --reload-rules && \
        sudo udevadm trigger && \
        log SUCCESS "$(sudo visudo -c -f /etc/sudoers.d/keyboard-led)" || log ERROR "Failed to set permissions on [ /etc/sudoers.d/keyboard-led ]"
    else
        log NOTICE "Sudoers file configuration already exists [ /etc/sudoers.d/keyboard-led ]"
    fi

    ## Systemd user directory
    if [[ ! -d "~/.config/systemd/user" ]]; then
        mkdir -p ~/.config/systemd/user
    else
        log NOTICE "Systemd user directory already exists [ ~/.config/systemd/user ]"
    fi

    ## Systemd service configuration
    if  [[ ! -f "~/.config/systemd/user/kbd-backlight.service" ]]; then
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
        EOF && \
        sudo systemctl --user enable --now kbd-backlight.service && \
        sudo systemctl --user start kbd-backlight.service && \
        log SUCCESS "Systemd LED Monitor service started [ kbd-backlight.service ]" || log ERROR "Failed to start systemd LED Monitor service [ kbd-backlight.service ]"


    else
        log NOTICE "Systemd service configuration already exists [ ~/.config/systemd/user/kbd-backlight.service ]"
    fi
}
