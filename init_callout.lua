-- Cartel Convoy Callout Integration Script
-- This script initializes and manages the tactical callout system

local CartelConvoyCallout = require('cartel_convoy_callout')

-- Global callout manager
local CalloutManager = {
    activeCallout = nil,
    calloutAvailable = true,
    cooldownTime = 300000, -- 5 minutes between callouts
    lastCalloutTime = 0
}

-- Command to start the mission
RegisterCommand('start_convoy_mission', function(source, args, rawCommand)
    if CalloutManager.calloutAvailable and not CalloutManager.activeCallout then
        CalloutManager.activeCallout = CartelConvoyCallout
        
        local success = CalloutManager.activeCallout:Initialize()
        
        if success then
            CalloutManager.calloutAvailable = false
            CalloutManager.lastCalloutTime = GetGameTimer()
            
            TriggerEvent('chat:addMessage', {
                color = {0, 255, 0},
                multiline = true,
                args = {"[TACTICAL CALLOUT]", "Operation Shadow Strike initiated. Check your radio for briefing."}
            })
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                multiline = true,
                args = {"[ERROR]", "Failed to initialize convoy mission."}
            })
        end
    else
        local timeRemaining = math.max(0, CalloutManager.cooldownTime - (GetGameTimer() - CalloutManager.lastCalloutTime))
        local minutesRemaining = math.ceil(timeRemaining / 60000)
        
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"[CALLOUT]", "Mission not available. Cooldown: " .. minutesRemaining .. " minutes remaining."}
        })
    end
end, false)

-- Command to end the mission
RegisterCommand('end_convoy_mission', function(source, args, rawCommand)
    if CalloutManager.activeCallout then
        CalloutManager.activeCallout:Cleanup()
        CalloutManager.activeCallout = nil
        CalloutManager.calloutAvailable = true
        
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"[TACTICAL CALLOUT]", "Mission terminated. All units return to base."}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"[ERROR]", "No active mission to terminate."}
        })
    end
end, false)

-- Auto-trigger system (optional random callouts)
local AutoCalloutSystem = {
    enabled = false,
    minInterval = 1800000, -- 30 minutes
    maxInterval = 3600000, -- 60 minutes
    nextCalloutTime = 0
}

-- Enable/disable auto callouts
RegisterCommand('toggle_auto_callouts', function(source, args, rawCommand)
    AutoCalloutSystem.enabled = not AutoCalloutSystem.enabled
    
    if AutoCalloutSystem.enabled then
        AutoCalloutSystem.nextCalloutTime = GetGameTimer() + math.random(AutoCalloutSystem.minInterval, AutoCalloutSystem.maxInterval)
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"[AUTO CALLOUTS]", "Automatic tactical callouts enabled."}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"[AUTO CALLOUTS]", "Automatic tactical callouts disabled."}
        })
    end
end, false)

-- Help command
RegisterCommand('convoy_help', function(source, args, rawCommand)
    TriggerEvent('chat:addMessage', {
        color = {0, 200, 255},
        multiline = true,
        args = {"[TACTICAL CALLOUT HELP]", 
               "\n/start_convoy_mission - Start Operation Shadow Strike" ..
               "\n/end_convoy_mission - Terminate active mission" ..
               "\n/toggle_auto_callouts - Enable/disable random callouts" ..
               "\n\nMission Controls:" ..
               "\nE - Signal synchronized strike (when Ghost team is ready)" ..
               "\nN - Toggle night vision" ..
               "\n\nMission Phases:" ..
               "\n1. INTERCEPT - Ambush the convoy before it reaches the compound" ..
               "\n2. COMPOUND - If convoy escapes, breach the fortified base" ..
               "\n3. EXTRACTION - Helicopter extraction with evidence/prisoners" ..
               "\n\nSuccess Types:" ..
               "\nGhost - Silent operation, no alarms" ..
               "\nPanther - Partial stealth, minimal casualties" ..
               "\nAssault - Loud approach, heavy firefight"}
    })
end, false)

-- Status command
RegisterCommand('convoy_status', function(source, args, rawCommand)
    if CalloutManager.activeCallout then
        local phase = "Unknown"
        if CalloutManager.activeCallout.MISSION_CONFIG then
            phase = CalloutManager.activeCallout.MISSION_CONFIG.phases[CalloutManager.activeCallout.MISSION_CONFIG.currentPhase] or "Unknown"
        end
        
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"[MISSION STATUS]", "Active: Operation Shadow Strike | Phase: " .. phase}
        })
    else
        local timeRemaining = math.max(0, CalloutManager.cooldownTime - (GetGameTimer() - CalloutManager.lastCalloutTime))
        local minutesRemaining = math.ceil(timeRemaining / 60000)
        
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 0},
            multiline = true,
            args = {"[MISSION STATUS]", "No active mission | Cooldown: " .. minutesRemaining .. " minutes"}
        })
    end
end, false)

-- Main thread for auto callouts and cooldown management
Citizen.CreateThread(function()
    while true do
        local currentTime = GetGameTimer()
        
        -- Handle cooldown
        if not CalloutManager.calloutAvailable and (currentTime - CalloutManager.lastCalloutTime) >= CalloutManager.cooldownTime then
            CalloutManager.calloutAvailable = true
        end
        
        -- Handle auto callouts
        if AutoCalloutSystem.enabled and CalloutManager.calloutAvailable and currentTime >= AutoCalloutSystem.nextCalloutTime then
            if not CalloutManager.activeCallout then
                -- Trigger random callout
                ExecuteCommand('start_convoy_mission')
                
                -- Set next callout time
                AutoCalloutSystem.nextCalloutTime = currentTime + math.random(AutoCalloutSystem.minInterval, AutoCalloutSystem.maxInterval)
            end
        end
        
        Citizen.Wait(30000) -- Check every 30 seconds
    end
end)

-- Event handlers for mission completion
AddEventHandler('convoy:missionComplete', function(result)
    CalloutManager.activeCallout = nil
    CalloutManager.lastCalloutTime = GetGameTimer()
    
    -- Shorter cooldown for successful missions
    if result == "GHOST_SUCCESS" or result == "PANTHER_SUCCESS" then
        CalloutManager.cooldownTime = 180000 -- 3 minutes
    else
        CalloutManager.cooldownTime = 300000 -- 5 minutes
    end
end)

-- Initialize notification system
TriggerEvent('chat:addMessage', {
    color = {0, 255, 255},
    multiline = true,
    args = {"[TACTICAL CALLOUT SYSTEM]", 
           "Cartel Convoy Interdiction callout loaded successfully." ..
           "\nType /convoy_help for commands and controls." ..
           "\nType /start_convoy_mission to begin Operation Shadow Strike."}
})

-- Export functions for other scripts
exports('startConvoyMission', function()
    ExecuteCommand('start_convoy_mission')
end)

exports('endConvoyMission', function()
    ExecuteCommand('end_convoy_mission')
end)

exports('isCalloutActive', function()
    return CalloutManager.activeCallout ~= nil
end)