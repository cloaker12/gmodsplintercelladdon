# Splinter Cell NextBot Improvements

## Bug Fixes

### 1. Fixed GetNextSegment Error
- **Issue**: `attempt to call method 'GetNextSegment' (a nil value)` error in pathfinding
- **Fix**: Added proper null checks in `IsPathBlocked()` function
- **Location**: Line 1041 in `init.lua`

### 2. Fixed T-Pose Animation Issues
- **Issue**: AI was getting stuck in T-pose due to invalid animation sequences
- **Fix**: Improved `PlayAnimation()` function with better fallback sequences
- **Changes**: Added proper sequence validation and fallback to sequence 0 if needed

### 3. Added Error Handling
- **Issue**: AI crashes when pathfinding fails
- **Fix**: Added `pcall()` error handling in AI cycle and navigation functions
- **Benefit**: AI will reset to safe state instead of crashing

## AI Improvements

### 1. Reduced Aimbotting
- **Changes**:
  - Reduced base accuracy from 85% to 65%
  - Reduced moving accuracy from 60% to 40%
  - Reduced cover accuracy from 95% to 75%
  - Added distance-based accuracy penalties
  - Added movement penalties to accuracy
  - Increased spread for more realistic shooting

### 2. Improved Pathfinding
- **Changes**:
  - Added alternative pathfinding with different parameters
  - Better error handling for invalid paths
  - Improved path validation

### 3. Less Aggressive Behavior
- **Changes**:
  - Reduced immediate threat detection range from 50 to 30 units
  - Added target change cooldown (3 seconds minimum between target changes)
  - Reduced stealth level penalties
  - Lower engagement thresholds
  - Added patience system for better decision making

### 4. Better Resource Management
- **Changes**:
  - Added proper cleanup in `OnRemove()` function
  - Timer cleanup to prevent memory leaks
  - Weapon entity cleanup

## New Features

### 1. NPC Spawn Menu Integration
- **File**: `lua/autorun/splinter_cell_npc.lua`
- **Feature**: AI can now be spawned from the NPC menu instead of entity spawner
- **Category**: "Splinter Cell" in NPC spawn menu
- **Access**: Available to all players (not admin-only)

### 2. Enhanced Error Recovery
- **Feature**: AI automatically resets to patrol state if errors occur
- **Benefit**: Prevents AI from getting stuck in broken states

## Configuration Changes

### Combat Accuracy (Reduced for less aimbotty behavior)
```lua
COMBAT_ACCURACY_BASE = 0.65,    -- Was 0.85
COMBAT_ACCURACY_MOVING = 0.4,   -- Was 0.6
COMBAT_ACCURACY_COVER = 0.75,   -- Was 0.95
```

### AI Behavior (More patient and less aggressive)
```lua
targetChangeCooldown = 3.0      -- New: Minimum time between target changes
engagementCooldown = 5.0        -- New: Cooldown before re-engaging
patienceLevel = 1.0             -- New: Affects decision making
```

## Usage

### Spawning the AI
1. Open the spawn menu (Q by default)
2. Go to the "NPCs" tab
3. Look for "Splinter Cell" category
4. Select "Splinter Cell Operative"
5. Click to spawn

### Console Command (Alternative)
```
npc_create nextbot_splinter_cell
```

## Technical Details

### Error Handling
- All AI functions now use `pcall()` for error handling
- Automatic state reset on errors
- Proper cleanup of resources

### Animation System
- Better sequence validation
- Fallback animations for missing sequences
- Prevents T-pose issues

### Pathfinding
- Multiple pathfinding attempts with different parameters
- Better validation of path objects
- Graceful fallback to direct movement

## Performance Improvements
- Reduced AI update frequency from 0.1s to 0.2s
- Better resource cleanup
- More efficient target selection
- Reduced unnecessary state changes