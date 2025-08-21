-- Splinter Cell NextBot Test Script
-- Run this in console: lua_run_cl "include('splinter_cell_nextbot/test_ai.lua')"

if SERVER then
    print("=== Splinter Cell NextBot Test Script ===")
    print("This script will test the Splinter Cell NextBot AI functionality.")
    
    -- Test function to spawn a test NextBot
    function TestSplinterCellAI()
        local player = player.GetAll()[1]
        if not IsValid(player) then
            print("No players found to test with!")
            return
        end
        
        local spawnPos = player:GetPos() + Vector(0, 0, 50)
        
        -- Spawn the NextBot
        local nextbot = ents.Create("nextbot_splinter_cell")
        if IsValid(nextbot) then
            nextbot:SetPos(spawnPos)
            nextbot:Spawn()
            print("✓ Splinter Cell NextBot spawned successfully!")
            print("NextBot ID: " .. nextbot:EntIndex())
            print("Position: " .. tostring(spawnPos))
            
            -- Test basic functionality
            timer.Simple(1, function()
                if IsValid(nextbot) then
                    print("✓ NextBot health: " .. nextbot:Health())
                    print("✓ NextBot tactical state: " .. nextbot:GetNWInt("tacticalState", 0))
                    print("✓ NextBot stealth level: " .. nextbot:GetNWFloat("stealthLevel", 0))
                    print("✓ NextBot objective: " .. nextbot:GetNWString("currentObjective", "none"))
                end
            end)
        else
            print("✗ Failed to create Splinter Cell NextBot!")
        end
    end
    
    -- Test function to check all NextBots
    function CheckAllNextBots()
        local nextbots = ents.FindByClass("nextbot_splinter_cell")
        print("Found " .. #nextbots .. " Splinter Cell NextBots:")
        
        for i, nextbot in pairs(nextbots) do
            if IsValid(nextbot) then
                print("  NextBot " .. i .. ":")
                print("    ID: " .. nextbot:EntIndex())
                print("    Health: " .. nextbot:Health())
                print("    State: " .. nextbot:GetNWInt("tacticalState", 0))
                print("    Stealth: " .. nextbot:GetNWFloat("stealthLevel", 0))
                print("    Position: " .. tostring(nextbot:GetPos()))
            end
        end
    end
    
    -- Test function to stress test the AI
    function StressTestAI()
        print("Starting AI stress test...")
        
        -- Spawn multiple NextBots
        for i = 1, 3 do
            timer.Simple(i * 2, function()
                local player = player.GetAll()[1]
                if IsValid(player) then
                    local spawnPos = player:GetPos() + Vector(math.random(-200, 200), math.random(-200, 200), 50)
                    local nextbot = ents.Create("nextbot_splinter_cell")
                    if IsValid(nextbot) then
                        nextbot:SetPos(spawnPos)
                        nextbot:Spawn()
                        print("✓ Stress test NextBot " .. i .. " spawned")
                    end
                end
            end)
        end
        
        -- Check performance after 10 seconds
        timer.Simple(10, function()
            CheckAllNextBots()
            print("Stress test completed!")
        end)
    end
    
    -- Make functions available in console
    _G.TestSplinterCellAI = TestSplinterCellAI
    _G.CheckAllNextBots = CheckAllNextBots
    _G.StressTestAI = StressTestAI
    
    print("Test functions available:")
    print("  TestSplinterCellAI() - Spawn a single test NextBot")
    print("  CheckAllNextBots() - Check all existing NextBots")
    print("  StressTestAI() - Run stress test with multiple NextBots")
    print("")
    print("Run: lua_run TestSplinterCellAI() to test the AI")
end

if CLIENT then
    print("=== Splinter Cell NextBot Client Test ===")
    
    -- Test client-side effects
    function TestClientEffects()
        local nextbots = ents.FindByClass("nextbot_splinter_cell")
        print("Found " .. #nextbots .. " NextBots for client testing:")
        
        for i, nextbot in pairs(nextbots) do
            if IsValid(nextbot) then
                print("  NextBot " .. i .. " client data:")
                print("    Tactical State: " .. nextbot:GetNWInt("tacticalState", 0))
                print("    Stealth Level: " .. nextbot:GetNWFloat("stealthLevel", 0))
                print("    Objective: " .. nextbot:GetNWString("currentObjective", "none"))
                print("    Distance: " .. math.floor(LocalPlayer():GetPos():Distance(nextbot:GetPos())))
            end
        end
    end
    
    -- Test whisper effects
    function TestWhisperEffects()
        print("Testing whisper effects...")
        net.Start("SplinterCellWhisper")
        net.WriteString("Test whisper message from client")
        net.SendToServer()
        print("Whisper test sent!")
    end
    
    -- Make functions available
    _G.TestClientEffects = TestClientEffects
    _G.TestWhisperEffects = TestWhisperEffects
    
    print("Client test functions available:")
    print("  TestClientEffects() - Test client-side data")
    print("  TestWhisperEffects() - Test whisper system")
    print("")
    print("Run: lua_run_cl TestClientEffects() to test client effects")
end

print("Splinter Cell NextBot test script loaded successfully!")