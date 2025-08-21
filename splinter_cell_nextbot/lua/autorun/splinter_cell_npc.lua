-- Splinter Cell NextBot NPC Spawn Menu Entry
-- This file adds the Splinter Cell operative to the NPC spawn menu

list.Set("NPC", "splinter_cell_operative", {
    Name = "Splinter Cell Operative", -- What shows in the spawn menu
    Class = "nextbot_splinter_cell",  -- Base entity class
    Category = "Splinter Cell",       -- Tab name in the NPC section
    AdminOnly = false,                -- Can regular players spawn it
    Model = "models/splinter_cell_3/player/Sam_E.mdl", -- Model preview
    KeyValues = {},                   -- Additional keyvalues
    SpawnFlags = 0,                   -- Spawn flags
    Weapons = {},                     -- Weapons to give
    Health = 200,                     -- Health value
    MaxHealth = 200,                  -- Max health
    Description = "Advanced tactical AI specializing in stealth operations, environmental control, and psychological warfare." -- Description
})

-- Add to the custom NPC category if it exists
if list.Get("NPC")["custom_npc"] then
    list.Set("NPC", "splinter_cell_operative", {
        Name = "Splinter Cell Operative",
        Class = "nextbot_splinter_cell",
        Category = "Custom NPCs",
        AdminOnly = false,
        Model = "models/splinter_cell_3/player/Sam_E.mdl",
        KeyValues = {},
        SpawnFlags = 0,
        Weapons = {},
        Health = 200,
        MaxHealth = 200,
        Description = "Advanced tactical AI specializing in stealth operations, environmental control, and psychological warfare."
    })
end