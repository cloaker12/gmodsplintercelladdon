-- Test script for NextBot initialization fix
-- This script tests that the Splinter Cell NextBot can be spawned without errors

if SERVER then
    print("=== Testing Splinter Cell NextBot Initialization Fix ===")
    
    -- Test function to spawn the NextBot
    local function TestNextBotSpawn()
        print("Attempting to spawn Splinter Cell NextBot...")
        
        -- Get a valid spawn position
        local spawnPos = Vector(0, 0, 100)
        local spawnAng = Angle(0, 0, 0)
        
        -- Try to spawn the NextBot
        local nextbot = ents.Create("nextbot_splinter_cell")
        if IsValid(nextbot) then
            nextbot:SetPos(spawnPos)
            nextbot:SetAngles(spawnAng)
            nextbot:Spawn()
            
            print("✓ NextBot spawned successfully!")
            print("  - Entity: " .. tostring(nextbot))
            print("  - Position: " .. tostring(spawnPos))
            print("  - NextBot initialized: " .. tostring(nextbot.nextbotInitialized or false))
            
            -- Check if NextBot methods are available
            if nextbot.SetDesiredSpeed then
                print("✓ NextBot movement methods are available")
            else
                print("⚠ NextBot movement methods not yet available (this is normal during initialization)")
            end
            
            return nextbot
        else
            print("✗ Failed to create NextBot entity")
            return nil
        end
    end
    
    -- Test function to check NextBot after a delay
    local function CheckNextBotAfterDelay(nextbot, delay)
        timer.Simple(delay, function()
            if IsValid(nextbot) then
                print("=== NextBot Status Check (after " .. delay .. " seconds) ===")
                print("  - Entity valid: " .. tostring(IsValid(nextbot)))
                print("  - NextBot initialized: " .. tostring(nextbot.nextbotInitialized or false))
                print("  - Initialization attempts: " .. tostring(nextbot.nextbotInitializationAttempts or 0))
                
                if nextbot.SetDesiredSpeed then
                    print("✓ NextBot movement methods are available")
                    print("  - Desired speed: " .. tostring(nextbot:GetDesiredSpeed()))
                    print("  - Max speed: " .. tostring(nextbot:GetMaxSpeed()))
                else
                    print("✗ NextBot movement methods still not available")
                end
                
                print("  - Tactical state: " .. tostring(nextbot.tacticalState or "unknown"))
                print("  - Stealth level: " .. tostring(nextbot.stealthLevel or "unknown"))
            else
                print("✗ NextBot entity is no longer valid")
            end
        end)
    end
    
    -- Run the test
    concommand.Add("test_splinter_cell_nextbot", function(ply, cmd, args)
        if not IsValid(ply) or ply:IsAdmin() then
            local nextbot = TestNextBotSpawn()
            if nextbot then
                -- Check status after 1 second
                CheckNextBotAfterDelay(nextbot, 1)
                -- Check status after 3 seconds
                CheckNextBotAfterDelay(nextbot, 3)
                -- Check status after 5 seconds
                CheckNextBotAfterDelay(nextbot, 5)
            end
        else
            print("You need admin privileges to run this test")
        end
    end)
    
    print("Test command registered: test_splinter_cell_nextbot")
    print("Run this command in console to test the NextBot spawn")
end

if CLIENT then
    print("NextBot initialization fix test script loaded (client-side)")
end