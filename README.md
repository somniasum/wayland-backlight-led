<div align="center">
  <img src="src/title.svg" alt="W4YBACL3D" width="600">
</div>

A lightweight user friendly tool to manage keyboard backlight (LED) in Wayland enviroments.

## **Features**

1. **Keyboard Backlight Control**: Type 'on' or 'off' on your terminal of choice.

2. **Cross-Shell Support**: Automatically sets up aliases ('on' and 'off') for your shell. Supported shells: Bash, Fish, Zsh.

3. **GNOME Support**: Automatically sets up keyboard shortcuts for GNOME users.

## **Installation**

### **Steps**
1. **Clone the repository**
```bash
git clone https://github.com/somniasum/wayland-backlight-led && \ 
cd wayland-backlight-led
```

2. **Run script**

Run the install script:
```bash
./install.sh
```
This sets up everything needed.

## **Uninstallation**

Run the uninstall script:
```bash
./uninstall.sh
```
This will remove all the installed files and configurations.

## **Usage**

### **GNOME**

If on GNOME, you can use the default keyboard shortcuts to toggle the backlight:

**Turn backlight on**:
```bash
SUPER + SHIFT + ENTER
```

**Turn backlight off**:
```bash
SUPER + CTRL + ENTER
```
You can change the shortcuts to your preferred choice. Just look through your keyboard settings to do so.

### **Aliases**

Alternatively, you can use the following on your terminal to toggle the backlight:

**Turn backlight on**:
```bash
on
```

**Turn backlight off**:
```bash
off
```
You can change the aliases to your preferred choice. Just look through your shell config to do so.

## **Configuration**

### **Unsupported Shell Configuration**

You use a different shell from Bash, Fish, and Zsh. You can set the aliases manually in your shell config:
```bash
alias on='/usr/local/bin/backlight.sh on'
alias off='usr/local/bin/backlight.sh off'
```

## **Troubleshooting**

### **No Scroll Lock Device Found**

If the script returns and error ```[*] Error No scroll lock device found```, make sure your keyboard supports scroll lock and that brightnessctl can detect it. Use the following to check:
```bash
brightnessctl -l | grep scrolllock
```
