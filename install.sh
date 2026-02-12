#!/bin/bash

# LXQt + Labwc Openbox Style Configuration Installer
# This script installs the configuration files and sets up the environment
#
# Usage:
#   ./install.sh           - Full install (preserves existing theme customizations)
#   ./install.sh --reset   - Full install with reset (overwrites ALL configs with repo defaults)

set -e

CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESET_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --reset)
            RESET_MODE=true
            shift
            ;;
        -h|--help)
            echo "Usage: ./install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --reset    Reset all configs to repo defaults (overwrites customizations)"
            echo "  -h, --help Show this help message"
            echo ""
            echo "Default behavior preserves your existing theme and color customizations."
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

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

# Check for required dependencies
check_dependencies() {
    local missing=()
    local required=(labwc python3 swaybg swayidle swaylock dunst brightnessctl lxqt-panel)
    local optional=(grimshot wl-clip-persist cliphist paplay)
    
    print_status "Checking dependencies..."
    for cmd in "${required[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing required dependencies: ${missing[*]}"
        print_status "Install them with your package manager before continuing."
        exit 1
    fi
    
    for cmd in "${optional[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            print_warning "Optional: $cmd not found (some features may not work)"
        fi
    done
    print_success "All required dependencies found"
}

check_dependencies

# Check if we're in the right directory
if [ ! -f "$SCRIPT_DIR/README.md" ]; then
    print_error "Please run this script from the lxqt-labwc-openbox repository root"
    exit 1
fi

print_status "LXQt + Labwc Openbox Style Configuration Installer"
print_status "=================================================="
if [ "$RESET_MODE" = true ]; then
    print_warning "RESET MODE: All configurations will be overwritten with repo defaults!"
    echo -n "Continue? [y/N] "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        print_status "Aborted."
        exit 0
    fi
else
    print_status "Preserving existing theme and color customizations..."
fi

# Create backup directory
print_status "Creating backup of existing configurations..."
mkdir -p "$BACKUP_DIR" || { print_error "Failed to create backup directory"; exit 1; }

# Backup existing configurations if they exist
if [ -d "$CONFIG_DIR/labwc" ]; then
    print_warning "Backing up existing Labwc configuration..."
    mv "$CONFIG_DIR/labwc" "$BACKUP_DIR/" || { print_error "Failed to backup Labwc config"; exit 1; }
fi

if [ -d "$CONFIG_DIR/lxqt" ]; then
    print_warning "Backing up existing LXQt configuration..."
    mv "$CONFIG_DIR/lxqt" "$BACKUP_DIR/" || { print_error "Failed to backup LXQt config"; exit 1; }
fi

# Install configurations
print_status "Installing Labwc configuration..."
mkdir -p "$CONFIG_DIR/labwc" || { print_error "Failed to create labwc config directory"; exit 1; }

# Copy core config files
cp "$SCRIPT_DIR/labwc-config/autostart" "$CONFIG_DIR/labwc/"
cp "$SCRIPT_DIR/labwc-config/environment" "$CONFIG_DIR/labwc/"
cp "$SCRIPT_DIR/labwc-config/labwc.xml" "$CONFIG_DIR/labwc/"

# Preserve existing themerc if it exists (user customizations)
if [ "$RESET_MODE" = true ]; then
    cp "$SCRIPT_DIR/labwc-config/themerc" "$CONFIG_DIR/labwc/"
    print_status "Installed themerc from repo (reset mode)"
elif [ -f "$BACKUP_DIR/labwc/themerc" ]; then
    print_status "Preserving your existing themerc (restoring from backup)..."
    cp "$BACKUP_DIR/labwc/themerc" "$CONFIG_DIR/labwc/"
else
    cp "$SCRIPT_DIR/labwc-config/themerc" "$CONFIG_DIR/labwc/"
fi

# Copy subdirectories (except colors - handled separately for preservation)
cp -r "$SCRIPT_DIR/labwc-config/scripts" "$CONFIG_DIR/labwc/"
cp -r "$SCRIPT_DIR/labwc-config/idle" "$CONFIG_DIR/labwc/"
cp -r "$SCRIPT_DIR/labwc-config/sound" "$CONFIG_DIR/labwc/"
cp -r "$SCRIPT_DIR/labwc-config/systemd" "$CONFIG_DIR/labwc/"
cp -r "$SCRIPT_DIR/labwc-config/templates" "$CONFIG_DIR/labwc/"

