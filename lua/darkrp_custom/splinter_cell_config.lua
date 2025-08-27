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
timer.Simple(1, function()
    if not weapons.Get("splinter_cell_vision") then
        print("[WARNING] splinter_cell_vision weapon not found! Make sure the weapon file is loaded.")
    end
end)

-- ============================================================================
-- ENTITIES
-- ============================================================================

-- Get available teams (fallback to TEAM_CITIZEN if others don't exist)
local allowedTeams = {}
if TEAM_CITIZEN then table.insert(allowedTeams, TEAM_CITIZEN) end
if TEAM_POLICE then table.insert(allowedTeams, TEAM_POLICE) end
if TEAM_GANG then table.insert(allowedTeams, TEAM_GANG) end
if TEAM_MOB then table.insert(allowedTeams, TEAM_MOB) end

-- Ensure we have at least one team
if #allowedTeams == 0 then
    allowedTeams = {TEAM_CITIZEN}
end

-- Multiple attempts to create entity with different timing
local function CreateSplinterEntity()
    if DarkRP and DarkRP.createEntity then
        local success, err = pcall(function()
            -- Create the entity for the F4 menu
            DarkRP.createEntity("Splinter Cell Vision Goggles", {
                ent = "splinter_cell_vision",
                model = "models/weapons/w_pistol.mdl", -- Using default pistol model as placeholder
                price = 7500,
                max = 1,
                cmd = "buysplintervision",
                allowed = allowedTeams
            })
        end)
        
        if success then
            print("[DarkRP] Splinter Cell Vision Goggles entity created successfully!")
            return true
        else
            print("[ERROR] Failed to create DarkRP entity: " .. tostring(err))
            return false
        end
    else
        print("[ERROR] DarkRP.createEntity not available")
        return false
    end
end

-- Try creating immediately
if not CreateSplinterEntity() then
    -- Try again after 2 seconds
    timer.Simple(2, function()
        if not CreateSplinterEntity() then
            -- Final attempt after 5 seconds
            timer.Simple(3, CreateSplinterEntity)
        end
    end)
end

-- Create a shipment for bulk purchase (also delayed)
timer.Simple(2.5, function()
    if DarkRP and DarkRP.createShipment then
        DarkRP.createShipment("Splinter Cell Vision Goggles", {
            model = "models/weapons/w_pistol.mdl",
            entity = "splinter_cell_vision",
            price = 67500,
            amount = 10,
            separate = true,
            pricesep = 7500,
            noship = false,
            allowed = allowedTeams
        })
        print("[DarkRP] Splinter Cell Vision Goggles shipment created successfully!")
    else
        print("[ERROR] Could not create DarkRP shipment for Splinter Cell Vision Goggles")
    end
end)

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
    
    EQUIPMENT:
    - Advanced Vision Goggles with multiple modes
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
    
    Your mission is to gather intelligence and complete objectives using stealth and advanced technology.]],
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
    
    ENHANCED EQUIPMENT:
    - Military-grade Vision Goggles
    - Advanced tactical weapons
    - Leadership privileges
    
    SPECIAL ABILITIES:
    - Can coordinate team operations
    - Access to restricted areas
    - Enhanced health and armor
    
    Lead your team to victory using superior technology and tactical expertise.]],
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
    print("[DarkRP] - Weapon: splinter_cell_vision")
    print("[DarkRP] - Jobs: Splinter Cell Operative, Splinter Cell Commander")
    print("[DarkRP] - Chat Commands: /togglevision, /cyclevision")
    print("[DarkRP] - Admin Command: rp_givevision [player]")
    print("[DarkRP] - Test Command: test_splinter (for admins)")
    print("[DarkRP] - If items don't appear in F4, try restarting the server")
end)