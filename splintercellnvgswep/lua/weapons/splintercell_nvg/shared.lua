-- ============================================================================
-- Splinter Cell Goggles SWEP
-- ============================================================================
-- A fully functional tactical night vision system inspired by Splinter Cell
-- Features three vision modes with immersive HUD and customizable settings

SWEP.PrintName = "Splinter Cell Goggles"
SWEP.Author = "Splinter Cell Tactical"
SWEP.Instructions = "N: Toggle Goggles | T: Cycle Modes | Fully customizable vision system"
SWEP.Category = "Splinter Cell"

-- SWEP Configuration
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5 -- Utility slot
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

-- Weapon Properties
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

-- ============================================================================
-- VISION MODES CONFIGURATION
-- ============================================================================

-- Three vision modes inspired by Splinter Cell
SWEP.VisionModes = {
    [1] = {
        name = "Night Vision",
        description = "Enhanced low-light vision with green tint",
        color = Color(0, 255, 0, 255),
        overlayStrength = 0.7,
        grainEffect = true,
        brightnessBoost = 3.0,
        energyDrain = 0.8, -- Energy per second
        soundEffect = "buttons/button9.wav"
    },
    [2] = {
        name = "Thermal Vision",
        description = "Heat signature detection",
        color = Color(255, 140, 0, 255),
        overlayStrength = 0.8,
        heatDetection = true,
        brightnessBoost = 1.2,
        energyDrain = 1.2, -- Higher drain for advanced detection
        soundEffect = "buttons/button10.wav"
    },
    [3] = {
        name = "Sonar Vision",
        description = "Pulse-based wall-penetrating detection",
        color = Color(0, 200, 255, 255),
        overlayStrength = 0.6,
        sonarPulse = true,
        brightnessBoost = 1.0,
        energyDrain = 1.0, -- Medium drain for sonar
        soundEffect = "buttons/button15.wav"
    }
}

-- ============================================================================
-- ENERGY SYSTEM
-- ============================================================================

SWEP.Energy = 100
SWEP.MaxEnergy = 100
SWEP.EnergyRechargeRate = 0.5 -- Energy per second when inactive
SWEP.EnergyRechargeDelay = 2 -- Seconds before recharge starts
SWEP.LowEnergyThreshold = 20 -- Warning threshold

-- ============================================================================
-- CUSTOMIZABLE SETTINGS
-- ============================================================================

SWEP.DefaultSettings = {
    -- Vision Settings
    visionStrength = 1.0, -- Overall vision intensity multiplier
    nightVisionGrain = 0.5, -- Grain effect intensity for night vision
    thermalSensitivity = 1.5, -- Heat detection sensitivity (increased for better visibility)
    sonarRange = 800, -- Sonar detection range in units
    sonarPulseInterval = 1.5, -- Seconds between sonar pulses (faster for better responsiveness)

    -- Energy Settings
    energyDrainMultiplier = 1.0, -- Multiply all energy drain rates
    energyRechargeMultiplier = 1.0, -- Multiply recharge rate
    autoRecharge = true, -- Auto-recharge when inactive
    lowEnergyWarning = true, -- Show low energy warning

    -- HUD Settings
    showModeIndicator = true, -- Show current mode in HUD
    showEnergyBar = true, -- Show energy bar
    showCompass = true, -- Show compass
    overlayOpacity = 0.8, -- HUD overlay opacity
    crosshairEnabled = true, -- Show center crosshair

    -- Sound Settings
    soundEnabled = true, -- Enable sound effects
    soundVolume = 0.7, -- Master sound volume
    toggleSound = "buttons/button14.wav",
    warningSound = "buttons/button16.wav",

    -- Color Customization
    nightVisionColor = Color(0, 255, 0), -- Green tint
    thermalHotColor = Color(255, 255, 255), -- Hot areas (white-hot)
    thermalColdColor = Color(0, 20, 60), -- Cold areas (very dark blue)
    sonarColor = Color(0, 200, 255), -- Sonar pulse color
    hudColor = Color(255, 255, 255) -- HUD text color
}

-- ============================================================================
-- SYSTEM STATE
-- ============================================================================

