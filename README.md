# LXQt + Labwc Openbox Style Configuration

A minimal, Openbox-inspired Wayland desktop using LXQt and Labwc. Clean, fast, and keyboard-driven.

## Overview

This repository provides a complete configuration for a lightweight Wayland desktop:
- **Labwc** - Wayland compositor inspired by Openbox
- **LXQt** - Lightweight Qt-based panel and session
- **Vermello Theme** - Clean red/black Openbox-style decorations
- **Right-click Menu** - Openbox-style desktop menu with app categories and session controls

## Features

### Minimal Desktop
- **No desktop icons** - Clean, distraction-free workspace
- **Taskbar only** - Panel shows running apps, tray, clock (no app menu or quicklaunch)
- **Right-click menu** - All app launching via Openbox-style desktop menu

### Vermello Theme
- **Server-side decorations** - Consistent titlebars across all apps
- **Red titlebar** - Active windows with Vermello red (#ea545c)
- **Minimal borders** - Clean look with subtle outlines

### Openbox-Style Menu
- **App categories** - Editors, Games, Graphics, Internet, Multimedia, Office, Settings, System, Utilities
- **Quick launch** - Terminal, File Manager, Web Browser at top level
- **Config submenu** - Reconfigure Labwc, Update Menu, Sync GTK Theme, Restart Portals, Edit configs
- **Session submenu** - Lock, Suspend, Hibernate, Log Out, Reboot, Shutdown

### Systemd Integration
- **Menu updates** - Automatic periodic menu regeneration (every 30 min)
- **GTK sync** - Applies GTK dark theme on login
- **Portal restart** - Ensures file dialogs work correctly
- **Theme watcher** - Auto-reconfigures Labwc when theme files change

### Installation
- **Automated installer** - `install.sh` handles everything
- **Safe backups** - Existing configs backed up automatically
- **XDG autostart** - Proper integration with LXQt session

## Quick Start

### Automated Installation (Recommended)

```bash
# Clone and install
git clone <repository-url>
cd lxqt-labwc-openbox
./install.sh
```

The installer will:
- Backup your existing configurations
- Install all configuration files
- Set up proper permissions
- Generate initial application menu
- Create desktop session entry

### Manual Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd lxqt-labwc-openbox
```

2. Backup existing configurations:
```bash
mv ~/.config/labwc ~/.config/labwc.bak
mv ~/.config/lxqt ~/.config/lxqt.bak
```

3. Install the configurations:
```bash
# Copy Labwc configuration
cp -r labwc-config/* ~/.config/labwc/

# Copy LXQt configuration  
cp -r lxqt-config/* ~/.config/lxqt/

# Make scripts executable
chmod +x ~/.config/labwc/*.sh
chmod +x ~/.config/labwc/menu-generator.*
```

## Configuration Files

### Labwc Configuration (`labwc-config/`)

- `labwc.xml` - Main Labwc configuration (theme, keybinds, menu)
- `rc.xml` - Window manager settings
- `menu.xml` - Generated application menu
- `autostart` - Startup applications (wallpaper, clipboard, notifications, idle)
- `labwc-autostart.desktop` - XDG autostart entry for LXQt integration
- `menu-generator.py` - Dynamic menu generator with categories
- `menu-update.sh` - Regenerate menu from installed apps
- `*.xbm` - Window button bitmaps

### LXQt Configuration (`lxqt-config/`)

- `panel.conf` - Minimal panel (taskbar, tray, clock only)
- `session.conf` - Session settings (Labwc compositor, GTK settings)
- `lxqt.conf` - Main LXQt settings

### Themes (`themes/`)

- `Vermello/` - Default red/black Openbox theme

## Customization

### Theme Customization

Edit `themes/Vermello/openbox-3/themerc` to customize:
- Titlebar colors
- Menu colors and borders
- Button styling

### Menu Customization

Regenerate menu after installing new apps:
```bash
~/.config/labwc/menu-update.sh
```

Edit `menu-generator.py` to customize:
- Quick launch items (Terminal, File Manager, Browser)
- Session submenu items
- App category filtering

### Keybindings

Edit `labwc-config/labwc.xml` under `<keyboard>` section. Default bindings:
- `Super+Return` - Terminal
- `Super+D` - Fuzzel launcher
- `Super+Q` - Close window
- `Super+F` - Fullscreen
- `Super+Space` - Show menu

## Usage

### Starting the Session

1. From display manager - Select **"LXQt + Labwc"** (Wayland session)
2. Or select **"LXQt"** for X11 fallback

### Common Tasks

Menu updates happen automatically via systemd timer. For manual actions, use the **Config** submenu from right-click menu, or:

```bash
# Reload Labwc config
labwc --reconfigure
```

## Troubleshooting

### Common Issues

1. **White titlebar on some apps** - App is using client-side decorations (CSD). Add to app config:
   - Alacritty: `window.decorations: none` in `~/.config/alacritty/alacritty.yml`
   - GTK apps: Set `GTK_CSD=0` in environment

2. **Right-click menu not showing** - pcmanfm-qt is capturing desktop. The autostart kills it automatically.

3. **Menu not updating** - Use Config → Update Menu, or run `~/.config/labwc/menu-update.sh`

4. **Double panel** - LXQt starts its own panel; don't add lxqt-panel to autostart.

## File Structure

```
lxqt-labwc-openbox/
├── install.sh             # Automated installer
├── labwc-config/          # Labwc compositor configs
│   ├── labwc.xml          # Main config (theme, keybinds, menu)
│   ├── autostart          # Startup apps
│   ├── menu-generator.py  # Menu generator
│   ├── menu-update.sh     # Regenerate menu
│   └── labwc-autostart.desktop  # XDG autostart for LXQt
├── lxqt-config/           # LXQt panel/session configs
│   ├── panel.conf         # Minimal taskbar
│   └── session.conf       # Session settings
├── themes/                # Openbox themes
│   └── Vermello/          # Default red/black theme
└── README.md
```

## Contributing

Feel free to submit issues and pull requests to improve this configuration set.

## License

This configuration is provided as-is. Feel free to modify and redistribute according to your needs.

## Credits

- LXQt Project - Lightweight Qt desktop environment
- Labwc Project - Openbox-inspired Wayland compositor
- Openbox - Original inspiration for the window management style
