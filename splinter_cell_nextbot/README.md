# Splinter Cell NextBot - Advanced Edition

A sophisticated stealth-focused NextBot featuring advanced AI behaviors inspired by Splinter Cell agents. This advanced version includes improved animations, combat system, tactical AI, and special abilities like smoke grenades, decoys, and cloaking.

## Features

### 🎭 **Model & Animations**
- **Model**: `models/splinter_cell_3/player/Sam_E.mdl` (Sam Fisher from Splinter Cell 3)
- **Bodygroup**: Goggles enabled (bodygroup 1 set to 1)
- **Animations**: 
  - Idle animation with proper pose parameters
  - Walking animation with movement detection
  - Aiming animation during combat
  - Fixed T-posing issues with proper animation system

### 🔫 **Weapon System**
- **Weapon Model**: `models/weapons/w_fiveseven_ct.mdl` (suppressed Five-Seven)
- **Dynamic Weapon Positioning**: Weapon adjusts position based on animation state
- **Suppressed Combat**: Silent takedowns and suppressed shots
- **Accuracy System**: 
  - Accuracy decreases with rapid firing
  - Recovers over time when not shooting
  - Realistic spread based on accuracy level

### 🧠 **Advanced AI**
- **Enhanced Detection**: 
  - Visual contact detection
  - Flashlight detection
  - Sound-based detection
  - Movement-based detection
  - Environmental awareness
- **Advanced Tactical States** (9 total):
  - Idle Reconnaissance
  - Investigation
  - Stalking
  - Ambush
  - Suppressed Engagement
  - Tactical Retreat
  - Evade & Hide
  - Setup Ambush
  - Tactical Reposition
- **Stealth System**: 
  - Light level awareness
  - Stealth level management
  - Environmental interaction
  - Automatic cloaking in shadows

### 🎮 **Sandbox Integration**
- **NPCs Tab**: Appears in the NPCs tab in sandbox mode
- **Spawnable**: Can be spawned through the spawn menu
- **Admin Spawnable**: Available to administrators

### 🎯 **Special Abilities**
- **Smoke Grenade**: Creates smoke screen for tactical advantage
- **Decoy**: Deploys noise-making decoy to distract enemies
- **Cloak**: Automatically activates in shadow areas for stealth
- **Enhanced Navigation**: Better pathfinding and tactical positioning
- **Strafing Combat**: Moves while shooting for realistic combat

## Installation

1. Extract the `splinter_cell_nextbot` folder to your `garrysmod/addons/` directory
2. Restart your server or reload the addon
3. The NPC will appear in the NPCs tab in the spawn menu

## Usage

### Spawning
- Open the spawn menu (Q by default)
- Navigate to the NPCs tab
- Select "Splinter Cell Operative"
- Click to spawn

### Console Commands
```lua
-- Spawn via console
ent_create nextbot_splinter_cell

-- Test script
lua_run_file("splinter_cell_nextbot/test_npc.lua")
```

## Technical Details

### AI States
1. **IDLE_RECON**: Patrolling and gathering intelligence
2. **INVESTIGATE**: Moving toward detected activity
3. **STALKING**: Tracking target from cover
4. **AMBUSH**: Executing silent takedown
5. **ENGAGE_SUPPRESSED**: Firing from cover with suppressed weapon
6. **RETREAT_RESET**: Breaking contact and repositioning

### Combat Mechanics
- **Range**: Maximum effective range of 500 units
- **Damage**: 35 damage per shot
- **Cooldown**: 0.5 seconds between shots
- **Accuracy**: Starts at 100%, decreases with firing, recovers over time
- **Aim Time**: 1 second to aim before shooting (less aimbot-like)
- **Strafing**: Moves side-to-side during combat
- **Realistic Spread**: Based on accuracy, distance, and movement

### Stealth Features
- **Light Awareness**: Detects and avoids bright areas
- **Sound Distractions**: Creates environmental noise
- **Psychological Ops**: Whispers and flash effects
- **Environmental Control**: Disables nearby light sources
- **Automatic Cloaking**: Becomes transparent in shadow areas
- **Tactical Evasion**: Finds hiding spots and sets up ambushes

## Configuration

The NPC uses several configuration parameters that can be adjusted in the code:

```lua
local TACTICAL_CONFIG = {
    STEALTH_RADIUS = 800,           -- Detection radius
    ENGAGEMENT_RANGE = 400,         -- Optimal engagement distance
    TAKEDOWN_RANGE = 100,          -- Silent takedown range
    WEAPON_RANGE = 500,             -- Maximum weapon range
    ACCURACY_DECAY = 0.1,           -- Accuracy loss per shot
    RECOVERY_TIME = 2.0,            -- Accuracy recovery time
    CLOAK_LIGHT_THRESHOLD = 0.3,    -- Light level for cloak activation
    DECOY_COOLDOWN = 30,            -- Decoy cooldown time
    STRAFE_SPEED = 150,             -- Strafing speed during combat
    AIM_TIME = 1.0,                 -- Time to aim before shooting
    MAX_SPREAD = 200,               -- Maximum shot spread
    MIN_SPREAD = 50                 -- Minimum shot spread
}
```

## Troubleshooting

### Common Issues
1. **Model Not Loading**: Ensure the Splinter Cell model is installed
2. **T-Posing**: The animation system should prevent this, but if it occurs, try respawning the NPC
3. **Weapon Not Visible**: Check that the weapon model exists in your server

### Performance
- The NPC uses efficient pathfinding and AI cycles
- Animation updates are optimized for smooth performance
- Weapon rendering is handled efficiently

## Credits

- **Model**: Splinter Cell 3 Sam Fisher model
- **Weapon**: Counter-Strike Five-Seven model
- **AI Framework**: Based on NextBot system
- **Development**: AI Assistant

## Version History

### v1.2 (Advanced Edition)
- ✅ Added smoke grenade ability with entity creation
- ✅ Added decoy ability (noise-making distraction)
- ✅ Added automatic cloaking in shadow areas
- ✅ Enhanced navigation with 9 AI states
- ✅ Improved combat with strafing and realistic shooting
- ✅ Less aimbot-like behavior with aim time and spread
- ✅ Better evasion and ambush capabilities
- ✅ Enhanced tactical positioning and cover usage

### v1.1 (Enhanced Edition)
- ✅ Updated to Splinter Cell 3 Sam Fisher model
- ✅ Added goggles bodygroup
- ✅ Fixed T-posing with proper animation system
- ✅ Implemented walking and idle animations
- ✅ Added Five-Seven suppressed weapon
- ✅ Enhanced combat and detection systems
- ✅ Improved accuracy and weapon mechanics
- ✅ Better sandbox integration

### v1.0 (Original)
- Initial release with basic stealth AI
- Combine soldier model
- Basic tactical behaviors