SWEP.GogglesActive = false
SWEP.CurrentMode = 1
SWEP.LastEnergyUpdate = 0
SWEP.LastSonarPulse = 0
SWEP.SonarDetections = {}
SWEP.LastRechargeTime = 0
SWEP.Settings = table.Copy(SWEP.DefaultSettings)

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

function SWEP:Initialize()
    self:SetHoldType("normal")

    -- Initialize system state
    self.GogglesActive = false
    self.CurrentMode = 1
    self.Energy = self.MaxEnergy
    self.LastEnergyUpdate = CurTime()
    self.LastSonarPulse = CurTime()
    self.SonarDetections = {}
    self.LastRechargeTime = 0

    -- Ensure settings are properly copied
    self.Settings = table.Copy(self.DefaultSettings)

    -- Bind keys for controls
    if CLIENT then
        self:BindKeys()
    end
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "GogglesActive")
    self:NetworkVar("Int", 0, "CurrentMode")
    self:NetworkVar("Float", 0, "Energy")
    self:NetworkVar("Float", 1, "VisionStrength")
    self:NetworkVar("Float", 2, "EnergyDrainMultiplier")
end

-- ============================================================================
-- KEY BINDING SYSTEM
-- ============================================================================

function SWEP:BindKeys()
    -- Bind 'N' key for toggling goggles
    if input.LookupBinding("nvg_toggle") == nil then
        self.ToggleKey = KEY_N
    else
        self.ToggleKey = input.GetKeyCode(input.LookupBinding("nvg_toggle"))
    end

    -- Bind 'T' key for cycling modes
    if input.LookupBinding("nvg_cycle") == nil then
        self.CycleKey = KEY_T
    else
        self.CycleKey = input.GetKeyCode(input.LookupBinding("nvg_cycle"))
    end
end

-- ============================================================================
-- CONTROLS AND INPUT HANDLING
-- ============================================================================

function SWEP:PrimaryAttack()
    -- Primary attack toggles goggles on/off
    if not IsFirstTimePredicted() then return end

    if self.GogglesActive then
        self:DeactivateGoggles()
    else
        self:ActivateGoggles()
    end

    self:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:SecondaryAttack()
    -- Secondary attack cycles through vision modes
    if not IsFirstTimePredicted() then return end

    if self.GogglesActive then
        self:CycleVisionMode()
    end

    self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:Reload()
    -- Reload also cycles modes for convenience
    if not IsFirstTimePredicted() then return end

    if self.GogglesActive then
        self:CycleVisionMode()
    end
end

-- ============================================================================
-- VISION MODE MANAGEMENT
-- ============================================================================

function SWEP:CycleVisionMode()
    -- Cycle through the three vision modes
    self.CurrentMode = self.CurrentMode + 1
    if self.CurrentMode > 3 then
        self.CurrentMode = 1
    end

    -- Play mode change sound
    if SERVER and self.Settings.soundEnabled then
        local modeSound = self.VisionModes[self.CurrentMode].soundEffect
        if modeSound then
            self.Owner:EmitSound(modeSound, 75, 100, self.Settings.soundVolume)
        end
    end

    -- Notify client of mode change
    if SERVER then
        net.Start("SplinterCell_Goggles_Mode")
        net.WriteInt(self.CurrentMode, 8)
        net.Send(self.Owner)
    end
end

function SWEP:ActivateGoggles()
    -- Check if we have enough energy
    if self.Energy <= 0 then
        if SERVER then
            self.Owner:ChatPrint("Goggles: Insufficient energy!")
            if self.Settings.soundEnabled and self.Settings.warningSound then
                self.Owner:EmitSound(self.Settings.warningSound, 75, 100, self.Settings.soundVolume)
            end
        end
        return
    end

    -- Activate goggles
    self.GogglesActive = true
    self.LastRechargeTime = 0

    -- Play activation sound
    if SERVER and self.Settings.soundEnabled then
        local modeSound = self.VisionModes[self.CurrentMode].soundEffect
        if modeSound then
            self.Owner:EmitSound(modeSound, 75, 100, self.Settings.soundVolume)
        end
    end

    -- Notify client
    if SERVER then
        net.Start("SplinterCell_Goggles_State")
        net.WriteBool(true)
        net.WriteInt(self.CurrentMode, 8)
        net.Send(self.Owner)
    end
