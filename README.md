# Splinter Cell Vision Goggles - DarkRP Enhanced

## Overview
Advanced vision goggles weapon for Garry's Mod with full DarkRP integration. Features multiple vision modes including Night Vision, Thermal Vision, Sonar Vision, and more.

## Features

### Vision Modes
- **Night Vision**: Enhanced visibility in darkness (Green overlay)
- **Thermal Vision**: See heat signatures through walls (Red overlay)
- **Sonar Vision**: Detect movement and objects (Blue overlay)
- **X-Ray Vision**: See through solid objects (Purple overlay)
- **Motion Detection**: Highlight moving targets (Yellow overlay)
- **EMP Vision**: Detect electronic devices (Cyan overlay)

### Controls
- **N**: Toggle vision modes on/off
- **T**: Cycle through different vision modes

### DarkRP Integration
- Custom Splinter Cell Operative job
- Custom Splinter Cell Commander job (VIP/Donator)
- F4 menu integration for purchasing goggles
- Shipment support for bulk purchases
- Chat commands for easy access
- Admin commands for management

## Installation

1. Extract the addon to your `garrysmod/addons/` folder
2. Restart your server
3. The weapon and jobs will be automatically available

## File Structure
```
lua/
├── weapons/
│   └── splinter_cell_vision.lua      # Main weapon file
└── darkrp_custom/
    └── splinter_cell_config.lua      # DarkRP configuration
```

## DarkRP Jobs

### Splinter Cell Operative
- **Salary**: $75
- **Max Players**: 3
- **Weapons**: Splinter Cell Vision Goggles, Pistol
- **Health**: 120 HP
- **Armor**: 50 AP

### Splinter Cell Commander (VIP)
- **Salary**: $100
- **Max Players**: 1
- **Weapons**: Splinter Cell Vision Goggles, Pistol, Stunstick
- **Health**: 150 HP
- **Armor**: 75 AP
- **Requires**: VIP/Donator status (customizable)

## Chat Commands
- `/togglevision` - Toggle vision modes
- `/cyclevision` - Cycle through vision modes

## Admin Commands
- `rp_givevision [player]` - Give vision goggles to a player

## Configuration

### Customizing VIP Check
Edit the `customCheck` function in `lua/darkrp_custom/splinter_cell_config.lua`:
```lua
customCheck = function(ply) 
    return ply:IsVIP() or ply:IsDonator() -- Replace with your VIP system
end
```

### Adjusting Prices
Modify the prices in the DarkRP configuration:
- Entity price: Currently $7,500
- Shipment price: Currently $67,500 (10 units)

### Team Permissions
Adjust the `allowed` teams in the configuration file to control which jobs can purchase the goggles.

## Requirements
- Garry's Mod
- DarkRP gamemode

## Support
- Compatible with DarkRP 2.5+
- Works with most popular DarkRP modifications
- Tested on Garry's Mod update 2023+

## Changelog
- **Latest**: Complete rewrite with enhanced DarkRP integration
- Removed old legacy files
- Added multiple vision modes
- Enhanced job system
- Improved user interface
- Added admin commands and chat integration