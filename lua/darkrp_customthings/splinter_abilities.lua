-- ============================================================================
-- Splinter Cell Job Abilities System
-- ============================================================================
-- This file implements NVG abilities for Splinter Cell jobs without using SWEPs
-- ============================================================================

if CLIENT then
    -- Client-side variables
    local visionActive = false
    local currentMode = 1
    local energy = 100
    local lastPulseTime = 0
    local pulseAlpha = 0
    local grainTexture = surface.GetTextureID("effects/tvscreen_noise002a")
    local nKeyPressed = false
    local tKeyPressed = false
    
    -- Vision modes configuration
    local visionModes = {
        {
            name = "Night Vision",
            id = "nightvision",
            color = Color(0, 255, 0, 50),
            sound = "npc/scanner/scanner_electric1.wav"
        },
        {
            name = "Thermal Vision",
            id = "thermal",
            color = Color(255, 0, 0, 30),
            sound = "npc/scanner/scanner_electric2.wav"
        },
        {
            name = "Sonar Vision",
            id = "sonar",
            color = Color(0, 150, 255, 40),
            sound = "npc/scanner/combat_scan1.wav"
        }
    }
    
    -- Settings
    local settings = {
        visionStrength = 1.0,
        energyDrainRate = 0.5,
        energyRechargeRate = 1.0,
        maxEnergy = 100,
        sonarPulseInterval = 1.5,
        sonarPulseDuration = 0.5,
        nightVisionGrainAmount = 0.3,
        thermalSensitivity = 1.0
    }
    
    -- Create convars for customization
    CreateClientConVar("sc_vision_strength", "1", true, false, "Vision effect strength", 0.1, 2)
    CreateClientConVar("sc_energy_drain", "0.5", true, false, "Energy drain rate per second", 0.1, 2)
    CreateClientConVar("sc_energy_recharge", "1", true, false, "Energy recharge rate per second", 0.1, 3)
    CreateClientConVar("sc_sonar_interval", "1.5", true, false, "Sonar pulse interval", 0.5, 5)
    CreateClientConVar("sc_grain_amount", "0.3", true, false, "Night vision grain amount", 0, 1)
    
    -- Helper function to check if player has Splinter Cell abilities
    local function HasSplinterCellAbilities()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        
        local team = ply:Team()
        return team == TEAM_SPLINTERCELL or team == TEAM_SPLINTERCOMMANDER
    end
    
    -- Toggle vision function
    local function ToggleVision()
        if not HasSplinterCellAbilities() then
            LocalPlayer():ChatPrint("You don't have access to this technology!")
            return
        end
        
        -- Send toggle request to server
        net.Start("SC_AbilityToggle")
        net.SendToServer()
    end
    
    -- Cycle vision mode function
    local function CycleMode()
        if not HasSplinterCellAbilities() then return end
        if not visionActive then return end
        
        -- Send mode change request to server
        net.Start("SC_AbilityModeChange")
        net.SendToServer()
    end
    
    -- Key handling
    hook.Add("Think", "SplinterCellAbilityKeys", function()
        if not HasSplinterCellAbilities() then return end
        
        -- N key to toggle vision
        if input.IsKeyDown(KEY_N) and not nKeyPressed then
            nKeyPressed = true
            ToggleVision()
        elseif not input.IsKeyDown(KEY_N) then
            nKeyPressed = false
        end
        
        -- T key to cycle modes
        if input.IsKeyDown(KEY_T) and not tKeyPressed then
            tKeyPressed = true
            CycleMode()
        elseif not input.IsKeyDown(KEY_T) then
            tKeyPressed = false
        end
    end)
    
    -- Night Vision Rendering
    local function RenderNightVision(strength)
        local tab = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0.1 * strength,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0.2 * strength,
            ["$pp_colour_contrast"] = 1.2,
            ["$pp_colour_colour"] = 0.5,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 5 * strength,
            ["$pp_colour_mulb"] = 0
        }
        DrawColorModify(tab)
        
        -- Add grain effect
        local grainAmount = GetConVar("sc_grain_amount"):GetFloat()
        if grainAmount > 0 then
            surface.SetDrawColor(0, 255, 0, 30 * grainAmount)
            surface.SetTexture(grainTexture)
            
            -- Animated grain
            local offset = CurTime() * 10
            surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrW() * 2, ScrH() * 2, offset)
        end
        
        -- Add subtle bloom
        DrawBloom(0.65, 2 * strength, 9, 9, 1, 1, 1, 1, 1)
    end
    
    -- Get entity heat for thermal vision
    local function GetEntityHeat(ent)
        if not IsValid(ent) then return 0 end
        
        local heat = 0
        
        if ent:IsPlayer() then
            heat = ent:Alive() and 1.0 or 0.3
        elseif ent:IsNPC() then
            heat = ent:Health() > 0 and 0.8 or 0.2
        elseif ent:IsVehicle() then
            heat = 0.6
        elseif ent:GetClass():find("lamp") or ent:GetClass():find("light") then
            heat = 0.9
        elseif ent:GetClass():find("fire") or ent:GetClass():find("flame") then
            heat = 1.0
        else
            heat = 0.1
        end
        
        return math.Clamp(heat * settings.thermalSensitivity, 0, 1)
    end
    
    -- Thermal Vision Rendering
    local function RenderThermalVision(strength)
        local entities = ents.GetAll()
        
        render.SetStencilEnable(true)
        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(1)
        
        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        
        cam.Start3D()
        render.SuppressEngineLighting(true)
        
        for _, ent in ipairs(entities) do
            if IsValid(ent) and ent != LocalPlayer() then
                local heat = GetEntityHeat(ent)
                if heat > 0.1 then
                    render.SetColorModulation(heat, heat * 0.5, 0)
                    render.SetBlend(heat)
                    ent:DrawModel()
                end
            end
        end
        
        render.SuppressEngineLighting(false)
        cam.End3D()
        
        render.SetStencilEnable(false)
        
        -- Apply thermal color modification
        local tab = {
            ["$pp_colour_addr"] = 0.1 * strength,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = -0.3,
            ["$pp_colour_contrast"] = 2,
            ["$pp_colour_colour"] = 0.2,
            ["$pp_colour_mulr"] = 2 * strength,
            ["$pp_colour_mulg"] = 0.5,
            ["$pp_colour_mulb"] = 0
        }
        DrawColorModify(tab)
    end
    
    -- Sonar Vision Rendering
    local function RenderSonarVision(strength)
        local time = CurTime()
        local interval = GetConVar("sc_sonar_interval"):GetFloat()
        
        -- Update pulse
        if time - lastPulseTime > interval then
            lastPulseTime = time
            pulseAlpha = 1.0
        end
        
        -- Fade pulse
        if pulseAlpha > 0 then
            pulseAlpha = math.max(0, pulseAlpha - FrameTime() * 2)
        end
        
        -- Base sonar effect
        local tab = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0.1 * strength,
            ["$pp_colour_brightness"] = -0.5,
            ["$pp_colour_contrast"] = 1.5,
            ["$pp_colour_colour"] = 0.3,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0.5,
            ["$pp_colour_mulb"] = 2 * strength
        }
        DrawColorModify(tab)
        
        -- Pulse overlay
        if pulseAlpha > 0 then
            surface.SetDrawColor(0, 150, 255, 100 * pulseAlpha)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        end
    end
    
    -- Draw sonar halos
    local function DrawSonarHalos()
        if pulseAlpha <= 0 then return end
        
        local entities = ents.GetAll()
        local targets = {}
        
        for _, ent in ipairs(entities) do
            if IsValid(ent) and ent != LocalPlayer() then
                local distance = LocalPlayer():GetPos():Distance(ent:GetPos())
                if distance < 1000 and (ent:IsPlayer() or ent:IsNPC() or ent:IsVehicle()) then
                    table.insert(targets, ent)
                end
            end
        end
        
        if #targets > 0 then
            halo.Add(targets, Color(0, 150, 255, 255 * pulseAlpha), 2, 2, 2, true, true)
        end
    end
    
    -- Main rendering hook
    hook.Add("RenderScreenspaceEffects", "SplinterCellAbilityEffects", function()
        if not HasSplinterCellAbilities() or not visionActive then return end
        
        local mode = visionModes[currentMode]
        local strength = GetConVar("sc_vision_strength"):GetFloat()
        
        if mode.id == "nightvision" then
            RenderNightVision(strength)
        elseif mode.id == "thermal" then
            RenderThermalVision(strength)
        elseif mode.id == "sonar" then
            RenderSonarVision(strength)
        end
    end)
    
    -- Halo rendering hook
    hook.Add("PreDrawHalos", "SplinterCellAbilityHalos", function()
        if not HasSplinterCellAbilities() or not visionActive then return end
        
        if visionModes[currentMode].id == "sonar" then
            DrawSonarHalos()
        end
    end)
    
    -- HUD for vision status
    hook.Add("HUDPaint", "SplinterCellAbilityHUD", function()
        if not HasSplinterCellAbilities() then return end
        
        local x, y = 50, 50
        
        -- Vision status
        if visionActive then
            local mode = visionModes[currentMode]
            draw.SimpleText("Vision: " .. mode.name, "DermaDefault", x, y, mode.color, TEXT_ALIGN_LEFT)
            draw.SimpleText("Energy: " .. math.floor(energy) .. "%", "DermaDefault", x, y + 20, Color(255, 255, 255), TEXT_ALIGN_LEFT)
        else
            draw.SimpleText("Vision: OFF", "DermaDefault", x, y, Color(100, 100, 100), TEXT_ALIGN_LEFT)
        end
        
        -- Controls reminder
        draw.SimpleText("N: Toggle | T: Mode", "DermaDefault", x, y + 40, Color(200, 200, 200), TEXT_ALIGN_LEFT)
    end)
    
    -- Network message handlers
    net.Receive("SC_AbilityState", function()
        visionActive = net.ReadBool()
        currentMode = net.ReadInt(8)
        
        if visionActive then
            local mode = visionModes[currentMode]
            surface.PlaySound(mode.sound)
            LocalPlayer():ChatPrint("Vision Mode: " .. mode.name)
        else
            LocalPlayer():ChatPrint("Vision Deactivated")
        end
    end)
    
