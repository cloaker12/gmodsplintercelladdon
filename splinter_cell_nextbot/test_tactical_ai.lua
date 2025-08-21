-- Splinter Cell NextBot - Enhanced Tactical AI Test
-- This file demonstrates the new tactical behaviors and states

if SERVER then
    util.AddNetworkString("SplinterCellTacticalTest")
    
    -- Test command to spawn enhanced Splinter Cell NextBot
    concommand.Add("spawn_tactical_splinter_cell", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            ply:PrintMessage(HUD_PRINTTALK, "You need admin privileges to spawn tactical Splinter Cell NextBot")
            return
        end
        
        local spawnPos = ply:GetPos() + Vector(0, 0, 50)
        local nextbot = ents.Create("nextbot_splinter_cell")
        
        if IsValid(nextbot) then
            nextbot:SetPos(spawnPos)
            nextbot:Spawn()
            
            -- Set initial tactical state
            nextbot:SetNWInt("tacticalState", 1)  -- Start in PATROL state
            nextbot:SetNWFloat("stealthLevel", 1.0)
            nextbot:SetNWString("currentObjective", "patrol")
            nextbot:SetNWBool("nightVisionActive", true)
            nextbot:SetNWInt("smokeGrenades", 3)
            nextbot:SetNWInt("ammoCount", 30)
            nextbot:SetNWInt("grenadesAvailable", 2)
            
            ply:PrintMessage(HUD_PRINTTALK, "Enhanced Tactical Splinter Cell NextBot spawned!")
            ply:PrintMessage(HUD_PRINTTALK, "States: PATROL → SUSPICIOUS → HUNT → ENGAGE → DISAPPEAR")
            ply:PrintMessage(HUD_PRINTTALK, "Features: NVG, Smoke Grenades, Tactical Movement, Stealth Takedowns")
        end
    end)
    
    -- Test command to cycle through tactical states
    concommand.Add("test_tactical_states", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            ply:PrintMessage(HUD_PRINTTALK, "You need admin privileges to test tactical states")
            return
        end
        
        local nextbots = ents.FindByClass("nextbot_splinter_cell")
        if #nextbots == 0 then
            ply:PrintMessage(HUD_PRINTTALK, "No Splinter Cell NextBots found. Spawn one first with spawn_tactical_splinter_cell")
            return
        end
        
        local nextbot = nextbots[1]
        local currentState = nextbot:GetNWInt("tacticalState", 1)
        local newState = (currentState % 5) + 1  -- Cycle through states 1-5
        
        nextbot:SetNWInt("tacticalState", newState)
        
        local stateNames = {
            [1] = "PATROL",
            [2] = "SUSPICIOUS", 
            [3] = "HUNT",
            [4] = "ENGAGE",
            [5] = "DISAPPEAR"
        }
        
        ply:PrintMessage(HUD_PRINTTALK, "Tactical State changed to: " .. stateNames[newState])
        ply:PrintMessage(HUD_PRINTTALK, "Movement: " .. nextbot:GetNWString("currentAnimation", "idle"))
    end)
    
    -- Test command to demonstrate tactical abilities
    concommand.Add("test_tactical_abilities", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            ply:PrintMessage(HUD_PRINTTALK, "You need admin privileges to test tactical abilities")
            return
        end
        
        local nextbots = ents.FindByClass("nextbot_splinter_cell")
        if #nextbots == 0 then
            ply:PrintMessage(HUD_PRINTTALK, "No Splinter Cell NextBots found. Spawn one first with spawn_tactical_splinter_cell")
            return
        end
        
        local nextbot = nextbots[1]
        
        -- Test different abilities
        local ability = args[1] or "all"
        
        if ability == "nvg" or ability == "all" then
            local nvActive = nextbot:GetNWBool("nightVisionActive", false)
            nextbot:SetNWBool("nightVisionActive", not nvActive)
            ply:PrintMessage(HUD_PRINTTALK, "Night Vision: " .. (not nvActive and "ACTIVE" or "INACTIVE"))
        end
        
        if ability == "smoke" or ability == "all" then
            local smokeCount = nextbot:GetNWInt("smokeGrenades", 3)
            if smokeCount > 0 then
                nextbot:SetNWInt("smokeGrenades", smokeCount - 1)
                ply:PrintMessage(HUD_PRINTTALK, "Smoke grenade deployed! Remaining: " .. (smokeCount - 1))
            else
                ply:PrintMessage(HUD_PRINTTALK, "No smoke grenades remaining!")
            end
        end
        
        if ability == "stealth" or ability == "all" then
            local stealthLevel = nextbot:GetNWFloat("stealthLevel", 1.0)
            local newStealth = math.max(0.0, stealthLevel - 0.2)
            nextbot:SetNWFloat("stealthLevel", newStealth)
            ply:PrintMessage(HUD_PRINTTALK, "Stealth Level: " .. math.floor(newStealth * 100) .. "%")
        end
        
        if ability == "movement" or ability == "all" then
            local movements = {"idle", "walk", "crouch_walk", "aim", "run"}
            local currentAnim = nextbot:GetNWString("currentAnimation", "idle")
            local currentIndex = 1
            for i, anim in ipairs(movements) do
                if anim == currentAnim then
                    currentIndex = i
                    break
                end
            end
            local newIndex = (currentIndex % #movements) + 1
            nextbot:SetNWString("currentAnimation", movements[newIndex])
            ply:PrintMessage(HUD_PRINTTALK, "Movement Style: " .. string.upper(movements[newIndex]))
        end
    end)
    
    -- Test command to create tactical environment
    concommand.Add("create_tactical_environment", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            ply:PrintMessage(HUD_PRINTTALK, "You need admin privileges to create tactical environment")
            return
        end
        
        local pos = ply:GetPos()
        
        -- Create light sources for tactical gameplay
        for i = 1, 5 do
            local light = ents.Create("light")
            if IsValid(light) then
                local lightPos = pos + Vector(math.random(-200, 200), math.random(-200, 200), 100)
                light:SetPos(lightPos)
                light:SetKeyValue("_light", "255 255 255 200")
                light:SetKeyValue("_lightHDR", "-1 -1 -1 1")
                light:SetKeyValue("_lightscaleHDR", "1")
                light:SetKeyValue("distance", "300")
                light:Spawn()
            end
        end
        
        -- Create cover objects
        for i = 1, 8 do
            local prop = ents.Create("prop_physics")
            if IsValid(prop) then
                local propPos = pos + Vector(math.random(-300, 300), math.random(-300, 300), 0)
                prop:SetModel("models/props_c17/woodbarrel01.mdl")
                prop:SetPos(propPos)
                prop:Spawn()
            end
        end
        
        ply:PrintMessage(HUD_PRINTTALK, "Tactical environment created! Light sources and cover objects added.")
        ply:PrintMessage(HUD_PRINTTALK, "The Splinter Cell NextBot will now use these for tactical gameplay.")
    end)
    
    -- Test command to demonstrate suspicion system
    concommand.Add("test_suspicion", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            ply:PrintMessage(HUD_PRINTTALK, "You need admin privileges to test suspicion system")
            return
        end
        
        local nextbots = ents.FindByClass("nextbot_splinter_cell")
        if #nextbots == 0 then
            ply:PrintMessage(HUD_PRINTTALK, "No Splinter Cell NextBots found. Spawn one first with spawn_tactical_splinter_cell")
            return
        end
        
        local nextbot = nextbots[1]
        local suspicionLevel = tonumber(args[1]) or 50
        
        nextbot:SetNWFloat("suspicionMeter", math.Clamp(suspicionLevel, 0, 100))
        
        ply:PrintMessage(HUD_PRINTTALK, "Suspicion Level set to: " .. suspicionLevel)
        if suspicionLevel >= 100 then
            ply:PrintMessage(HUD_PRINTTALK, "NextBot will transition to HUNT mode!")
        elseif suspicionLevel >= 50 then
            ply:PrintMessage(HUD_PRINTTALK, "NextBot is becoming suspicious...")
        else
            ply:PrintMessage(HUD_PRINTTALK, "NextBot is in normal patrol mode.")
        end
    end)
    
    -- Test command to demonstrate combat mechanics
    concommand.Add("test_combat", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then
            ply:PrintMessage(HUD_PRINTTALK, "You need admin privileges to test combat mechanics")
            return
        end
        
        local nextbots = ents.FindByClass("nextbot_splinter_cell")
        if #nextbots == 0 then
            ply:PrintMessage(HUD_PRINTTALK, "No Splinter Cell NextBots found. Spawn one first with spawn_tactical_splinter_cell")
            return
        end
        
        local nextbot = nextbots[1]
        
        -- Set combat stance
        local stance = args[1] or "standing"
        nextbot:SetNWString("combatStance", stance)
        
        -- Set ammo count
        local ammo = tonumber(args[2]) or 30
        nextbot:SetNWInt("ammoCount", ammo)
        
        -- Set grenades
        local grenades = tonumber(args[3]) or 2
        nextbot:SetNWInt("grenadesAvailable", grenades)
        
        ply:PrintMessage(HUD_PRINTTALK, "Combat Status:")
        ply:PrintMessage(HUD_PRINTTALK, "- Stance: " .. string.upper(stance))
        ply:PrintMessage(HUD_PRINTTALK, "- Ammo: " .. ammo .. "/30")
        ply:PrintMessage(HUD_PRINTTALK, "- Grenades: " .. grenades)
    end)
    
    -- Help command
    concommand.Add("splinter_cell_help", function(ply, cmd, args)
        ply:PrintMessage(HUD_PRINTTALK, "=== Splinter Cell NextBot - Enhanced Tactical AI ===")
        ply:PrintMessage(HUD_PRINTTALK, "Commands:")
        ply:PrintMessage(HUD_PRINTTALK, "- spawn_tactical_splinter_cell: Spawn enhanced NextBot")
        ply:PrintMessage(HUD_PRINTTALK, "- test_tactical_states: Cycle through AI states")
        ply:PrintMessage(HUD_PRINTTALK, "- test_tactical_abilities [nvg/smoke/stealth/movement/all]: Test abilities")
        ply:PrintMessage(HUD_PRINTTALK, "- create_tactical_environment: Create tactical environment")
        ply:PrintMessage(HUD_PRINTTALK, "- test_suspicion [0-100]: Test suspicion system")
        ply:PrintMessage(HUD_PRINTTALK, "- test_combat [stance] [ammo] [grenades]: Test combat mechanics")
        ply:PrintMessage(HUD_PRINTTALK, "")
        ply:PrintMessage(HUD_PRINTTALK, "Tactical States:")
        ply:PrintMessage(HUD_PRINTTALK, "1. PATROL: Low alert, stealth movement, NVG hum")
        ply:PrintMessage(HUD_PRINTTALK, "2. SUSPICIOUS: Investigating, crouch-walk, suspicion meter")
        ply:PrintMessage(HUD_PRINTTALK, "3. HUNT: Tactical stalking, cover-to-cover, circling")
        ply:PrintMessage(HUD_PRINTTALK, "4. ENGAGE: Combat, precision shots, stealth takedowns")
        ply:PrintMessage(HUD_PRINTTALK, "5. DISAPPEAR: Retreat with smoke, fake noises, reset")
    end)
    
    print("=== Splinter Cell NextBot - Enhanced Tactical AI Loaded ===")
    print("Use 'splinter_cell_help' in console for available commands")
    print("States: PATROL → SUSPICIOUS → HUNT → ENGAGE → DISAPPEAR")
    print("Features: NVG, Smoke Grenades, Tactical Movement, Stealth Takedowns")
    print("Movement Styles: ACT_WALK_PISTOL, ACT_WALK_CROUCH_PISTOL, ACT_IDLE_PISTOL")
end

if CLIENT then
    -- Client-side help display
    hook.Add("HUDPaint", "SplinterCellTacticalHelp", function()
        if not LocalPlayer():IsAdmin() then return end
        
        local helpText = {
            "=== Splinter Cell NextBot - Enhanced Tactical AI ===",
            "Admin Commands:",
            "spawn_tactical_splinter_cell - Spawn enhanced NextBot",
            "test_tactical_states - Cycle through AI states", 
            "test_tactical_abilities - Test tactical abilities",
            "create_tactical_environment - Create tactical environment",
            "test_suspicion [0-100] - Test suspicion system",
            "test_combat [stance] [ammo] [grenades] - Test combat",
            "splinter_cell_help - Show this help",
            "",
            "Tactical States:",
            "1. PATROL: Low alert, stealth movement, NVG hum",
            "2. SUSPICIOUS: Investigating, crouch-walk, suspicion meter", 
            "3. HUNT: Tactical stalking, cover-to-cover, circling",
            "4. ENGAGE: Combat, precision shots, stealth takedowns",
            "5. DISAPPEAR: Retreat with smoke, fake noises, reset"
        }
        
        local y = 50
        for i, text in ipairs(helpText) do
            draw.SimpleText(text, "DermaDefault", 10, y, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            y = y + 15
        end
    end)
    
    print("=== Splinter Cell NextBot - Enhanced Tactical AI Client Loaded ===")
    print("Admin help display active - use console commands to test")
end