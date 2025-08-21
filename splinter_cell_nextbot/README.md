# Splinter Cell NextBot - Enhanced Tactical AI

A sophisticated NextBot AI that replicates the tactical stealth gameplay of Splinter Cell, featuring advanced AI states, movement styles, and tactical behaviors.

## 🎭 Identity

**Codename:** Echelon Operative  
**Personality:** Silent, patient, methodical — a hunter, not a berserker  
**Goal:** Outthink and outmaneuver players using real stealth and tactical methods

## 🔹 Core AI States & Behaviors

### 1. **PATROL** (Low Alert)
- **Movement Style:** Slow HL2 pistol walk anim (ACT_WALK_PISTOL)
- **Behaviors:**
  - Occasionally pauses in pistol idle anim (ACT_IDLE_PISTOL)
  - Breaks light sources to create cover
  - Keeps to shadows, walls, and alternative routes
  - NVG hum when scanning dark areas
  - Quiet radio whispers for atmosphere

### 2. **SUSPICIOUS** (Searching)
- **Movement Style:** HL2 pistol crouch-walk anim (ACT_WALK_CROUCH_PISTOL)
- **Triggers:** Footsteps, sprinting, doors, gunfire, thrown props
- **Behaviors:**
  - Alternates between crouch-walk and pistol idle
  - Aims weapon while sweeping corners
  - Investigates noise sources tactically (doesn't rush head-on)
  - Flashes NVG on/off while scanning
  - Builds a Suspicion Meter (if it reaches 100 → Hunt Mode)

### 3. **HUNT** (High Alert, Tactical Stalking)
- **Movement Style:** Mix of pistol walk + crouch-walk depending on cover
- **Behaviors:**
  - Uses walls, vents, and vertical traversal to flank
  - Uses cover-to-cover movement (never open-field rushing)
  - Tries to circle the player instead of beelining
  - Can rappel from ceilings/ledges for ambush
  - Will throw a flashbang or EMP if player holds a chokepoint

### 4. **ENGAGE** (Combat)
- **Weapons:** Suppressed pistol or SMG only
- **Movement Style:**
  - Fires from pistol idle anim stance
  - Crouch-walks during gunfights for smaller hitbox
  - Dodges side-to-side while shooting (combat evasive walk)
- **Behaviors:**
  - Prefers stealth melee takedown if behind the player
  - Aims for quick precision shots, not spray
  - Can blind player by breaking lights or using gadgets

### 5. **DISAPPEAR** (Reset/Retreat)
- **Movement Style:** Deploys smoke → crouch-walks backwards into shadows
- **Behaviors:**
  - Resets into patrol mode if player loses track
  - May leave fake noise (thrown object) to mislead
  - Will not re-engage immediately; stalks again for ambush

## 🔹 Tactical Abilities

### Light Manipulation
- Breaks lamps and bulbs to create stealth zones
- Prefers movement in shadows and dark areas
- Uses light levels to determine movement style

### Verticality
- Uses ladders, climbs ledges, rappels down ropes
- Can access rooftops and elevated positions
- Uses vertical traversal for tactical advantage

### Cover Usage
- Moves tactically between cover instead of open chase
- Finds optimal cover positions based on target location
- Uses cover-to-cover movement patterns

### Distractions
- Can toss objects or noise-makers to bait the player
- Creates fake noises to mislead during retreat
- Uses psychological warfare with whispers

### Suppression Tools
- Flashbangs, smoke, EMP grenades
- Tactical smoke deployment for cover and retreat
- Light manipulation for tactical advantage

## 🔹 Animation Blueprint

- **Idle:** ACT_IDLE_PISTOL (weapon ready, scanning stance)
- **Walk:** ACT_WALK_PISTOL (quiet movement with pistol)
- **Crouch Walk:** ACT_WALK_CROUCH_PISTOL (stealth advance)
- **Run:** ACT_RUN_PISTOL (only in emergencies)
- **Aim:** Gesture range attack (aiming stance)
- **Reload:** Gesture reload (tactical reload)
- **Death:** Silent collapse instead of dramatic ragdoll

## 🎮 Installation

1. Extract the `splinter_cell_nextbot` folder to your `garrysmod/addons/` directory
2. Restart your server or use `lua_run_cl` to reload
3. Use the spawn menu or console commands to spawn the NextBot

## 🎯 Console Commands

### Admin Commands
- `spawn_tactical_splinter_cell` - Spawn enhanced NextBot
- `test_tactical_states` - Cycle through AI states
- `test_tactical_abilities [nvg/smoke/stealth/movement/all]` - Test abilities
- `create_tactical_environment` - Create tactical environment
- `test_suspicion [0-100]` - Test suspicion system
- `test_combat [stance] [ammo] [grenades]` - Test combat mechanics
- `splinter_cell_help` - Show help

### Example Usage
```
spawn_tactical_splinter_cell
test_tactical_states
test_tactical_abilities all
create_tactical_environment
test_suspicion 75
test_combat crouching 15 1
```

## 🔧 Configuration

The NextBot uses a comprehensive configuration system with the following key parameters:

### Movement & Speed
- `PATROL_SPEED = 100` - Speed during patrol (slow pistol walk)
- `SUSPICIOUS_SPEED = 80` - Speed during suspicious state (crouch walk)
- `HUNT_SPEED = 120` - Speed during hunt (mix of walk/crouch)
- `ENGAGE_SPEED = 150` - Speed during engagement
- `DISAPPEAR_SPEED = 90` - Speed during disappear (crouch backwards)

### Detection & Stealth
- `STEALTH_RADIUS = 800` - Detection radius for stealth operations
- `SHADOW_PREFERENCE = 0.8` - Preference for dark areas (0-1)
- `SUSPICION_DECAY_RATE = 0.5` - Rate at which suspicion decreases
- `SUSPICION_INCREASE_RATE = 2.0` - Rate at which suspicion increases

### Combat & Tactics
- `TAKEDOWN_RANGE = 100` - Range for silent takedowns
- `WEAPON_RANGE = 500` - Maximum effective weapon range
- `COMBAT_ACCURACY_BASE = 0.85` - Base accuracy in combat
- `SMOKE_COOLDOWN = 8` - Cooldown for tactical smoke usage

## 🎨 Visual Effects

### Client-Side Features
- **Tactical Information Display:** Shows current state, objective, stealth level
- **Suspicion Meter:** Visual indicator of AI suspicion level
- **Movement Style Indicator:** Shows current animation state
- **Combat Status:** Displays ammo, grenades, and stance
- **Enhanced Particles:** Stealth particles that change color based on state
- **Night Vision Effects:** NVG glow and scanning effects
- **Smoke Effects:** Visual smoke deployment effects
- **Rappel Effects:** Rope and climbing visual effects

### State-Based Visual Feedback
- **PATROL:** Green particles, calm atmosphere
- **SUSPICIOUS:** Yellow particles, scanning effects
- **HUNT:** Orange particles, aggressive movement
- **ENGAGE:** Red particles, combat effects
- **DISAPPEAR:** Gray particles, retreat effects

## 🎭 Psychological Operations

### Whisper System
The NextBot uses psychological warfare through whispers:
- **PATROL:** "Area secure...", "No activity detected..."
- **SUSPICIOUS:** "Something's not right...", "I heard something..."
- **HUNT:** "I can see you...", "You're being hunted..."
- **ENGAGE:** "Engaging target...", "You're mine..."
- **DISAPPEAR:** "Disappearing...", "You'll never find me..."

### Screen Effects
- Screen shake based on tactical state
- Flash effects when using tactical grenades
- Visual distortion during high-intensity states

## 🔄 State Transitions

The AI follows a logical progression through states:

1. **PATROL** → **SUSPICIOUS** (when player activity detected)
2. **SUSPICIOUS** → **HUNT** (when suspicion reaches 100 or visual contact)
3. **HUNT** → **ENGAGE** (when close enough for takedown or compromised)
4. **ENGAGE** → **DISAPPEAR** (when health low or stealth compromised)
5. **DISAPPEAR** → **PATROL** (when safe to reset)

## 🎯 Tactical Features

### Advanced Navigation
- Navmesh integration for intelligent pathfinding
- Cover-to-cover movement patterns
- Vertical traversal capabilities
- Wall-following behavior

### Environmental Interaction
- Light source manipulation
- Cover object utilization
- Sound-based investigation
- Tactical positioning

### Combat Mechanics
- Precision shooting with accuracy decay
- Tactical reload system
- Burst fire capabilities
- Stealth takedown system

## 🐛 Troubleshooting

### Common Issues
1. **NextBot not moving:** Check if navmesh is generated for the map
2. **No visual effects:** Ensure client-side files are properly loaded
3. **Commands not working:** Verify admin privileges
4. **Performance issues:** Reduce particle effects or tactical update frequency

### Debug Commands
- `splinter_cell_help` - Show all available commands
- Check console for error messages
- Verify file structure in addons folder

## 📝 Changelog

### Version 2.0 - Enhanced Tactical AI
- **New AI States:** PATROL, SUSPICIOUS, HUNT, ENGAGE, DISAPPEAR
- **Enhanced Movement:** HL2 pistol animations with tactical variations
- **Suspicion System:** Dynamic suspicion meter with state transitions
- **Tactical Abilities:** Light manipulation, vertical traversal, cover usage
- **Psychological Ops:** Whisper system and screen effects
- **Visual Enhancements:** State-based particles and effects
- **Combat Mechanics:** Precision shooting and tactical reload
- **Environment Control:** Light breaking and tactical positioning

### Version 1.0 - Basic Implementation
- Initial NextBot implementation
- Basic AI behaviors
- Simple movement and combat

## 🤝 Contributing

Feel free to contribute to this project by:
- Reporting bugs and issues
- Suggesting new tactical features
- Improving AI behaviors
- Enhancing visual effects

## 📄 License

This project is open source and available under the MIT License.

---

**"The shadows are my allies, and silence is my weapon."** - Echelon Operative