else -- SERVER
    
    -- Network strings
    util.AddNetworkString("SC_AbilityToggle")
    util.AddNetworkString("SC_AbilityModeChange")
    util.AddNetworkString("SC_AbilityState")
    
    -- Server-side player data
    local playerData = {}
    
    -- Helper function to check if player has Splinter Cell abilities
    local function HasSplinterCellAbilities(ply)
        if not IsValid(ply) then return false end
        local team = ply:Team()
        return team == TEAM_SPLINTERCELL or team == TEAM_SPLINTERCOMMANDER
    end
    
    -- Initialize player data
    local function InitPlayerData(ply)
        playerData[ply] = {
            visionActive = false,
            currentMode = 1,
            energy = 100
        }
    end
    
    -- Clean up player data
    local function CleanupPlayerData(ply)
        playerData[ply] = nil
    end
    
    -- Toggle vision ability
    local function ToggleVision(ply)
        if not HasSplinterCellAbilities(ply) then
            ply:ChatPrint("You don't have access to this technology!")
            return
        end
        
        if not playerData[ply] then
            InitPlayerData(ply)
        end
        
        playerData[ply].visionActive = not playerData[ply].visionActive
        
        -- Send state to client
        net.Start("SC_AbilityState")
        net.WriteBool(playerData[ply].visionActive)
        net.WriteInt(playerData[ply].currentMode, 8)
        net.Send(ply)
    end
    
    -- Cycle vision mode
    local function CycleMode(ply)
        if not HasSplinterCellAbilities(ply) then return end
        if not playerData[ply] or not playerData[ply].visionActive then return end
        
        playerData[ply].currentMode = playerData[ply].currentMode % 3 + 1
        
        -- Send updated state to client
        net.Start("SC_AbilityState")
        net.WriteBool(playerData[ply].visionActive)
        net.WriteInt(playerData[ply].currentMode, 8)
        net.Send(ply)
    end
    
    -- Network receivers
    net.Receive("SC_AbilityToggle", function(len, ply)
        ToggleVision(ply)
    end)
    
    net.Receive("SC_AbilityModeChange", function(len, ply)
        CycleMode(ply)
    end)
    
    -- Player spawn handler
    hook.Add("PlayerSpawn", "SplinterCellAbilitySpawn", function(ply)
        timer.Simple(1, function() -- Delay to ensure team is set
            if IsValid(ply) and HasSplinterCellAbilities(ply) then
                InitPlayerData(ply)
                ply:ChatPrint("Splinter Cell abilities activated! Press N to toggle vision, T to cycle modes.")
            end
        end)
    end)
    
    -- Team change handler
    hook.Add("OnPlayerChangedTeam", "SplinterCellAbilityTeamChange", function(ply, before, after)
        if before == TEAM_SPLINTERCELL or before == TEAM_SPLINTERCOMMANDER then
            -- Player left Splinter Cell team, disable abilities
            if playerData[ply] then
                playerData[ply].visionActive = false
                net.Start("SC_AbilityState")
                net.WriteBool(false)
                net.WriteInt(1, 8)
                net.Send(ply)
            end
        end
        
        if after == TEAM_SPLINTERCELL or after == TEAM_SPLINTERCOMMANDER then
            -- Player joined Splinter Cell team, enable abilities
            InitPlayerData(ply)
            ply:ChatPrint("Splinter Cell abilities activated! Press N to toggle vision, T to cycle modes.")
        end
    end)
    
    -- Player disconnect cleanup
    hook.Add("PlayerDisconnected", "SplinterCellAbilityDisconnect", function(ply)
        CleanupPlayerData(ply)
    end)
    
end

print("[SPLINTER CELL] Ability system loaded successfully!")