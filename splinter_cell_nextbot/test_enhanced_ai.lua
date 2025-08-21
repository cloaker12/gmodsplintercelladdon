-- Enhanced Splinter Cell AI Test Script
-- Demonstrates new features: wall climbing, night vision, improved smoke grenades, and enhanced combat

if SERVER then
    util.AddNetworkString("TestEnhancedAI")
    
    -- Command to spawn enhanced AI
    concommand.Add("spawn_enhanced_splinter_cell", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local spawnPos = ply:GetPos() + Vector(0, 0, 50)
        local ai = ents.Create("nextbot_splinter_cell")
        
        if IsValid(ai) then
            ai:SetPos(spawnPos)
            ai:Spawn()
            
            -- Activate night vision immediately
            ai:ActivateNightVision()
            
            -- Give extra smoke grenades for testing
            ai.smokeGrenades = 5
            ai:SetNWInt("smokeGrenades", 5)
            
            -- Set target to the spawning player for testing
            ai.targetPlayer = ply
            ai.lastKnownPosition = ply:GetPos()
            
            ply:PrintMessage(HUD_PRINTTALK, "Enhanced Splinter Cell AI spawned with night vision and extra smoke grenades!")
        end
    end)
    
    -- Command to test wall climbing
    concommand.Add("test_wall_climb", function(ply, cmd, args)
        local ais = ents.FindByClass("nextbot_splinter_cell")
        for _, ai in pairs(ais) do
            if IsValid(ai) then
                ai:ChangeState(7) -- WALL_CLIMBING state
                ply:PrintMessage(HUD_PRINTTALK, "AI attempting wall climb...")
            end
        end
    end)
    
    -- Command to test smoke grenades
    concommand.Add("test_smoke_grenade", function(ply, cmd, args)
        local ais = ents.FindByClass("nextbot_splinter_cell")
        for _, ai in pairs(ais) do
            if IsValid(ai) then
                ai:ChangeState(9) -- TACTICAL_SMOKE state
                ply:PrintMessage(HUD_PRINTTALK, "AI deploying tactical smoke...")
            end
        end
    end)
    
    -- Command to test evasive maneuvers
    concommand.Add("test_evasion", function(ply, cmd, args)
        local ais = ents.FindByClass("nextbot_splinter_cell")
        for _, ai in pairs(ais) do
            if IsValid(ai) then
                ai:ChangeState(8) -- EVASIVE_MANEUVER state
                ply:PrintMessage(HUD_PRINTTALK, "AI performing evasive maneuvers...")
            end
        end
    end)
    
    -- Command to test night vision hunting
    concommand.Add("test_night_hunt", function(ply, cmd, args)
        local ais = ents.FindByClass("nextbot_splinter_cell")
        for _, ai in pairs(ais) do
            if IsValid(ai) then
                ai:ChangeState(10) -- NIGHT_VISION_HUNT state
                ply:PrintMessage(HUD_PRINTTALK, "AI using night vision to hunt...")
            end
        end
    end)
    
    -- Command to display AI status
    concommand.Add("ai_status", function(ply, cmd, args)
        local ais = ents.FindByClass("nextbot_splinter_cell")
        for _, ai in pairs(ais) do
            if IsValid(ai) then
                local state = ai:GetNWInt("tacticalState", 1)
                local stealth = ai:GetNWFloat("stealthLevel", 1.0)
                local nightVision = ai:GetNWBool("nightVisionActive", false)
                local smokeGrenades = ai:GetNWInt("smokeGrenades", 3)
                local ammoCount = ai:GetNWInt("ammoCount", 30)
                local isClimbing = ai:GetNWBool("isClimbing", false)
                local combatStance = ai:GetNWString("combatStance", "standing")
                
                ply:PrintMessage(HUD_PRINTTALK, string.format("AI Status - State: %d, Stealth: %.2f, Night Vision: %s, Smoke: %d, Ammo: %d, Climbing: %s, Stance: %s", 
                    state, stealth, tostring(nightVision), smokeGrenades, ammoCount, tostring(isClimbing), combatStance))
            end
        end
    end)
    
    -- Command to create test environment
    concommand.Add("create_test_environment", function(ply, cmd, args)
        -- Create some walls for climbing
        for i = 1, 3 do
            local wall = ents.Create("func_brush")
            if IsValid(wall) then
                local pos = ply:GetPos() + Vector(i * 200, 0, 0)
                wall:SetPos(pos)
                wall:SetModel("models/props_junk/wooden_box01a.mdl")
                wall:SetKeyValue("solidity", "6")
                wall:Spawn()
            end
        end
        
        -- Create some light sources to disable
        for i = 1, 2 do
            local light = ents.Create("light")
            if IsValid(light) then
                local pos = ply:GetPos() + Vector(0, i * 150, 100)
                light:SetPos(pos)
                light:SetKeyValue("_light", "255 255 255 200")
                light:SetKeyValue("distance", "300")
                light:Spawn()
            end
        end
        
        ply:PrintMessage(HUD_PRINTTALK, "Test environment created with walls and lights!")
    end)
