# Splinter Cell Goggles SWEP

A fully functional Garry's Mod SWEP inspired by *Tom Clancy's Splinter Cell* series, featuring advanced tactical vision systems with immersive gameplay mechanics.

## 🌟 Features

### 🎯 **Three Vision Modes**
- **Night Vision**: Enhanced low-light vision with authentic green tint and grain effect
- **Thermal Vision**: Heat signature detection with realistic line-of-sight blocking
- **Sonar Vision**: Wall-penetrating pulse detection with expanding rings and entity indicators

### ⚡ **Advanced Energy System**
- **Mode-Specific Drain**: Different energy consumption rates for each vision mode
- **Smart Recharge**: Automatic recharging when inactive with customizable delay
- **Low Energy Warnings**: Audio and visual alerts when energy is critically low
- **Auto-Shutdown**: Automatic deactivation when energy is depleted

### 🎮 **Intuitive Controls**
- **N Key**: Toggle goggles on/off
- **T Key**: Cycle through vision modes (Night Vision → Thermal → Sonar)
- **Primary Attack**: Alternative toggle method
- **Secondary Attack**: Alternative mode cycling

### 🎨 **Immersive HUD**
- **Mode Indicator**: Current vision mode display with description
- **Energy Bar**: Real-time energy meter with color-coded levels
- **Compass**: Cardinal direction indicator
- **Crosshair**: Optional center crosshair
- **Sonar Detections**: Real-time entity tracking with type indicators

### 🔧 **Comprehensive Settings System**
- **Vision Strength**: Adjust overall intensity of all vision modes
- **Grain Effects**: Customize night vision grain intensity
- **Thermal Sensitivity**: Control heat detection sensitivity
- **Sonar Range**: Adjust sonar detection distance
- **Energy Rates**: Customize drain and recharge multipliers
- **HUD Customization**: Toggle elements and adjust opacity
- **Color Themes**: Customize all vision mode colors
- **Sound Control**: Master volume and enable/disable audio

### 🔊 **Immersive Audio**
- **Mode-Specific Sounds**: Unique activation sounds for each vision mode
- **Sonar Ping**: Authentic sonar pulse sound effects
- **Energy Warnings**: Low energy alert sounds
- **Toggle Feedback**: Audio confirmation for all interactions

## 📦 Installation

### For Sandbox
1. Extract the addon to your `garrysmod/addons/` folder
2. Restart your server or use `lua_run_cl` to reload
3. Spawn the weapon using the spawn menu or console: `give splintercell_nvg`

### For DarkRP
1. Extract the addon to your `garrysmod/addons/` folder
2. The DarkRP integration will automatically load
3. Players can purchase from F4 menu under "Weapons"
4. Available for: Citizens, Police, Gang, Mob members

## Usage

### Basic Controls
- **Left Click**: Toggle goggles on/off
- **Right Click**: Cycle vision modes (Night Vision → Thermal → Sonar)
- **R Key**: Quick mode switch
- **Chat Commands**: Type `!goggles` for help

### Enhanced Features
- **Settings System**: Use `goggles_settings` in console to view settings
- **Sonar Detection**: Now properly detects and displays entities through walls
- **Battery Management**: More realistic power consumption and faster recharge
- **Audio Feedback**: Enhanced sound effects for all actions

### Vision Mode Details

#### Night Vision
- Best for general visibility in dark areas
- Medium battery consumption (0.2/s)
- Enhanced brightness boost
- Authentic scan lines and static

#### Thermal (IMPROVED)
- Detects heat signatures from players and NPCs
- **Body Highlighting**: Shows body outlines and head positions
- **Wall Detection**: Cannot see through walls (realistic thermal behavior)
- Higher battery drain (0.4/s)
- Useful for finding visible enemies

#### Sonar (ENHANCED)
- **Fixed Detection**: Now properly detects entities through walls
- **Body Highlighting**: Shows body outlines and head positions for players/NPCs
- **Wall Penetration**: Can detect entities behind walls with different colors
- **Enhanced Range**: 1000 units detection radius
- **Entity Type Indicators**: Shows what type of entity was detected
- **Multiple Pulse Rings**: Visual feedback with expanding circles
- **Detection Persistence**: Entities remain visible for 3 seconds
- **Medium battery consumption** (0.3/s)

## DarkRP Integration

### Purchasing
- **Individual**: 5,000 credits from F4 menu
- **Bulk**: 45,000 credits for 10 goggles (4,500 each)
- **Dealer**: 4,000 credits from weapon dealers

