-- ============================================================================
-- Splinter Cell Vision Goggles - Autorun Loader
-- ============================================================================
-- This file ensures proper loading order for DarkRP integration
-- ============================================================================

-- Only run on server
if SERVER then
    -- Print loading message
    print("[AUTORUN] Loading Splinter Cell Vision Goggles...")
    
    -- Check if weapon file exists (don't include directly - let GMod's weapon system handle it)
    if file.Exists("lua/weapons/splinter_cell_vision.lua", "GAME") then
        print("[AUTORUN] Weapon file found: splinter_cell_vision.lua")
    else
        print("[ERROR] Weapon file not found: weapons/splinter_cell_vision.lua")
    end
    
    -- Load DarkRP configuration after a delay to ensure DarkRP is ready
    timer.Simple(0.5, function()
        if DarkRP then
            if file.Exists("lua/darkrp_customthings/splinter_cell_config.lua", "GAME") then
                include("darkrp_customthings/splinter_cell_config.lua")
                print("[AUTORUN] DarkRP configuration loaded: splinter_cell_config.lua")
            else
                print("[ERROR] DarkRP config file not found: darkrp_customthings/splinter_cell_config.lua")
            end
        else
            print("[WARNING] DarkRP not loaded yet, retrying in 1 second...")
            timer.Simple(1, function()
                if DarkRP then
                    include("darkrp_customthings/splinter_cell_config.lua")
                    print("[AUTORUN] DarkRP configuration loaded (delayed): splinter_cell_config.lua")
                else
                    print("[ERROR] DarkRP still not loaded! Manual configuration required.")
                end
            end)
        end
    end)
    
    print("[AUTORUN] Splinter Cell Vision Goggles autorun complete!")
end