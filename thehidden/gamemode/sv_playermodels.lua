-- Enhanced Player Model System with Splinter Cell Support
-- Handles bodygroups and model customization

local PLY = FindMetaTable("Player")

-- Splinter Cell model configurations
local SC_MODELS = {
    {
        model = "models/splinter_cell_3/player/Sam_E.mdl",
        bodygroups = {
            ["Goggles"] = 1,  -- Enable goggles
            ["Equipment"] = math.random(0, 2)  -- Random equipment variation
        },
        name = "Sam Fisher (Night Vision)",
        description = "Elite Third Echelon operative with night vision goggles"
    },
    {
        model = "models/splinter_cell_3/player/Sam_E.mdl",
        bodygroups = {
            ["Goggles"] = 0,  -- Disable goggles
            ["Equipment"] = math.random(0, 2)
        },
        name = "Sam Fisher (Standard)",
        description = "Elite Third Echelon operative in standard gear"
    }
}

-- Enhanced model selection for IRIS team
GM.EnhancedModels = {
    IRIS = {
        "models/splinter_cell_3/player/Sam_E.mdl",  -- Primary I.R.I.S model
        "models/splinter_cell_3/player/Sam_E.mdl",  -- Increased chance
        "models/splinter_cell_3/player/Sam_E.mdl",  -- Increased chance
        "models/player/riot.mdl",
        "models/player/urban.mdl",
        "models/player/gasmask.mdl"
    },
    Captain = {
        "models/splinter_cell_3/player/Sam_E.mdl",  -- Captains always get Sam Fisher model
        "models/splinter_cell_3/player/Sam_E.mdl"
    }
}

-- Apply bodygroups to Splinter Cell models
function PLY:ApplyBodygroups()
    local model = self:GetModel()
    
    if string.find(model, "splinter_cell") then
        -- Apply Splinter Cell specific bodygroups
        local bodygroups = {
            ["Goggles"] = 1,  -- Always enable goggles for agents
            ["Equipment"] = math.random(0, 2)
        }
        
        for bgName, bgValue in pairs(bodygroups) do
            local bgIndex = self:FindBodygroupByName(bgName)
            if bgIndex >= 0 then
                self:SetBodygroup(bgIndex, bgValue)
            end
        end
        
        -- Apply night vision capabilities
        self:SetNWBool("HasNightVision", true)
        
        -- Enhanced movement for Splinter Cell models
        if self:Team() == TEAM_HUMAN then
            self:SetWalkSpeed(self:GetWalkSpeed() * 1.1)
            self:SetRunSpeed(self:GetRunSpeed() * 1.1)
        end
    else
        self:SetNWBool("HasNightVision", false)
    end
end

