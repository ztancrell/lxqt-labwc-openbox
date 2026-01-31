#!/bin/bash

# Labwc Theme Switcher
# Usage: ./theme-switcher.sh [theme-name]

CONFIG_DIR="$HOME/.config/labwc"
LABWC_XML="$CONFIG_DIR/labwc.xml"
RC_XML="$CONFIG_DIR/rc.xml"
BACKUP_DIR="$CONFIG_DIR/theme-switcher-backup"

get_available_themes() {
    local themes=()
    local dir
    for dir in "$HOME/.local/share/themes" "/usr/share/themes"; do
        [ -d "$dir" ] || continue
        while IFS= read -r -d '' themerc; do
            themes+=("$(basename "$(dirname "$(dirname "$themerc")")")")
        done < <(find "$dir" -maxdepth 3 -type f -path '*/openbox-3/themerc' -print0 2>/dev/null)
    done
    printf '%s\n' "${themes[@]}" | awk 'NF' | sort -fu
}

show_usage() {
    echo "Labwc Theme Switcher"
    echo "Usage: $0 [theme-name]"
    echo ""
    echo "Available themes:"
    get_available_themes | sed 's/^/  - /'
    echo ""
    echo "Examples:"
    echo "  $0 Vermello"
}

backup_configs() {
    mkdir -p "$BACKUP_DIR"
    if [ -f "$LABWC_XML" ]; then
        cp "$LABWC_XML" "$BACKUP_DIR/labwc.xml.backup"
    fi
    if [ -f "$RC_XML" ]; then
        cp "$RC_XML" "$BACKUP_DIR/rc.xml.backup"
    fi
}

apply_theme() {
    local theme_name="$1"
    if ! get_available_themes | grep -Fxq "$theme_name"; then
        echo "Error: Theme '$theme_name' not found."
        echo "Available themes:"
        get_available_themes
        exit 1
    fi

    backup_configs

    if command -v python3 >/dev/null 2>&1; then
        python3 - "$LABWC_XML" "$theme_name" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
theme_name = sys.argv[2]
if not path.exists():
    raise SystemExit(0)

s = path.read_text(encoding="utf-8", errors="replace")

pattern = re.compile(r"(<theme\b[^>]*>.*?<name>)(.*?)(</name>)", re.S)
if pattern.search(s):
    s = pattern.sub(r"\\1" + theme_name + r"\\3", s, count=1)
else:
    theme_open = re.compile(r"<theme\b[^>]*>")
    if theme_open.search(s):
        s = theme_open.sub(lambda m: m.group(0) + "\n    <name>" + theme_name + "</name>", s, count=1)
    else:
        root_open = re.compile(r"<labwc\b[^>]*>")
        if root_open.search(s):
            s = root_open.sub(lambda m: m.group(0) + "\n  <theme>\n    <name>" + theme_name + "</name>\n  </theme>", s, count=1)

path.write_text(s, encoding="utf-8")
PY

        python3 - "$RC_XML" "$theme_name" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
theme_name = sys.argv[2]
if not path.exists():
    raise SystemExit(0)

s = path.read_text(encoding="utf-8", errors="replace")

pattern = re.compile(r"(<theme\b[^>]*>.*?<name>)(.*?)(</name>)", re.S)
if pattern.search(s):
    s = pattern.sub(r"\\1" + theme_name + r"\\3", s, count=1)
else:
    theme_open = re.compile(r"<theme\b[^>]*>")
    if theme_open.search(s):
        s = theme_open.sub(lambda m: m.group(0) + "\n\t<name>" + theme_name + "</name>", s, count=1)

path.write_text(s, encoding="utf-8")
PY
    else
        echo "Error: python3 is required to switch themes."
        exit 1
    fi

    if command -v labwcctl >/dev/null 2>&1; then
        labwcctl reload
        echo "Theme '$theme_name' applied and Labwc reloaded"
    else
        echo "Theme '$theme_name' applied. Restart Labwc to see changes."
    fi
}

list_themes() {
    echo "Available themes:"
    get_available_themes
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
    
    apply_theme "$selected_theme"
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
        if [ -f "$BACKUP_DIR/labwc.xml.backup" ] || [ -f "$BACKUP_DIR/rc.xml.backup" ]; then
            if [ -f "$BACKUP_DIR/labwc.xml.backup" ]; then
                cp "$BACKUP_DIR/labwc.xml.backup" "$LABWC_XML"
            fi
            if [ -f "$BACKUP_DIR/rc.xml.backup" ]; then
                cp "$BACKUP_DIR/rc.xml.backup" "$RC_XML"
            fi
            if command -v labwcctl >/dev/null 2>&1; then
                labwcctl reload 2>/dev/null || echo "Restart Labwc to see changes"
            fi
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