end

function SWEP:DeactivateGoggles()
    -- Deactivate goggles
    self.GogglesActive = false
    self.LastRechargeTime = CurTime()

    -- Play deactivation sound
    if SERVER and self.Settings.soundEnabled then
        if self.VisionModes[self.CurrentMode] and self.VisionModes[self.CurrentMode].soundEffect then
            self.Owner:EmitSound(self.VisionModes[self.CurrentMode].soundEffect, 75, 100, self.Settings.soundVolume)
        end
    end

    -- Notify client
    if SERVER then
        net.Start("SplinterCell_Goggles_State")
        net.WriteBool(false)
        net.Send(self.Owner)
    end
end

-- ============================================================================
-- ENERGY MANAGEMENT SYSTEM
-- ============================================================================

function SWEP:UpdateEnergy()
    local currentTime = CurTime()

    -- Only update energy once per second for performance
    if currentTime - self.LastEnergyUpdate < 1 then return end
    self.LastEnergyUpdate = currentTime

    if self.GogglesActive and self.Energy > 0 then
        -- Drain energy based on current vision mode
        local currentMode = self.VisionModes[self.CurrentMode]
        if currentMode then
            local drainRate = currentMode.energyDrain * self.Settings.energyDrainMultiplier
            self.Energy = math.max(0, self.Energy - drainRate)

            -- Low energy warning
            if self.Energy <= self.LowEnergyThreshold and not self.LowEnergyWarned then
                if SERVER then
                    if self.Settings.lowEnergyWarning then
                        self.Owner:ChatPrint("WARNING: Energy critically low!")
                    end
                    if self.Settings.soundEnabled and self.Settings.warningSound then
                        self.Owner:EmitSound(self.Settings.warningSound, 75, 100, self.Settings.soundVolume)
                    end
                end
                self.LowEnergyWarned = true
            elseif self.Energy > self.LowEnergyThreshold then
                self.LowEnergyWarned = false
            end

            -- Auto-shutdown when energy is depleted
            if self.Energy <= 0 then
                if SERVER then
                    self.Owner:ChatPrint("Energy depleted! Goggles shutting down.")
                end
                self:DeactivateGoggles()
            end
        end
    elseif not self.GogglesActive and self.Settings.autoRecharge and self.Energy < self.MaxEnergy then
        -- Recharge energy when inactive
        if self.LastRechargeTime > 0 and currentTime - self.LastRechargeTime >= self.EnergyRechargeDelay then
            local rechargeRate = self.EnergyRechargeRate * self.Settings.energyRechargeMultiplier
            self.Energy = math.min(self.MaxEnergy, self.Energy + rechargeRate)
        end
    end
end

function SWEP:GetEnergyPercentage()
    return (self.Energy / self.MaxEnergy) * 100
end

function SWEP:CanActivateGoggles()
    return self.Energy > 0
end

-- ============================================================================
-- SONAR SYSTEM
-- ============================================================================

function SWEP:UpdateSonar()
    if not self.GogglesActive or self.CurrentMode ~= 3 then
        self.SonarDetections = {}
        return
    end

    local currentTime = CurTime()

    -- Trigger sonar pulse at specified intervals
    if currentTime - self.LastSonarPulse >= self.Settings.sonarPulseInterval then
        self:TriggerSonarPulse()
        self.LastSonarPulse = currentTime
    end

    -- Clean up old detections
    for entity, detectionTime in pairs(self.SonarDetections) do
        if currentTime - detectionTime > 3.0 then -- Detections last 3 seconds
            self.SonarDetections[entity] = nil
        end
    end
end

