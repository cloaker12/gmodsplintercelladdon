AddCSLuaFile()

SWEP.PrintName = "Splinter Cell Vision Goggles"
SWEP.Author = "DarkRP Enhanced"
SWEP.Instructions = "Press N to toggle vision, T to cycle modes | DarkRP Compatible"
SWEP.Category = "DarkRP Special"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

-- DarkRP Integration
SWEP.IsDarkRPWeapon = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true

-- Vision modes
SWEP.VisionModes = {
    {
        name = "Night Vision",
        id = "nightvision",
        color = Color(0, 255, 0, 50),
        sound = "npc/scanner/scanner_electric1.wav"
    },
    {
        name = "Thermal Vision",
        id = "thermal",
        color = Color(255, 0, 0, 30),
        sound = "npc/scanner/scanner_electric2.wav"
    },
    {
        name = "Sonar Vision",
        id = "sonar",
        color = Color(0, 150, 255, 40),
        sound = "npc/scanner/combat_scan1.wav"
    }
}

-- Customizable settings
SWEP.Settings = {
    visionStrength = 1.0,
    energyDrainRate = 0.5, -- Per second
    energyRechargeRate = 1.0, -- Per second
    maxEnergy = 100,
    sonarPulseInterval = 1.5, -- Seconds between pulses
    sonarPulseDuration = 0.5, -- How long the pulse lasts
    nightVisionGrainAmount = 0.3,
    thermalSensitivity = 1.0
}

function SWEP:Initialize()
    self:SetHoldType("normal")
    
    if CLIENT then
        self.VisionActive = false
        self.CurrentMode = 1
        self.Energy = self.Settings.maxEnergy
        self.LastPulseTime = 0
        self.PulseAlpha = 0
        self.GrainTexture = surface.GetTextureID("effects/tvscreen_noise002a")
        
        -- Create convars for customization
        CreateClientConVar("sc_vision_strength", "1", true, false, "Vision effect strength", 0.1, 2)
        CreateClientConVar("sc_energy_drain", "0.5", true, false, "Energy drain rate per second", 0.1, 2)
        CreateClientConVar("sc_energy_recharge", "1", true, false, "Energy recharge rate per second", 0.1, 3)
        CreateClientConVar("sc_sonar_interval", "1.5", true, false, "Sonar pulse interval", 0.5, 5)
        CreateClientConVar("sc_grain_amount", "0.3", true, false, "Night vision grain amount", 0, 1)
        
        -- Key bindings
        self:SetupKeyBindings()
    end
end

function SWEP:SetupKeyBindings()
    if CLIENT then
        -- Remove old hooks if they exist
        hook.Remove("Think", "SC_VisionKeyCheck_" .. self:EntIndex())
        
        -- Add key checking hook
        hook.Add("Think", "SC_VisionKeyCheck_" .. self:EntIndex(), function()
            if not IsValid(self) or self:GetOwner() != LocalPlayer() then
                hook.Remove("Think", "SC_VisionKeyCheck_" .. self:EntIndex())
                return
            end
            
            -- N key to toggle vision
            if input.IsKeyDown(KEY_N) and not self.NKeyPressed then
                self.NKeyPressed = true
                self:ToggleVision()
            elseif not input.IsKeyDown(KEY_N) then
                self.NKeyPressed = false
            end
            
            -- T key to cycle modes
            if input.IsKeyDown(KEY_T) and not self.TKeyPressed then
                self.TKeyPressed = true
                self:CycleMode()
            elseif not input.IsKeyDown(KEY_T) then
                self.TKeyPressed = false
            end
        end)
    end
end

function SWEP:ToggleVision()
    if CLIENT then
        self.VisionActive = not self.VisionActive
        
        if self.VisionActive then
            surface.PlaySound(self.VisionModes[self.CurrentMode].sound)
            self:StartVisionEffects()
        else
            surface.PlaySound("npc/turret_floor/retract.wav")
            self:StopVisionEffects()
        end
    end
end

function SWEP:CycleMode()
    if CLIENT and self.VisionActive then
        local oldMode = self.CurrentMode
        self.CurrentMode = self.CurrentMode % #self.VisionModes + 1
        
        surface.PlaySound(self.VisionModes[self.CurrentMode].sound)
        
        -- Reset mode-specific variables
        self.LastPulseTime = CurTime()
        self.PulseAlpha = 0
    end
end

function SWEP:StartVisionEffects()
    if CLIENT then
        hook.Add("RenderScreenspaceEffects", "SC_VisionEffects_" .. self:EntIndex(), function()
            if not IsValid(self) or self:GetOwner() != LocalPlayer() or not self.VisionActive then
                hook.Remove("RenderScreenspaceEffects", "SC_VisionEffects_" .. self:EntIndex())
                return
            end
            
            local mode = self.VisionModes[self.CurrentMode]
            local strength = GetConVar("sc_vision_strength"):GetFloat()
            
            if mode.id == "nightvision" then
                self:RenderNightVision(strength)
            elseif mode.id == "thermal" then
                self:RenderThermalVision(strength)
            elseif mode.id == "sonar" then
                self:RenderSonarVision(strength)
            end
        end)
        
        hook.Add("PreDrawHalos", "SC_VisionHalos_" .. self:EntIndex(), function()
            if not IsValid(self) or self:GetOwner() != LocalPlayer() or not self.VisionActive then
                hook.Remove("PreDrawHalos", "SC_VisionHalos_" .. self:EntIndex())
                return
            end
            
            if self.VisionModes[self.CurrentMode].id == "sonar" then
                self:DrawSonarHalos()
            end
        end)
    end
