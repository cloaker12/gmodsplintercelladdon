-- Test script for NextBot behavior fixes
-- This script tests the RunBehaviour and movement initialization fixes

-- Clean up any existing test entities
for _, ent in ipairs(ents.FindByClass("nextbot_splinter_cell")) do
    if IsValid(ent) then
        ent:Remove()
    end
end

print("\n=== Splinter Cell NextBot Behavior Fix Test ===")
print("Testing RunBehaviour and movement initialization...")

-- Spawn the NextBot
local bot = ents.Create("nextbot_splinter_cell")
if not IsValid(bot) then
    print("ERROR: Failed to create NextBot entity!")
    return
end

-- Position the bot in front of the player
local ply = Entity(1) -- Assuming player is entity 1
if IsValid(ply) then
    local spawnPos = ply:GetPos() + ply:GetForward() * 200
    bot:SetPos(spawnPos)
end

bot:Spawn()
bot:Activate()

print("NextBot spawned successfully!")
print("Entity: " .. tostring(bot))
print("Model: " .. bot:GetModel())
print("Health: " .. bot:Health())

-- Monitor behavior over time
local checkCount = 0
local maxChecks = 10

timer.Create("NextBotBehaviorTest", 0.5, maxChecks, function()
    checkCount = checkCount + 1
    
    if not IsValid(bot) then
        print("\n[Check " .. checkCount .. "] ERROR: Bot is no longer valid!")
        timer.Remove("NextBotBehaviorTest")
        return
    end
    
    print("\n[Check " .. checkCount .. "/" .. maxChecks .. "] Status Report:")
    
    -- Check if bot is still alive
    print("- Health: " .. bot:Health() .. "/" .. bot:GetMaxHealth())
    
    -- Check NextBot initialization status
    local initStatus = bot.nextbotInitialized and "Initialized" or "Not Initialized"
    print("- NextBot Movement: " .. initStatus)
    
    -- Check initialization attempts
    local attempts = bot.nextbotInitializationAttempts or 0
    print("- Initialization Attempts: " .. attempts)
    
    -- Check if movement methods are available
    local hasMovementMethods = (bot.SetDesiredSpeed and bot.SetMaxSpeed) and "Yes" or "No"
    print("- Movement Methods Available: " .. hasMovementMethods)
    
    -- Check current sequence
    local seq = bot:GetSequence()
    local seqName = bot:GetSequenceName(seq)
    print("- Current Animation: " .. seqName .. " (ID: " .. seq .. ")")
    
    -- Check velocity
    local vel = bot:GetVelocity():Length()
    print("- Velocity: " .. math.Round(vel, 2))
    
    -- Check AI state
    local state = bot.tacticalState or "Unknown"
    print("- AI State: " .. state)
    
    -- Try to make the bot move if movement is initialized
    if bot.nextbotInitialized and checkCount == 5 then
        print("\n>>> Attempting to trigger movement...")
        if bot.SetDesiredSpeed then
            local success = pcall(function()
                bot:SetDesiredSpeed(200)
                if IsValid(ply) then
                    bot.targetPosition = ply:GetPos()
                end
            end)
            print(">>> Movement command: " .. (success and "Success" or "Failed"))
        end
    end
    
    -- Final summary
    if checkCount == maxChecks then
        print("\n=== TEST COMPLETE ===")
        print("Summary:")
        print("- Bot spawned: " .. (IsValid(bot) and "Yes" or "No"))
        print("- NextBot initialized: " .. (bot.nextbotInitialized and "Yes" or "No"))
        print("- Initialization attempts: " .. (bot.nextbotInitializationAttempts or 0))
        print("- No RunBehaviour warnings: Check console above")
        print("\nIf you see 'RunBehaviour() has finished' warnings, the fix needs adjustment.")
        print("If you see 'movement initialization failed after 10 attempts', check NextBot setup.")
    end
end)

-- Console command for easy testing
concommand.Add("test_splinter_cell_behavior", function()
    include("splinter_cell_nextbot/test_nextbot_behavior_fix.lua")
end)

print("\nTest started! Monitoring NextBot for " .. (maxChecks * 0.5) .. " seconds...")
print("Run 'test_splinter_cell_behavior' in console to repeat this test.")