end

if CLIENT then
    -- Display help information
    hook.Add("HUDPaint", "EnhancedAIHelp", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        -- Check if there are any Splinter Cell AIs nearby
        local ais = ents.FindByClass("nextbot_splinter_cell")
        local nearbyAI = false
        for _, ai in pairs(ais) do
            if IsValid(ai) and ply:GetPos():Distance(ai:GetPos()) < 1000 then
                nearbyAI = true
                break
            end
        end
        
        if nearbyAI then
            local y = 50
            draw.SimpleText("Enhanced Splinter Cell AI Commands:", "DermaDefault", 10, y, Color(255, 255, 255))
            y = y + 20
            draw.SimpleText("spawn_enhanced_splinter_cell - Spawn AI with night vision", "DermaDefault", 10, y, Color(200, 200, 200))
            y = y + 15
            draw.SimpleText("test_wall_climb - Test wall climbing", "DermaDefault", 10, y, Color(200, 200, 200))
            y = y + 15
            draw.SimpleText("test_smoke_grenade - Test tactical smoke", "DermaDefault", 10, y, Color(200, 200, 200))
            y = y + 15
            draw.SimpleText("test_evasion - Test evasive maneuvers", "DermaDefault", 10, y, Color(200, 200, 200))
            y = y + 15
            draw.SimpleText("test_night_hunt - Test night vision hunting", "DermaDefault", 10, y, Color(200, 200, 200))
            y = y + 15
            draw.SimpleText("ai_status - Show AI status", "DermaDefault", 10, y, Color(200, 200, 200))
            y = y + 15
            draw.SimpleText("create_test_environment - Create test walls and lights", "DermaDefault", 10, y, Color(200, 200, 200))
        end
    end)
    
    -- Enhanced visual effects for night vision
    hook.Add("RenderScreenspaceEffects", "EnhancedAINightVision", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        -- Check if player is near AI with night vision
        local ais = ents.FindByClass("nextbot_splinter_cell")
        for _, ai in pairs(ais) do
            if IsValid(ai) and ai:GetNWBool("nightVisionActive", false) then
                local distance = ply:GetPos():Distance(ai:GetPos())
                if distance < 300 then
                    -- Apply night vision effect to player
                    local intensity = math.max(0, (300 - distance) / 300)
                    
                    -- Green tint effect
                    local tab = {
                        ["$pp_colour_addr"] = 0,
                        ["$pp_colour_addg"] = intensity * 0.1,
                        ["$pp_colour_addb"] = 0,
                        ["$pp_colour_brightness"] = intensity * 0.05,
                        ["$pp_colour_contrast"] = 1 + intensity * 0.1,
                        ["$pp_colour_colour"] = 1 + intensity * 0.2,
                        ["$pp_colour_mulr"] = 0,
                        ["$pp_colour_mulg"] = 0,
                        ["$pp_colour_mulb"] = 0
                    }
                    
                    DrawColorModify(tab)
                    DrawBloom(0.5, intensity * 2, 8, 8, 1, 1, 1, 1, 1)
                end
            end
        end
    end)
end

print("Enhanced Splinter Cell AI test script loaded!")
print("Use 'spawn_enhanced_splinter_cell' to spawn an AI with all new features!")
print("New features include:")
print("- Wall climbing capability")
print("- Night vision goggles with enhanced detection")
print("- Improved smoke grenade system with tactical uses")
print("- Enhanced navigation and evasion")
print("- Improved combat mechanics with accuracy and stance changes")