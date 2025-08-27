-- ============================================================================
-- Splinter Cell Commands and Functionality
-- ============================================================================
-- Chat commands and admin commands for Splinter Cell addon
-- ============================================================================

-- ============================================================================
-- CHAT COMMANDS
-- ============================================================================

-- Add chat command for vision toggle (backup method)
hook.Add("PlayerSay", "SplinterCellCommands", function(ply, text, teamChat)
    if string.lower(text) == "/togglevision" then
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "splinter_cell_vision" then
            if weapon.ToggleVision then
                weapon:ToggleVision()
                ply:ChatPrint("Vision mode toggled!")
            end
        else
            ply:ChatPrint("You need to have Splinter Cell Vision Goggles equipped!")
        end
        return ""
    elseif string.lower(text) == "/cyclevision" then
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "splinter_cell_vision" then
            if weapon.CycleVisionMode then
                weapon:CycleVisionMode()
                ply:ChatPrint("Vision mode cycled!")
            end
        else
            ply:ChatPrint("You need to have Splinter Cell Vision Goggles equipped!")
        end
        return ""
    end
end)

-- ============================================================================
-- ADMIN COMMANDS
-- ============================================================================

-- Admin command to give vision goggles
concommand.Add("rp_givevision", function(ply, cmd, args)
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
    
    target:Give("splinter_cell_vision")
    ply:ChatPrint("Gave Splinter Cell Vision Goggles to " .. target:Name())
    if target != ply then
        target:ChatPrint("You received Splinter Cell Vision Goggles from " .. ply:Name())
    end
end)

-- Test command to check if addon is working
concommand.Add("test_splinter", function(ply)
    if IsValid(ply) then
        ply:ChatPrint("=== Splinter Cell Addon Status ===")
        ply:ChatPrint("DarkRP Loaded: " .. tostring(DarkRP ~= nil))
        ply:ChatPrint("Weapon Exists: " .. tostring(weapons.Get("splinter_cell_vision") ~= nil))
        
        -- Try giving the weapon directly
        if ply:IsAdmin() then
            ply:Give("splinter_cell_vision")
            ply:ChatPrint("Weapon given directly (admin only)")
        end
    end
end)

-- ============================================================================
-- LOADING CONFIRMATION
-- ============================================================================

hook.Add("InitPostEntity", "SplinterCellCommandsLoaded", function()
    print("[DarkRP] Splinter Cell commands loaded successfully!")
    print("[DarkRP] - Chat Commands: /togglevision, /cyclevision")
    print("[DarkRP] - Admin Command: rp_givevision [player]")
    print("[DarkRP] - Test Command: test_splinter (for admins)")
end)