# Enhanced Splinter Cell Tactical NVG System

## Overview
This is a complete overhaul of the Splinter Cell NVG system, transforming it from a basic vision enhancement tool into a military-grade tactical system with realistic features and advanced capabilities.

## 🔥 New Features

### 🎯 Four Advanced Vision Modes

#### 1. Night Vision (Enhanced)
- **Auto-brightness adjustment** based on environment
- **Bloom protection** against bright lights
- **Center focus enhancement** for better target acquisition
- **Temperature-based grain effects** that respond to system heat
- **Stealth mode compatibility** with reduced visual signatures

#### 2. Thermal Vision (Military Grade)
- **Temperature gradients** with realistic color mapping:
  - White hot (very high temp)
  - Yellow-white (high temp) 
  - Orange-red (medium-high temp)
  - Red (medium temp)
  - Dark red (low temp)
- **Heat trail tracking** showing movement paths of targets
- **Movement-based heat generation** (moving targets are hotter)
- **Combat state detection** (NPCs in combat generate more heat)
- **Distance-based heat attenuation** for realistic thermal fade
- **Enhanced targeting data** for high-value thermal contacts

#### 3. Sonar Vision (3D Mapping)
- **3D structural mapping** with multi-directional traces
- **Material detection and classification**:
  - Concrete, Metal, Wood, Glass, Plastic, Organic matter
  - Color-coded by material properties
  - Density-based visualization
- **Range rings** and **scanning line effects**
- **Surface normal indicators** showing wall orientations
- **Performance-optimized** with configurable point limits

#### 4. Enhanced Multi-Spectrum (NEW)
- **Combines all vision technologies**
- **Entity type classification**:
  - Yellow-white: Players (threat level 80)
  - Orange: NPCs (threat level 60)
  - Cyan: Weapons (threat level 40)
  - Purple: Vehicles (threat level 30)
- **Tactical grid overlay** for navigation assistance
- **Enhanced bloom and motion blur** effects
- **Multi-spectrum analysis** with comprehensive targeting

### 🔋 Realistic Power Management

#### Battery System
- **Separate battery from energy** for realistic power management
- **Mode-specific power drain**:
  - Night Vision: 0.3x drain rate
  - Thermal: 0.7x drain rate  
  - Sonar: 0.5x drain rate
  - Enhanced: 1.0x drain rate (highest consumption)
- **Low battery warnings** with audio alerts
- **Auto-shutdown** when battery depleted
- **Visual battery indicator** with color-coded status

#### System Temperature
- **Realistic thermal management** with overheating protection
- **Mode-based heat generation** 
- **Performance degradation** when overheating
- **Visual temperature warnings** with system alerts
- **Automatic cooling** when NVG is disabled

### 🎯 Advanced Tactical HUD

#### Left Panel - System Status
- **Real-time mode display** with descriptions
- **Battery level** with color-coded status bar
- **System temperature** monitoring
- **Overheating warnings** with flashing alerts

#### Right Panel - Tactical Information  
- **GPS coordinates** (X, Y, Z positioning)
- **Compass bearing** with cardinal directions
- **Threat level assessment** with color-coded warnings:
  - Green: Clear (0-10%)
  - Orange: Low Threat (10-30%)
  - Yellow: Moderate (30-60%)
  - Red: High Threat (60%+)
- **Environmental noise detection**
- **Stealth mode indicator**
- **Recording mode indicator**

#### Center HUD - Vision-Specific Data
- **Mode-specific information display**
- **Thermal contact counting**
- **Priority target identification**
- **Sonar mapping statistics**
- **Enhanced crosshair** with distance measurement

### 🔊 Audio Visualization System

#### Directional Sound Detection
- **Visual audio indicators** showing sound sources
- **Pulsing circles** with intensity-based sizing
- **Sound wave rings** emanating from sources
- **Directional arrows** pointing to audio sources
- **Distance measurement** for sound sources
- **Environmental audio meter** showing overall noise levels

#### Sound Source Analysis
- **Movement-based audio** (faster = louder)
- **Vehicle engine detection**
- **Weapon sound identification**
- **Configurable detection range** (default 800 units)

### 🥷 Stealth Integration

