include("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE

-- Client-side variables
local stealthIndicator = 0
local lastStealthUpdate = 0

function ENT:Initialize()
    -- Initialize client-side effects
    self.stealthParticles = {}
    self.flashEffect = 0
    self.whisperTimer = 0
    self.nightVisionEffect = 0
    self.smokeEffects = {}
    self.wallClimbEffect = 0
    
    -- Set up particle effects for stealth mode
    self:SetupStealthParticles()
end

function ENT:SetupStealthParticles()
    -- Create stealth particle effect
    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    effect:SetScale(0.5)
    util.Effect("smoke", effect)
end

function ENT:Draw()
    -- Draw the NextBot
    self:DrawModel()
    
    -- Draw weapon if it exists
    local weapon = self:GetNWEntity("weaponEntity")
    if IsValid(weapon) then
        weapon:DrawModel()
    end
    
    -- Draw tactical information if player is close
    local player = LocalPlayer()
    if IsValid(player) and player:GetPos():Distance(self:GetPos()) < 500 then
        self:DrawTacticalInfo()
    end
    
    -- Draw stealth indicator
    self:DrawStealthIndicator()
    
    -- Draw night vision effect
    self:DrawNightVisionEffect()
    
    -- Draw wall climbing effect
    self:DrawWallClimbEffect()
    
    -- Draw smoke effects
    self:DrawSmokeEffects()
end

function ENT:DrawTacticalInfo()
    local pos = self:GetPos() + Vector(0, 0, 80)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        -- Draw tactical state
        local stateText = self:GetTacticalStateText()
        local stateColor = self:GetStateColor()
        
        draw.SimpleTextOutlined("TACTICAL STATE", "DermaDefault", 0, -20, stateColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined(stateText, "DermaDefault", 0, 0, stateColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        -- Draw objective
        local objective = self:GetNWString("currentObjective", "patrol")
        draw.SimpleTextOutlined("OBJECTIVE: " .. string.upper(objective), "DermaDefault", 0, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        -- Draw stealth level
        local stealthLevel = self:GetNWFloat("stealthLevel", 1.0)
        local stealthBarWidth = 100
        local stealthBarHeight = 8
        
        -- Background
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(-stealthBarWidth/2, 35, stealthBarWidth, stealthBarHeight)
        
        -- Stealth bar
        local stealthColor = self:GetStealthColor(stealthLevel)
        surface.SetDrawColor(stealthColor)
        surface.DrawRect(-stealthBarWidth/2, 35, stealthBarWidth * stealthLevel, stealthBarHeight)
        
        -- Border
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawOutlinedRect(-stealthBarWidth/2, 35, stealthBarWidth, stealthBarHeight)
        
        draw.SimpleTextOutlined("STEALTH", "DermaDefault", 0, 50, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        -- Draw night vision status
        local nightVisionActive = self:GetNWBool("nightVisionActive", false)
        if nightVisionActive then
            draw.SimpleTextOutlined("NIGHT VISION: ACTIVE", "DermaDefault", 0, 70, Color(0, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        end
        
        -- Draw equipment status
        local smokeGrenades = self:GetNWInt("smokeGrenades", 3)
        local ammoCount = self:GetNWInt("ammoCount", 30)
        local grenadesAvailable = self:GetNWInt("grenadesAvailable", 2)
        
        draw.SimpleTextOutlined("SMOKE: " .. smokeGrenades .. " | AMMO: " .. ammoCount .. " | GRENADES: " .. grenadesAvailable, "DermaDefault", 0, 90, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        -- Draw combat stance
        local combatStance = self:GetNWString("combatStance", "standing")
        local stanceColor = Color(255, 255, 255)
        if combatStance == "crouching" then
            stanceColor = Color(255, 255, 0)
        elseif combatStance == "prone" then
            stanceColor = Color(255, 0, 0)
        end
        
        draw.SimpleTextOutlined("STANCE: " .. string.upper(combatStance), "DermaDefault", 0, 110, stanceColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        -- Draw wall climbing status
        local isClimbing = self:GetNWBool("isClimbing", false)
        if isClimbing then
            draw.SimpleTextOutlined("WALL CLIMBING", "DermaDefault", 0, 130, Color(0, 150, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        end
    cam.End3D2D()
end

function ENT:DrawStealthIndicator()
    local stealthLevel = self:GetNWFloat("stealthLevel", 1.0)
    
    -- Update stealth indicator
    if CurTime() - lastStealthUpdate > 0.1 then
        stealthIndicator = stealthLevel
        lastStealthUpdate = CurTime()
    end
    
    -- Draw stealth particles around the NextBot
    if stealthLevel > 0.7 then
        self:DrawStealthParticles()
    end
end

function ENT:DrawStealthParticles()
    local pos = self:GetPos()
    local particleCount = 5
    
    for i = 1, particleCount do
        local offset = Vector(
            math.sin(CurTime() + i) * 30,
            math.cos(CurTime() + i) * 30,
            math.sin(CurTime() * 0.5 + i) * 20
        )
        
        local particlePos = pos + offset
        
        -- Draw stealth particle
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(particlePos, 8, 8, Color(0, 100, 200, 100))
    end
end

function ENT:GetTacticalStateText()
    local state = self:GetNWInt("tacticalState", 1)
    
    if state == 1 then
        return "IDLE/RECON"
    elseif state == 2 then
        return "INVESTIGATE"
    elseif state == 3 then
        return "STALKING"
    elseif state == 4 then
        return "AMBUSH"
    elseif state == 5 then
        return "ENGAGE SUPPRESSED"
    elseif state == 6 then
        return "RETREAT/RESET"
    else
        return "UNKNOWN"
    end
end

function ENT:GetStateColor()
    local state = self:GetNWInt("tacticalState", 1)
    
    if state == 1 then
        return Color(0, 255, 0)      -- Green for idle
    elseif state == 2 then
        return Color(255, 255, 0)    -- Yellow for investigate
    elseif state == 3 then
        return Color(255, 165, 0)    -- Orange for stalking
    elseif state == 4 then
        return Color(255, 0, 0)      -- Red for ambush
    elseif state == 5 then
        return Color(255, 0, 255)    -- Magenta for engage
    elseif state == 6 then
        return Color(128, 128, 128)  -- Gray for retreat
    else
        return Color(255, 255, 255)  -- White for unknown
    end
end

function ENT:GetStealthColor(stealthLevel)
    if stealthLevel > 0.7 then
        return Color(0, 255, 0)      -- Green for high stealth
    elseif stealthLevel > 0.4 then
        return Color(255, 255, 0)    -- Yellow for medium stealth
    else
        return Color(255, 0, 0)      -- Red for low stealth
    end
end

-- Handle whisper effects
hook.Add("HUDPaint", "SplinterCellWhisperEffect", function()
    local player = LocalPlayer()
    if not IsValid(player) then return end
    
    -- Check for nearby Splinter Cell NextBots
    local nextbots = ents.FindByClass("nextbot_splinter_cell")
    for _, nextbot in pairs(nextbots) do
        if IsValid(nextbot) then
            local distance = player:GetPos():Distance(nextbot:GetPos())
            if distance < 200 then
                -- Create whisper effect
                nextbot:CreateWhisperEffect(player)
            end
        end
    end
end)

function ENT:CreateWhisperEffect(player)
    -- Create screen distortion effect
    local distance = player:GetPos():Distance(self:GetPos())
    local intensity = math.max(0, (200 - distance) / 200)
    
    if intensity > 0 then
        -- Apply screen shake
        local shake = math.sin(CurTime() * 10) * intensity * 2
        player:SetViewOffset(player:GetViewOffset() + Vector(shake, shake, 0))
        
        -- Create whisper text
        if CurTime() - self.whisperTimer > 3 then
            self.whisperTimer = CurTime()
            -- Whisper effect would be implemented here
        end
    end
end

function ENT:ShowWhisperText(player)
    -- Show whisper text on screen
    local messages = {
        "You're being watched...",
        "I can see you...",
        "The shadows are my allies...",
        "Your footsteps betray you...",
        "Silence is golden...",
        "I am the night..."
    }
    
    local message = messages[math.random(1, #messages)]
    
    -- Create whisper notification
    notification.AddLegacy("[Whisper] " .. message, NOTIFY_GENERIC, 3)
    
    -- Play whisper sound
    surface.PlaySound("ambient/voices/m_scream1.wav")
end

-- Handle flash effects
hook.Add("RenderScreenspaceEffects", "SplinterCellFlashEffect", function()
    local player = LocalPlayer()
    if not IsValid(player) then return end
    
    -- Check for flash effects
    local nextbots = ents.FindByClass("nextbot_splinter_cell")
    for _, nextbot in pairs(nextbots) do
        if IsValid(nextbot) then
            local distance = player:GetPos():Distance(nextbot:GetPos())
            if distance < 150 then
                -- Apply flash effect
                nextbot:ApplyFlashEffect(player, distance)
            end
        end
    end
end)

function ENT:ApplyFlashEffect(player, distance)
    local intensity = math.max(0, (150 - distance) / 150)
    
    if intensity > 0 then
        -- Create flash overlay
        local flashColor = Color(255, 255, 255, intensity * 50)
        surface.SetDrawColor(flashColor)
        surface.DrawRect(0, 0, ScrW(), ScrH())
        
        -- Apply screen distortion
        local distortion = math.sin(CurTime() * 20) * intensity * 5
        player:SetViewOffset(player:GetViewOffset() + Vector(distortion, 0, 0))
    end
end

-- Cleanup on entity removal
function ENT:OnRemove()
    -- Clean up client-side effects
    self.stealthParticles = {}
    self.flashEffect = 0
    self.whisperTimer = 0
end

-- Additional client-side effects and improvements
function ENT:Think()
    -- Update client-side effects
    if not IsValid(self) then return end
    
    -- Update stealth particles
    self:UpdateStealthParticles()
    
    -- Update flash effects
    self:UpdateFlashEffects()
    
    -- Set next think time
    self:NextThink(CurTime() + 0.05)
    return true
end

function ENT:UpdateStealthParticles()
    local stealthLevel = self:GetNWFloat("stealthLevel", 1.0)
    
    -- Only show particles when highly stealthy
    if stealthLevel > 0.8 then
        -- Create new particles
        if not self.stealthParticles then
            self.stealthParticles = {}
        end
        
        -- Add new particle every few frames
        if CurTime() % 0.2 < 0.05 then
            local particle = {
                pos = self:GetPos() + VectorRand() * 50,
                vel = VectorRand() * 10,
                life = 2.0,
                maxLife = 2.0
            }
            table.insert(self.stealthParticles, particle)
        end
        
        -- Update existing particles
        for i = #self.stealthParticles, 1, -1 do
            local particle = self.stealthParticles[i]
            particle.pos = particle.pos + particle.vel * FrameTime()
            particle.life = particle.life - FrameTime()
            
            -- Remove dead particles
            if particle.life <= 0 then
                table.remove(self.stealthParticles, i)
            end
        end
    else
        -- Clear particles when not stealthy
        self.stealthParticles = {}
    end
end

function ENT:UpdateFlashEffects()
    local tacticalState = self:GetNWInt("tacticalState", 1)
    
    -- Flash effect when in aggressive states
    if tacticalState == 4 or tacticalState == 5 then -- AMBUSH or ENGAGE_SUPPRESSED
        self.flashEffect = math.min(1.0, self.flashEffect + FrameTime() * 2)
    else
        self.flashEffect = math.max(0.0, self.flashEffect - FrameTime() * 3)
    end
end

-- Enhanced tactical info display
function ENT:DrawEnhancedTacticalInfo()
    local pos = self:GetPos() + Vector(0, 0, 80)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        -- Background panel
        surface.SetDrawColor(0, 0, 0, 180)
        surface.DrawRect(-120, -40, 240, 120)
        
        -- Border
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawOutlinedRect(-120, -40, 240, 120)
        
        -- Tactical state with enhanced styling
        local stateText = self:GetTacticalStateText()
        local stateColor = self:GetStateColor()
        
        -- State background
        surface.SetDrawColor(stateColor.r * 0.3, stateColor.g * 0.3, stateColor.b * 0.3, 200)
        surface.DrawRect(-110, -30, 220, 25)
        
        draw.SimpleTextOutlined("TACTICAL STATE", "DermaDefault", 0, -20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined(stateText, "DermaDefault", 0, -5, stateColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        -- Objective with icon
        local objective = self:GetNWString("currentObjective", "patrol")
        local objectiveIcon = self:GetObjectiveIcon(objective)
        
        draw.SimpleTextOutlined(objectiveIcon .. " OBJECTIVE: " .. string.upper(objective), "DermaDefault", 0, 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        -- Enhanced stealth bar
        local stealthLevel = self:GetNWFloat("stealthLevel", 1.0)
        local stealthBarWidth = 180
        local stealthBarHeight = 12
        
        -- Stealth bar background
        surface.SetDrawColor(50, 50, 50, 200)
        surface.DrawRect(-stealthBarWidth/2, 30, stealthBarWidth, stealthBarHeight)
        
        -- Stealth bar fill
        local stealthColor = self:GetStealthColor(stealthLevel)
        surface.SetDrawColor(stealthColor)
        surface.DrawRect(-stealthBarWidth/2, 30, stealthBarWidth * stealthLevel, stealthBarHeight)
        
        -- Stealth bar border
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawOutlinedRect(-stealthBarWidth/2, 30, stealthBarWidth, stealthBarHeight)
        
        -- Stealth percentage
        local stealthPercent = math.floor(stealthLevel * 100)
        draw.SimpleTextOutlined(stealthPercent .. "% STEALTH", "DermaDefault", 0, 50, stealthColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        -- Flash effect overlay
        if self.flashEffect > 0 then
            local flashColor = Color(255, 0, 0, self.flashEffect * 50)
            surface.SetDrawColor(flashColor)
            surface.DrawRect(-120, -40, 240, 120)
        end
    cam.End3D2D()
end

function ENT:GetObjectiveIcon(objective)
    local icons = {
        patrol = "🔄",
        investigate = "🔍",
        stalk = "👁️",
        execute_takedown = "⚔️",
        suppress = "🔫",
        retreat = "🏃"
    }
    return icons[objective] or "❓"
end

-- Enhanced stealth particles
function ENT:DrawEnhancedStealthParticles()
    if not self.stealthParticles then return end
    
    for _, particle in pairs(self.stealthParticles) do
        local alpha = (particle.life / particle.maxLife) * 100
        local size = (particle.life / particle.maxLife) * 12
        
        -- Draw particle
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(particle.pos, size, size, Color(0, 150, 255, alpha))
        
        -- Draw trail
        local trailPos = particle.pos - particle.vel * 0.1
        render.DrawSprite(trailPos, size * 0.5, size * 0.5, Color(0, 100, 200, alpha * 0.5))
    end
end

-- New Visual Effect Functions
function ENT:DrawNightVisionEffect()
    local nightVisionActive = self:GetNWBool("nightVisionActive", false)
    if not nightVisionActive then return end
    
    local pos = self:GetPos()
    local player = LocalPlayer()
    if not IsValid(player) then return end
    
    -- Create night vision goggles effect
    local gogglePos = pos + Vector(0, 0, 60)
    local distance = player:GetPos():Distance(pos)
    
    if distance < 300 then
        -- Draw night vision goggles glow
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(gogglePos, 20, 20, Color(0, 255, 0, 100))
        
        -- Draw scanning effect
        local scanAngle = CurTime() * 50
        local scanPos = gogglePos + Vector(math.cos(math.rad(scanAngle)), math.sin(math.rad(scanAngle)), 0) * 30
        render.DrawSprite(scanPos, 8, 8, Color(0, 255, 0, 150))
    end
end

function ENT:DrawWallClimbEffect()
    local isClimbing = self:GetNWBool("isClimbing", false)
    if not isClimbing then return end
    
    local pos = self:GetPos()
    local player = LocalPlayer()
    if not IsValid(player) then return end
    
    local distance = player:GetPos():Distance(pos)
    if distance < 400 then
        -- Draw climbing particles
        for i = 1, 5 do
            local particlePos = pos + Vector(
                math.sin(CurTime() * 2 + i) * 15,
                math.cos(CurTime() * 2 + i) * 15,
                math.sin(CurTime() + i) * 10
            )
            
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(particlePos, 6, 6, Color(0, 150, 255, 120))
        end
        
        -- Draw climbing trail
        local trailStart = pos + Vector(0, 0, -20)
        local trailEnd = pos + Vector(0, 0, 20)
        
        render.SetMaterial(Material("trails/laser"))
        render.DrawBeam(trailStart, trailEnd, 3, 0, 1, Color(0, 150, 255, 80))
    end
end

function ENT:DrawSmokeEffects()
    local player = LocalPlayer()
    if not IsValid(player) then return end
    
    -- Draw smoke grenade effects (this would be populated by server-side smoke deployment)
    for i = 1, 3 do
        local smokePos = self:GetPos() + VectorRand() * 100
        local distance = player:GetPos():Distance(smokePos)
        
        if distance < 500 then
            -- Draw smoke particles
            for j = 1, 3 do
                local particlePos = smokePos + Vector(
                    math.sin(CurTime() + i + j) * 20,
                    math.cos(CurTime() + i + j) * 20,
                    math.sin(CurTime() * 0.5 + i + j) * 15
                )
                
                render.SetMaterial(Material("sprites/light_glow02_add"))
                render.DrawSprite(particlePos, 10, 10, Color(128, 128, 128, 80))
            end
        end
    end
end

-- Enhanced stealth particles with night vision integration
function ENT:DrawStealthParticles()
    local stealthLevel = self:GetNWFloat("stealthLevel", 1.0)
    local nightVisionActive = self:GetNWBool("nightVisionActive", false)
    
    if stealthLevel > 0.7 then
        local pos = self:GetPos()
        local particleCount = 5
        local particleColor = Color(0, 100, 200, 100)
        
        -- Change particle color based on night vision
        if nightVisionActive then
            particleColor = Color(0, 255, 0, 120)
        end
        
        for i = 1, particleCount do
            local offset = Vector(
                math.sin(CurTime() + i) * 30,
                math.cos(CurTime() + i) * 30,
                math.sin(CurTime() * 0.5 + i) * 20
            )
            
            local particlePos = pos + offset
            
            -- Draw stealth particle
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(particlePos, 8, 8, particleColor)
        end
    end
end

-- Override the original Draw function to use enhanced version
local originalDraw = ENT.Draw
function ENT:Draw()
    -- Draw the NextBot model
    self:DrawModel()
    
    -- Draw enhanced tactical information if player is close
    local player = LocalPlayer()
    if IsValid(player) and player:GetPos():Distance(self:GetPos()) < 500 then
        self:DrawEnhancedTacticalInfo()
    end
    
    -- Draw enhanced stealth particles
    self:DrawEnhancedStealthParticles()
end
