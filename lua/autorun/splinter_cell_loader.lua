-- ============================================================================
-- Splinter Cell Abilities System - Autorun Loader
-- ============================================================================
-- This file ensures proper loading order for DarkRP integration (ABILITY SYSTEM)
-- ============================================================================

-- Print loading message
print("[AUTORUN] Loading Splinter Cell Abilities System...")

-- Check if ability system file exists
if file.Exists("lua/darkrp_customthings/splinter_abilities.lua", "GAME") then
    print("[AUTORUN] Ability system found: splinter_abilities.lua")
else
    print("[ERROR] Ability system not found: darkrp_customthings/splinter_abilities.lua")
end

-- Load ability system files
if file.Exists("lua/darkrp_customthings/splinter_abilities.lua", "GAME") then
    include("darkrp_customthings/splinter_abilities.lua")
    print("[AUTORUN] Splinter Cell abilities loaded")
end

-- Load extended abilities system
if file.Exists("lua/darkrp_customthings/splinter_abilities_extended.lua", "GAME") then
    include("darkrp_customthings/splinter_abilities_extended.lua")
    print("[AUTORUN] Splinter Cell extended abilities loaded")
end

-- Load advanced HUD system
if file.Exists("lua/darkrp_customthings/splinter_hud_system.lua", "GAME") then
    include("darkrp_customthings/splinter_hud_system.lua")
    print("[AUTORUN] Splinter Cell HUD system loaded")
end

-- Load networking and team coordination
if file.Exists("lua/darkrp_customthings/splinter_networking.lua", "GAME") then
    include("darkrp_customthings/splinter_networking.lua")
    print("[AUTORUN] Splinter Cell networking system loaded")
end

-- Load environmental effects system
if file.Exists("lua/darkrp_customthings/splinter_environmental.lua", "GAME") then
    include("darkrp_customthings/splinter_environmental.lua")
    print("[AUTORUN] Splinter Cell environmental system loaded")
end

-- Load advanced systems module
if file.Exists("lua/darkrp_customthings/splinter_advanced_systems.lua", "GAME") then
    include("darkrp_customthings/splinter_advanced_systems.lua")
    print("[AUTORUN] Splinter Cell advanced systems loaded")
end

-- Only handle DarkRP-specific loading on server
if SERVER then
    -- Load chat commands and other functionality
    if file.Exists("lua/darkrp_customthings/splinter_commands.lua", "GAME") then
        include("darkrp_customthings/splinter_commands.lua")
        print("[AUTORUN] Splinter Cell commands loaded")
    end
    
    -- DarkRP will automatically load jobs.lua from darkrp_customthings folder
    -- No need to manually include it here
    
    -- Hook to confirm everything loaded properly
    hook.Add("InitPostEntity", "SplinterCellAutorunComplete", function()
        timer.Simple(2, function()
            print("[AUTORUN] === Splinter Cell Addon Status ===")
            print("[AUTORUN] DarkRP Loaded: " .. tostring(DarkRP ~= nil))
            print("[AUTORUN] Ability System: ACTIVE (No SWEP required)")
            if DarkRP then
                print("[AUTORUN] Jobs available in F4 menu under 'Special Forces'")
                print("[AUTORUN] Vision abilities automatically granted to Splinter Cell operatives")
            else
                print("[AUTORUN] DarkRP not detected - ability system requires DarkRP")
            end
            print("[AUTORUN] Splinter Cell Abilities System fully loaded!")
        end)
    end)
end

print("[AUTORUN] Splinter Cell ability system initialization complete!")