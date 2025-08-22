# Operation Shadow Strike - Cartel Convoy Interdiction

A tactical callout system featuring a complex multi-phase black operation against a cartel weapons convoy.

## 🎯 Mission Overview

**Code Name:** Operation Shadow Strike  
**Classification:** Black Operation  
**Objective:** Intercept cartel weapons convoy before it reaches their fortified compound

### Mission Briefing
*"Shadow Unit, satellite confirms a cartel convoy moving heavy weapons toward their stronghold. This is a black operation. Suppressed weapons only. An allied Ghost team will insert from an Annihilator 2 helicopter to support your ambush. Objective: intercept and neutralize the convoy before it reaches the base. If they make it, you'll breach the compound. Silent if possible, lethal if required."*

## 🚁 Features

### Allied Ghost Team Support
- **Annihilator 2 Helicopter Insertion**: Stealth approach with no lights
- **4-6 Ghost Operatives**: Equipped with suppressed weapons
- **Rooftop Sniper**: Overwatch support with suppressed sniper rifle
- **Tactical Communications**: "On station", "Target down", "Stacking up"
- **Cover-to-Cover Movement**: Advanced AI tactical behavior

### Convoy System
- **Formation Driving**: Tight convoy formation with realistic spacing
- **Dynamic AI**: Accelerates when attacked, calls reinforcements
- **Vehicle Types**: Lead SUV (scouts), 2x Cargo Trucks (contraband), Rear SUV (heavy weapons)
- **Escalation**: Reinforcement SUVs respond to firefights

### Fortified Compound
- **Guard Towers**: Snipers with overwatch positions
- **Perimeter Patrols**: Armed guards with AKs and shotguns
- **Generator System**: Destroy for blackout effect
- **Multiple Infiltration Paths**: Ghost, Panther, or Assault approaches

### Stealth Mechanics
- **Night Vision Toggle**: Press `N` for NVGs
- **Suppressed Weapons**: Ghost team uses only suppressed firearms
- **Blackout System**: Generator destruction disables compound lighting
- **Synchronized Strikes**: Coordinate with Ghost team for simultaneous engagement

## 🎮 Mission Phases

### Phase 1: Intercept
- Set ambush point along convoy route
- **Silent Strike**: Synchronized suppressed fire with operatives
- **Loud Strike**: Firefight triggers reinforcements

### Phase 2A: Success (Convoy Stopped)
- Secure contraband and evidence
- Optional: Capture cartel commander alive
- Helicopter extraction preparation

### Phase 2B: Failure (Convoy Escapes)
- Breach fortified compound (75m radius)
- Multiple approach options:
  - **Ghost**: Generator blackout → NVG stealth takedowns
  - **Panther**: Aggressive stealth with suppressed rapid clearing
  - **Assault**: Loud approach with heavy firefight

### Phase 3: Cartel Leader
- Located in compound safehouse
- Equipped with radio jammer (disables minimap)
- Protected by bodyguards
- **Capture alive** = intel bonus, **eliminate** = partial success

### Phase 4: Extraction
- Annihilator 2 returns for pickup
- Load operatives and evidence
- Choice: Escort convoy to safe zone OR board helicopter

## 🏆 Success Types

- **Ghost Success**: Silent operation, convoy seized, leader captured
- **Panther Success**: Partial stealth, leader eliminated  
- **Assault Success**: Loud firefight, limited intel recovered
- **Failure**: Convoy escapes or operatives compromised

## 🎯 Controls

| Key | Action |
|-----|--------|
| `E` | Signal synchronized strike (when Ghost team ready) |
| `N` | Toggle night vision |

## 📋 Commands

| Command | Description |
|---------|-------------|
| `/start_convoy_mission` | Initialize Operation Shadow Strike |
| `/end_convoy_mission` | Terminate active mission |
| `/convoy_status` | Check mission status and cooldown |
| `/convoy_help` | Display help and controls |
| `/toggle_auto_callouts` | Enable/disable automatic random callouts |

## 🛠️ Installation

1. Place `cartel_convoy_callout.lua` in your resources folder
2. Place `init_callout.lua` in your resources folder  
3. Add to your `server.cfg`:
   ```
   ensure cartel_convoy_callout
   ensure init_callout
   ```
4. Restart your server
5. Type `/convoy_help` in-game for commands

## ⚙️ Configuration

### Convoy Route
Edit `CONVOY_ROUTE` waypoints in `cartel_convoy_callout.lua`:
```lua
local CONVOY_ROUTE = {
    vector3(-2000.0, 4000.0, 30.0),  -- Start position
    vector3(-1800.0, 4200.0, 35.0),  -- Waypoint 1
    vector3(-1600.0, 4400.0, 40.0),  -- Waypoint 2
    vector3(-1500.0, 4500.0, 50.0)   -- Compound entrance
}
```

### Compound Location
Adjust compound center coordinates:
```lua
center = vector3(-1500.0, 4500.0, 50.0)
```

### Cooldown Times
Modify in `init_callout.lua`:
```lua
cooldownTime = 300000, -- 5 minutes between callouts
```

## 🚛 Vehicle & Weapon Loadouts

### Cartel Equipment
- **Vehicles**: Baller2 (lead), Mule3 (cargo), Dubsta2 (rear), Kuruma (reinforcements)
- **Weapons**: Assault Rifles, Pump Shotguns, Micro SMGs, MG, Sniper Rifles, RPG

### Ghost Team Equipment  
- **Helicopter**: Annihilator 2 (black ops livery, no lights)
- **Weapons**: Suppressed SMG Mk2, Carbine Rifle Mk2, Combat Pistol, Pistol .50, Sniper Rifle
- **Behavior**: High combat ability, cover-to-cover movement, high alertness

## 🎬 Cinematic Moments

- **Helicopter Insertion**: Rappel animation with tactical communications
- **Blackout Event**: Generator destruction triggers lighting blackout with NVG filter
- **Synchronized Takedown**: Ghost team awaits player signal for coordinated strike
- **Extraction Sequence**: Cinematic helicopter dust-off with "This mission never happened"

## 🔧 Technical Features

- **Entity Management**: Automatic cleanup of all spawned vehicles, peds, and objects
- **Mission State Tracking**: Comprehensive phase management and success/failure detection
- **AI Behavior**: Advanced NPC combat and movement patterns
- **Performance Optimized**: Efficient resource usage with proper entity disposal

## 🆘 Troubleshooting

**Mission won't start:**
- Check if another callout is active: `/convoy_status`
- Ensure cooldown period has passed
- Verify script installation and server restart

**Ghost team not deploying:**
- Wait 15 seconds after mission start for helicopter insertion
- Check console for any error messages

**Convoy not moving:**
- Verify convoy route coordinates are valid for your map
- Check if convoy vehicles were destroyed during spawn

## 📝 Notes

- Mission coordinates may need adjustment for different maps
- Audio system uses placeholder notifications (can be enhanced with custom audio)
- Suppressor components automatically added to Ghost team weapons
- Mission supports both single-player and multiplayer environments

---

**Classification Level:** EYES ONLY  
**Authorized Personnel:** Shadow Unit Operatives  
**Distribution:** Need-to-Know Basis

*"This mission never happened."*