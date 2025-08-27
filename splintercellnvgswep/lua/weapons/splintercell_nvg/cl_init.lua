-- ============================================================================
-- Splinter Cell Goggles SWEP - Client Initialization
-- ============================================================================
-- Client-side implementation with vision modes, HUD, and effects

include("shared.lua")

-- ============================================================================
-- CLIENT-SIDE INITIALIZATION
-- ============================================================================

function SWEP:Initialize()
    -- Client-side initialization
    self.GogglesActive = false
    self.CurrentMode = 1
    self.Energy = self.MaxEnergy
    self.SonarDetections = {}
    self.LastSonarPulse = 0
    self.KeyPressed = false
    self.CycleKeyPressed = false
    self.LowEnergyWarned = false

    -- Ensure settings are properly copied
    self.Settings = table.Copy(self.DefaultSettings)

    -- Bind keys for this client
    self:BindKeys()
end

-- ============================================================================
-- VISION RENDERING SYSTEM
-- ============================================================================

local function RenderVisionEffects()
    local ply = LocalPlayer()
    local weapon = ply:GetActiveWeapon()

    if not IsValid(weapon) or weapon:GetClass() ~= "splintercell_nvg" or not weapon.GogglesActive then
        return
    end

    local screenW, screenH = ScrW(), ScrH()
    local currentMode = weapon.VisionModes[weapon.CurrentMode]

    if currentMode then
        -- Mode-specific overlay
        if weapon.CurrentMode == 1 then
            -- Night Vision
            weapon:RenderNightVision(screenW, screenH, currentMode)
        elseif weapon.CurrentMode == 2 then
            -- Thermal Vision
            weapon:RenderThermalVision(screenW, screenH, currentMode)
        elseif weapon.CurrentMode == 3 then
            -- Sonar Vision
            weapon:RenderSonarVision(screenW, screenH, currentMode)
        end
    end
end

hook.Add("RenderScreenspaceEffects", "SplinterCell_Vision_Effects", RenderVisionEffects)

-- Additional brightness enhancement for night vision
local function EnhanceScreenBrightness()
    local ply = LocalPlayer()
    local weapon = ply:GetActiveWeapon()
    
    if not IsValid(weapon) or weapon:GetClass() ~= "splintercell_nvg" or not weapon.GogglesActive then
        return
    end
    
    -- Only enhance brightness for night vision mode
    if weapon.CurrentMode == 1 then
        local screenW, screenH = ScrW(), ScrH()
        
        -- Brightness enhancement overlay
        surface.SetDrawColor(0, 255, 0, 15 * (weapon.Settings.visionStrength or 1))
        surface.DrawRect(0, 0, screenW, screenH)
        
        -- Additional gamma correction for very dark areas
        surface.SetDrawColor(0, 180, 0, 10 * (weapon.Settings.visionStrength or 1))
        surface.DrawRect(0, 0, screenW, screenH)
    end
end

hook.Add("HUDPaint", "SplinterCell_Brightness_Enhancement", EnhanceScreenBrightness)

-- ============================================================================
-- NETWORK RECEIVERS
-- ============================================================================

-- Receive goggles state from server
net.Receive("SplinterCell_Goggles_State", function()
    local active = net.ReadBool()
    local mode = net.ReadInt(8)
    local weapon = LocalPlayer():GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
        weapon.GogglesActive = active
        weapon.CurrentMode = mode
    end
end)

-- Receive goggles mode from server
net.Receive("SplinterCell_Goggles_Mode", function()
    local mode = net.ReadInt(8)
    local weapon = LocalPlayer():GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
        weapon.CurrentMode = mode
    end
end)

-- Enhanced sonar detection effects
net.Receive("SplinterCell_Sonar_Detection", function()
    local ent = net.ReadEntity()
    local pos = net.ReadVector()
    local detectionTime = net.ReadFloat()
    
    if IsValid(ent) then
        local weapon = LocalPlayer():GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
            weapon.SonarDetections[ent] = detectionTime
        end
    end
end)

-- ============================================================================
-- CONSOLE COMMANDS
-- ============================================================================

-- Settings menu
concommand.Add("goggles_settings", function(ply, cmd, args)
    local weapon = LocalPlayer():GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
        -- Ensure Settings are properly initialized
        if not weapon.Settings then
            weapon.Settings = {
                autoRecharge = true,
                lowBatteryWarning = 20,
                pulseVolume = 0.5,
                overlayOpacity = 0.8
            }
        end
        
        print("=== Splinter Cell Goggles Settings ===")
        print("Auto Recharge:", (weapon.Settings.autoRecharge or true) and "ON" or "OFF")
        print("Low Battery Warning:", (weapon.Settings.lowBatteryWarning or 20) .. "%")
        print("Pulse Volume:", weapon.Settings.pulseVolume or 0.5)
        print("Overlay Opacity:", weapon.Settings.overlayOpacity or 0.8)
    else
        print("Goggles not equipped!")
    end
end)

