-- ============================================================================
-- DarkRP Jobs for Splinter Cell Vision Goggles
-- ============================================================================
-- This file adds Splinter Cell jobs to DarkRP
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
TEAM_SPLINTERCELL = DarkRP.createJob("Splinter Cell Operative", {
    color = Color(0, 100, 0, 255),
    model = {
        "models/player/Group01/male_02.mdl",
        "models/player/Group01/male_04.mdl",
        "models/player/Group01/male_06.mdl",
        "models/player/Group01/male_08.mdl",
        "models/player/Group01/male_09.mdl"
    },
    description = [[You are an elite Splinter Cell operative specializing in covert operations.
    
    *** EXCLUSIVE JOB ABILITIES ***
    - Advanced Vision Technology built into your equipment (JOB ABILITY)
    - This cutting-edge technology is ONLY available to trained operatives
    - Night Vision, Thermal Vision, Sonar Vision capabilities
    
    CONTROLS:
    - N: Toggle vision modes on/off
    - T: Cycle through different vision modes
    
    VISION MODES:
    - Night Vision: Enhanced visibility in darkness with green overlay
    - Thermal Vision: See heat signatures of living beings
    - Sonar Vision: Detect movement with pulse-based scanning
    
    Your mission is to gather intelligence and complete objectives using stealth and advanced technology.
    Remember: Your vision abilities are classified and automatically activated when you become an operative!]],
    weapons = {"weapon_pistol"},
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
TEAM_SPLINTERCOMMANDER = DarkRP.createJob("Splinter Cell Commander", {
    color = Color(0, 150, 0, 255),
    model = {
        "models/player/Group01/male_01.mdl",
        "models/player/Group01/male_03.mdl",
        "models/player/Group01/male_05.mdl"
    },
    description = [[You are a Splinter Cell Commander leading covert operations.
    
    *** EXCLUSIVE COMMAND ABILITIES ***
    - Military-grade Vision Technology (CLASSIFIED JOB ABILITY)
    - Advanced tactical weapons
    - Leadership privileges
    - This technology is RESTRICTED to command personnel only
    
    SPECIAL ABILITIES:
    - Advanced Vision System with all modes
    - Can coordinate team operations
    - Access to restricted areas
    - Enhanced health and armor
    - Command-level tactical capabilities
    
    Lead your team to victory using superior technology and tactical expertise.
    Your abilities represent the pinnacle of military technology - unavailable to civilians!]],
    weapons = {"weapon_pistol", "stunstick"},
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