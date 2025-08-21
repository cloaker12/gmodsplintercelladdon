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
        return "PATROL"
    elseif state == 2 then
        return "SUSPICIOUS"
    elseif state == 3 then
        return "HUNT"
    elseif state == 4 then
        return "ENGAGE"
    elseif state == 5 then
        return "DISAPPEAR"
    elseif state == 6 then
        return "WALL CLIMB"
    elseif state == 7 then
        return "EVASIVE"
    elseif state == 8 then
        return "SMOKE"
    elseif state == 9 then
        return "NIGHT HUNT"
    else
        return "UNKNOWN"
    end
end

function ENT:GetStateColor()
    local state = self:GetNWInt("tacticalState", 1)
    
    if state == 1 then
        return Color(0, 255, 0)      -- Green for patrol
    elseif state == 2 then
        return Color(255, 255, 0)    -- Yellow for suspicious
    elseif state == 3 then
        return Color(255, 165, 0)    -- Orange for hunt
    elseif state == 4 then
        return Color(255, 0, 0)      -- Red for engage
    elseif state == 5 then
        return Color(128, 128, 128)  -- Gray for disappear
    elseif state == 6 then
        return Color(0, 255, 255)    -- Cyan for wall climb
    elseif state == 7 then
        return Color(255, 0, 255)    -- Magenta for evasive
    elseif state == 8 then
        return Color(128, 0, 128)    -- Purple for smoke
    elseif state == 9 then
        return Color(0, 255, 128)    -- Green-cyan for night hunt
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

-- Enhanced Tactical Effects for Splinter Cell NextBot

