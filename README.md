# LXQt + Labwc Openbox Style Configuration

A complete configuration setup that combines LXQt desktop environment with Labwc window manager, styled to look and feel like Openbox.

## Overview

This repository provides configuration files to create a lightweight, Openbox-styled desktop environment using:
- **LXQt** - Lightweight Qt-based desktop environment
- **Labwc** - Wayland compositor inspired by Openbox
- **Openbox styling** - Classic look and feel with modern Wayland support

## Features

- Openbox-style window decorations and themes
- Lightweight and fast performance
- Wayland support with modern compositing
- Custom menu system with dynamic generation
- Panel and desktop configuration
- Autostart applications management
- Theme customization scripts

## Installation

### Prerequisites

Ensure you have the following packages installed:
```bash
# Arch Linux
sudo pacman -S lxqt labwc

# Debian/Ubuntu
sudo apt install lxqt labwc
```

### Setup

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

4. Set up the session:
```bash
# Copy session files if needed
cp labwc-config/xinitrc ~/.xinitrc
```

## Configuration Files

### Labwc Configuration (`labwc-config/`)

- `labwc.xml` - Main Labwc configuration
- `rc.xml` - Window manager settings and keybindings
- `menu.xml` - Application menu configuration
- `themerc` - Theme configuration
- `themerc-override` - Theme customizations
- `autostart` - Applications to launch on startup
- `environment` - Environment variables
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

### Menu Generation

To regenerate the application menu:
```bash
~/.config/labwc/menu-generator.sh
```

### Theme Switching

To apply theme changes:
```bash
~/.config/labwc/setup-theme.sh
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