function SWEP:TriggerSonarPulse()
    if SERVER then
        -- Play sonar ping sound
        if self.Settings.soundEnabled then
            self.Owner:EmitSound("buttons/button15.wav", 75, 100, self.Settings.soundVolume)
        end

        -- Find entities within sonar range (enhanced for better detection)
        local entities = ents.FindInSphere(self.Owner:GetPos(), self.Settings.sonarRange)
        local detectionCount = 0
        
        for _, ent in pairs(entities) do
            if self:IsSonarDetectable(ent) then
                -- Store detection time
                self.SonarDetections[ent] = CurTime()
                detectionCount = detectionCount + 1

                -- Send sonar detection to client
                net.Start("SplinterCell_Sonar_Detection")
                net.WriteEntity(ent)
                net.WriteVector(ent:GetPos())
                net.WriteFloat(CurTime())
                net.Send(self.Owner)
            end
        end
        
        -- Debug feedback to owner
        if detectionCount > 0 then
            self.Owner:ChatPrint("Sonar detected " .. detectionCount .. " entities")
        else
            self.Owner:ChatPrint("No sonar detections in range")
        end
    end
end

function SWEP:IsSonarDetectable(ent)
    if not IsValid(ent) or ent == self.Owner then return false end

    -- Enhanced detection criteria for sonar - detects through walls
    if ent:IsPlayer() then
        return true -- Always detect other players
    elseif ent:IsNPC() then
        return true -- Always detect NPCs
    elseif ent:GetClass():find("weapon_") then
        return true -- Detect weapons
    elseif ent:IsVehicle() then
        return true -- Detect vehicles
    elseif ent:GetClass():find("prop_physics") then
        -- Detect physics props of reasonable size (lowered threshold)
        local mins, maxs = ent:GetCollisionBounds()
        local size = (maxs - mins):Length()
        return size > 20 -- Lowered threshold for more detections
    elseif ent:GetClass():find("func_door") or ent:GetClass():find("prop_door") then
        return true -- Detect doors
    elseif ent:GetClass():find("npc_") then
        return true -- Detect any NPC type
    elseif ent:GetClass():find("nextbot") then
        return true -- Detect NextBot NPCs
    elseif ent:GetClass():find("sent_") then
        return true -- Detect SENTs (scripted entities)
    elseif ent:GetClass():find("grenade") or ent:GetClass():find("explosive") then
        return true -- Detect explosives
    elseif ent:GetClass():find("item_") then
        return true -- Detect items
    elseif ent:GetClass():find("prop_") then
        return true -- Detect most props
    elseif ent:GetClass():find("func_") then
        return true -- Detect functional entities
    elseif ent:GetMoveType() == MOVETYPE_VPHYSICS then
        return true -- Detect physics entities
    end

    return false
end

-- ============================================================================
-- MAIN THINK FUNCTION
-- ============================================================================

function SWEP:Think()
    if not IsValid(self.Owner) then return end

    -- Update energy system
    self:UpdateEnergy()

    -- Update sonar system if active
    self:UpdateSonar()
    
    -- Ensure proper networking synchronization
    if SERVER and self.GogglesActive then
        -- Send periodic updates to ensure client stays synchronized
        local currentTime = CurTime()
        if not self.LastNetworkUpdate or currentTime - self.LastNetworkUpdate > 1.0 then
            self.LastNetworkUpdate = currentTime
            
            net.Start("SplinterCell_Goggles_State")
            net.WriteBool(self.GogglesActive)
            net.WriteInt(self.CurrentMode, 8)
            net.Send(self.Owner)
        end
    end

    -- Handle key input for toggling
    if CLIENT then
        self:HandleKeyInput()
    end
end

-- ============================================================================
-- INPUT HANDLING
-- ============================================================================

function SWEP:HandleKeyInput()
    -- Check for N key toggle
    if input.IsKeyDown(KEY_N) and not self.KeyPressed then
        if self.GogglesActive then
            self:DeactivateGoggles()
        else
            self:ActivateGoggles()
        end
        self.KeyPressed = true
    elseif input.IsKeyDown(KEY_T) and not self.CycleKeyPressed then
        if self.GogglesActive then
            self:CycleVisionMode()
        end
        self.CycleKeyPressed = true
    elseif not input.IsKeyDown(KEY_N) and not input.IsKeyDown(KEY_T) then
        self.KeyPressed = false
        self.CycleKeyPressed = false
    end
end

-- ============================================================================
-- WEAPON LIFECYCLE
-- ============================================================================