-- Enhanced tactical information display
function ENT:DrawEnhancedTacticalInfo()
    local pos = self:GetPos() + Vector(0, 0, 80)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        -- Draw tactical state with enhanced styling
        local stateText = self:GetTacticalStateText()
        local stateColor = self:GetStateColor()
        
        -- Enhanced state display
        draw.SimpleTextOutlined("TACTICAL STATE", "DermaDefault", 0, -30, stateColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined(stateText, "DermaDefault", 0, -10, stateColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        -- Draw suspicion meter (if available)
        local suspicionMeter = self:GetNWFloat("suspicionMeter", 0)
        if suspicionMeter > 0 then
            local suspicionBarWidth = 100
            local suspicionBarHeight = 6
            
            -- Background
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(-suspicionBarWidth/2, 5, suspicionBarWidth, suspicionBarHeight)
            
            -- Suspicion bar
            local suspicionColor = Color(255, 165, 0, 255)  -- Orange
            surface.SetDrawColor(suspicionColor)
            surface.DrawRect(-suspicionBarWidth/2, 5, suspicionBarWidth * (suspicionMeter / 100), suspicionBarHeight)
            
            -- Border
            surface.SetDrawColor(255, 255, 255, 100)
            surface.DrawOutlinedRect(-suspicionBarWidth/2, 5, suspicionBarWidth, suspicionBarHeight)
            
            draw.SimpleTextOutlined("SUSPICION", "DermaDefault", 0, 20, Color(255, 165, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        end
        
        -- Draw objective
        local objective = self:GetNWString("currentObjective", "patrol")
        draw.SimpleTextOutlined("OBJECTIVE: " .. string.upper(objective), "DermaDefault", 0, 35, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        -- Draw stealth level
        local stealthLevel = self:GetNWFloat("stealthLevel", 1.0)
        local stealthBarWidth = 100
        local stealthBarHeight = 8
        
        -- Background
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(-stealthBarWidth/2, 50, stealthBarWidth, stealthBarHeight)
        
        -- Stealth bar
        local stealthColor = self:GetStealthColor(stealthLevel)
        surface.SetDrawColor(stealthColor)
        surface.DrawRect(-stealthBarWidth/2, 50, stealthBarWidth * stealthLevel, stealthBarHeight)
        
        -- Border
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawOutlinedRect(-stealthBarWidth/2, 50, stealthBarWidth, stealthBarHeight)
        
        draw.SimpleTextOutlined("STEALTH", "DermaDefault", 0, 65, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        -- Draw night vision status
        local nightVisionActive = self:GetNWBool("nightVisionActive", false)
        if nightVisionActive then
            draw.SimpleTextOutlined("NIGHT VISION: ACTIVE", "DermaDefault", 0, 85, Color(0, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        end
        
        -- Draw movement style indicator
        local currentAnimation = self:GetNWString("currentAnimation", "idle")
        local movementColor = self:GetMovementColor(currentAnimation)
        draw.SimpleTextOutlined("MOVEMENT: " .. string.upper(currentAnimation), "DermaDefault", 0, 105, movementColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        -- Draw combat stance
        local combatStance = self:GetNWString("combatStance", "standing")
        if combatStance ~= "standing" then
            draw.SimpleTextOutlined("STANCE: " .. string.upper(combatStance), "DermaDefault", 0, 125, Color(255, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        end
        
        -- Draw ammo count
        local ammoCount = self:GetNWInt("ammoCount", 30)
        local maxAmmo = 30
        draw.SimpleTextOutlined("AMMO: " .. ammoCount .. "/" .. maxAmmo, "DermaDefault", 0, 145, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        
        -- Draw grenades
        local grenadesAvailable = self:GetNWInt("grenadesAvailable", 2)
        if grenadesAvailable > 0 then
            draw.SimpleTextOutlined("GRENADES: " .. grenadesAvailable, "DermaDefault", 0, 165, Color(255, 128, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
        end
        
    cam.End3D2D()
end

function ENT:GetMovementColor(animation)
    if animation == "idle" then
        return Color(0, 255, 0)      -- Green for idle
    elseif animation == "walk" then
        return Color(0, 200, 255)    -- Blue for walk
    elseif animation == "crouch_walk" then
        return Color(255, 165, 0)    -- Orange for crouch walk
    elseif animation == "aim" then
        return Color(255, 0, 0)      -- Red for aiming
    elseif animation == "run" then
        return Color(255, 0, 255)    -- Magenta for run
    else
        return Color(255, 255, 255)  -- White for unknown
    end
end

-- Enhanced stealth particles with tactical state integration
function ENT:DrawEnhancedStealthParticles()
    local stealthLevel = self:GetNWFloat("stealthLevel", 1.0)
    local nightVisionActive = self:GetNWBool("nightVisionActive", false)
    local tacticalState = self:GetNWInt("tacticalState", 1)
    
    local pos = self:GetPos()
    local particleCount = 3
    local particleColor = Color(0, 100, 200, 100)
    
    -- Adjust particle color based on tactical state
    if tacticalState == 1 then  -- PATROL
        particleColor = Color(0, 255, 0, 80)      -- Green
    elseif tacticalState == 2 then  -- SUSPICIOUS
        particleColor = Color(255, 255, 0, 100)   -- Yellow
    elseif tacticalState == 3 then  -- HUNT
        particleColor = Color(255, 165, 0, 120)   -- Orange
    elseif tacticalState == 4 then  -- ENGAGE
        particleColor = Color(255, 0, 0, 150)     -- Red
    elseif tacticalState == 5 then  -- DISAPPEAR
        particleColor = Color(128, 128, 128, 100) -- Gray
    end
    
    -- Change particle color based on night vision
    if nightVisionActive then
        particleColor = Color(0, 255, 0, 120)
    end
    
    -- Only show particles when stealth level is high
    if stealthLevel > 0.5 then
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

-- Enhanced NVG effect
function ENT:DrawEnhancedNightVisionEffect()
    local nightVisionActive = self:GetNWBool("nightVisionActive", false)
    
    if nightVisionActive then
        local pos = self:GetPos() + Vector(0, 0, 50)
        local player = LocalPlayer()
        if not IsValid(player) then return end
        
        local distance = player:GetPos():Distance(pos)
        if distance < 300 then
            -- Draw NVG glow effect
            for i = 1, 8 do
                local angle = (i - 1) * 45
                local offset = Vector(
                    math.cos(math.rad(angle)) * 40,
                    math.sin(math.rad(angle)) * 40,
                    0
                )
                
                local glowPos = pos + offset
                
                render.SetMaterial(Material("sprites/light_glow02_add"))
                render.DrawSprite(glowPos, 12, 12, Color(0, 255, 0, 60))
            end
            
            -- Draw scanning line effect
            local scanLine = math.sin(CurTime() * 3) * 50
            local scanStart = pos + Vector(-50, scanLine, 0)
            local scanEnd = pos + Vector(50, scanLine, 0)
            
            render.SetMaterial(Material("trails/laser"))
            render.DrawBeam(scanStart, scanEnd, 2, 0, 1, Color(0, 255, 0, 80))
        end
    end
end

-- Enhanced flash effect
function ENT:DrawEnhancedFlashEffect()
    local player = LocalPlayer()
    if not IsValid(player) then return end
    
    local distance = player:GetPos():Distance(self:GetPos())
    if distance < TACTICAL_CONFIG.FLASH_RANGE then
        -- Create flash effect on player screen
        local flashIntensity = math.max(0, (TACTICAL_CONFIG.FLASH_RANGE - distance) / TACTICAL_CONFIG.FLASH_RANGE)
        
        if flashIntensity > 0 then
            -- Draw flash overlay
            surface.SetDrawColor(255, 255, 255, flashIntensity * 100)
            surface.DrawRect(0, 0, ScrW(), ScrH())
            
            -- Draw flash particles
            for i = 1, 10 do
                local x = math.random(0, ScrW())
                local y = math.random(0, ScrH())
                
                surface.SetDrawColor(255, 255, 255, flashIntensity * 150)
                surface.DrawRect(x, y, 2, 2)
            end
        end
    end
end

-- Enhanced smoke effect
function ENT:DrawEnhancedSmokeEffect()
    local player = LocalPlayer()
    if not IsValid(player) then return end
    
    local smokeGrenades = self:GetNWInt("smokeGrenades", 3)
    if smokeGrenades > 0 then
        local pos = self:GetPos()
        local distance = player:GetPos():Distance(pos)
        
        if distance < 500 then
            -- Draw smoke particles around the NextBot
            for i = 1, 15 do
                local smokePos = pos + Vector(
                    math.sin(CurTime() + i) * 100,
                    math.cos(CurTime() + i) * 100,
                    math.sin(CurTime() * 0.5 + i) * 50
                )
                
                render.SetMaterial(Material("sprites/light_glow02_add"))
                render.DrawSprite(smokePos, 15, 15, Color(128, 128, 128, 60))
            end
        end
    end
end

-- Enhanced rappel effect
function ENT:DrawEnhancedRappelEffect()
    local isClimbing = self:GetNWBool("isClimbing", false)
    
    if isClimbing then
        local pos = self:GetPos()
        local player = LocalPlayer()
        if not IsValid(player) then return end
        
        local distance = player:GetPos():Distance(pos)
        if distance < 400 then
            -- Draw rappel rope effect
            local ropeStart = pos + Vector(0, 0, 100)
            local ropeEnd = pos + Vector(0, 0, -20)
            
            render.SetMaterial(Material("trails/laser"))
            render.DrawBeam(ropeStart, ropeEnd, 4, 0, 1, Color(139, 69, 19, 200))
            
            -- Draw rappel particles
            for i = 1, 8 do
                local particlePos = pos + Vector(
                    math.sin(CurTime() * 2 + i) * 20,
                    math.cos(CurTime() * 2 + i) * 20,
                    math.sin(CurTime() + i) * 15
                )
                
                render.SetMaterial(Material("sprites/light_glow02_add"))
                render.DrawSprite(particlePos, 8, 8, Color(139, 69, 19, 120))
            end
        end
    end
end

-- Override the original Draw function to use all enhanced effects
local originalDraw = ENT.Draw
function ENT:Draw()
    -- Draw the NextBot model
    self:DrawModel()
    
    -- Draw weapon if it exists
    local weapon = self:GetNWEntity("weaponEntity")
    if IsValid(weapon) then
        weapon:DrawModel()
    end
    
    -- Draw enhanced tactical information if player is close
    local player = LocalPlayer()
    if IsValid(player) and player:GetPos():Distance(self:GetPos()) < 500 then
        self:DrawEnhancedTacticalInfo()
    end
    
    -- Draw all enhanced effects
    self:DrawEnhancedStealthParticles()
    self:DrawEnhancedNightVisionEffect()
    self:DrawEnhancedSmokeEffect()
    self:DrawEnhancedRappelEffect()
end

-- Enhanced whisper effect with tactical state integration
function ENT:CreateEnhancedWhisperEffect(player)
    local tacticalState = self:GetNWInt("tacticalState", 1)
    local distance = player:GetPos():Distance(self:GetPos())
    local intensity = math.max(0, (200 - distance) / 200)
    
    if intensity > 0 then
        -- Apply screen distortion based on tactical state
        local distortionAmount = intensity * 2
        
        if tacticalState == 2 then  -- SUSPICIOUS
            distortionAmount = intensity * 3
        elseif tacticalState == 3 then  -- HUNT
            distortionAmount = intensity * 4
        elseif tacticalState == 4 then  -- ENGAGE
            distortionAmount = intensity * 5
        end
        
        -- Apply screen shake
        local shake = math.sin(CurTime() * 10) * distortionAmount
        player:SetViewOffset(player:GetViewOffset() + Vector(shake, shake, 0))
        
        -- Create whisper text based on tactical state
        if CurTime() - self.whisperTimer > 3 then
            self.whisperTimer = CurTime()
            self:ShowEnhancedWhisperText(player, tacticalState)
        end
    end
end

function ENT:ShowEnhancedWhisperText(player, tacticalState)
    local messages = {
        [1] = {  -- PATROL
            "Area secure...",
            "No activity detected...",
            "Maintaining patrol...",
            "All clear..."
        },
        [2] = {  -- SUSPICIOUS
            "Something's not right...",
            "I heard something...",
            "Investigating...",
            "Stay alert..."
        },
        [3] = {  -- HUNT
            "I can see you...",
            "You're being hunted...",
            "The shadows are my allies...",
            "There's nowhere to hide..."
        },
        [4] = {  -- ENGAGE
            "Engaging target...",
            "You're mine...",
            "Time to end this...",
            "Surrender now..."
        },
        [5] = {  -- DISAPPEAR
            "Disappearing...",
            "You'll never find me...",
            "Gone like the wind...",
            "Until next time..."
        }
    }
    
    local stateMessages = messages[tacticalState] or messages[1]
    local message = stateMessages[math.random(1, #stateMessages)]
    
    -- Display whisper text on screen
    chat.AddText(Color(0, 255, 0), "[Whisper] ", Color(255, 255, 255), message)
end

-- Client-side light level detection for server requests
net.Receive("SplinterCellRequestLightLevel", function(len)
    local position = net.ReadVector()
    
    -- Get light level using render.GetLightColor (client-side only)
    local light = render.GetLightColor(position)
    local lightLevel = (light.r + light.g + light.b) / 3
    
    -- Send the light level back to the server
    net.Start("SplinterCellLightLevelResponse")
    net.WriteVector(position)
    net.WriteFloat(lightLevel)
    net.SendToServer()
end)