# Handle colors directory - preserve user's custom color schemes
print_status "Installing color schemes..."
mkdir -p "$CONFIG_DIR/labwc/colors"
if [ "$RESET_MODE" = true ]; then
    # Reset mode - overwrite all color schemes
    cp -r "$SCRIPT_DIR/labwc-config/colors/"* "$CONFIG_DIR/labwc/colors/"
    print_status "Installed all color schemes from repo (reset mode)"
elif [ -d "$BACKUP_DIR/labwc/colors" ]; then
    # Restore user's existing colors first
    cp -r "$BACKUP_DIR/labwc/colors/"* "$CONFIG_DIR/labwc/colors/" 2>/dev/null || true
    print_status "Restored your existing color schemes"
    # Then add any NEW color schemes from repo that user doesn't have
    for color_file in "$SCRIPT_DIR/labwc-config/colors/"*.color; do
        color_name=$(basename "$color_file")
        if [ ! -f "$CONFIG_DIR/labwc/colors/$color_name" ]; then
            cp "$color_file" "$CONFIG_DIR/labwc/colors/"
            print_status "Added new color scheme: $color_name"
        fi
    done
else
    # Fresh install - copy all color schemes
    cp -r "$SCRIPT_DIR/labwc-config/colors/"* "$CONFIG_DIR/labwc/colors/"
fi

print_status "Installing LXQt configuration..."
mkdir -p "$CONFIG_DIR/lxqt" || { print_error "Failed to create lxqt config directory"; exit 1; }
cp -r "$SCRIPT_DIR/lxqt-config/"* "$CONFIG_DIR/lxqt/" || { print_error "Failed to copy LXQt config"; exit 1; }

# Note: We do NOT install labwc-autostart.desktop to XDG autostart
# because labwc already runs ~/.config/labwc/autostart natively.
# Installing it would cause double execution (chime plays twice, etc.)

# Symlink LXQt's labwc config path to our labwc config directory
print_status "Linking LXQt to use Labwc config..."
ln -sfn "$CONFIG_DIR/labwc" "$CONFIG_DIR/lxqt/labwc"

# Install Waybar config (replaces lxqt-panel with minimal taskbar)
print_status "Installing Waybar configuration..."
mkdir -p "$CONFIG_DIR/waybar"
if [ -d "$SCRIPT_DIR/labwc-config/waybar" ]; then
    cp "$SCRIPT_DIR/labwc-config/waybar/"* "$CONFIG_DIR/waybar/"
    print_status "Waybar config installed (replaces lxqt-panel)"
fi

# Disable lxqt-panel - use Waybar instead (prevents panel from starting)
print_status "Disabling lxqt-panel (using Waybar for taskbar)..."
mkdir -p "$CONFIG_DIR/autostart"
cp "$SCRIPT_DIR/labwc-config/templates/lxqt-panel.desktop" "$CONFIG_DIR/autostart/"
print_status "lxqt-panel disabled"

# Disable LXQt desktop - use labwc wallpaper + right-click menu only
print_status "Disabling LXQt desktop (no icons, labwc handles right-click)..."
cp "$SCRIPT_DIR/labwc-config/templates/lxqt-desktop.desktop" "$CONFIG_DIR/autostart/"
print_status "LXQt desktop disabled"

# Install GTK dark theme settings
print_status "Installing GTK dark theme..."
mkdir -p "$CONFIG_DIR/gtk-3.0"
mkdir -p "$CONFIG_DIR/gtk-4.0"
cp "$CONFIG_DIR/labwc/templates/gtk-3.0-settings.ini" "$CONFIG_DIR/gtk-3.0/settings.ini"
cp "$CONFIG_DIR/labwc/templates/gtk-4.0-settings.css" "$CONFIG_DIR/gtk-4.0/gtk.css"

# Install xdg-desktop-portal config (fixes file picker on Wayland)
print_status "Installing portal configuration..."
mkdir -p "$CONFIG_DIR/xdg-desktop-portal"
cp "$CONFIG_DIR/labwc/templates/xdg-desktop-portal-portals.conf" "$CONFIG_DIR/xdg-desktop-portal/portals.conf"