function SWEP:Holster()
    if self.GogglesActive then
        self:DeactivateGoggles()
    end
    return true
end

function SWEP:OnRemove()
    if self.GogglesActive then
        self:DeactivateGoggles()
    end
end

-- ============================================================================
-- THERMAL DETECTION HELPER
-- ============================================================================

function SWEP:IsThermalDetectable(ent)
    if not IsValid(ent) or ent == LocalPlayer() then return false end

    -- Detect living entities (players and NPCs) - highest priority
    if ent:IsPlayer() or ent:IsNPC() then
        return true
    end

    -- Detect NextBot NPCs (different from regular NPCs)
    if ent:GetClass() == "npc_*" or ent:GetClass():find("nextbot") then
        return true
    end

    -- Detect weapons
    if ent:GetClass():find("weapon_") then
        return true
    end

    -- Detect vehicles (engines generate heat)
    if ent:IsVehicle() then
        return true
    end

    -- Detect physics props (can have heat if recently interacted with)
    if ent:GetClass() == "prop_physics" and ent:GetVelocity():Length() > 50 then
        return true
    end

    -- Detect explosive entities
    if ent:GetClass():find("grenade") or ent:GetClass():find("explosive") then
        return true
    end

    -- Detect recently fired weapons or hot barrels
    if ent:GetClass():find("prop_physics") and ent:GetModel() and (
        ent:GetModel():find("gun") or
        ent:GetModel():find("rifle") or
        ent:GetModel():find("pistol") or
        ent:GetModel():find("shotgun")
    ) then
        return true
    end

    -- Detect other potential heat sources
    if ent:GetClass():find("prop_vehicle") then
        return true
    end

    return false
end

-- ============================================================================
-- SETTINGS MANAGEMENT
-- ============================================================================

function SWEP:ResetSettings()
    self.Settings = table.Copy(self.DefaultSettings)
    if SERVER then
        net.Start("SplinterCell_Settings_Update")
        net.WriteTable(self.Settings)
        net.Send(self.Owner)
    end
end

function SWEP:UpdateSetting(key, value)
    if self.Settings[key] ~= nil then
        self.Settings[key] = value
        if SERVER then
            net.Start("SplinterCell_Settings_Update")
            net.WriteTable(self.Settings)
            net.Send(self.Owner)
        end
    end
end

-- ============================================================================
-- DEBUGGING AND CONSOLE COMMANDS
-- ============================================================================

if SERVER then
    -- Server-side debug commands
    concommand.Add("splintercell_debug_server", function(ply, cmd, args)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
            print("=== Splinter Cell Server Debug ===")
            print("Goggles Active:", weapon.GogglesActive)
            print("Current Mode:", weapon.CurrentMode)
            print("Energy:", weapon.Energy)
            print("Sonar Detections:", table.Count(weapon.SonarDetections))
            
            ply:ChatPrint("Server debug info printed to console")
        else
            ply:ChatPrint("Splinter Cell Goggles not equipped!")
        end
    end)

    -- Force sonar pulse (server-side)
    concommand.Add("splintercell_force_pulse", function(ply, cmd, args)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
            weapon:TriggerSonarPulse()
            ply:ChatPrint("Sonar pulse triggered!")
        else
            ply:ChatPrint("Splinter Cell Goggles not equipped!")
        end
    end)

    -- Test entity detection (server-side)
    concommand.Add("splintercell_test_detection", function(ply, cmd, args)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
            local entities = ents.FindInSphere(ply:GetPos(), 500)
            local thermalCount = 0
            local sonarCount = 0
            
            for _, ent in pairs(entities) do
                if weapon:IsThermalDetectable(ent) then
                    thermalCount = thermalCount + 1
                end
                if weapon:IsSonarDetectable(ent) then
                    sonarCount = sonarCount + 1
                end
            end
            
            ply:ChatPrint("Detection Test Results:")
            ply:ChatPrint("Thermal detectable: " .. thermalCount)
            ply:ChatPrint("Sonar detectable: " .. sonarCount)
            ply:ChatPrint("Total entities in range: " .. #entities)
        else
            ply:ChatPrint("Splinter Cell Goggles not equipped!")
        end
    end)
end
