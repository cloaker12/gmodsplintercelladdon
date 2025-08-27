# Splinter Cell Vision SWEP - Installation & Usage Guide

## Installation

1. Navigate to your Garry's Mod addons folder:
   - Windows: `Steam\steamapps\common\GarrysMod\garrysmod\addons`
   - Mac: `~/Library/Application Support/Steam/steamapps/common/GarrysMod/garrysmod/addons`
   - Linux: `~/.steam/steam/steamapps/common/GarrysMod/garrysmod/addons`

2. Create a new folder called `splinter_cell_vision`

3. Inside that folder, create the following structure:
   ```
   splinter_cell_vision/
   ├── lua/
   │   └── weapons/
   │       └── splinter_cell_vision.lua
   └── addon.json
   ```

4. Copy the `splinter_cell_vision.lua` file into the `lua/weapons/` folder

5. Create `addon.json` with the following content:
   ```json
   {
       "title": "Splinter Cell Vision SWEP",
       "type": "weapon",
       "tags": ["fun", "roleplay"],
       "ignore": []
   }
   ```

## Usage

### Spawning the Weapon
1. Start Garry's Mod
2. Load any map
3. Open the spawn menu (Q)
4. Go to the "Weapons" tab
5. Look under "Splinter Cell" category
6. Click on "Splinter Cell Vision Goggles"

### Controls
- **N Key**: Toggle vision on/off
- **T Key**: Cycle through vision modes (when vision is active)

### Vision Modes

1. **Night Vision**
   - Green tint with massively enhanced brightness for dark areas
   - Animated grain effect for realism
   - Advanced bloom and sharpen effects
   - Automatic light amplification in extremely dark conditions
   - Fog override for better long-range visibility
   - Perfect for nighttime and pitch-black environments

2. **Thermal Vision**
   - Heat signatures displayed in orange/red
   - Living entities (players, NPCs) show as hot (bright)
   - Dead entities show as cooling (dim)
   - Vehicles and moving props show medium heat
   - Static props show as cold (dark)

3. **Sonar Vision**
   - Periodic sonar pulses with sound effects
   - Highlights entities through walls briefly
   - Blue-tinted vision with scanline effects
   - Useful for detecting hidden enemies and objects

### Energy System
- Energy bar displays in the top-right corner
- Energy drains while vision is active
- Energy recharges when vision is off
- Vision automatically deactivates when energy depletes
- Bar color indicates energy level:
  - Green: >60% energy
  - Yellow: 30-60% energy
  - Red: <30% energy

### Customization (Client Console Commands)

- `sc_vision_strength [0.1-2]` - Adjust vision effect intensity
- `sc_energy_drain [0.1-2]` - Energy drain rate per second
- `sc_energy_recharge [0.1-3]` - Energy recharge rate per second
- `sc_sonar_interval [0.5-5]` - Time between sonar pulses
- `sc_grain_amount [0-1]` - Night vision grain effect intensity
- `sc_night_brightness [0.5-2]` - Night vision brightness boost for extreme darkness

### Features

- **Multiplayer Optimized**: All effects are client-side for optimal performance
- **Smooth Transitions**: Professional fade effects between modes
- **Immersive Audio**: Each mode has unique activation sounds
- **HUD Integration**: Clean UI showing current mode and energy status
- **Performance Friendly**: Optimized rendering with minimal FPS impact
- **Realistic Effects**: 
  - Night vision includes grain and bloom
  - Thermal vision calculates entity heat dynamically
  - Sonar vision uses halos for wall penetration effect

### Tips

1. Conserve energy by toggling vision off when not needed
2. Thermal vision is most effective for spotting living targets
3. Sonar vision's pulse can reveal enemies behind cover
4. Night vision works best in completely dark areas
5. Adjust settings to match your preference and hardware

### Troubleshooting

- If the weapon doesn't appear, ensure file paths are correct
- If vision effects don't work, check that you're running the latest GMod version
- For performance issues, reduce `sc_vision_strength` value
- If sounds don't play, verify GMod sound settings

### Technical Details

- Uses AddCSLuaFile for proper client/server architecture
- Implements proper cleanup on weapon removal
- Energy system uses frame-independent timing
- All visual effects use GMod's built-in rendering systems
- Compatible with all gamemodes