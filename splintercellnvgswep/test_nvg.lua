-- Test script for Splinter Cell Goggles SWEP - Enhanced Version
-- Run this in console or as admin to test the weapon

if SERVER then
    -- Give the goggles weapon to the player
    concommand.Add("test_goggles", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local weapon = ply:Give("splintercell_nvg")
        if IsValid(weapon) then
            ply:SelectWeapon(weapon)
            ply:ChatPrint("Splinter Cell Goggles given! Use Left Click to toggle goggles.")
        else
            ply:ChatPrint("Failed to give goggles. Make sure the addon is properly installed.")
        end
    end)
    
    -- Test battery functions
    concommand.Add("goggles_battery", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
            local battery = args[1] or 100
            weapon.Battery = math.Clamp(tonumber(battery) or 100, 0, 100)
            ply:ChatPrint("Goggles Battery set to " .. weapon.Battery .. "%")
        else
            ply:ChatPrint("You need to have the goggles equipped!")
        end
    end)
    
    -- Test goggles toggle
    concommand.Add("goggles_toggle", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
            if weapon.GogglesEnabled then
                weapon:DisableGoggles()
                ply:ChatPrint("Goggles Disabled")
            else
                weapon:EnableGoggles()
                ply:ChatPrint("Goggles Enabled")
            end
        else
            ply:ChatPrint("You need to have the goggles equipped!")
        end
    end)
    
    -- Test mode cycling
    concommand.Add("goggles_mode", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
            weapon:CycleMode()
        else
            ply:ChatPrint("You need to have the goggles equipped!")
        end
    end)
    
    -- Test sonar pulse
    concommand.Add("goggles_sonar", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
            weapon:TriggerSonarPulse()
            ply:ChatPrint("Sonar pulse triggered!")
        else
            ply:ChatPrint("You need to have the goggles equipped!")
        end
    end)
    
    -- Test settings
    concommand.Add("goggles_settings_test", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
            ply:ChatPrint("=== Goggles Settings ===")
            ply:ChatPrint("Auto Recharge: " .. (weapon.Settings.autoRecharge and "ON" or "OFF"))
            ply:ChatPrint("Low Battery Warning: " .. weapon.Settings.lowBatteryWarning .. "%")
            ply:ChatPrint("Pulse Volume: " .. weapon.Settings.pulseVolume)
            ply:ChatPrint("Overlay Opacity: " .. weapon.Settings.overlayOpacity)
        else
            ply:ChatPrint("You need to have the goggles equipped!")
        end
    end)
    
    print("Splinter Cell Goggles Test Commands loaded:")
    print("test_goggles - Give the goggles weapon")
    print("goggles_battery <amount> - Set battery level (0-100)")
    print("goggles_toggle - Toggle goggles on/off")
    print("goggles_mode - Cycle through vision modes")
    print("goggles_sonar - Trigger sonar pulse manually")
    print("goggles_settings_test - Show current settings")
end

if CLIENT then
    -- Client-side test commands
    concommand.Add("goggles_info", function()
        local ply = LocalPlayer()
        local weapon = ply:GetActiveWeapon()
        
        if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
            print("=== Splinter Cell Goggles Status ===")
            print("Enabled:", weapon.GogglesEnabled)
            print("Mode:", weapon.Modes[weapon.CurrentMode].name)
            print("Battery:", weapon.Battery .. "%")
            print("Brightness:", weapon.Brightness)
            print("Intensity:", weapon.Intensity)
            print("Sonar Detections:", table.Count(weapon.SonarDetections))
            print("Last Sonar Pulse:", weapon.LastSonarPulse)
        else
            print("Goggles not equipped!")
        end
    end)
    
    -- Test sonar detection display
    concommand.Add("goggles_sonar_test", function()
        local ply = LocalPlayer()
        local weapon = ply:GetActiveWeapon()
        
        if IsValid(weapon) and weapon:GetClass() == "splintercell_nvg" then
            print("=== Sonar Detection Test ===")
            print("Current Detections:")
            for entity, detectionTime in pairs(weapon.SonarDetections) do
                if IsValid(entity) then
                    print("- " .. entity:GetClass() .. " at " .. tostring(entity:GetPos()) .. " (detected at " .. detectionTime .. ")")
                end
            end
        else
            print("Goggles not equipped!")
        end
    end)
    
    print("Client test commands loaded:")
    print("goggles_info - Show goggles status")
    print("goggles_sonar_test - Show sonar detections")
    print("goggles_settings - Show settings (in console)")
end