### Jobs
- **Splinter Cell Operative**: Custom job with goggles included
- **Weapon Dealer**: Can sell goggles to other players
- **Admin Commands**: `!givegoggles [player]` for admins

### Permissions
- Available to: Citizens, Police, Gang, Mob members
- Requires appropriate job permissions
- Admin privilege: `SplinterCell_Admin`

## Technical Details

### Network Messages
- `SplinterCell_Goggles_State`: Toggle state synchronization
- `SplinterCell_Goggles_Mode`: Mode change synchronization
- `SplinterCell_Sonar_Detection`: Enhanced sonar entity detection

### Performance
- Optimized rendering with modular functions
- Enhanced battery management system
- Minimal impact on server performance
- Client-side effects only when active

### Compatibility
- **Sandbox**: Full functionality
- **DarkRP**: Complete integration with F4 menu
- **Other Gamemodes**: Basic functionality available
- **No External Dependencies**: Uses only HL2/GMod assets

## Console Commands

### Client Commands
- `give splintercell_nvg`: Give yourself the goggles
- `!goggles`: Display help information
- `goggles_settings`: View current settings
- `goggles_info`: Show detailed status

### Admin Commands
- `!givegoggles [player]`: Give goggles to specified player
- Requires `SplinterCell_Admin` privilege

### Test Commands
- `test_goggles`: Give goggles for testing
- `goggles_battery <amount>`: Set battery level
- `goggles_toggle`: Toggle goggles on/off
- `goggles_mode`: Cycle through modes
- `goggles_sonar`: Trigger sonar pulse manually
- `goggles_sonar_test`: Test sonar detection display

## File Structure

```
splintercellnvgswep/
├── lua/
│   ├── weapons/
│   │   └── splintercell_nvg/
│   │       ├── init.lua          # Network setup
│   │       └── shared.lua        # Enhanced SWEP code
│   └── darkrp_custom/
│       └── splintercell_goggles.lua  # DarkRP integration
├── addon.json                    # Addon metadata
├── icon.jpg                      # Workshop icon
├── workshop_description.txt      # Workshop description
├── test_nvg.lua                  # Test commands
└── README.md                     # This file
```

## Troubleshooting

### Common Issues

1. **Goggles not appearing in F4 menu**
   - Ensure DarkRP is properly installed
   - Check that the DarkRP integration file is in the correct location
   - Restart the server after installation

2. **Vision effects not working**
   - Verify the weapon is properly spawned
   - Check that you're using the correct controls
   - Ensure battery is not depleted

3. **Sonar not detecting entities (FIXED)**
   - **Fixed in Enhanced Version**: Sonar now properly detects entities
   - Ensure you're in Sonar mode (mode 3)
   - Check that entities are within 1000 units range
   - Use `goggles_sonar_test` to verify detections

4. **Performance issues**
   - Reduce the intensity setting if needed
   - Disable the hex grid overlay for better performance
   - Check server resources during heavy usage

### Debug Commands
- `goggles_info`: Show detailed goggles status
- `goggles_sonar_test`: Display current sonar detections
- `goggles_settings`: View all settings
- `lua_run_cl PrintTable(LocalPlayer():GetActiveWeapon())`: Debug weapon state

## Enhanced Features Summary

### What's New in Enhanced Version:
- ✅ **Fixed Sonar Detection**: Now properly detects entities through walls
- ✅ **Improved Battery System**: Better drain rates and faster recharge
- ✅ **Enhanced Visual Effects**: Multiple pulse rings, entity type indicators
- ✅ **Better Audio Feedback**: More sound effects and volume control
- ✅ **Settings System**: Configurable options for customization
- ✅ **Low Battery Warnings**: Audio and visual alerts
- ✅ **Enhanced HUD**: Three-color battery system, better visual feedback
- ✅ **Improved Performance**: Optimized rendering and detection algorithms

## Credits

- **Author**: Splinter Cell Addon
- **Inspiration**: Splinter Cell series by Ubisoft
- **Compatibility**: Sandbox and DarkRP gamemodes
- **Version**: Enhanced Edition

## License

This addon is provided as-is for educational and entertainment purposes. Use at your own discretion.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Verify all files are in the correct locations
3. Ensure DarkRP is properly installed (if using DarkRP features)
4. Check server console for any error messages
5. Use the test commands to verify functionality

---

**Enjoy your tactical operations with the Enhanced Splinter Cell Goggles!**
