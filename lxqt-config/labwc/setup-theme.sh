#!/bin/bash

# Custom theme setup for labwc
# This creates a custom theme directory with better-looking decorations

THEME_DIR="$HOME/.local/share/themes/labwc-custom"

mkdir -p "$THEME_DIR"

cat > "$THEME_DIR/themerc" << 'EOF'
# Custom labwc theme - cleaner window decorations

# Window geometry
border.width: 2
padding.height: 8

# Active window colors
window.active.title.bg.color: #3584e4
window.active.handle.bg.color: #3584e4
window.active.border.color: #3584e4
window.active.title.fg.color: #ffffff
window.active.button.unpressed.image.color: #ffffff
window.active.button.hover.image.color: #e0e0e0

# Inactive window colors  
window.inactive.title.bg.color: #3d3d3d
window.inactive.handle.bg.color: #3d3d3d
window.inactive.border.color: #2d2d2d
window.inactive.title.fg.color: #a0a0a0
window.inactive.button.unpressed.image.color: #a0a0a0

# Menu
menu.border.width: 1
menu.border.color: #3584e4
menu.title.bg.color: #3584e4
menu.title.fg.color: #ffffff
menu.items.bg.color: #2d2d2d
menu.items.fg.color: #ffffff
menu.items.active.bg.color: #3584e4
menu.items.active.fg.color: #ffffff

# On-screen display
osd.border.width: 1
osd.border.color: #3584e4
osd.bg.color: #2d2d2d
osd.fg.color: #ffffff
osd.label.fg.color: #ffffff
EOF

echo "Custom theme created at: $THEME_DIR"
echo "To use it, update your rc.xml <theme><name> to: labwc-custom"
