-- Splinter Cell NextBot Installation Verification Script
-- Run this to verify your installation is complete and working

print("=== Splinter Cell NextBot Installation Verification ===")

-- Check if we're on server or client
if SERVER then
    print("Running server-side verification...")
    
    -- Check if the entity class exists
    if scripted_ents.Get("nextbot_splinter_cell") then
        print("✓ NextBot entity class registered successfully")
    else
        print("✗ NextBot entity class not found!")
        print("  Make sure all files are in the correct location:")
        print("  garrysmod/addons/splinter_cell_nextbot/lua/entities/nextbot_splinter_cell/")
        return
    end
    
    -- Check if network strings are registered
    local networkStrings = {
        "SplinterCellWhisper",
        "SplinterCellFlash",
        "SplinterCellFlashEffect"
    }
    
    for _, netString in pairs(networkStrings) do
        if util.NetworkStringToID(netString) > 0 then
            print("✓ Network string '" .. netString .. "' registered")
        else
            print("✗ Network string '" .. netString .. "' not found!")
        end
    end
    
    -- Check if we can create the entity
    local testEntity = ents.Create("nextbot_splinter_cell")
    if IsValid(testEntity) then
        print("✓ NextBot entity can be created successfully")
        testEntity:Remove()
    else
        print("✗ Failed to create NextBot entity!")
    end
    
    -- Check file structure
    local requiredFiles = {
        "lua/entities/nextbot_splinter_cell/shared.lua",
        "lua/entities/nextbot_splinter_cell/init.lua",
        "lua/entities/nextbot_splinter_cell/cl_init.lua",
        "addon.txt"
    }
    
    print("\nChecking file structure...")
    for _, filePath in pairs(requiredFiles) do
        local fullPath = "addons/splinter_cell_nextbot/" .. filePath
        if file.Exists(fullPath, "GAME") then
            print("✓ " .. filePath)
        else
            print("✗ " .. filePath .. " - FILE MISSING!")
        end
    end
    
    -- Check addon.txt content
    local addonPath = "addons/splinter_cell_nextbot/addon.txt"
    if file.Exists(addonPath, "GAME") then
        local content = file.Read(addonPath, "GAME")
        if string.find(content, "Splinter Cell Agent NextBot") then
            print("✓ addon.txt contains correct information")
        else
            print("✗ addon.txt content appears incorrect")
        end
    end
    
    -- Test spawning functionality
    print("\nTesting spawn functionality...")
    local player = player.GetAll()[1]
    if IsValid(player) then
        local spawnPos = player:GetPos() + Vector(0, 0, 50)
        local nextbot = ents.Create("nextbot_splinter_cell")
        if IsValid(nextbot) then
            nextbot:SetPos(spawnPos)
            nextbot:Spawn()
            
            -- Check if it spawned correctly
            timer.Simple(1, function()
                if IsValid(nextbot) then
                    print("✓ NextBot spawned and is valid")
                    print("  Health: " .. nextbot:Health())
                    print("  Position: " .. tostring(nextbot:GetPos()))
                    print("  Tactical State: " .. nextbot:GetNWInt("tacticalState", 0))
                    print("  Stealth Level: " .. nextbot:GetNWFloat("stealthLevel", 0))
                    
                    -- Clean up test entity
                    nextbot:Remove()
                    print("✓ Test NextBot removed successfully")
                else
                    print("✗ NextBot became invalid after spawning")
                end
            end)
        else
            print("✗ Failed to create test NextBot")
        end
    else
        print("⚠ No players found for spawn test")
    end
    
    print("\n=== Server-side verification complete ===")
    
elseif CLIENT then
    print("Running client-side verification...")
    
    -- Check if client files are loaded
    local clientFiles = {
        "lua/entities/nextbot_splinter_cell/shared.lua",
        "lua/entities/nextbot_splinter_cell/cl_init.lua"
    }
    
    for _, filePath in pairs(clientFiles) do
        local fullPath = "addons/splinter_cell_nextbot/" .. filePath
        if file.Exists(fullPath, "GAME") then
            print("✓ " .. filePath)
        else
            print("✗ " .. filePath .. " - FILE MISSING!")
        end
    end
    
    -- Check if we can find existing NextBots
    local nextbots = ents.FindByClass("nextbot_splinter_cell")
    if #nextbots > 0 then
        print("✓ Found " .. #nextbots .. " existing NextBot(s)")
        
        for i, nextbot in pairs(nextbots) do
            if IsValid(nextbot) then
                print("  NextBot " .. i .. ":")
                print("    Distance: " .. math.floor(LocalPlayer():GetPos():Distance(nextbot:GetPos())))
                print("    Tactical State: " .. nextbot:GetNWInt("tacticalState", 0))
                print("    Stealth Level: " .. nextbot:GetNWFloat("stealthLevel", 0))
                print("    Objective: " .. nextbot:GetNWString("currentObjective", "none"))
            end
        end
    else
        print("⚠ No NextBots found in current map")
        print("  Spawn a NextBot to test client-side functionality")
    end
    
    -- Test network string access
    local networkStrings = {
        "SplinterCellWhisper",
        "SplinterCellFlash",
        "SplinterCellFlashEffect"
    }
    
    for _, netString in pairs(networkStrings) do
        if util.NetworkStringToID(netString) > 0 then
            print("✓ Network string '" .. netString .. "' accessible")
        else
            print("✗ Network string '" .. netString .. "' not accessible!")
        end
    end
    
    print("\n=== Client-side verification complete ===")
end

-- Common verification for both server and client
print("\n=== Common Verification ===")

-- Check Garry's Mod version
local gmodVersion = VERSION
print("Garry's Mod version: " .. (gmodVersion or "Unknown"))

-- Check if we're in singleplayer or multiplayer
if game.SinglePlayer() then
    print("Game mode: Single Player")
else
    print("Game mode: Multiplayer")
end

-- Check current map
local currentMap = game.GetMap()
print("Current map: " .. currentMap)

-- Check if navmesh exists
if navmesh.GetAllNavAreas() and #navmesh.GetAllNavAreas() > 0 then
    print("✓ Navmesh available (" .. #navmesh.GetAllNavAreas() .. " areas)")
else
    print("⚠ No navmesh found - run 'nav_generate' for better pathfinding")
end

print("\n=== Verification Summary ===")
print("If you see mostly ✓ marks, your installation is working correctly!")
print("If you see ✗ marks, check the file paths and restart your server.")
print("If you see ⚠ marks, those are warnings but not critical errors.")

print("\nFor testing, run: lua_run TestSplinterCellAI()")
print("For help, see INSTALLATION.md")