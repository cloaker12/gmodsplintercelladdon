-- Test script for Splinter Cell NPC
-- Run this in console: lua_run_file("splinter_cell_nextbot/test_npc.lua")

if SERVER then
    print("Testing Splinter Cell NPC...")
    
    -- Spawn the NPC
    local npc = ents.Create("nextbot_splinter_cell")
    if IsValid(npc) then
        npc:SetPos(Vector(0, 0, 0))
        npc:Spawn()
        print("Splinter Cell NPC spawned successfully!")
        print("Model: " .. npc:GetModel())
        print("Health: " .. npc:Health())
        print("Bodygroup Goggles: " .. npc:GetBodygroup(1))
    else
        print("Failed to create Splinter Cell NPC!")
    end
end