# Splinter Cell AI NextBot - Complete Working Version

## Overview
This is a complete, working Splinter Cell AI NextBot for Garry's Mod that features advanced tactical AI behavior, stealth mechanics, and realistic Splinter Cell-style gameplay.

## Features

### Core AI Behavior
- **Advanced State Machine**: 9 different AI states (Patrol, Suspicious, Hunt, Engage, Disappear, etc.)
- **Stealth Mechanics**: Light level detection, shadow preference, silent movement
- **Tactical Combat**: Cover usage, precision shooting, tactical retreats
- **Environmental Control**: Light source manipulation, smoke grenades
- **Psychological Operations**: Radio whispers, NVG effects, intimidation tactics

### Movement & Animation
- **Realistic Movement**: Slow pistol walk, crouch-walk, tactical positioning
- **Proper NextBot Integration**: Uses Garry's Mod's NextBot framework correctly
- **Pathfinding**: Advanced navigation with fallback systems
- **Animation System**: Smooth transitions between different movement states

### Combat System
- **Silent Takedowns**: Stealth melee attacks from behind
- **Suppressed Weapons**: Realistic shooting mechanics with accuracy decay
- **Tactical Positioning**: Cover usage and flanking maneuvers
- **Smoke Grenades**: Tactical smoke deployment for cover and retreat

### Environmental Interaction
- **Light Control**: Automatically disables nearby light sources
- **Shadow Navigation**: Prefers dark areas for movement
- **Vertical Traversal**: Wall climbing and alternative routes
- **Night Vision**: Enhanced vision in darkness

## Installation

### 1. File Structure
Ensure your files are organized as follows:
```
splinter_cell_nextbot/
├── lua/
│   ├── autorun/
│   │   └── splinter_cell_npc.lua
│   └── entities/
│       └── nextbot_splinter_cell/
│           ├── init.lua
│           ├── cl_init.lua
│           └── shared.lua
├── test_working_bot.lua
└── WORKING_BOT_README.md
```

### 2. Installation Steps
1. Copy the `splinter_cell_nextbot` folder to your Garry's Mod addons directory
2. Restart your server or reload the addon
3. The bot will be available as `nextbot_splinter_cell`

## Usage

### Spawning the Bot
```lua
-- Console command
ent_create nextbot_splinter_cell

-- Lua command
local bot = ents.Create("nextbot_splinter_cell")
bot:SetPos(Vector(0, 0, 0))
bot:Spawn()
```

### Testing the Bot
```lua
-- Run the test script
lua_run_file("splinter_cell_nextbot/test_working_bot.lua")
```

### Bot Commands
- **Spawn**: `ent_create nextbot_splinter_cell`
- **Test**: `lua_run_file('splinter_cell_nextbot/test_working_bot.lua')`
- **Status Check**: `lua_run('PrintTable(Entity(1):GetNWVars())')`

## AI Behavior States

### 1. Patrol State
- **Behavior**: Low alert, stealth movement
- **Movement**: Slow pistol walk animation
- **Actions**: Disables lights, prefers shadows, occasional scanning
- **Transitions**: Moves to Suspicious when player activity detected

### 2. Suspicious State
- **Behavior**: Searching, investigating noises
- **Movement**: Crouch-walk animation, weapon aiming
- **Actions**: Builds suspicion meter, investigates tactically
- **Transitions**: Moves to Hunt when visual contact established

### 3. Hunt State
- **Behavior**: High alert, tactical stalking
- **Movement**: Mix of walk/crouch based on light level
- **Actions**: Uses cover, vertical traversal, enhanced navigation
- **Transitions**: Moves to Engage when close enough for takedown

### 4. Engage State
- **Behavior**: Combat engagement
- **Movement**: Tactical positioning, cover usage
- **Actions**: Silent takedowns, precision shooting, tactical retreats
- **Transitions**: Moves to Disappear when compromised or low health

### 5. Disappear State
- **Behavior**: Reset/retreat with smoke
- **Movement**: Crouch-walk backwards
- **Actions**: Uses smoke grenades, finds escape routes
- **Transitions**: Returns to Patrol when safe

## Configuration

### Tactical Settings
The bot's behavior can be customized by modifying the `TACTICAL_CONFIG` table in `init.lua`:

```lua
local TACTICAL_CONFIG = {
    STEALTH_RADIUS = 800,           -- Detection radius
    ENGAGEMENT_RANGE = 400,         -- Optimal engagement distance
    TAKEDOWN_RANGE = 100,          -- Range for silent takedowns
    RETREAT_HEALTH = 50,            -- Health threshold for retreat
    PATROL_SPEED = 100,             -- Patrol movement speed
    HUNT_SPEED = 120,               -- Hunt movement speed
    -- ... more settings
}
```

### AI States
The bot uses 9 different AI states that can be modified in the `AI_STATES` table:

```lua
local AI_STATES = {
    PATROL = 1,
    SUSPICIOUS = 2,
    HUNT = 3,
    ENGAGE = 4,
    DISAPPEAR = 5,
    WALL_CLIMBING = 6,
    EVASIVE_MANEUVER = 7,
    TACTICAL_SMOKE = 8,
    NIGHT_VISION_HUNT = 9
}
```

## Troubleshooting

### Bot Not Moving
1. Check if the bot spawned correctly
2. Verify NextBot framework is working
3. Check console for error messages
4. Ensure the bot has valid movement targets

### Bot Not Detecting Players
1. Check `STEALTH_RADIUS` setting
2. Verify player visibility calculations
3. Check light level detection
4. Ensure proper line of sight calculations

### Animation Issues
1. Verify model file exists
2. Check animation sequence names
3. Ensure proper animation transitions
4. Check for T-pose issues

## Performance Optimization

### Server Performance
- The bot uses efficient NextBot framework
- Minimal network traffic
- Optimized pathfinding
- Efficient state machine

### Client Performance
- Minimal client-side processing
- Efficient networking
- Optimized effects and sounds

## Credits

This bot is based on the Splinter Cell series and implements realistic tactical AI behavior. The bot features:

- Advanced stealth mechanics
- Realistic combat behavior
- Environmental interaction
- Psychological operations
- Tactical positioning and movement

## Support

For issues or questions:
1. Check the console for error messages
2. Verify file structure and installation
3. Test with the provided test script
4. Check NextBot framework compatibility

## Version History

### v1.0 - Complete Working Version
- Fixed all movement issues
- Added missing AI functions
- Implemented proper NextBot integration
- Added comprehensive testing
- Complete stealth and combat systems