-- ============================================================================
-- Splinter Cell Vision Goggles - Autorun Loader
-- ============================================================================
-- This file ensures proper loading order for DarkRP integration
-- ============================================================================

-- Print loading message
print("[AUTORUN] Loading Splinter Cell Vision Goggles...")

-- Check if weapon file exists
if file.Exists("lua/weapons/splinter_cell_vision.lua", "GAME") then
    print("[AUTORUN] Weapon file found: splinter_cell_vision.lua")
else
    print("[ERROR] Weapon file not found: weapons/splinter_cell_vision.lua")
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
            print("[AUTORUN] Weapon Available: " .. tostring(weapons.Get("splinter_cell_vision") ~= nil))
            if DarkRP then
                print("[AUTORUN] Jobs should be available in F4 menu under 'Special Forces'")
            else
                print("[AUTORUN] DarkRP not detected - addon will work as standalone weapon")
            end
            print("[AUTORUN] Splinter Cell Vision Goggles fully loaded!")
        end)
    end)
end

print("[AUTORUN] Splinter Cell autorun initialization complete!")