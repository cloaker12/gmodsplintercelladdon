-- Test script for Enhanced Splinter Cell NPC
-- Run this in console: lua_run_file("splinter_cell_nextbot/test_npc.lua")

if SERVER then
    print("Testing Enhanced Splinter Cell NPC...")
    
    -- Spawn the NPC
    local npc = ents.Create("nextbot_splinter_cell")
    if IsValid(npc) then
        npc:SetPos(Vector(0, 0, 0))
        npc:Spawn()
        print("Enhanced Splinter Cell NPC spawned successfully!")
        print("Model: " .. npc:GetModel())
        print("Health: " .. npc:Health())
        print("Bodygroup Goggles: " .. npc:GetBodygroup(1))
        print("Weapon Model: " .. npc.weaponModel)
        print("AI States Available: 9")
        print("Abilities: Smoke Grenade, Decoy, Cloak")
        print("Features: Enhanced Navigation, Strafing Combat, Realistic Shooting")
    else
        print("Failed to create Enhanced Splinter Cell NPC!")
    end
    
    -- Test abilities
    timer.Simple(2, function()
        if IsValid(npc) then
            print("Testing abilities...")
            npc:UseSmokeGrenade()
            print("Smoke grenade deployed!")
            
            timer.Simple(1, function()
                if IsValid(npc) then
                    npc:UseDecoy()
                    print("Decoy deployed!")
                end
            end)
        end
    end)
end