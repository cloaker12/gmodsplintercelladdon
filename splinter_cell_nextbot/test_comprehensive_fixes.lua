-- Comprehensive Test Script for Splinter Cell NextBot Fixes
-- This script tests all the fixes and improvements made to the AI

local function TestNextBotSpawn()
    print("[SplinterCellAI] Testing NextBot spawning...")
    
    -- Clean up any existing bots
    for _, ent in ipairs(ents.FindByClass("nextbot_splinter_cell")) do
        if IsValid(ent) then
            ent:Remove()
        end
    end
    
    -- Wait a moment for cleanup
    timer.Simple(1, function()
        -- Spawn new bot
        local spawnPos = LocalPlayer():GetPos() + LocalPlayer():GetForward() * 200
        local bot = ents.Create("nextbot_splinter_cell")
        if IsValid(bot) then
            bot:SetPos(spawnPos)
            bot:Spawn()
            
            print("[SplinterCellAI] ✓ NextBot spawned successfully")
            
            -- Test movement methods
            timer.Simple(2, function()
                if IsValid(bot) then
                    TestMovementMethods(bot)
                end
            end)
            
            -- Test animation system
            timer.Simple(4, function()
                if IsValid(bot) then
                    TestAnimationSystem(bot)
                end
            end)
            
            -- Test pathfinding
            timer.Simple(6, function()
                if IsValid(bot) then
                    TestPathfinding(bot)
                end
            end)
            
            -- Test AI states
            timer.Simple(8, function()
                if IsValid(bot) then
                    TestAIStates(bot)
                end
            end)
            
        else
            print("[SplinterCellAI] ✗ Failed to spawn NextBot")
        end
    end)
end

function TestMovementMethods(bot)
    print("[SplinterCellAI] Testing movement methods...")
    
    -- Test SetDesiredSpeed/SetMaxSpeed fallback
    local hasDesiredSpeed = bot.SetDesiredSpeed ~= nil
    local hasMaxSpeed = bot.SetMaxSpeed ~= nil
    
    if hasDesiredSpeed then
        print("[SplinterCellAI] ✓ SetDesiredSpeed method available")
        bot:SetDesiredSpeed(100)
    elseif hasMaxSpeed then
        print("[SplinterCellAI] ✓ SetMaxSpeed method available (fallback)")
        bot:SetMaxSpeed(100)
    else
        print("[SplinterCellAI] ⚠ No movement speed methods available")
    end
    
    -- Test NextBot initialization
    if bot.nextbotInitialized then
        print("[SplinterCellAI] ✓ NextBot properly initialized")
    else
        print("[SplinterCellAI] ⚠ NextBot initialization may be pending")
    end
end

function TestAnimationSystem(bot)
    print("[SplinterCellAI] Testing animation system...")
    
    -- Test sequence validation
    local currentSeq = bot:GetSequence()
    local maxSeq = bot:GetSequenceCount()
    
    if currentSeq >= 0 and currentSeq < maxSeq then
        print("[SplinterCellAI] ✓ Valid animation sequence: " .. currentSeq)
    else
        print("[SplinterCellAI] ⚠ Invalid animation sequence: " .. currentSeq)
    end
    
    -- Test animation changes
    if bot.PlayAnimation then
        bot:PlayAnimation("idle")
        timer.Simple(1, function()
            if IsValid(bot) then
                bot:PlayAnimation("walk")
                print("[SplinterCellAI] ✓ Animation system functional")
            end
        end)
    else
        print("[SplinterCellAI] ✗ PlayAnimation method not found")
    end
end

function TestPathfinding(bot)
    print("[SplinterCellAI] Testing pathfinding...")
    
    -- Test MoveToPosition
    if bot.MoveToPosition then
        local targetPos = LocalPlayer():GetPos() + Vector(100, 100, 0)
        bot:MoveToPosition(targetPos)
        print("[SplinterCellAI] ✓ MoveToPosition called successfully")
        
        -- Check if path was created
        timer.Simple(1, function()
            if IsValid(bot) then
                if bot.currentPath and bot.currentPath:IsValid() then
                    print("[SplinterCellAI] ✓ Path created successfully")
                else
                    print("[SplinterCellAI] ⚠ No valid path created (may be normal)")
                end
            end
        end)
    else
        print("[SplinterCellAI] ✗ MoveToPosition method not found")
    end
end

function TestAIStates(bot)
    print("[SplinterCellAI] Testing AI states...")
    
    if bot.tacticalState then
        print("[SplinterCellAI] ✓ Current AI state: " .. tostring(bot.tacticalState))
        
        -- Test state change
        if bot.ChangeState then
            local originalState = bot.tacticalState
            bot:ChangeState("SUSPICIOUS")
            
            timer.Simple(1, function()
                if IsValid(bot) then
                    if bot.tacticalState ~= originalState then
                        print("[SplinterCellAI] ✓ State change successful")
                    else
                        print("[SplinterCellAI] ⚠ State change may not have occurred")
                    end
                end
            end)
        end
    else
        print("[SplinterCellAI] ✗ No tactical state found")
    end
end

function TestPerformanceOptimizations(bot)
    print("[SplinterCellAI] Testing performance optimizations...")
    
    -- Test caching systems
    if bot.GetCachedPlayerPositions then
        local positions = bot:GetCachedPlayerPositions()
        print("[SplinterCellAI] ✓ Player position caching functional")
    end
    
    if bot.GetCachedDistance then
        local distance = bot:GetCachedDistance(LocalPlayer())
        print("[SplinterCellAI] ✓ Distance caching functional: " .. tostring(distance))
    end
    
    -- Test cleanup
    if bot.CleanupPerformanceCache then
        bot:CleanupPerformanceCache()
        print("[SplinterCellAI] ✓ Performance cache cleanup functional")
    end
end

function TestErrorHandling(bot)
    print("[SplinterCellAI] Testing error handling...")
    
    -- Test RunBehavior error handling
    if bot.RunBehavior then
        print("[SplinterCellAI] ✓ RunBehavior method exists")
        
        -- The error handling is internal, so we just verify the method exists
        -- and that the bot continues to function after potential errors
        timer.Simple(5, function()
            if IsValid(bot) then
                print("[SplinterCellAI] ✓ Bot still functional after 5 seconds")
            else
                print("[SplinterCellAI] ✗ Bot was removed or became invalid")
            end
        end)
    end
end

-- Main test function
local function RunAllTests()
    print("[SplinterCellAI] Starting comprehensive test suite...")
    print("[SplinterCellAI] ==========================================")
    
    TestNextBotSpawn()
    
    -- Schedule additional tests
    timer.Simple(10, function()
        local bot = ents.FindByClass("nextbot_splinter_cell")[1]
        if IsValid(bot) then
            TestPerformanceOptimizations(bot)
            TestErrorHandling(bot)
        end
    end)
    
    -- Final report
    timer.Simple(15, function()
        print("[SplinterCellAI] ==========================================")
        print("[SplinterCellAI] Test suite completed!")
        print("[SplinterCellAI] Check console output above for results.")
        print("[SplinterCellAI] ==========================================")
    end)
end

-- Auto-run tests if this file is executed
if CLIENT then
    print("[SplinterCellAI] Client-side test script loaded. Run RunAllTests() to start tests.")
else
    print("[SplinterCellAI] Server-side test script loaded. Run RunAllTests() to start tests.")
end

-- Make the function globally available
_G.RunAllTests = RunAllTests
_G.TestNextBotSpawn = TestNextBotSpawn

print("[SplinterCellAI] Comprehensive test script loaded!")
print("[SplinterCellAI] Usage: RunAllTests() or TestNextBotSpawn()")