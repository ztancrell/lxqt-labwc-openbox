#!/bin/bash

# LXQt + Labwc Openbox Style Configuration Installer
# This script installs the configuration files and sets up the environment

set -e

CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    print_error "Do not run this installer as root (no sudo ./install.sh)."
    print_error "Run it as your user so it installs into your HOME (~/.config, ~/.local)."
    print_error "The script will prompt for sudo only if you choose the optional system-wide install."
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "$SCRIPT_DIR/README.md" ]; then
    print_error "Please run this script from the lxqt-labwc-openbox repository root"
    exit 1
fi

print_status "LXQt + Labwc Openbox Style Configuration Installer"
print_status "=================================================="

# Create backup directory
print_status "Creating backup of existing configurations..."
mkdir -p "$BACKUP_DIR"

# Backup existing configurations if they exist
if [ -d "$CONFIG_DIR/labwc" ]; then
    print_warning "Backing up existing Labwc configuration..."
    mv "$CONFIG_DIR/labwc" "$BACKUP_DIR/"
fi

if [ -d "$CONFIG_DIR/lxqt" ]; then
    print_warning "Backing up existing LXQt configuration..."
    mv "$CONFIG_DIR/lxqt" "$BACKUP_DIR/"
fi

# Install configurations
print_status "Installing Labwc configuration..."
mkdir -p "$CONFIG_DIR/labwc"
cp -r "$SCRIPT_DIR/labwc-config/"* "$CONFIG_DIR/labwc/"

print_status "Installing LXQt configuration..."
mkdir -p "$CONFIG_DIR/lxqt"
cp -r "$SCRIPT_DIR/lxqt-config/"* "$CONFIG_DIR/lxqt/"

# Install Openbox themes (used by Labwc theme name lookup)
print_status "Installing Openbox themes..."
THEMES_SRC="$SCRIPT_DIR/themes"
THEMES_DEST="$HOME/.local/share/themes"
if [ -d "$THEMES_SRC" ]; then
    mkdir -p "$THEMES_DEST"
    cp -r "$THEMES_SRC/"* "$THEMES_DEST/"
else
    print_warning "No themes/ directory found in repo; skipping theme install."
fi

# Set permissions
print_status "Setting correct permissions..."
chmod +x "$CONFIG_DIR/labwc"/*.sh
chmod +x "$CONFIG_DIR/labwc/menu-generator.py"
chmod +x "$CONFIG_DIR/labwc/menu-generator.sh"
chmod +x "$CONFIG_DIR/labwc/idle"/*.sh

# Create symlinks for consolidated config
if [ -f "$CONFIG_DIR/labwc/labwc-consolidated.xml" ]; then
    print_status "Setting up consolidated configuration..."
    # Backup original configs
    mv "$CONFIG_DIR/labwc/labwc.xml" "$CONFIG_DIR/labwc/labwc.xml.backup" 2>/dev/null || true
    mv "$CONFIG_DIR/labwc/rc.xml" "$CONFIG_DIR/labwc/rc.xml.backup" 2>/dev/null || true
    
    # Use consolidated config
    cp "$CONFIG_DIR/labwc/labwc-consolidated.xml" "$CONFIG_DIR/labwc/labwc.xml"
    cp "$CONFIG_DIR/labwc/labwc-consolidated.xml" "$CONFIG_DIR/labwc/rc.xml"
fi

# Install theme switcher system-wide if desired
read -p "Do you want to install theme switcher system-wide? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Installing theme switcher system-wide..."
    sudo cp "$CONFIG_DIR/labwc/theme-switcher.sh" "/usr/local/bin/labwc-theme"
    sudo chmod +x "/usr/local/bin/labwc-theme"
    print_success "Theme switcher installed as 'labwc-theme' command"
fi

# Generate initial menu
print_status "Generating application menu..."
if [ -f "$CONFIG_DIR/labwc/menu-update.sh" ]; then
    "$CONFIG_DIR/labwc/menu-update.sh"
fi

# Create desktop session file if needed
SESSION_DIR="/usr/share/xsessions"
if [ -d "$SESSION_DIR" ] && [ ! -f "$SESSION_DIR/lxqt-labwc.desktop" ]; then
    print_status "Creating desktop session file..."
    if command -v sudo >/dev/null 2>&1; then
        sudo tee "$SESSION_DIR/lxqt-labwc.desktop" > /dev/null <<EOF
[Desktop Entry]
Name=LXQt with Labwc
Comment=LXQt desktop environment with Labwc window manager
Exec=startlxqt
Type=Application
DesktopNames=LXQt
EOF
        print_success "Session file created"
    fi
fi

print_success "Installation completed!"
echo ""
print_status "What's been installed:"
echo "  - Labwc window manager configuration"
echo "  - LXQt desktop environment configuration"
echo "  - Theme switcher with 20+ color schemes"
echo "  - Dynamic menu generation"
echo "  - Consolidated configuration files"
echo ""
print_status "Backup location: $BACKUP_DIR"
echo ""
print_status "Next steps:"
echo "  1. Restart your display manager or logout/login"
echo "  2. Select 'LXQt' session from your display manager"
echo "  3. Use 'labwc-theme' or '~/.config/labwc/theme-switcher.sh' to switch themes"
echo "  4. Use '~/.config/labwc/menu-update.sh' to update application menu"
echo ""
print_warning "If you encounter issues, restore from backup:"
echo "  rm -rf ~/.config/labwc ~/.config/lxqt"
echo "  mv $BACKUP_DIR/* ~/.config/"
echo ""
print_status "Enjoy your Openbox-styled LXQt + Labwc desktop!"
