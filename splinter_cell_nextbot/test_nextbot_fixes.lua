-- Test script to verify NextBot fixes
-- This script tests the Splinter Cell NextBot to ensure it works without errors

print("[SplinterCellAI] Testing NextBot fixes...")

-- Function to test NextBot creation and basic functionality
local function TestNextBotCreation()
    print("[SplinterCellAI] Testing NextBot creation...")
    
    -- Create a test NextBot
    local testPos = Vector(0, 0, 100)
    local nextbot = ents.Create("nextbot_splinter_cell")
    
    if IsValid(nextbot) then
        nextbot:SetPos(testPos)
        nextbot:Spawn()
        
        print("[SplinterCellAI] ✓ NextBot created successfully")
        
        -- Test basic properties
        if nextbot.IsNextBot then
            print("[SplinterCellAI] ✓ NextBot properly initialized")
        else
            print("[SplinterCellAI] ✗ NextBot not properly initialized")
        end
        
        -- Test if RunBehavior exists
        if nextbot.RunBehavior then
            print("[SplinterCellAI] ✓ RunBehavior function exists")
        else
            print("[SplinterCellAI] ✗ RunBehavior function missing")
        end
        
        -- Test if SetDesiredSpeed exists
        if nextbot.SetDesiredSpeed then
            print("[SplinterCellAI] ✓ SetDesiredSpeed method exists")
        else
            print("[SplinterCellAI] ⚠ SetDesiredSpeed method not available")
        end
        
        -- Test if SetMaxSpeed exists (fallback)
        if nextbot.SetMaxSpeed then
            print("[SplinterCellAI] ✓ SetMaxSpeed method exists (fallback)")
        else
            print("[SplinterCellAI] ⚠ SetMaxSpeed method not available")
        end
        
        -- Test AI cycle start
        if nextbot.aiCycleStarted then
            print("[SplinterCellAI] ✓ AI cycle started")
        else
            print("[SplinterCellAI] ✗ AI cycle not started")
        end
        
        -- Clean up
        timer.Simple(5, function()
            if IsValid(nextbot) then
                nextbot:Remove()
                print("[SplinterCellAI] ✓ Test NextBot cleaned up")
            end
        end)
        
        return true
    else
        print("[SplinterCellAI] ✗ Failed to create NextBot")
        return false
    end
end

-- Function to test movement speed setting
local function TestMovementSpeed()
    print("[SplinterCellAI] Testing movement speed setting...")
    
    local testPos = Vector(100, 0, 100)
    local nextbot = ents.Create("nextbot_splinter_cell")
    
    if IsValid(nextbot) then
        nextbot:SetPos(testPos)
        nextbot:Spawn()
        
        -- Test setting movement speed safely
        local success, err = pcall(function()
            if nextbot.SetDesiredSpeed then
                nextbot:SetDesiredSpeed(100)
                print("[SplinterCellAI] ✓ SetDesiredSpeed called successfully")
            elseif nextbot.SetMaxSpeed then
                nextbot:SetMaxSpeed(100)
                print("[SplinterCellAI] ✓ SetMaxSpeed called successfully (fallback)")
            else
                print("[SplinterCellAI] ⚠ No movement speed method available")
            end
        end)
        
        if not success then
            print("[SplinterCellAI] ✗ Error setting movement speed: " .. tostring(err))
        end
        
        -- Clean up
        timer.Simple(3, function()
            if IsValid(nextbot) then
                nextbot:Remove()
            end
        end)
        
        return success
    else
        print("[SplinterCellAI] ✗ Failed to create NextBot for movement test")
        return false
    end
end

-- Function to test AI state execution
local function TestAIStateExecution()
    print("[SplinterCellAI] Testing AI state execution...")
    
    local testPos = Vector(200, 0, 100)
    local nextbot = ents.Create("nextbot_splinter_cell")
    
    if IsValid(nextbot) then
        nextbot:SetPos(testPos)
        nextbot:Spawn()
        
        -- Test ExecuteTacticalAI function
        local success, err = pcall(function()
            nextbot:ExecuteTacticalAI()
        end)
        
        if success then
            print("[SplinterCellAI] ✓ ExecuteTacticalAI executed successfully")
        else
            print("[SplinterCellAI] ✗ Error in ExecuteTacticalAI: " .. tostring(err))
        end
        
        -- Test specific state execution
        local success2, err2 = pcall(function()
            nextbot:ExecutePatrol()
        end)
        
        if success2 then
            print("[SplinterCellAI] ✓ ExecutePatrol executed successfully")
        else
            print("[SplinterCellAI] ✗ Error in ExecutePatrol: " .. tostring(err2))
        end
        
        -- Clean up
        timer.Simple(3, function()
            if IsValid(nextbot) then
                nextbot:Remove()
            end
        end)
        
        return success and success2
    else
        print("[SplinterCellAI] ✗ Failed to create NextBot for AI test")
        return false
    end
end

-- Run all tests
timer.Simple(1, function()
    print("[SplinterCellAI] ========================================")
    print("[SplinterCellAI] Starting NextBot Fix Verification Tests")
    print("[SplinterCellAI] ========================================")
    
    local test1 = TestNextBotCreation()
    timer.Simple(2, function()
        local test2 = TestMovementSpeed()
        timer.Simple(2, function()
            local test3 = TestAIStateExecution()
            
            print("[SplinterCellAI] ========================================")
            print("[SplinterCellAI] Test Results Summary:")
            print("[SplinterCellAI] Creation Test: " .. (test1 and "PASS" or "FAIL"))
            print("[SplinterCellAI] Movement Test: " .. (test2 and "PASS" or "FAIL"))
            print("[SplinterCellAI] AI State Test: " .. (test3 and "PASS" or "FAIL"))
            print("[SplinterCellAI] ========================================")
            
            if test1 and test2 and test3 then
                print("[SplinterCellAI] ✓ All tests passed! NextBot should work correctly.")
            else
                print("[SplinterCellAI] ✗ Some tests failed. Check the output above.")
            end
        end)
    end)
end)

print("[SplinterCellAI] Test script loaded. Tests will run in 1 second...")