end

function SWEP:StopVisionEffects()
    if CLIENT then
        hook.Remove("RenderScreenspaceEffects", "SC_VisionEffects_" .. self:EntIndex())
        hook.Remove("PreDrawHalos", "SC_VisionHalos_" .. self:EntIndex())
    end
end

function SWEP:RenderNightVision(strength)
    local tab = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0.1 * strength,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0.2 * strength,
        ["$pp_colour_contrast"] = 1.2,
        ["$pp_colour_colour"] = 0.5,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 5 * strength,
        ["$pp_colour_mulb"] = 0
    }
    DrawColorModify(tab)
    
    -- Add grain effect
    local grainAmount = GetConVar("sc_grain_amount"):GetFloat()
    if grainAmount > 0 then
        surface.SetDrawColor(0, 255, 0, 30 * grainAmount)
        surface.SetTexture(self.GrainTexture)
        
        -- Animated grain
        local offset = CurTime() * 10
        surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrW() * 2, ScrH() * 2, offset)
    end
    
    -- Add subtle bloom
    DrawBloom(0.65, 2 * strength, 9, 9, 1, 1, 1, 1, 1)
end

function SWEP:RenderThermalVision(strength)
    -- Get all entities and calculate their "heat"
    local entities = ents.GetAll()
    
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)
    render.SetStencilReferenceValue(1)
    
    -- First pass: Draw hot entities
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    
    cam.Start3D()
    render.SuppressEngineLighting(true)
    
    for _, ent in ipairs(entities) do
        if IsValid(ent) and ent != self:GetOwner() then
            local heat = self:GetEntityHeat(ent)
            if heat > 0.1 then
                render.SetColorModulation(heat, heat * 0.5, 0)
                render.SetBlend(heat)
                ent:DrawModel()
            end
        end
    end
    
    render.SuppressEngineLighting(false)
    cam.End3D()
    
    render.SetStencilEnable(false)
    
    -- Apply thermal color modification
    local tab = {
        ["$pp_colour_addr"] = 0.1 * strength,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = -0.3,
        ["$pp_colour_contrast"] = 2,
        ["$pp_colour_colour"] = 0.2,
        ["$pp_colour_mulr"] = 2 * strength,
        ["$pp_colour_mulg"] = 0.5,
        ["$pp_colour_mulb"] = 0
    }
    DrawColorModify(tab)
    
    -- Add thermal blur
    DrawMotionBlur(0.4, 0.8, 0.01)
end

function SWEP:GetEntityHeat(ent)
    -- Calculate heat signature based on entity type
    if ent:IsPlayer() or ent:IsNPC() then
        if ent:Health() > 0 then
            return 1.0 -- Living entities are hot
        else
            return 0.3 -- Dead entities cool down
        end
    elseif ent:IsVehicle() and ent:GetDriver():IsValid() then
        return 0.8 -- Running vehicles
    elseif ent:GetClass():find("prop_physics") then
        -- Props can have heat if recently interacted with
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) and phys:GetVelocity():Length() > 50 then
            return 0.6 -- Moving props
        end
        return 0.1 -- Static props are cold
    end
    
    return 0.2 -- Default low heat
end

function SWEP:RenderSonarVision(strength)
    local interval = GetConVar("sc_sonar_interval"):GetFloat()
    local duration = self.Settings.sonarPulseDuration
    
    -- Update pulse timing
    if CurTime() - self.LastPulseTime > interval then
        self.LastPulseTime = CurTime()
        self.PulseAlpha = 1
        surface.PlaySound("npc/scanner/scanner_siren2.wav")
    end
    
    -- Fade out pulse
    if self.PulseAlpha > 0 then
        self.PulseAlpha = math.max(0, self.PulseAlpha - FrameTime() / duration)
    end
    
    -- Apply sonar color modification
    local pulseStrength = self.PulseAlpha * strength
    local tab = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0.05 * pulseStrength,
        ["$pp_colour_addb"] = 0.1 * pulseStrength,
        ["$pp_colour_brightness"] = -0.5 + (0.3 * pulseStrength),
        ["$pp_colour_contrast"] = 1.5,
        ["$pp_colour_colour"] = 0.3,
        ["$pp_colour_mulr"] = 0.5,
        ["$pp_colour_mulg"] = 0.5,
        ["$pp_colour_mulb"] = 2 * strength
    }
    DrawColorModify(tab)
    
    -- Add sonar scanlines
    if self.PulseAlpha > 0 then
        surface.SetDrawColor(0, 150, 255, 30 * self.PulseAlpha)
        for i = 0, ScrH(), 4 do
            surface.DrawLine(0, i, ScrW(), i)
        end
    end