# Install systemd services and timers
print_status "Installing systemd services..."
mkdir -p "$CONFIG_DIR/systemd/user"
cp "$CONFIG_DIR/labwc/systemd/"*.service "$CONFIG_DIR/systemd/user/"
cp "$CONFIG_DIR/labwc/systemd/"*.timer "$CONFIG_DIR/systemd/user/"
systemctl --user daemon-reload || print_warning "Failed to reload systemd daemon"
systemctl --user enable --now labwc-menu-update.timer || print_warning "Failed to enable menu-update timer"
systemctl --user enable labwc-gtk-sync.service || print_warning "Failed to enable gtk-sync service"
systemctl --user enable labwc-portal-restart.service || print_warning "Failed to enable portal-restart service"
systemctl --user enable labwc-theme-watcher.service || print_warning "Failed to enable theme-watcher service"

# Install Openbox themes (used by Labwc theme name lookup)
print_status "Installing Openbox themes..."
THEMES_SRC="$SCRIPT_DIR/themes"
THEMES_DEST="$HOME/.local/share/themes"
THEMES_BACKUP="$HOME/.local/share/themes-backup-$(date +%Y%m%d-%H%M%S)"
if [ -d "$THEMES_SRC" ]; then
    mkdir -p "$THEMES_DEST"
    
    # Install themes - preserve existing customizations unless reset mode
    for theme_dir in "$THEMES_SRC"/*/; do
        theme_name=$(basename "$theme_dir")
        if [ "$RESET_MODE" = true ]; then
            # Reset mode - overwrite theme
            if [ -d "$THEMES_DEST/$theme_name" ]; then
                mkdir -p "$THEMES_BACKUP"
                cp -r "$THEMES_DEST/$theme_name" "$THEMES_BACKUP/" 2>/dev/null || true
            fi
            cp -r "$theme_dir" "$THEMES_DEST/"
            print_status "Installed $theme_name theme (reset mode)"
        elif [ -d "$THEMES_DEST/$theme_name" ]; then
            # Theme exists - backup and preserve user's version
            print_status "Preserving existing $theme_name theme (your customizations kept)..."
            # Backup user's theme just in case
            mkdir -p "$THEMES_BACKUP"
            cp -r "$THEMES_DEST/$theme_name" "$THEMES_BACKUP/" 2>/dev/null || true
        else
            # Fresh theme install
            cp -r "$theme_dir" "$THEMES_DEST/"
            print_status "Installed $theme_name theme"
        fi
    done
    
    # If we created a themes backup, tell the user
    if [ -d "$THEMES_BACKUP" ] && [ "$(ls -A "$THEMES_BACKUP" 2>/dev/null)" ]; then
        print_status "Theme backup location: $THEMES_BACKUP"
    else
        rmdir "$THEMES_BACKUP" 2>/dev/null || true
    fi
else
    print_warning "No themes/ directory found in repo; skipping theme install."
fi

# Install wallpapers
print_status "Installing wallpapers..."
WALLPAPERS_SRC="$SCRIPT_DIR/.wallpapers"
WALLPAPERS_DEST="$HOME/.wallpapers"
if [ -d "$WALLPAPERS_SRC" ]; then
    if [ -d "$WALLPAPERS_DEST" ]; then
        # Merge wallpapers - copy new ones without overwriting existing
        find "$WALLPAPERS_SRC" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | while read -r src_file; do
            rel_path="${src_file#$WALLPAPERS_SRC/}"
            dest_file="$WALLPAPERS_DEST/$rel_path"
            if [ ! -f "$dest_file" ]; then
                mkdir -p "$(dirname "$dest_file")"
                cp "$src_file" "$dest_file"
            fi
        done
        print_status "Merged new wallpapers into existing collection"
    else
        cp -r "$WALLPAPERS_SRC" "$WALLPAPERS_DEST"
        print_status "Installed wallpapers to ~/.wallpapers"
    fi
    wallpaper_count=$(find "$WALLPAPERS_DEST" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | wc -l)
    print_status "Total wallpapers available: $wallpaper_count"
else
    print_warning "No .wallpapers directory found in repo; skipping wallpaper install."
fi

# Set permissions
print_status "Setting correct permissions..."
chmod +x "$CONFIG_DIR/labwc/autostart" 2>/dev/null || print_warning "Could not set autostart permissions"
find "$CONFIG_DIR/labwc/scripts" -name "*.sh" -exec chmod +x {} \; 2>/dev/null
find "$CONFIG_DIR/labwc/scripts" -name "*.py" -exec chmod +x {} \; 2>/dev/null
find "$CONFIG_DIR/labwc/idle" -name "*.sh" -exec chmod +x {} \; 2>/dev/null

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
echo "  - Vermello theme (Openbox-style) - existing customizations preserved"
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
