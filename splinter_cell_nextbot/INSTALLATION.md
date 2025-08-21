# Splinter Cell NextBot AI - Installation Guide

## Quick Installation

1. **Extract the addon** to your `garrysmod/addons/` directory
2. **Restart your server** or use `lua_run` to reload
3. **Spawn the NextBot** from the NPCs tab in the spawn menu

## Detailed Installation Steps

### For Server Administrators

1. **Download and Extract**
   - Download the `splinter_cell_nextbot` folder
   - Extract it to `garrysmod/addons/splinter_cell_nextbot/`

2. **File Structure Verification**
   Ensure your file structure looks like this:
   ```
   garrysmod/addons/splinter_cell_nextbot/
   ├── addon.txt
   ├── lua/
   │   └── entities/
   │       └── nextbot_splinter_cell/
   │           ├── shared.lua
   │           ├── init.lua
   │           └── cl_init.lua
   └── test_ai.lua
   ```

3. **Server Restart**
   - Restart your Garry's Mod server
   - Or use `lua_run` to reload the addon

4. **Verification**
   - Check console for any error messages
   - The NextBot should appear in the NPCs spawn menu

### For Single Player

1. **Install as above**
2. **Load a map** (preferably one with good navmesh)
3. **Spawn the NextBot** from the NPCs tab

## Usage Instructions

### Spawning the NextBot

1. **Open Spawn Menu** (Q by default)
2. **Navigate to NPCs tab**
3. **Find "Splinter Cell Operative"**
4. **Click to spawn**

### Testing the AI

Run these console commands to test the AI:

```lua
-- Load test script
lua_run "include('splinter_cell_nextbot/test_ai.lua')"

-- Spawn test NextBot
lua_run TestSplinterCellAI()

-- Check all NextBots
lua_run CheckAllNextBots()

-- Run stress test
lua_run StressTestAI()
```

### Client-side Testing

```lua
-- Test client effects
lua_run_cl TestClientEffects()

-- Test whisper system
lua_run_cl TestWhisperEffects()
```

## Configuration

### Tactical Settings

Edit `init.lua` to modify AI behavior:

```lua
local TACTICAL_CONFIG = {
    STEALTH_RADIUS = 800,           -- Detection range
    ENGAGEMENT_RANGE = 400,         -- Combat distance
    TAKEDOWN_RANGE = 100,          -- Silent takedown range
    RETREAT_HEALTH = 50,            -- Health to trigger retreat
    SHADOW_PREFERENCE = 0.8,        -- Preference for dark areas
    PATIENCE_TIMER = 5,             -- State change patience
    SMOKE_COOLDOWN = 15,            -- Smoke grenade cooldown
    LIGHT_DISABLE_RANGE = 300,      -- Light manipulation range
    WHISPER_RADIUS = 200,           -- Psychological ops range
    FLASH_RANGE = 150               -- Flash effect range
}
```

### Performance Optimization

For better performance on busy servers:

```lua
-- Reduce detection ranges
STEALTH_RADIUS = 600,
LIGHT_DISABLE_RANGE = 200,

-- Increase AI update intervals
-- Edit the timer in StartAICycle() function
timer.Create("SplinterCellAI_" .. self:EntIndex(), 0.2, 0, function()
```

## Troubleshooting

### Common Issues

**NextBot doesn't appear in spawn menu**
- Check file permissions
- Verify all files are in correct locations
- Restart server completely

**NextBot doesn't move or behave correctly**
- Ensure map has navmesh (`nav_generate` in console)
- Check console for error messages
- Verify NextBot is spawned on solid ground

**Client effects not working**
- Check network string registration
- Verify client files are loaded
- Restart client if needed

**Performance issues**
- Reduce number of simultaneous NextBots
- Lower detection ranges in configuration
- Increase AI update intervals

### Console Commands

```lua
-- Generate navmesh for current map
nav_generate

-- Enable navmesh editing
nav_edit 1

-- Target all Splinter Cell NextBots
ent_fire nextbot_splinter_cell

-- Enable developer console
developer 1

-- Check for errors
lua_openscript_cl splinter_cell_nextbot/test_ai.lua
```

### Error Messages

**"Attempt to call method 'GetPos' on a nil value"**
- NextBot entity is invalid
- Check if entity was removed

**"Path API error"**
- Map lacks proper navmesh
- Run `nav_generate` in console

**"Network string not found"**
- Client files not loaded properly
- Restart client

## Advanced Features

### Custom Models

To use different models:

1. **Change model in `shared.lua`:**
   ```lua
   ENT.Model = "models/your_custom_model.mdl"
   ```

2. **Adjust collision bounds:**
   ```lua
   self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 72))
   ```

### Custom Sounds

Add custom sounds by modifying the sound paths in `init.lua`:

```lua
-- Takedown sound
self:EmitSound("your_custom_sound.wav", 75, 100)

-- Suppressed shot sound
self:EmitSound("your_suppressed_shot.wav", 50, 100)
```

### Integration with Other Addons

The NextBot is designed to work with:
- **DRGBase** - Enhanced display integration
- **Custom weapon packs** - Compatible with most weapon systems
- **Map-specific addons** - Adapts to different environments

## Support

### Getting Help

1. **Check console** for error messages
2. **Verify installation** using test script
3. **Test on different maps** to isolate issues
4. **Check file permissions** and paths

### Reporting Issues

When reporting issues, include:
- Garry's Mod version
- Server/client setup
- Error messages from console
- Steps to reproduce the issue
- Map being used

### Performance Tips

- **Limit NextBots** to 2-3 per map
- **Use maps with navmesh** for better pathfinding
- **Monitor server performance** when using multiple NextBots
- **Adjust configuration** based on server capabilities

## Version History

### Version 1.0
- Initial release with full stealth AI system
- Advanced pathfinding and movement
- Client-side effects and HUD
- Psychological operations system
- Environmental manipulation features
- Enhanced NextBot lifecycle functions
- Improved client-side visual effects
- Comprehensive testing framework

---

**Enjoy your tactical stealth operations!**