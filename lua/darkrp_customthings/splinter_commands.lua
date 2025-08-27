-- ============================================================================
-- Splinter Cell Commands and Functionality
-- ============================================================================
-- Chat commands and admin commands for Splinter Cell addon (ABILITY SYSTEM)
-- ============================================================================

-- ============================================================================
-- CHAT COMMANDS
-- ============================================================================

-- Helper function to check if player has Splinter Cell abilities
local function HasSplinterCellAbilities(ply)
    if not IsValid(ply) then return false end
    local team = ply:Team()
    return team == TEAM_SPLINTERCELL or team == TEAM_SPLINTERCOMMANDER
end

-- Add chat command for vision toggle (backup method)
hook.Add("PlayerSay", "SplinterCellCommands", function(ply, text, teamChat)
    if string.lower(text) == "/togglevision" then
        if HasSplinterCellAbilities(ply) then
            -- Send toggle request through the ability system
            net.Start("SC_AbilityToggle")
            net.Send(ply)
            ply:ChatPrint("Vision mode toggle requested!")
        else
            ply:ChatPrint("You need to be a Splinter Cell operative to use vision abilities!")
        end
        return ""
    elseif string.lower(text) == "/cyclevision" then
        if HasSplinterCellAbilities(ply) then
            -- Send mode change request through the ability system
            net.Start("SC_AbilityModeChange")
            net.Send(ply)
            ply:ChatPrint("Vision mode cycle requested!")
        else
            ply:ChatPrint("You need to be a Splinter Cell operative to use vision abilities!")
        end
        return ""
    end
end)

-- ============================================================================
-- ADMIN COMMANDS
-- ============================================================================

-- Admin command to force a player to Splinter Cell job (which gives vision abilities)
concommand.Add("rp_makesplinter", function(ply, cmd, args)
    if not ply:IsAdmin() then 
        ply:ChatPrint("You don't have permission to use this command!")
        return 
    end
    
    local target = ply
    if args[1] then
        target = DarkRP.findPlayer(args[1])
        if not IsValid(target) then
            ply:ChatPrint("Player not found!")
            return
        end
    end
    
    target:changeTeam(TEAM_SPLINTERCELL, true)
    ply:ChatPrint("Made " .. target:Name() .. " a Splinter Cell operative (with vision abilities)")
    if target != ply then
        target:ChatPrint("You have been made a Splinter Cell operative by " .. ply:Name() .. "! You now have vision abilities.")
    end
end)

-- Test command to check if addon is working
concommand.Add("test_splinter", function(ply)
    if IsValid(ply) then
        ply:ChatPrint("=== Splinter Cell Addon Status ===")
        ply:ChatPrint("DarkRP Loaded: " .. tostring(DarkRP ~= nil))
        ply:ChatPrint("Has Abilities: " .. tostring(HasSplinterCellAbilities(ply)))
        ply:ChatPrint("Current Team: " .. team.GetName(ply:Team()))
        ply:ChatPrint("Splinter Teams: TEAM_SPLINTERCELL=" .. tostring(TEAM_SPLINTERCELL) .. ", TEAM_SPLINTERCOMMANDER=" .. tostring(TEAM_SPLINTERCOMMANDER))
        
        -- Test ability system
        if HasSplinterCellAbilities(ply) then
            ply:ChatPrint("✓ You have access to Splinter Cell vision abilities!")
            ply:ChatPrint("Press N to toggle vision, T to cycle modes")
        else
            ply:ChatPrint("✗ You need to be a Splinter Cell operative to use abilities")
        end
    end
end)

-- ============================================================================
-- LOADING CONFIRMATION
-- ============================================================================

-- DarkRP Integration Hooks for Ability System
hook.Add("playerBoughtCustomJob", "SplinterCellJobHandler", function(ply, jobTable)
    -- Check if this is a Splinter Cell job
    if jobTable.command == "splintercell" or jobTable.command == "splintercommander" then
        timer.Simple(0.5, function()
            if IsValid(ply) and HasSplinterCellAbilities(ply) then
                ply:ChatPrint("You have received advanced vision technology!")
                ply:ChatPrint("Press N to toggle vision modes, T to cycle between modes")
                ply:ChatPrint("Vision abilities are now ACTIVE as a job ability!")
            end
        end)
    end
end)

hook.Add("InitPostEntity", "SplinterCellCommandsLoaded", function()
    print("[DarkRP] Splinter Cell commands loaded successfully!")
    print("[DarkRP] - Chat Commands: /togglevision, /cyclevision")
    print("[DarkRP] - Admin Command: rp_makesplinter [player]")
    print("[DarkRP] - Test Command: test_splinter")
    print("[DarkRP] - Job integration enabled for automatic ABILITY distribution")
    print("[DarkRP] - Vision system converted from SWEP to JOB ABILITIES")
end)