-- ============================================================================
-- VISION MODE RENDERING FUNCTIONS
-- ============================================================================

function SWEP:RenderNightVision(screenW, screenH, mode)
    -- Enhanced night vision with much better brightness and visibility
    local strength = self.Settings.visionStrength * mode.overlayStrength

    -- Base green overlay with reduced opacity for better visibility
    surface.SetDrawColor(mode.color.r, mode.color.g, mode.color.b, 30 * strength)
    surface.DrawRect(0, 0, screenW, screenH)

    -- Multiple brightness enhancement layers for much better visibility
    for i = 1, 5 do
        local alpha = (50 - i * 6) * strength * mode.brightnessBoost
        surface.SetDrawColor(0, 255, 0, alpha)
        surface.DrawRect(0, 0, screenW, screenH)
    end

    -- Additional brightness boost for very dark environments
    surface.SetDrawColor(120, 255, 120, 25 * strength)
    surface.DrawRect(0, 0, screenW, screenH)

    -- Enhanced gamma correction overlay
    surface.SetDrawColor(180, 255, 180, 15 * strength)
    surface.DrawRect(0, 0, screenW, screenH)

    -- Grain effect (reduced for better clarity)
    if self.Settings.nightVisionGrain > 0 then
        surface.SetDrawColor(0, 255, 0, 8 * strength * self.Settings.nightVisionGrain)
        for i = 1, 150 do
            local x = math.random(0, screenW)
            local y = math.random(0, screenH)
            surface.DrawRect(x, y, 1, 1)
        end
    end

    -- Subtle scan lines effect (less intrusive)
    surface.SetDrawColor(0, 255, 0, 20 * strength)
    for i = 0, screenH, 4 do
        surface.DrawLine(0, i, screenW, i)
    end

    -- Center enhancement for better focus
    local centerSize = math.min(screenW, screenH) * 0.3
    surface.SetDrawColor(50, 255, 50, 10 * strength)
    surface.DrawRect(screenW/2 - centerSize/2, screenH/2 - centerSize/2, centerSize, centerSize)
end

