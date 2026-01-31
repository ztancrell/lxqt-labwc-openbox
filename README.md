# LXQt + Labwc Openbox Style Configuration

A complete configuration setup that combines LXQt desktop environment with Labwc window manager, styled to look and feel like Openbox.

## Overview

This repository provides configuration files to create a lightweight, Openbox-styled desktop environment using:
- **LXQt** - Lightweight Qt-based desktop environment
- **Labwc** - Wayland compositor inspired by Openbox
- **Openbox styling** - Classic look and feel with modern Wayland support

## New Features (Updated)

### Theme System
- **20+ Color Schemes**: Nord, Dracula, Catppuccin, Gruvbox, Tokyo Night, and more
- **Theme Switcher**: Easy command-line theme switching with `theme-switcher.sh`
- **Dynamic Theming**: Instant theme changes without restart

### Consolidated Configuration
- **Unified Config**: Single `labwc-consolidated.xml` replaces conflicting configs
- **Consistent Keybindings**: Standardized shortcuts across all applications
- **Resolved Conflicts**: Fixed theme and keybinding inconsistencies

### Enhanced Menu System
- **Dynamic Generation**: Automatic application menu updates
- **Clean Interface**: Streamlined menu without footer clutter
- **Easy Updates**: One-command menu regeneration

### Installation Tools
- **Automated Installer**: `install.sh` handles everything automatically
- **Safe Backups**: Automatic backup of existing configurations
- **Session Integration**: Creates desktop session entries

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

- `labwc-consolidated.xml` - **NEW**: Unified configuration file
- `labwc.xml` - Main Labwc configuration (now uses consolidated config)
- `rc.xml` - Window manager settings (now uses consolidated config)
- `menu.xml` - Application menu configuration
- `themerc` - Theme configuration
- `themerc-override` - Theme customizations
- `autostart` - Applications to launch on startup
- `theme-switcher.sh` - **NEW**: Theme switching utility
- `menu-update.sh` - **NEW**: Simple menu update utility
- `colors/` - **NEW**: 20+ pre-made color schemes
- `*.xbm` - Window button bitmaps
- `menu-generator.*` - Dynamic menu generation scripts

### LXQt Configuration (`lxqt-config/`)

- `panel.conf` - Panel configuration
- `globalkeyshortcuts.conf` - Global keyboard shortcuts
- `lxqt.conf` - Main LXQt settings
- `session.conf` - Session management
- `windowmanagers.conf` - Window manager integration

### Scripts

- `setup-theme.sh` - Theme setup script
- `gtk.sh` - GTK theme configuration
- `menu-generator.py` - Python menu generator
- `device-monitor.sh` - Device monitoring script

## Customization

### Theme Customization

Edit the following files to customize the appearance:
- `labwc-config/themerc` - Main theme settings
- `labwc-config/themerc-override` - Theme overrides
- `labwc-config/colors/` - Color schemes

### Menu Customization

The menu can be customized by:
1. Editing `labwc-config/menu.xml` directly
2. Using the menu generator: `./menu-generator.sh`
3. Modifying `menu-generator.py` for custom menu logic

### Keybindings

Edit `labwc-config/rc.xml` to modify keyboard shortcuts and mouse actions.

### Panel Configuration

Edit `lxqt-config/panel.conf` to customize the LXQt panel layout and applets.

## Usage

### Starting the Session

1. From a display manager (SDDM, LightDM, etc.) - Select "LXQt" session
2. From command line:
   ```bash
   startlxqt
   ```
3. With custom xinitrc:
   ```bash
   startx ~/.xinitrc
   ```

### Theme Management

#### Interactive Theme Switching
```bash
~/.config/labwc/theme-switcher.sh --interactive
```

#### Command Line Theme Switching
```bash
# Switch to specific theme
~/.config/labwc/theme-switcher.sh nord
~/.config/labwc/theme-switcher.sh dracula
~/.config/labwc/theme-switcher.sh catppuccin

# List available themes
~/.config/labwc/theme-switcher.sh --list

# Restore previous theme
~/.config/labwc/theme-switcher.sh --restore
```

#### System-wide Theme Switching (if installed)
```bash
labwc-theme nord
labwc-theme --list
```

### Menu Management

#### Update Application Menu
```bash
~/.config/labwc/menu-update.sh
```

#### Advanced Menu Generation (with rofi)
```bash
~/.config/labwc/menu-generator.sh
```

### Configuration Management

#### Reload Configuration
```bash
# Reload Labwc settings
labwcctl reload

# Or use keybinding: W-Shift-c
```

#### View Available Themes
```bash
ls ~/.config/labwc/colors/*.color | sed 's|.*/||' | sed 's|\.color||'
```

## Troubleshooting

### Common Issues

1. **Menu not updating**: Run the menu generator script
2. **Theme not applying**: Check permissions on theme files and run setup script
3. **Keybindings not working**: Verify syntax in `rc.xml`
4. **Panel not showing**: Check LXQt session configuration

### Logs

Check the following logs for debugging:
- Labwc: `~/.local/share/labwc/labwc.log`
- LXQt: `~/.local/share/lxqt/lxqt-session.log`
- X11/Wayland: `.xsession-errors`

## File Structure

```
lxqt-labwc-openbox/
├── labwc-config/          # Labwc window manager configs
│   ├── labwc.xml         # Main configuration
│   ├── rc.xml            # Keybindings and settings
│   ├── menu.xml          # Application menu
│   ├── themerc           # Theme configuration
│   ├── autostart         # Startup applications
│   └── *.sh              # Setup scripts
├── lxqt-config/           # LXQt desktop environment configs
│   ├── panel.conf        # Panel settings
│   ├── lxqt.conf         # Main LXQt config
│   └── *.conf            # Various LXQt components
├── scripts/               # Additional utility scripts
├── docs/                  # Documentation
└── README.md             # This file
```

## Contributing

Feel free to submit issues and pull requests to improve this configuration set.

## License

This configuration is provided as-is. Feel free to modify and redistribute according to your needs.

## Credits

- LXQt Project - Lightweight Qt desktop environment
- Labwc Project - Openbox-inspired Wayland compositor
- Openbox - Original inspiration for the window management style
