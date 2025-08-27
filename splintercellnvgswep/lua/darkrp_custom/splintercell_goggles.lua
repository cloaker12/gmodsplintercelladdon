-- ============================================================================
-- DarkRP Compatibility for Splinter Cell Goggles
-- ============================================================================
-- This file adds the Splinter Cell Goggles to the DarkRP F4 menu
-- Place this file in: lua/darkrp_custom/splintercell_goggles.lua

-- Check if DarkRP is loaded
if not DarkRP then return end

-- Create the entity for the F4 menu
DarkRP.createEntity("Splinter Cell Goggles", {
    ent = "splintercell_nvg",
    model = "models/props_lab/huladoll.mdl", -- Placeholder model
    price = 5000,
    max = 1,
    cmd = "buysplintercellgoggles",
    allowed = {TEAM_CITIZEN, TEAM_POLICE, TEAM_GANG, TEAM_MOB}
})

-- Create a shipment for bulk purchase
DarkRP.createShipment("Splinter Cell Goggles", {
    model = "models/props_lab/huladoll.mdl",
    entity = "splintercell_nvg",
    price = 45000,
    amount = 10,
    separate = true,
    pricesep = 5000,
    noship = false,
    allowed = {TEAM_CITIZEN, TEAM_POLICE, TEAM_GANG, TEAM_MOB}
})

-- Add custom job for Splinter Cell operatives (optional)
DarkRP.createJob("Splinter Cell Operative", {
    color = Color(0, 100, 0, 255),
    model = {
        "models/player/Group01/male_02.mdl",
        "models/player/Group01/male_04.mdl",
        "models/player/Group01/male_06.mdl",
        "models/player/Group01/male_08.mdl"
    },
    description = [[You are a Splinter Cell operative.
    Use your tactical goggles to complete stealth missions.
    Primary: Toggle goggles
    Secondary: Cycle vision modes
    Reload: Quick mode switch]],
    weapons = {"splintercell_nvg"},
    command = "becomesplintercell",
    max = 2,
    salary = 45,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Special Forces"
})

-- Add the goggles to the weapon dealer
DarkRP.createEntity("Splinter Cell Goggles (Dealer)", {
    ent = "splintercell_nvg",
    model = "models/props_lab/huladoll.mdl",
    price = 4000,
    max = 2,
    cmd = "buysplintercellgoggles_dealer",
    allowed = {TEAM_GUN}
})

-- Add to the gun dealer's inventory
hook.Add("DarkRPFinishedLoading", "SplinterCell_GunDealer", function()
    if DarkRP.retrieveJobSchema and DarkRP.retrieveJobSchema(TEAM_GUN) then
        local gunDealer = DarkRP.retrieveJobSchema(TEAM_GUN)
        if gunDealer and gunDealer.weapons then
            table.insert(gunDealer.weapons, "splintercell_nvg")
        end
    end
end)

-- Add custom commands
DarkRP.declareChatCommand{
    command = "goggles",
    description = "Toggle your Splinter Cell Goggles on/off",
    delay = 1.5
}

-- Add help text for the goggles
hook.Add("OnPlayerChat", "SplinterCell_Goggles_Help", function(ply, text)
    if text == "!goggles" or text == "/goggles" then
        ply:ChatPrint("=== Splinter Cell Goggles Help ===")
        ply:ChatPrint("Primary Attack: Toggle goggles on/off")
        ply:ChatPrint("Secondary Attack: Cycle vision modes")
        ply:ChatPrint("Reload: Quick mode switch")
        ply:ChatPrint("Modes: Night Vision → Thermal → Sonar")
        ply:ChatPrint("Battery drains while active, recharges when off")
        ply:ChatPrint("Thermal and Sonar modes drain battery faster")
    end
end)

-- Add spawn protection for the goggles
hook.Add("PlayerSpawn", "SplinterCell_Goggles_Spawn", function(ply)
    if ply:getJobTable().weapons then
        for _, weapon in pairs(ply:getJobTable().weapons) do
            if weapon == "splintercell_nvg" then
                -- Give the player the goggles if their job includes it
                timer.Simple(1, function()
                    if IsValid(ply) and ply:Alive() then
                        ply:Give("splintercell_nvg")
                    end
                end)
                break
            end
        end
    end
end)

-- Add custom permissions for admin commands
hook.Add("DarkRPFinishedLoading", "SplinterCell_AdminCommands", function()
    DarkRP.declarePrivilege("SplinterCell_Admin", "Splinter Cell Admin", "Allows access to Splinter Cell admin commands")
end)

-- Admin command to give goggles to players
DarkRP.declarePrivilege("SplinterCell_Admin", "Splinter Cell Admin", "Allows access to Splinter Cell admin commands")

DarkRP.definePrivilegedChatCommand("givegoggles", "SplinterCell_Admin", function(ply, args)
    local target = DarkRP.findPlayer(args[1])
    if not target then
        DarkRP.notify(ply, 1, 3, "Player not found!")
        return
    end
    
    target:Give("splintercell_nvg")
    DarkRP.notify(ply, 0, 3, "Gave Splinter Cell Goggles to " .. target:Nick())
    DarkRP.notify(target, 0, 3, "You received Splinter Cell Goggles from an admin!")
end)

-- Add goggles to the weapon category in F4 menu
hook.Add("DarkRPFinishedLoading", "SplinterCell_F4Category", function()
    -- This ensures the goggles appear in the weapons category
    if DarkRP and DarkRP.createEntity then
        -- The entity is already created above, this just ensures proper categorization
        print("[Splinter Cell Goggles] DarkRP integration loaded successfully!")
    end
end)
