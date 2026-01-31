#!/bin/bash

# Labwc Theme Switcher
# Usage: ./theme-switcher.sh [theme-name]

THEME_DIR="$HOME/.config/labwc/colors"
THEME_FILE="$HOME/.config/labwc/themerc"
BACKUP_FILE="$HOME/.config/labwc/themerc.backup"

# Available themes
THEMES=(
    "nord"
    "dracula" 
    "catppuccin"
    "gruvbox"
    "solarized-dark"
    "tokyonight"
    "onedark"
    "everforest"
    "wallpaper"
    "black"
    "adapta"
    "arc"
    "cyberpunk"
    "lavender-pastel"
    "lovelace"
    "navy"
    "paper"
    "solarized"
    "yousai"
    "everforest-light"
)

show_usage() {
    echo "Labwc Theme Switcher"
    echo "Usage: $0 [theme-name]"
    echo ""
    echo "Available themes:"
    for theme in "${THEMES[@]}"; do
        echo "  - $theme"
    done
    echo ""
    echo "Examples:"
    echo "  $0 nord"
    echo "  $0 dracula"
    echo "  $0 catppuccin"
}

backup_current_theme() {
    if [ -f "$THEME_FILE" ]; then
        cp "$THEME_FILE" "$BACKUP_FILE"
        echo "Current theme backed up to $BACKUP_FILE"
    fi
}

apply_theme() {
    local theme_name="$1"
    local theme_path="$THEME_DIR/${theme_name}.color"
    
    if [ ! -f "$theme_path" ]; then
        echo "Error: Theme '$theme_name' not found at $theme_path"
        echo "Available themes:"
        ls -1 "$THEME_DIR"/*.color | sed 's|.*/||' | sed 's|\.color||'
        exit 1
    fi
    
    backup_current_theme
    
    # Copy theme to themerc
    cp "$theme_path" "$THEME_FILE"
    
    # Reload labwc configuration
    if command -v labwcctl >/dev/null 2>&1; then
        labwcctl reload
        echo "Theme '$theme_name' applied and Labwc reloaded"
    else
        echo "Theme '$theme_name' applied. Restart Labwc to see changes."
    fi
}

list_themes() {
    echo "Available themes:"
    for theme in "${THEMES[@]}"; do
        local theme_path="$THEME_DIR/${theme}.color"
        if [ -f "$theme_path" ]; then
            echo "  ✓ $theme"
        else
            echo "  ✗ $theme (file missing)"
        fi
    done
}

interactive_mode() {
    echo "Labwc Theme Switcher - Interactive Mode"
    echo "======================================"
    echo ""
    
    list_themes
    echo ""
    
    read -p "Enter theme name (or 'q' to quit): " selected_theme
    
    if [[ "$selected_theme" == "q" || "$selected_theme" == "quit" ]]; then
        echo "Exiting."
        exit 0
    fi
    
    # Check if theme exists
    local theme_found=false
    for theme in "${THEMES[@]}"; do
        if [[ "$theme" == "$selected_theme" ]]; then
            theme_found=true
            break
        fi
    done
    
    if [ "$theme_found" = true ]; then
        apply_theme "$selected_theme"
    else
        echo "Error: Unknown theme '$selected_theme'"
        echo "Use '$0 --list' to see available themes."
        exit 1
    fi
}

# Main script logic
case "${1:-}" in
    --help|-h)
        show_usage
        exit 0
        ;;
    --list|-l)
        list_themes
        exit 0
        ;;
    --interactive|-i)
        interactive_mode
        exit 0
        ;;
    --restore|-r)
        if [ -f "$BACKUP_FILE" ]; then
            cp "$BACKUP_FILE" "$THEME_FILE"
            labwcctl reload 2>/dev/null || echo "Restart Labwc to see changes"
            echo "Previous theme restored"
        else
            echo "No backup theme found"
        fi
        exit 0
        ;;
    "")
        interactive_mode
        ;;
    *)
        apply_theme "$1"
        ;;
esac