function SWEP:RenderThermalVision(screenW, screenH, mode)
    -- Dark blue/black background for thermal vision (cold areas)
    surface.SetDrawColor(self.Settings.thermalColdColor.r,
                        self.Settings.thermalColdColor.g,
                        self.Settings.thermalColdColor.b, 140 * self.Settings.visionStrength)
    surface.DrawRect(0, 0, screenW, screenH)

    -- Add subtle thermal noise effect
    surface.SetDrawColor(0, 100, 150, 15 * self.Settings.visionStrength)
    for i = 1, 150 do
        local x = math.random(0, screenW)
        local y = math.random(0, screenH)
        surface.DrawRect(x, y, 1, 1)
    end

    -- Heat signatures for detectable entities
    local entities = ents.GetAll()
    for _, ent in pairs(entities) do
        if self:IsThermalDetectable(ent) then
            local screenPos = ent:GetPos():ToScreen()
            if screenPos.visible then
                -- Thermal vision can see through walls (like real thermal imaging)
                -- Only check distance for thermal detection range
                local distance = LocalPlayer():GetPos():Distance(ent:GetPos())
                local maxRange = 800 -- Maximum thermal detection range
                
                if distance <= maxRange then
                    local intensity = math.max(0, 1 - (distance / maxRange))
                    local baseSize = 30 -- Base size for thermal signatures

                    -- Different sizes for different entity types
                    local size
                    if ent:IsPlayer() then
                        size = baseSize
                    elseif ent:IsNPC() then
                        size = baseSize * 0.9
                    elseif ent:IsVehicle() then
                        size = baseSize * 1.5
                    elseif ent:GetClass():find("weapon_") then
                        size = baseSize * 0.6
                    else
                        size = baseSize * 0.8
                    end

                    -- Adjust size based on distance and intensity
                    size = size * (0.5 + intensity * 0.5)

                    -- Enhanced thermal colors based on entity type and heat
                    local hotColor = self.Settings.thermalHotColor
                    local heatIntensity = 255 * intensity * self.Settings.thermalSensitivity

                    if ent:IsPlayer() or ent:IsNPC() then
                        -- Living entities - brightest and most detailed
                        hotColor = Color(255, 255, 255) -- White hot for living beings

                        -- Outer glow effect
                        surface.SetDrawColor(255, 200, 100, heatIntensity * 0.3)
                        surface.DrawOutlinedRect(screenPos.x - size - 3, screenPos.y - size - 3, size * 2 + 6, size * 2 + 6)

                        -- Main body signature
                        surface.SetDrawColor(hotColor.r, hotColor.g, hotColor.b, heatIntensity)
                        surface.DrawOutlinedRect(screenPos.x - size, screenPos.y - size, size * 2, size * 2)

                        -- Inner body heat (filled)
                        surface.SetDrawColor(255, 180, 50, heatIntensity * 0.8)
                        surface.DrawRect(screenPos.x - size + 3, screenPos.y - size + 3, size * 2 - 6, size * 2 - 6)

                        -- Head signature (hottest part)
                        local headSize = size * 0.4
                        surface.SetDrawColor(255, 255, 255, heatIntensity * 1.2) -- Even hotter
                        surface.DrawRect(screenPos.x - headSize, screenPos.y - size - headSize - 2, headSize * 2, headSize * 2)

                        -- Limb signatures for players and NPCs
                        if ent:IsPlayer() or ent:IsNPC() then
                            local limbSize = size * 0.3
                            -- Left arm
                            surface.SetDrawColor(255, 220, 100, heatIntensity * 0.6)
                            surface.DrawRect(screenPos.x - size - limbSize, screenPos.y - limbSize, limbSize * 2, limbSize * 2)
                            -- Right arm
                            surface.SetDrawColor(255, 220, 100, heatIntensity * 0.6)
                            surface.DrawRect(screenPos.x + size - limbSize, screenPos.y - limbSize, limbSize * 2, limbSize * 2)

                            -- Add leg signatures for more detailed heat map
                            local legSize = size * 0.25
                            -- Left leg
                            surface.SetDrawColor(255, 200, 80, heatIntensity * 0.5)
                            surface.DrawRect(screenPos.x - legSize, screenPos.y + size - legSize, legSize * 2, legSize * 2)
                            -- Right leg
                            surface.SetDrawColor(255, 200, 80, heatIntensity * 0.5)
                            surface.DrawRect(screenPos.x + size * 0.5 - legSize, screenPos.y + size - legSize, legSize * 2, legSize * 2)
                        end

                    elseif ent:IsVehicle() then
                        -- Vehicles - large heat signatures
                        hotColor = Color(255, 140, 0) -- Orange for engine heat

                        -- Engine block (hottest part)
                        surface.SetDrawColor(hotColor.r, hotColor.g, hotColor.b, heatIntensity)
                        surface.DrawRect(screenPos.x - size * 0.6, screenPos.y - size * 0.4, size * 1.2, size * 0.8)

                        -- Vehicle outline
                        surface.SetDrawColor(255, 180, 50, heatIntensity * 0.7)
                        surface.DrawOutlinedRect(screenPos.x - size, screenPos.y - size * 0.7, size * 2, size * 1.4)

                    elseif ent:GetClass():find("weapon_") or (ent:GetClass():find("prop_physics") and ent:GetModel() and (
                        ent:GetModel():find("gun") or ent:GetModel():find("rifle") or
                        ent:GetModel():find("pistol") or ent:GetModel():find("shotgun"))) then
                        -- Weapons - smaller, very hot signatures
                        hotColor = Color(255, 255, 100) -- Yellow-white for metal heat

                        surface.SetDrawColor(hotColor.r, hotColor.g, hotColor.b, heatIntensity * 0.9)
                        surface.DrawOutlinedRect(screenPos.x - size, screenPos.y - size, size * 2, size * 2)

                        surface.SetDrawColor(255, 240, 150, heatIntensity * 0.6)
                        surface.DrawRect(screenPos.x - size + 2, screenPos.y - size + 2, size * 2 - 4, size * 2 - 4)

                    else
                        -- Other heat sources (explosives, moving props)
                        hotColor = Color(255, 100, 0) -- Orange-red for general heat

                        surface.SetDrawColor(hotColor.r, hotColor.g, hotColor.b, heatIntensity * 0.8)
                        surface.DrawOutlinedRect(screenPos.x - size, screenPos.y - size, size * 2, size * 2)

                        surface.SetDrawColor(255, 150, 50, heatIntensity * 0.5)
                        surface.DrawRect(screenPos.x - size + 2, screenPos.y - size + 2, size * 2 - 4, size * 2 - 4)
                    end

                    -- Distance indicator (subtle fade effect)
                    if distance > maxRange * 0.7 then
                        surface.SetDrawColor(255, 255, 255, 50 * (1 - intensity))
                        draw.SimpleText("FAR", "DermaDefault", screenPos.x, screenPos.y + size + 5,
                                      Color(255, 255, 255, 100 * (1 - intensity)), TEXT_ALIGN_CENTER)
                    end
                end
            end
        end
    end