#### Stealth Mode (M Key)
- **Reduced visual signatures** for covert operations
- **Minimized HUD elements** 
- **Suppressed grain effects** for cleaner vision
- **Lower power consumption**
- **Tactical grid overlay disabled**

#### Environmental Awareness
- **Noise level monitoring** for situational awareness
- **Movement detection** for threat assessment
- **Audio-visual correlation** between sound and thermal signatures

### 🎮 Enhanced Controls

#### Primary Controls
- **N**: Toggle NVG system on/off
- **T**: Cycle through vision modes (4 modes)
- **M**: Toggle stealth mode
- **R**: Toggle recording/marking mode

#### Advanced Features
- **Battery management** with realistic drain rates
- **Temperature monitoring** with overheating protection
- **Threat assessment** with environmental scanning
- **Audio visualization** with directional indicators

### 🛠️ Debug and Testing Tools

#### Console Commands
- `sc_system_info` - Display comprehensive system status
- `sc_debug_thermal` - Debug thermal vision with entity analysis
- `sc_debug_sonar` - Debug sonar system with material breakdown
- `sc_debug_audio` - Debug audio visualization system
- `sc_reset_system` - Reset all systems to default state
- `sc_toggle_stealth` - Quick stealth mode toggle
- `sc_simulate_overheat` - Test overheating protection
- `sc_force_threat [0-100]` - Set specific threat level for testing

#### Client ConVars
- `sc_vision_strength` - Vision effect intensity (0.1-2.0)
- `sc_energy_drain` - Energy consumption rate (0.1-2.0)
- `sc_energy_recharge` - Energy recharge rate (0.1-3.0)
- `sc_threat_detection` - Enable/disable threat assessment
- `sc_heat_trails` - Enable/disable thermal heat trails
- `sc_audio_visual` - Enable/disable audio visualization
- `sc_auto_adjust` - Enable/disable auto-brightness
- `sc_stealth_mode` - Force stealth mode on/off
- `sc_tactical_hud` - Enable/disable tactical HUD overlay

## 🎯 Tactical Applications

### Military Operations
- **Reconnaissance** with enhanced thermal tracking
- **Surveillance** with heat trail analysis
- **Navigation** with 3D sonar mapping
- **Threat assessment** with multi-spectrum analysis

### Stealth Missions
- **Covert infiltration** with stealth mode
- **Silent observation** with reduced signatures
- **Environmental awareness** with audio detection
- **Tactical movement** with noise monitoring

### Combat Support
- **Target identification** with thermal classification
- **Distance measurement** for engagement planning
- **Threat prioritization** with assessment system
- **Situational awareness** with comprehensive HUD

## 📊 Performance Optimization

### Efficient Rendering
- **Distance-based LOD** for thermal and sonar systems
- **Configurable entity limits** to maintain FPS
- **Smart update frequencies** to reduce CPU usage
- **Memory management** for trail and mapping data

### Customizable Settings
- **Adjustable detection ranges** for different scenarios
- **Scalable visual effects** for various hardware
- **Configurable update rates** for performance tuning
- **Optional features** that can be disabled

## 🔧 Installation & Usage

1. **Place file** in `lua/darkrp_customthings/` directory
2. **Restart server** or reload lua files
3. **Join Splinter Cell team** to access abilities
4. **Use N key** to activate NVG system
5. **Cycle modes with T key** for different vision types
6. **Use M for stealth** and R for recording mode
7. **Check console** for debug commands and system info

## 🎯 Team Integration

### Compatible Teams
- `TEAM_SPLINTERCELL` - Standard Splinter Cell operatives
- `TEAM_SPLINTERCOMMANDER` - Command-level access

### Network Synchronization
- **Server-side validation** for all mode changes
- **Client-side prediction** for smooth operation  
- **Automatic state sync** every second when active
- **Disconnect cleanup** to prevent memory leaks

## 🚀 Future Enhancements

### Planned Features
- **Team data sharing** between Splinter Cell members
- **Waypoint marking system** for tactical coordination
- **Environmental interference** (EMP, weather effects)
- **Advanced recording** with playback capabilities
- **Mission-specific overlays** and objective markers

This enhanced NVG system transforms the basic vision goggles into a comprehensive tactical system worthy of elite special operations units. Every feature has been designed with realism, immersion, and tactical effectiveness in mind.