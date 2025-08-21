-- Test script to verify Splinter Cell AI fixes
-- This script tests the safety checks and animation fixes

if SERVER then
    print("[SplinterCellAI] Testing fixes...")
    
    -- Test 1: Create an AI and verify it doesn't crash
    timer.Simple(1, function()
        local ai = ents.Create("nextbot_splinter_cell")
        if IsValid(ai) then
            ai:SetPos(Vector(0, 0, 0))
            ai:Spawn()
            print("[SplinterCellAI] AI created successfully")
            
            -- Test 2: Verify it has a valid sequence
            timer.Simple(2, function()
                if IsValid(ai) then
                    local sequence = ai:GetSequence()
                    print("[SplinterCellAI] Current sequence: " .. tostring(sequence))
                    if sequence > 0 then
                        print("[SplinterCellAI] ✓ Valid sequence - T-posing should be fixed")
                    else
                        print("[SplinterCellAI] ⚠ Sequence is 0 - may still T-pose")
                    end
                    
                    -- Test 3: Verify SetMaxSpeed calls are protected
                    print("[SplinterCellAI] Testing SetMaxSpeed safety...")
                    ai:ExecutePatrol() -- This should call SetMaxSpeed safely
                    print("[SplinterCellAI] ✓ SetMaxSpeed calls should be protected")
                    
                    -- Clean up
                    timer.Simple(5, function()
                        if IsValid(ai) then
                            ai:Remove()
                            print("[SplinterCellAI] Test completed - AI removed")
                        end
                    end)
                end
            end)
        else
            print("[SplinterCellAI] Failed to create AI")
        end
    end)
end

if CLIENT then
    print("[SplinterCellAI] Client-side test loaded")
end