end

function SWEP:RenderSonarVision(screenW, screenH, mode)
    -- Dark blue sonar overlay
    surface.SetDrawColor(mode.color.r, mode.color.g, mode.color.b, 50 * self.Settings.visionStrength)
    surface.DrawRect(0, 0, screenW, screenH)

    -- Add sonar static noise
    surface.SetDrawColor(0, 150, 255, 20 * self.Settings.visionStrength)
    for i = 1, 100 do
        local x = math.random(0, screenW)
        local y = math.random(0, screenH)
        surface.DrawRect(x, y, 1, 1)
    end

    -- Sonar pulse rings
    local centerX, centerY = screenW / 2, screenH / 2
    local currentTime = CurTime()
    local pulseProgress = (currentTime - self.LastSonarPulse) / self.Settings.sonarPulseInterval

    if pulseProgress < 1 then
        local pulseRadius = pulseProgress * 500

        -- Multiple expanding rings with enhanced visibility
        for i = 1, 4 do
            local ringRadius = pulseRadius - (i - 1) * 100
            if ringRadius > 0 then
                local alpha = 255 * (1 - pulseProgress) * (1 - (i - 1) * 0.15)
                local ringThickness = 3 - (i - 1) * 0.5

                -- Outer ring
                surface.SetDrawColor(mode.color.r, mode.color.g, mode.color.b, alpha)
                surface.DrawOutlinedRect(centerX - ringRadius, centerY - ringRadius, ringRadius * 2, ringRadius * 2)

                -- Inner ring for thickness
                if ringRadius > ringThickness then
                    surface.SetDrawColor(mode.color.r, mode.color.g, mode.color.b, alpha * 0.6)
                    surface.DrawOutlinedRect(centerX - ringRadius + ringThickness, centerY - ringRadius + ringThickness,
                                           (ringRadius - ringThickness) * 2, (ringRadius - ringThickness) * 2)
                end

                -- Ring label for the first/main ring
                if i == 1 then
                    local ringCenterY = centerY - ringRadius - 15
                    draw.SimpleText("SONAR PULSE", "DermaDefault", centerX, ringCenterY,
                                  Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)
                end
            end
        end
    end

    -- Render sonar detections
    self:DrawSonarDetections()
end

-- ============================================================================
-- HUD RENDERING SYSTEM
-- ============================================================================

function SWEP:DrawHUD()
    if not self.GogglesActive then return end

    if self.Settings.showModeIndicator then
        self:DrawModeIndicator()
    end

    if self.Settings.showEnergyBar then
        self:DrawEnergyBar()
    end

    if self.Settings.showCompass then
        self:DrawCompass()
    end

    if self.Settings.crosshairEnabled then
        self:DrawCrosshair()
    end

    if self.CurrentMode == 3 then
        self:DrawSonarDetections()
    end
end

