-- ============================================================================
-- DarkRP Configuration for Splinter Cell Vision Goggles
-- ============================================================================
-- This file adds the Splinter Cell Vision Goggles to DarkRP
-- Supports latest splinter_cell_vision.lua weapon with multiple vision modes
-- ============================================================================

-- Check if DarkRP is loaded
if not DarkRP then 
    print("[ERROR] DarkRP not detected! Splinter Cell Vision Goggles config will not load.")
    return 
end

-- Ensure the weapon exists before adding to DarkRP
timer.Simple(2, function()
    if not weapons.Get("splinter_cell_vision") then
        print("[WARNING] splinter_cell_vision weapon not found! Make sure the weapon file is properly placed in lua/weapons/")
        print("[INFO] The weapon should load automatically through GMod's weapon system.")
    else
        print("[SUCCESS] splinter_cell_vision weapon loaded successfully!")
    end
end)

-- ============================================================================
-- ENTITIES & SHIPMENTS - DISABLED
-- ============================================================================
-- NOTE: Splinter Cell Vision Goggles are now JOB-EXCLUSIVE abilities only!
-- They are NOT available for purchase through F4 menu or shipments.
-- Only players with Splinter Cell jobs can use these advanced vision systems.
-- ============================================================================

-- ============================================================================
-- CATEGORIES
-- ============================================================================

-- Create the Special Forces category
DarkRP.createCategory{
    name = "Special Forces",
    categorises = "jobs",
    startExpanded = true,
    color = Color(0, 150, 0, 255),
    canSee = function(ply) return true end,
    sortOrder = 100,
}

-- ============================================================================
-- CUSTOM JOBS
-- ============================================================================

-- Splinter Cell Operative Job
DarkRP.createJob("Splinter Cell Operative", {
    color = Color(0, 100, 0, 255),
    model = {
        "models/player/Group01/male_02.mdl",
        "models/player/Group01/male_04.mdl",
        "models/player/Group01/male_06.mdl",
        "models/player/Group01/male_08.mdl",
        "models/player/Group01/male_09.mdl"
    },
    description = [[You are an elite Splinter Cell operative specializing in covert operations.
    
    *** EXCLUSIVE JOB-ONLY EQUIPMENT ***
    - Advanced Vision Goggles with multiple modes (NOT PURCHASABLE)
    - This cutting-edge technology is ONLY available to trained operatives
    - Night Vision, Thermal Vision, Sonar Vision, and more
    
    CONTROLS:
    - N: Toggle vision modes on/off
    - T: Cycle through different vision modes
    
    VISION MODES:
    - Night Vision: Enhanced visibility in darkness
    - Thermal Vision: See heat signatures through walls
    - Sonar Vision: Detect movement and objects
    - X-Ray Vision: See through solid objects
    - Motion Detection: Highlight moving targets
    - EMP Vision: Detect electronic devices
    
    Your mission is to gather intelligence and complete objectives using stealth and advanced technology.
    Remember: Your vision technology is classified and cannot be obtained by civilians!]],
    weapons = {"splinter_cell_vision", "weapon_pistol"},
    command = "splintercell",
    max = 3,
    salary = 75,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Special Forces",
    PlayerSpawn = function(ply)
        ply:SetMaxHealth(120)
        ply:SetHealth(120)
        ply:SetArmor(50)
    end
})

-- Splinter Cell Commander Job (VIP/Donator Job)
DarkRP.createJob("Splinter Cell Commander", {
    color = Color(0, 150, 0, 255),
    model = {
        "models/player/Group01/male_01.mdl",
        "models/player/Group01/male_03.mdl",
        "models/player/Group01/male_05.mdl"
    },
    description = [[You are a Splinter Cell Commander leading covert operations.
    
    *** EXCLUSIVE MILITARY-GRADE EQUIPMENT ***
    - Military-grade Vision Goggles (CLASSIFIED TECHNOLOGY)
    - Advanced tactical weapons
    - Leadership privileges
    - This technology is RESTRICTED to command personnel only
    
    SPECIAL ABILITIES:
    - Can coordinate team operations
    - Access to restricted areas
    - Enhanced health and armor
    - Command-level vision system access
    
    Lead your team to victory using superior technology and tactical expertise.
    Your equipment represents the pinnacle of military technology - unavailable to civilians!]],
    weapons = {"splinter_cell_vision", "weapon_pistol", "stunstick"},
    command = "splintercommander",
    max = 1,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = true,
    candemote = false,
    category = "Special Forces",
    customCheck = function(ply) 
        -- Add your VIP/donator check here
        -- return ply:IsVIP() or ply:IsDonator()
        return true -- Remove this line and add your check
    end,
    CustomCheckFailMsg = "You need to be a VIP/Donator to become a Splinter Cell Commander!",
    PlayerSpawn = function(ply)
        ply:SetMaxHealth(150)
        ply:SetHealth(150)
        ply:SetArmor(75)
    end
})

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

-- ============================================================================
-- CONFIGURATION MESSAGES
-- ============================================================================

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

hook.Add("InitPostEntity", "SplinterCellConfigLoaded", function()
    print("[DarkRP] Splinter Cell Vision Goggles configuration loaded successfully!")
    print("[DarkRP] - Weapon: splinter_cell_vision (JOB-EXCLUSIVE ONLY)")
    print("[DarkRP] - Jobs: Splinter Cell Operative, Splinter Cell Commander")
    print("[DarkRP] - Chat Commands: /togglevision, /cyclevision")
    print("[DarkRP] - Admin Command: rp_givevision [player]")
    print("[DarkRP] - Test Command: test_splinter (for admins)")
    print("[DarkRP] - NOTE: NVGs are NOT purchasable - job abilities only!")
end)