#!/usr/bin/env bash
# Author: somniasum
# Description: A script to handle errors and logs.

set -u

source ../install.sh

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
║                 v.0.5                  ║
╚════════════════════════════════════════╝
EOF
    echo -e "${COLORS[NC]}"
    log NOTICE "Log file: $LOG_FILE"
    echo
}

# Check prerequisites
check_prerequisites() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Do not run as root."
        exit 1
    fi

    if ! sudo -v; then
        log_error "Use sudo."
        exit 1
    fi

    if ! command -v brightnessctl &>/dev/null; then
        log_error "Brightness control tool not found."
        log PROMPT "Install [ brightnessctl ] using your package manager."
        exit 1
    fi
    log SUCCESS "Prerequisites checked."

    if ! ls $main_script_path | grep -q "brightness.sh"; then
        log_error "Brightness script not found."
        log PROMPT "Install [ brightness.sh ] using your package manager."
        exit 1
    fi
}
