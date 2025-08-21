-- Test script for working Splinter Cell AI bot
-- Run this in console: lua_run_file("splinter_cell_nextbot/test_working_bot.lua")

print("=== Splinter Cell AI Bot Test ===")

-- Spawn the bot
local bot = ents.Create("nextbot_splinter_cell")
if IsValid(bot) then
    bot:SetPos(Vector(0, 0, 0))
    bot:Spawn()
    print("✓ Bot spawned successfully!")
    print("Bot entity: " .. tostring(bot))
    print("Bot position: " .. tostring(bot:GetPos()))
    print("Bot health: " .. bot:Health())
    print("Bot tactical state: " .. bot:GetNWInt("tacticalState", 0))
    print("Bot current objective: " .. bot:GetNWString("currentObjective", "none"))
else
    print("✗ Failed to spawn bot!")
end

-- Test commands
print("\n=== Available Commands ===")
print("To spawn a bot: ent_create nextbot_splinter_cell")
print("To test bot behavior: lua_run_file('splinter_cell_nextbot/test_working_bot.lua')")
print("To check bot status: lua_run('PrintTable(Entity(1):GetNWVars())')")

-- Test bot functionality
timer.Simple(2, function()
    if IsValid(bot) then
        print("\n=== Bot Status Check ===")
        print("Bot is valid: " .. tostring(IsValid(bot)))
        print("Bot is moving: " .. tostring(bot:IsMoving()))
        print("Bot speed: " .. bot:GetDesiredSpeed())
        print("Bot animation: " .. bot:GetNWString("currentAnimation", "none"))
        print("Bot smoke grenades: " .. bot:GetNWInt("smokeGrenades", 0))
        print("Bot night vision: " .. tostring(bot:GetNWBool("nightVisionActive", false)))
    end
end)