function SWEP:DrawModeIndicator()
    local screenW, screenH = ScrW(), ScrH()
    local currentMode = self.VisionModes[self.CurrentMode]

    if currentMode then
        -- Mode name
        draw.SimpleText(currentMode.name, "DermaLarge", screenW / 2, 50,
                       self.Settings.hudColor, TEXT_ALIGN_CENTER)

        -- Mode description
        draw.SimpleText(currentMode.description, "DermaDefault", screenW / 2, 75,
                       Color(200, 200, 200, 180), TEXT_ALIGN_CENTER)

        -- Thermal mode specific indicator
        if self.CurrentMode == 2 then
            draw.SimpleText("THERMAL DETECTING HEAT SIGNATURES", "DermaDefault", screenW / 2, 95,
                          Color(255, 100, 100, 200), TEXT_ALIGN_CENTER)

            -- Count detectable entities for debugging
            local entities = ents.GetAll()
            local npcCount = 0
            local playerCount = 0
            local totalDetectable = 0
            local visibleDetectable = 0

            for _, ent in pairs(entities) do
                if ent:IsPlayer() and ent ~= LocalPlayer() then
                    playerCount = playerCount + 1
                elseif ent:IsNPC() then
                    npcCount = npcCount + 1
                end

                if self:IsThermalDetectable(ent) then
                    totalDetectable = totalDetectable + 1
                    local screenPos = ent:GetPos():ToScreen()
                    if screenPos.visible then
                        local distance = LocalPlayer():GetPos():Distance(ent:GetPos())
                        if distance <= 800 then -- Within thermal range
                            visibleDetectable = visibleDetectable + 1
                        end
                    end
                end
            end

            -- Display entity counts
            local debugText = string.format("NPCs: %d | Players: %d | Detectable: %d | Visible: %d",
                                          npcCount, playerCount, totalDetectable, visibleDetectable)
            draw.SimpleText(debugText, "DermaDefault", screenW / 2, 110,
                          Color(200, 200, 200, 150), TEXT_ALIGN_CENTER)

        -- Sonar mode specific indicator
        elseif self.CurrentMode == 3 then
            draw.SimpleText("SONAR SCANNING - DETECTS THROUGH WALLS", "DermaDefault", screenW / 2, 95,
                          Color(100, 100, 255, 200), TEXT_ALIGN_CENTER)

            -- Count detectable entities for sonar debugging
            local entities = ents.GetAll()
            local npcCount = 0
            local playerCount = 0
            local totalDetectable = 0
            local activeDetections = 0

            for _, ent in pairs(entities) do
                if ent:IsPlayer() and ent ~= LocalPlayer() then
                    playerCount = playerCount + 1
                elseif ent:IsNPC() then
                    npcCount = npcCount + 1
                end

                if self:IsSonarDetectable(ent) then
                    totalDetectable = totalDetectable + 1
                end
            end

            -- Count active sonar detections
            for entity, _ in pairs(self.SonarDetections) do
                if IsValid(entity) then
                    activeDetections = activeDetections + 1
                end
            end

            -- Display sonar debug info
            local sonarText = string.format("NPCs: %d | Players: %d | Detectable: %d | Active: %d",
                                          npcCount, playerCount, totalDetectable, activeDetections)
            draw.SimpleText(sonarText, "DermaDefault", screenW / 2, 110,
                          Color(150, 150, 255, 150), TEXT_ALIGN_CENTER)

            -- Show last pulse time
            local timeToNextPulse = math.max(0, self.Settings.sonarPulseInterval - (CurTime() - self.LastSonarPulse))
            local pulseText = string.format("Next Pulse: %.1fs", timeToNextPulse)
            draw.SimpleText(pulseText, "DermaDefault", screenW / 2, 125,
                          Color(200, 200, 255, 180), TEXT_ALIGN_CENTER)
        end
    end
end