-- Enhanced model selection system
function PLY:SelectEnhancedModel(team_type)
    local models = GM.EnhancedModels[team_type] or GM.EnhancedModels.IRIS
    local selected_model = models[math.random(#models)]
    
    self:SetModel(selected_model)
    
    -- Apply bodygroups after model is set
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:ApplyBodygroups()
        end
    end)
    
    return selected_model
end

-- Override the original team setup to use enhanced models
local original_TeamSetUp = TeamSetUp or {}

-- Enhanced IRIS team setup
TeamSetUp[TEAM_HUMAN] = function(ply)
    local plyInfo = ply:IsCaptain() and GAMEMODE.Captain or GAMEMODE.Jericho
    
    ply:ApplyLoadOut()
    ply:SetMaxHealth(plyInfo.Health)
    ply:SetHealth(plyInfo.Health)
    ply:SetArmor(plyInfo.Armor)
    ply:SetWalkSpeed(plyInfo.Speed)
    ply:SetRunSpeed(plyInfo.Speed)
    ply:SetJumpPower(plyInfo.JumpPower)
    
    -- Use enhanced model selection
    local team_type = ply:IsCaptain() and "Captain" or "IRIS"
    ply:SelectEnhancedModel(team_type)
    
    ply:AllowFlashlight(GAMEMODE.Jericho.AllowFlashlight)
    ply:SetupHands()
    ply:SetNextVoice(VO_IDLE, math.random(15, 45), false)
    ply:StripWeapons()

    ply:SetRenderMode(RENDERMODE_NORMAL)
    ply:SetColor(Color(255, 255, 255, 255))
    ply:SetMaterial("")
    ply:DrawShadow(true)
    ply:SetAvoidPlayers(true)
    
    -- Enhanced equipment for Splinter Cell models
    if string.find(ply:GetModel(), "splinter_cell") then
        -- Give special equipment
        ply:SetNWBool("HasTacticalGear", true)
        ply:SetNWInt("TacticalLevel", math.random(1, 3))
        
        -- Enhanced stamina for SC models
        ply:SetInt("Stamina", plyInfo.Stamina * 1.2)
    else
        ply:SetNWBool("HasTacticalGear", false)
        ply:SetInt("Stamina", plyInfo.Stamina)
    end
    
    ply:Give("weapon_hdn_knife")
    
    if ply:IsCaptain() then
        ply:SetNWBool("IsCaptain", true)
        ply:SetPlayerColor(Vector(0.2, 0.8, 0.2))  -- Green tint for captains
    else
        ply:SetNWBool("IsCaptain", false)
        ply:SetPlayerColor(Vector(0.8, 0.8, 1.0))  -- Blue tint for regular IRIS
    end
end

-- Enhanced Hidden setup (unchanged but added for completeness)
TeamSetUp[TEAM_HIDDEN] = function(ply)
    ply:StripWeapons()
    ply:SetMaxHealth(GAMEMODE.Hidden.Health)
    ply:SetHealth(GAMEMODE.Hidden.Health)
    ply:SetArmor(GAMEMODE.Hidden.Armor)
    ply:SetWalkSpeed(GAMEMODE.Hidden.Speed)
    ply:SetRunSpeed(GAMEMODE.Hidden.Speed)
    ply:SetJumpPower(GAMEMODE.Hidden.JumpPower)
    ply:SetModel(GAMEMODE.Hidden.Model)
    ply:SetMaterial(GAMEMODE.Hidden.Material)
    ply:AllowFlashlight(false)
    ply:SetupHands()
    ply:SetInt("Stamina", GAMEMODE.Hidden.Stamina)
    ply:Give("weapon_hdn_pipe")
    ply:SetRenderMode(RENDERMODE_TRANSALPHA)
    ply:SetColor(Color(255, 255, 255, GAMEMODE.Hidden.Alpha))
    ply:DrawShadow(false)
    ply:SetAvoidPlayers(false)
    ply:SetNWBool("IsHidden", true)
    
    -- Enhanced Hidden abilities
    ply:SetNWBool("CanPounce", true)
    ply:SetNWBool("HiddenVision", false)
    ply:SetNWFloat("NextPounce", 0)
end

-- Hook to apply bodygroups when player spawns
hook.Add("PlayerSpawn", "ApplyEnhancedModels", function(ply)
    timer.Simple(0.2, function()
        if IsValid(ply) then
            ply:ApplyBodygroups()
        end
    end)
end)

-- Network strings for enhanced model system
util.AddNetworkString("UpdatePlayerModel")
util.AddNetworkString("ApplyBodygroups")

-- Function to update player model mid-game (for admins)
function UpdatePlayerModel(ply, model_path, bodygroups)
    if not IsValid(ply) then return end
    
    ply:SetModel(model_path)
    
    timer.Simple(0.1, function()
        if IsValid(ply) and bodygroups then
            for bgName, bgValue in pairs(bodygroups) do
                local bgIndex = ply:FindBodygroupByName(bgName)
                if bgIndex >= 0 then
                    ply:SetBodygroup(bgIndex, bgValue)
                end
            end
        end
    end)
end

-- Console command for admins to change player models
concommand.Add("hdn_setmodel", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    
    local target_name = args[1]
    local model_path = args[2]
    
    if not target_name or not model_path then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Usage: hdn_setmodel <player_name> <model_path>")
        return
    end
    
    local target = nil
    for _, p in pairs(player.GetAll()) do
        if string.find(string.lower(p:Nick()), string.lower(target_name)) then
            target = p
            break
        end
    end
    
    if not IsValid(target) then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Player not found!")
        return
    end
    
    UpdatePlayerModel(target, model_path, {["Goggles"] = 1})
    ply:PrintMessage(HUD_PRINTCONSOLE, "Model updated for " .. target:Nick())
end)

-- Special model selection for events
function SelectSpecialModel(ply, event_type)
    if not IsValid(ply) then return end
    
    if event_type == "juggernaut" then
        -- Juggernaut Hidden gets a special model
        ply:SetModel("models/player/combine_super_soldier.mdl")
        ply:SetModelScale(1.2)
        ply:SetHealth(ply:Health() * 2)
        ply:SetNWBool("IsJuggernaut", true)
    elseif event_type == "stealth_ops" then
        -- All players get Splinter Cell models
        ply:SetModel("models/splinter_cell_3/player/Sam_E.mdl")
        timer.Simple(0.1, function()
            if IsValid(ply) then
                ply:SetBodygroup(ply:FindBodygroupByName("Goggles"), 1)
                ply:SetNWBool("HasNightVision", true)
            end
        end)
    end
end

-- Model precaching to prevent lag
hook.Add("Initialize", "PrecacheEnhancedModels", function()
    for _, model_list in pairs(GM.EnhancedModels) do
        for _, model in pairs(model_list) do
            util.PrecacheModel(model)
        end
    end
    
    -- Precache Splinter Cell models
    for _, config in pairs(SC_MODELS) do
        util.PrecacheModel(config.model)
    end
end)