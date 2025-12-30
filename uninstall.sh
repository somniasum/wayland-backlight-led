#!/usr/bin/env bash
# author: somniasum
# description: Uninstall script for wayland-backlight-led

source src/handler.sh

remove(){
    # Remove backlight.sh script
    if [ -f $main_script_path/backlight.sh ]; then
        log INFO "Removing [ backlight.sh ]."
        sudo rm $main_script_path/backlight.sh && \
        log SUCCESS "[ backlight.sh ] successfully removed." || log ERROR "Failed to remove [ backlight.sh ]."
    else
        log NOTICE "[ backlight.sh ] already removed."
    fi

    # Remove user service
    if [ -f ~/.config/systemd/user/kbd-backlight.service ]; then
        log INFO "Removing [ kbd-backlight.service ]."
        systemctl --user disable --now kbd-backlight.service &> /dev/null && \
        systemctl --user stop --now kbd-backlight.service &> /dev/null && \
        sudo rm ~/.config/systemd/user/kbd-backlight.service && \
        log SUCCESS "[ kbd-backlight.service ] successfully removed." || log ERROR "Failed to remove [ kbd-backlight.service ]."
    else
        log NOTICE "[ kbd-backlight.service ] already removed."
    fi

    # Remove backlight.sh script
    if [ -f $main_script_path/backlight.sh ]; then
        log INFO "Removing [ backlight.sh ]."
        rm $main_script_path/backlight.sh && \
        log SUCCESS "[ backlight.sh ] successfully removed." || log ERROR "Failed to remove [ backlight.sh ]."
    else
        log NOTICE "[ backlight.sh ] already removed."
    fi

    # Remove keyboard LED udev rules
    if [ -f "/etc/sudoers.d/keyboard-led" ]; then
        log INFO "Removing [ keyboard-led ] udev rules."
        sudo rm /etc/sudoers.d/keyboard-led && \
        sudo udevadm control --reload-rules && \
        sudo udevadm trigger && \
        log SUCCESS "Keyboard LED udev rules successfully removed." || log ERROR "Failed to remove [ keyboard-led ] udev rules."
    else
        log NOTICE "[ keyboard-led ] udev rules already removed."
    fi

    # Remove alias
    if grep -qE "alias (on|off)=.*backlight\.sh" \
        ~/.bashrc \
        ~/.zshrc \
        ~/.config/fish/config.fish 2>/dev/null; then

        for file in ~/.bashrc ~/.zshrc ~/.config/fish/config.fish; do
            if [ -f "$file" ]; then
                sed -i "/alias \(on\|off\)=.*backlight\.sh/d" "$file"
            fi
        done && \
        log SUCCESS "Aliases successfully removed" || log ERROR "Failed to remove aliases"
    else
        log NOTICE "Aliases already removed"
    fi

}

# Prompt
show_banner
echo -ne "${LOG_LEVELS[PROMPT]} Uninstall wayland-backlight-led? [${COLORS[GREEN]}Y${COLORS[NC]}/${COLORS[RED]}n${COLORS[NC]}]: "
read -r response
if [[ $response =~ ^[Yy]$ ]]; then
    remove && \
    log SUCCESS "Uninstallation completed." || log ERROR "Failed to uninstall [ wayland-backlight-led ]."
else
    log NOTICE "Uninstallation cancelled."
    exit 1
fi