function SWEP:DrawEnergyBar()
    local screenW, screenH = ScrW(), ScrH()
    local barWidth = 200
    local barHeight = 20
    local barX = screenW - barWidth - 20
    local barY = screenH - 40

    -- Background
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(barX, barY, barWidth, barHeight)

    -- Energy bar
    local energyPercent = self.Energy / self.MaxEnergy
    local energyColor = Color(0, 255, 0, 255) -- Green by default

    if energyPercent < 0.3 then
        energyColor = Color(255, 0, 0, 255) -- Red when low
    elseif energyPercent < 0.6 then
        energyColor = Color(255, 255, 0, 255) -- Yellow when medium
    end

    surface.SetDrawColor(energyColor)
    surface.DrawRect(barX + 2, barY + 2, (barWidth - 4) * energyPercent, barHeight - 4)

    -- Border
    surface.SetDrawColor(255, 255, 255, 100)
    surface.DrawOutlinedRect(barX, barY, barWidth, barHeight)

    -- Text
    draw.SimpleText("ENERGY", "DermaDefault", barX + barWidth / 2, barY - 15,
                   self.Settings.hudColor, TEXT_ALIGN_CENTER)
    draw.SimpleText(math.floor(energyPercent * 100) .. "%", "DermaDefault",
                   barX + barWidth / 2, barY + barHeight / 2,
                   self.Settings.hudColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SWEP:DrawCompass()
    local screenW, screenH = ScrW(), ScrH()
    local ply = LocalPlayer()
    local ang = ply:EyeAngles()
    local direction = math.Round(ang.y / 90) % 4

    local directions = {"N", "E", "S", "W"}
    local currentDir = directions[direction + 1]

    draw.SimpleText(currentDir, "DermaLarge", screenW / 2, screenH - 50,
                   self.Settings.hudColor, TEXT_ALIGN_CENTER)
end

function SWEP:DrawCrosshair()
    local screenW, screenH = ScrW(), ScrH()
    local centerX, centerY = screenW / 2, screenH / 2

    surface.SetDrawColor(self.Settings.hudColor)
    surface.DrawRect(centerX - 1, centerY - 1, 2, 2)
end

-- ============================================================================
-- DETECTION HELPER FUNCTIONS (CLIENT)
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

function SWEP:IsSonarDetectable(ent)
    if not IsValid(ent) or ent == LocalPlayer() then return false end

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
        -- Detect physics props of reasonable size
        local mins, maxs = ent:GetCollisionBounds()
        local size = (maxs - mins):Length()
        return size > 30 -- Lower threshold for more detections
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
    end

    return false
end

function SWEP:DrawSonarDetections()
    for entity, detectionTime in pairs(self.SonarDetections) do
        if IsValid(entity) then
            local screenPos = entity:GetPos():ToScreen()
            if screenPos.visible then
                local timeSinceDetection = CurTime() - detectionTime
                local alpha = 255 * math.max(0, 1 - timeSinceDetection / 3)
                local baseSize = 20
                local size = baseSize + (timeSinceDetection * 8)

                -- Check if entity is behind walls (sonar detects through walls)
                local trace = util.TraceLine({
                    start = LocalPlayer():EyePos(),
                    endpos = entity:GetPos() + Vector(0, 0, 30),
                    filter = {LocalPlayer(), entity},
                    mask = MASK_SOLID
                })

                local isBehindWall = trace.Entity ~= entity
                local detectionColor = isBehindWall and Color(255, 100, 0, alpha) or Color(0, 200, 255, alpha)

                -- Enhanced sonar detection rendering
                if entity:IsPlayer() or entity:IsNPC() then
                    -- Living entities - more detailed sonar signature
                    -- Outer pulse ring
                    surface.SetDrawColor(detectionColor.r, detectionColor.g, detectionColor.b, alpha * 0.5)
                    surface.DrawOutlinedRect(screenPos.x - size - 5, screenPos.y - size - 5, size * 2 + 10, size * 2 + 10)

                    -- Main detection circle
                    surface.SetDrawColor(detectionColor.r, detectionColor.g, detectionColor.b, alpha)
                    surface.DrawOutlinedRect(screenPos.x - size, screenPos.y - size, size * 2, size * 2)

                    -- Inner detection (filled for emphasis)
                    surface.SetDrawColor(detectionColor.r, detectionColor.g, detectionColor.b, alpha * 0.7)
                    surface.DrawRect(screenPos.x - size + 3, screenPos.y - size + 3, size * 2 - 6, size * 2 - 6)

                    -- Center dot for precision
                    surface.SetDrawColor(255, 255, 255, alpha)
                    surface.DrawRect(screenPos.x - 2, screenPos.y - 2, 4, 4)

                elseif entity:IsVehicle() then
                    -- Vehicles - larger signature
                    local vehicleSize = size * 1.5
                    surface.SetDrawColor(detectionColor.r, detectionColor.g, detectionColor.b, alpha)
                    surface.DrawOutlinedRect(screenPos.x - vehicleSize, screenPos.y - vehicleSize * 0.7, vehicleSize * 2, vehicleSize * 1.4)

                    -- Engine indicator (hotter area)
                    surface.SetDrawColor(255, 200, 100, alpha * 0.8)
                    surface.DrawRect(screenPos.x - vehicleSize * 0.6, screenPos.y - vehicleSize * 0.4, vehicleSize * 1.2, vehicleSize * 0.8)

                elseif entity:GetClass():find("weapon_") then
                    -- Weapons - smaller, distinct signature
                    surface.SetDrawColor(detectionColor.r, detectionColor.g, detectionColor.b, alpha * 0.9)
                    surface.DrawOutlinedRect(screenPos.x - size * 0.8, screenPos.y - size * 0.8, size * 1.6, size * 1.6)

                    -- Weapon indicator lines
                    surface.SetDrawColor(255, 255, 255, alpha)
                    surface.DrawLine(screenPos.x - size * 0.5, screenPos.y, screenPos.x + size * 0.5, screenPos.y)
                    surface.DrawLine(screenPos.x, screenPos.y - size * 0.5, screenPos.x, screenPos.y + size * 0.5)

                else
                    -- Other entities - standard signature
                    surface.SetDrawColor(detectionColor.r, detectionColor.g, detectionColor.b, alpha)
                    surface.DrawOutlinedRect(screenPos.x - size, screenPos.y - size, size * 2, size * 2)

                    surface.SetDrawColor(detectionColor.r, detectionColor.g, detectionColor.b, alpha * 0.6)
                    surface.DrawRect(screenPos.x - size + 2, screenPos.y - size + 2, size * 2 - 4, size * 2 - 4)
                end

                -- Enhanced entity type indicator
                local entityType = "?"
                if entity:IsPlayer() then entityType = "P"
                elseif entity:IsNPC() then entityType = "N"
                elseif entity:IsVehicle() then entityType = "V"
                elseif entity:GetClass():find("weapon_") then entityType = "W"
                elseif entity:GetClass():find("door") then entityType = "D"
                elseif entity:GetClass():find("prop_") then entityType = "O"
                end

                -- Draw entity type with background
                local textColor = isBehindWall and Color(255, 255, 255, alpha) or Color(0, 0, 0, alpha)
                local bgColor = detectionColor

                surface.SetDrawColor(bgColor.r, bgColor.g, bgColor.b, alpha * 0.8)
                surface.DrawRect(screenPos.x - 8, screenPos.y - 8, 16, 16)

                draw.SimpleText(entityType, "DermaDefault", screenPos.x, screenPos.y,
                               textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                -- Wall indicator for entities behind walls
                if isBehindWall then
                    draw.SimpleText("WALL", "DermaDefault", screenPos.x, screenPos.y + size + 10,
                                  Color(255, 100, 0, alpha), TEXT_ALIGN_CENTER)
                end

                -- Distance indicator
                local distance = LocalPlayer():GetPos():Distance(entity:GetPos())
                if distance > self.Settings.sonarRange * 0.7 then
                    draw.SimpleText("FAR", "DermaDefault", screenPos.x, screenPos.y - size - 15,
                                  Color(255, 255, 255, alpha * 0.8), TEXT_ALIGN_CENTER)
                end
            end
        end
    end
end

hook.Add("HUDPaint", "SplinterCell_HUD", function()
    local ply = LocalPlayer()
    local weapon = ply:GetActiveWeapon()

    if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
        weapon:DrawHUD()
    end
end)

-- ============================================================================
-- NETWORK RECEIVERS
-- ============================================================================

-- Receive goggles state from server
net.Receive("SplinterCell_Goggles_State", function()
    local active = net.ReadBool()
    local mode = net.ReadInt(8)
    local weapon = LocalPlayer():GetActiveWeapon()

    if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
        weapon.GogglesActive = active
        weapon.CurrentMode = mode
    end
end)

-- Receive goggles mode from server
net.Receive("SplinterCell_Goggles_Mode", function()
    local mode = net.ReadInt(8)
    local weapon = LocalPlayer():GetActiveWeapon()

    if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
        weapon.CurrentMode = mode
    end
end)

-- Receive sonar detection from server
net.Receive("SplinterCell_Sonar_Detection", function()
    local ent = net.ReadEntity()
    local pos = net.ReadVector()
    local detectionTime = net.ReadFloat()

    if IsValid(ent) then
        local weapon = LocalPlayer():GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
            weapon.SonarDetections[ent] = detectionTime
            weapon.LastSonarPulse = CurTime()
        end
    end
end)

-- Receive settings update from server
net.Receive("SplinterCell_Settings_Update", function()
    local settings = net.ReadTable()
    local weapon = LocalPlayer():GetActiveWeapon()

    if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
        weapon.Settings = settings
    end
end)

-- ============================================================================
-- CONSOLE COMMANDS
-- ============================================================================

-- Settings management command
concommand.Add("splintercell_settings", function(ply, cmd, args)
    local weapon = LocalPlayer():GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
        print("=== Splinter Cell Goggles Settings ===")
        for k, v in pairs(weapon.Settings) do
            print(k .. ": " .. tostring(v))
        end
    else
        print("Splinter Cell Goggles not equipped!")
    end
end)

-- Quick settings commands
concommand.Add("splintercell_reset", function(ply, cmd, args)
    local weapon = LocalPlayer():GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
        weapon:ResetSettings()
        print("Splinter Cell Goggles settings reset to default!")
    end
end)

-- Thermal vision test command
concommand.Add("splintercell_thermal_test", function(ply, cmd, args)
    local weapon = LocalPlayer():GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
        -- Force thermal mode for testing
        weapon.CurrentMode = 2
        weapon.GogglesActive = true
        print("Thermal vision test activated! Switch to thermal mode to test.")
    else
        print("Equip Splinter Cell Goggles first!")
    end
end)

-- Debug thermal detection
concommand.Add("splintercell_thermal_debug", function(ply, cmd, args)
    print("=== Thermal Detection Debug ===")
    local entities = ents.GetAll()
    local npcCount = 0
    local detectableCount = 0

    for _, ent in pairs(entities) do
        if ent:IsNPC() then
            npcCount = npcCount + 1
            print("Found NPC: " .. ent:GetClass() .. " at " .. tostring(ent:GetPos()))
        end
    end

    print("Total NPCs found: " .. npcCount)

    local weapon = LocalPlayer():GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
        print("Checking thermal detectability...")
        for _, ent in pairs(entities) do
            if weapon:IsThermalDetectable(ent) then
                detectableCount = detectableCount + 1
                print("Detectable: " .. ent:GetClass() .. " (" .. (ent:IsPlayer() and "Player" or (ent:IsNPC() and "NPC" or "Other")) .. ")")
            end
        end
        print("Total detectable entities: " .. detectableCount)
    end
end)

-- Debug sonar detection
concommand.Add("splintercell_sonar_debug", function(ply, cmd, args)
    print("=== Sonar Detection Debug ===")
    local entities = ents.GetAll()
    local npcCount = 0
    local detectableCount = 0

    for _, ent in pairs(entities) do
        if ent:IsNPC() then
            npcCount = npcCount + 1
            print("Found NPC: " .. ent:GetClass() .. " at " .. tostring(ent:GetPos()))
        end
    end

    print("Total NPCs found: " .. npcCount)

    local weapon = LocalPlayer():GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
        print("Checking sonar detectability...")
        for _, ent in pairs(entities) do
            if weapon:IsSonarDetectable(ent) then
                detectableCount = detectableCount + 1
                print("Sonar Detectable: " .. ent:GetClass() .. " (" .. (ent:IsPlayer() and "Player" or (ent:IsNPC() and "NPC" or "Other")) .. ")")
            end
        end
        print("Total sonar detectable entities: " .. detectableCount)

        -- Show current sonar detections
        print("Active sonar detections:")
        for entity, detectionTime in pairs(weapon.SonarDetections) do
            if IsValid(entity) then
                print("  - " .. entity:GetClass() .. " (detected " .. string.format("%.1f", CurTime() - detectionTime) .. "s ago)")
            end
        end
    end
end)

-- Force sonar pulse for testing
concommand.Add("splintercell_sonar_pulse", function(ply, cmd, args)
    local weapon = LocalPlayer():GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
        weapon.LastSonarPulse = CurTime() - weapon.Settings.sonarPulseInterval + 0.1
        print("Forced sonar pulse!")
    else
        print("Equip Splinter Cell Goggles first!")
    end
end)

-- Enhanced thermal test with NPC spawning (server-side)
concommand.Add("splintercell_spawn_test_npc", function(ply, cmd, args)
    if SERVER then
        -- Spawn a test NPC for thermal vision testing
        local npc = ents.Create("npc_citizen")
        if IsValid(npc) then
            local pos = ply:GetPos() + ply:GetForward() * 200 + Vector(0, 0, 50)
            npc:SetPos(pos)
            npc:Spawn()
            npc:SetHealth(100)
            npc:SetNPCState(NPC_STATE_IDLE)

            ply:ChatPrint("Test NPC spawned for thermal vision testing!")
            print("Test NPC spawned at: " .. tostring(pos))
        else
            ply:ChatPrint("Failed to spawn test NPC!")
        end
    else
        print("This command must be run on the server!")
    end
end)

-- Spawn test entities for sonar testing (server-side)
concommand.Add("splintercell_spawn_sonar_test", function(ply, cmd, args)
    if SERVER then
        local basePos = ply:GetPos() + ply:GetForward() * 150

        -- Spawn test NPC
        local npc = ents.Create("npc_citizen")
        if IsValid(npc) then
            npc:SetPos(basePos + Vector(0, 0, 50))
            npc:Spawn()
            npc:SetHealth(100)
            npc:SetNPCState(NPC_STATE_IDLE)
        end

        -- Spawn test weapon
        local weapon = ents.Create("weapon_pistol")
        if IsValid(weapon) then
            weapon:SetPos(basePos + Vector(50, 50, 10))
            weapon:Spawn()
        end

        -- Spawn test prop
        local prop = ents.Create("prop_physics")
        if IsValid(prop) then
            prop:SetModel("models/props_c17/oildrum001.mdl")
            prop:SetPos(basePos + Vector(-50, -50, 10))
            prop:Spawn()
        end

        ply:ChatPrint("Test entities spawned for sonar testing!")
        print("Sonar test entities spawned around: " .. tostring(basePos))
    else
        print("This command must be run on the server!")
    end
end)



