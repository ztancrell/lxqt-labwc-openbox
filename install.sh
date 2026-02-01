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
# Copy core config files
cp "$SCRIPT_DIR/labwc-config/autostart" "$CONFIG_DIR/labwc/"
cp "$SCRIPT_DIR/labwc-config/environment" "$CONFIG_DIR/labwc/"
cp "$SCRIPT_DIR/labwc-config/labwc.xml" "$CONFIG_DIR/labwc/"
# Copy subdirectories
cp -r "$SCRIPT_DIR/labwc-config/buttons" "$CONFIG_DIR/labwc/"
cp -r "$SCRIPT_DIR/labwc-config/scripts" "$CONFIG_DIR/labwc/"
cp -r "$SCRIPT_DIR/labwc-config/idle" "$CONFIG_DIR/labwc/"
cp -r "$SCRIPT_DIR/labwc-config/sound" "$CONFIG_DIR/labwc/"
cp -r "$SCRIPT_DIR/labwc-config/systemd" "$CONFIG_DIR/labwc/"
cp -r "$SCRIPT_DIR/labwc-config/templates" "$CONFIG_DIR/labwc/"

print_status "Installing LXQt configuration..."
mkdir -p "$CONFIG_DIR/lxqt"
cp -r "$SCRIPT_DIR/lxqt-config/"* "$CONFIG_DIR/lxqt/"

# Install XDG autostart entry (runs labwc autostart when LXQt starts)
print_status "Installing autostart entry..."
mkdir -p "$CONFIG_DIR/autostart"
cp "$CONFIG_DIR/labwc/templates/labwc-autostart.desktop" "$CONFIG_DIR/autostart/"

# Symlink LXQt's labwc config path to our labwc config directory
print_status "Linking LXQt to use Labwc config..."
ln -sfn "$CONFIG_DIR/labwc" "$CONFIG_DIR/lxqt/labwc"

# Install GTK dark theme settings
print_status "Installing GTK dark theme..."
mkdir -p "$CONFIG_DIR/gtk-3.0"
cp "$CONFIG_DIR/labwc/templates/gtk-3.0-settings.ini" "$CONFIG_DIR/gtk-3.0/settings.ini"

# Install xdg-desktop-portal config (fixes file picker on Wayland)
print_status "Installing portal configuration..."
mkdir -p "$CONFIG_DIR/xdg-desktop-portal"
cp "$CONFIG_DIR/labwc/templates/xdg-desktop-portal-portals.conf" "$CONFIG_DIR/xdg-desktop-portal/portals.conf"

# Install systemd services and timers
print_status "Installing systemd services..."
mkdir -p "$CONFIG_DIR/systemd/user"
cp "$CONFIG_DIR/labwc/systemd/"*.service "$CONFIG_DIR/systemd/user/"
cp "$CONFIG_DIR/labwc/systemd/"*.timer "$CONFIG_DIR/systemd/user/"
systemctl --user daemon-reload
systemctl --user enable --now labwc-menu-update.timer
systemctl --user enable labwc-gtk-sync.service
systemctl --user enable labwc-portal-restart.service
systemctl --user enable labwc-theme-watcher.service

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
chmod +x "$CONFIG_DIR/labwc/scripts"/*.sh
chmod +x "$CONFIG_DIR/labwc/scripts"/*.py
chmod +x "$CONFIG_DIR/labwc/idle"/*.sh

# Generate initial menu
print_status "Generating application menu..."
if [ -f "$CONFIG_DIR/labwc/scripts/menu-update.sh" ]; then
    "$CONFIG_DIR/labwc/scripts/menu-update.sh"
fi

# Note: The Wayland session file should be installed system-wide via:
# sudo cp /usr/local/share/wayland-sessions/lxqt-labwc.desktop /usr/share/wayland-sessions/
# This is typically handled by the lxqt-labwc-session package or manual setup.

print_success "Installation completed!"
echo ""
print_status "What's been installed:"
echo "  - Labwc window manager configuration"
echo "  - LXQt desktop environment configuration"
echo "  - Vermello theme (Openbox-style)"
echo "  - Dynamic menu generation with systemd timer"
echo "  - GTK/Portal sync services"
echo ""
print_status "Backup location: $BACKUP_DIR"
echo ""
print_status "Next steps:"
echo "  1. Restart your display manager or logout/login"
echo "  2. Select 'LXQt (labwc)' Wayland session from your display manager"
echo "  3. Right-click desktop for app menu"
echo "  4. Use Config submenu to manage Labwc settings"
echo ""
print_warning "If you encounter issues, restore from backup:"
echo "  rm -rf ~/.config/labwc ~/.config/lxqt"
echo "  mv $BACKUP_DIR/* ~/.config/"
echo ""
print_status "Enjoy your Openbox-styled LXQt + Labwc desktop!"