end

function SWEP:DrawSonarHalos()
    if self.PulseAlpha <= 0 then return end
    
    local highlighted = {}
    local owner = self:GetOwner()
    
    -- Find entities to highlight
    for _, ent in ipairs(ents.FindInSphere(owner:GetPos(), 2000)) do
        if IsValid(ent) and ent != owner then
            local shouldHighlight = false
            
            -- Highlight players and NPCs
            if ent:IsPlayer() or ent:IsNPC() then
                shouldHighlight = true
            -- Highlight physics props
            elseif ent:GetClass():find("prop_physics") then
                shouldHighlight = true
            -- Highlight weapons
            elseif ent:IsWeapon() then
                shouldHighlight = true
            -- Highlight vehicles
            elseif ent:IsVehicle() then
                shouldHighlight = true
            end
            
            if shouldHighlight then
                table.insert(highlighted, ent)
            end
        end
    end
    
    -- Draw halos with pulsing effect
    if #highlighted > 0 then
        local color = Color(0, 150, 255, 255 * self.PulseAlpha)
        halo.Add(highlighted, color, 5 * self.PulseAlpha, 5 * self.PulseAlpha, 2, true, true)
    end
end

function SWEP:Think()
    if CLIENT and self.VisionActive then
        -- Update energy
        local drainRate = GetConVar("sc_energy_drain"):GetFloat()
        self.Energy = math.max(0, self.Energy - drainRate * FrameTime())
        
        -- Turn off vision if out of energy
        if self.Energy <= 0 then
            self:ToggleVision()
        end
    elseif CLIENT and not self.VisionActive and self.Energy < self.Settings.maxEnergy then
        -- Recharge energy when vision is off
        local rechargeRate = GetConVar("sc_energy_recharge"):GetFloat()
        self.Energy = math.min(self.Settings.maxEnergy, self.Energy + rechargeRate * FrameTime())
    end
end

function SWEP:DrawHUD()
    if not CLIENT then return end
    
    local w, h = ScrW(), ScrH()
    local owner = self:GetOwner()
    
    if not IsValid(owner) or owner != LocalPlayer() then return end
    
    -- Draw vision mode indicator
    if self.VisionActive then
        local mode = self.VisionModes[self.CurrentMode]
        
        -- Mode name with Splinter Cell style
        draw.SimpleTextOutlined(mode.name, "Trebuchet24", w - 20, 20, 
            Color(0, 255, 0, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, 200))
        
        -- Draw crosshair overlay
        surface.SetDrawColor(mode.color)
        surface.DrawLine(w/2 - 20, h/2, w/2 - 5, h/2)
        surface.DrawLine(w/2 + 5, h/2, w/2 + 20, h/2)
        surface.DrawLine(w/2, h/2 - 20, w/2, h/2 - 5)
        surface.DrawLine(w/2, h/2 + 5, w/2, h/2 + 20)
    end
    
    -- Draw energy bar
    local barWidth = 200
    local barHeight = 20
    local barX = w - barWidth - 20
    local barY = 50
    
    -- Background
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(barX - 2, barY - 2, barWidth + 4, barHeight + 4)
    
    -- Energy bar
    local energyPercent = self.Energy / self.Settings.maxEnergy
    local barColor = Color(0, 255, 0, 255)
    
    if energyPercent < 0.3 then
        barColor = Color(255, 0, 0, 255)
    elseif energyPercent < 0.6 then
        barColor = Color(255, 255, 0, 255)
    end
    
    surface.SetDrawColor(barColor)
    surface.DrawRect(barX, barY, barWidth * energyPercent, barHeight)
    
    -- Energy text
    draw.SimpleText("ENERGY", "Default", barX + barWidth/2, barY + barHeight/2, 
        Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Instructions
    if not self.VisionActive then
        draw.SimpleTextOutlined("Press N to activate vision", "Default", w/2, h - 100, 
            Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 150))
    else
        draw.SimpleTextOutlined("Press T to cycle modes | Press N to deactivate", "Default", w/2, h - 100, 
            Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 150))
    end
end

function SWEP:Deploy()
    if CLIENT then
        self:SetupKeyBindings()
    end
    return true
end

function SWEP:Holster()
    if CLIENT then
        self:StopVisionEffects()
        hook.Remove("Think", "SC_VisionKeyCheck_" .. self:EntIndex())
    end
    return true
end

function SWEP:OnRemove()
    if CLIENT then
        self:StopVisionEffects()
        hook.Remove("Think", "SC_VisionKeyCheck_" .. self:EntIndex())
    end
end

function SWEP:PrimaryAttack()
    -- No primary attack
end

function SWEP:SecondaryAttack()
    -- No secondary attack
end

-- Network the active state for other players to see effects
if SERVER then
    util.AddNetworkString("SC_VisionState")
end

-- Prevent the weapon from being dropped
function SWEP:CanPrimaryAttack()
    return false
end

function SWEP:CanSecondaryAttack()
    return false
end