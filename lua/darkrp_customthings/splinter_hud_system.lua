-- ============================================================================
-- ULTRA-ENHANCED SPLINTER CELL HUD AND VISUALIZATION SYSTEM
-- ============================================================================
-- Advanced multi-panel HUD with real-time data visualization,
-- augmented reality overlays, and tactical information display
-- ============================================================================

if CLIENT then
    -- ============================================================================
    -- ADVANCED HUD RENDERING SYSTEM
    -- ============================================================================
    
    local HUDSystem = {
        -- Display Configuration
        display = {
            resolution = {ScrW(), ScrH()},
            aspect_ratio = ScrW() / ScrH(),
            refresh_rate = 120,
            color_depth = 32,
            hdr_enabled = true
        },
        
        -- Panel System
        panels = {
            main_display = {x = 0, y = 0, w = ScrW(), h = ScrH(), active = true},
            tactical_overlay = {x = 50, y = 50, w = 300, h = 400, active = true},
            minimap = {x = ScrW() - 250, y = 50, w = 200, h = 200, active = true},
            vitals = {x = 50, y = ScrH() - 200, w = 250, h = 150, active = true},
            threat_assessment = {x = ScrW() - 300, y = ScrH() - 200, w = 250, h = 150, active = true},
            communication = {x = ScrW()/2 - 200, y = 50, w = 400, h = 100, active = false},
            mission_briefing = {x = ScrW()/2 - 300, y = ScrH()/2 - 200, w = 600, h = 400, active = false}
        },
        
        -- Color Schemes
        color_schemes = {
            night_vision = {
                primary = Color(0, 255, 0, 200),
                secondary = Color(0, 200, 0, 150),
                accent = Color(255, 255, 0, 180),
                background = Color(0, 50, 0, 100),
                text = Color(200, 255, 200, 255)
            },
            thermal = {
                primary = Color(255, 100, 0, 200),
                secondary = Color(255, 50, 0, 150),
                accent = Color(255, 255, 100, 180),
                background = Color(50, 20, 0, 100),
                text = Color(255, 200, 100, 255)
            },
            sonar = {
                primary = Color(0, 150, 255, 200),
                secondary = Color(0, 100, 200, 150),
                accent = Color(100, 200, 255, 180),
                background = Color(0, 20, 50, 100),
                text = Color(150, 200, 255, 255)
            },
            quantum = {
                primary = Color(255, 0, 255, 200),
                secondary = Color(200, 0, 200, 150),
                accent = Color(255, 100, 255, 180),
                background = Color(50, 0, 50, 100),
                text = Color(255, 150, 255, 255)
            }
        },
        
        -- Animation System
        animations = {
            fade_duration = 0.3,
            slide_duration = 0.5,
            pulse_frequency = 2.0,
            rotation_speed = 45, -- degrees per second
            scale_amplitude = 0.1
        },
        
        -- Data Streams
        data_streams = {
            real_time = {},
            buffered = {},
            historical = {},
            predictive = {}
        }
    }
    
    -- ============================================================================
    -- TACTICAL OVERLAY RENDERING
    -- ============================================================================
    
    local function DrawTacticalOverlay()
        local panel = HUDSystem.panels.tactical_overlay
        if not panel.active then return end
        
        local x, y, w, h = panel.x, panel.y, panel.w, panel.h
        local currentMode = visionModes[currentMode] or visionModes[1]
        local colors = HUDSystem.color_schemes[currentMode.id] or HUDSystem.color_schemes.night_vision
        
        -- Background panel
        draw.RoundedBox(8, x, y, w, h, colors.background)
        draw.RoundedBox(8, x + 2, y + 2, w - 4, h - 4, Color(0, 0, 0, 50))
        
        -- Header
        draw.SimpleText("TACTICAL OVERLAY", "DermaLarge", x + w/2, y + 20, colors.primary, TEXT_ALIGN_CENTER)
        draw.RoundedBox(2, x + 10, y + 35, w - 20, 2, colors.accent)
        
        local yOffset = 50
        
        -- Current Mode Display
        draw.SimpleText("MODE: " .. currentMode.name, "DermaDefault", x + 15, y + yOffset, colors.text)
        draw.SimpleText(currentMode.description, "DermaDefaultBold", x + 15, y + yOffset + 15, colors.secondary)
        yOffset = yOffset + 40
        
        -- System Status
        draw.SimpleText("SYSTEM STATUS", "DermaDefaultBold", x + 15, y + yOffset, colors.primary)
        yOffset = yOffset + 20
        
        -- Battery Level
        local batteryColor = battery > 30 and Color(0, 255, 0) or (battery > 10 and Color(255, 255, 0) or Color(255, 0, 0))
        draw.RoundedBox(4, x + 15, y + yOffset, w - 30, 20, Color(0, 0, 0, 100))
        draw.RoundedBox(4, x + 15, y + yOffset, (w - 30) * (battery / 100), 20, batteryColor)
        draw.SimpleText("BATTERY: " .. math.floor(battery) .. "%", "DermaDefault", x + w/2, y + yOffset + 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        yOffset = yOffset + 30
        
        -- System Temperature
        local tempColor = systemTemp > 70 and Color(255, 0, 0) or (systemTemp > 50 and Color(255, 255, 0) or Color(0, 255, 0))
        draw.RoundedBox(4, x + 15, y + yOffset, w - 30, 20, Color(0, 0, 0, 100))
        draw.RoundedBox(4, x + 15, y + yOffset, (w - 30) * (systemTemp / 100), 20, tempColor)
        draw.SimpleText("TEMP: " .. math.floor(systemTemp) .. "°C", "DermaDefault", x + w/2, y + yOffset + 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        yOffset = yOffset + 30
        
        -- Threat Level
        local threatColor = threatLevel > 60 and Color(255, 0, 0) or (threatLevel > 30 and Color(255, 255, 0) or Color(0, 255, 0))
        draw.RoundedBox(4, x + 15, y + yOffset, w - 30, 20, Color(0, 0, 0, 100))
        draw.RoundedBox(4, x + 15, y + yOffset, (w - 30) * (threatLevel / 100), 20, threatColor)
        draw.SimpleText("THREAT: " .. math.floor(threatLevel) .. "%", "DermaDefault", x + w/2, y + yOffset + 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        yOffset = yOffset + 40
        
        -- Environmental Data
        draw.SimpleText("ENVIRONMENT", "DermaDefaultBold", x + 15, y + yOffset, colors.primary)
        yOffset = yOffset + 20
        
        local ply = LocalPlayer()
        local pos = ply:GetPos()
        
        draw.SimpleText("COORDINATES:", "DermaDefault", x + 15, y + yOffset, colors.text)
        draw.SimpleText(string.format("X: %.1f  Y: %.1f  Z: %.1f", pos.x, pos.y, pos.z), "DermaDefault", x + 15, y + yOffset + 15, colors.secondary)
        yOffset = yOffset + 35
        
        -- Compass
        local angles = ply:EyeAngles()
        local bearing = math.floor((angles.y + 360) % 360)
        local cardinalDir = "N"
        if bearing >= 315 or bearing < 45 then cardinalDir = "N"
        elseif bearing >= 45 and bearing < 135 then cardinalDir = "E"
        elseif bearing >= 135 and bearing < 225 then cardinalDir = "S"
        else cardinalDir = "W" end
        
        draw.SimpleText("BEARING: " .. bearing .. "° " .. cardinalDir, "DermaDefault", x + 15, y + yOffset, colors.text)
        yOffset = yOffset + 20
        
        -- Environmental Noise
        draw.SimpleText("NOISE LEVEL: " .. math.floor(environmentalNoise) .. "%", "DermaDefault", x + 15, y + yOffset, colors.text)
        yOffset = yOffset + 20
        
        -- Active Features
        if stealthMode then
            draw.SimpleText("STEALTH MODE: ACTIVE", "DermaDefault", x + 15, y + yOffset, Color(100, 100, 255))
            yOffset = yOffset + 15
        end
        
        if recordingMode then
            local flashAlpha = math.abs(math.sin(CurTime() * 4)) * 255
            draw.SimpleText("● RECORDING", "DermaDefault", x + 15, y + yOffset, Color(255, 0, 0, flashAlpha))
        end
    end
    
    -- ============================================================================
    -- MINIMAP SYSTEM
    -- ============================================================================
    
    local function DrawMinimap()
        local panel = HUDSystem.panels.minimap
        if not panel.active then return end
        
        local x, y, w, h = panel.x, panel.y, panel.w, panel.h
        local ply = LocalPlayer()
        local pos = ply:GetPos()
        local ang = ply:EyeAngles()
        
        -- Background
        draw.RoundedBox(8, x, y, w, h, Color(0, 0, 0, 150))
        draw.RoundedBox(8, x + 2, y + 2, w - 4, h - 4, Color(0, 50, 0, 100))
        
        -- Radar grid
        local centerX, centerY = x + w/2, y + h/2
        local gridSize = 20
        
        for i = -w/2, w/2, gridSize do
            draw.Line(centerX + i, y + 5, centerX + i, y + h - 5, Color(0, 100, 0, 50))
        end
        for i = -h/2, h/2, gridSize do
            draw.Line(x + 5, centerY + i, x + w - 5, centerY + i, Color(0, 100, 0, 50))
        end
        
        -- Range circles
        for radius = 20, w/2 - 10, 20 do
            surface.DrawCircle(centerX, centerY, radius, Color(0, 150, 0, 30))
        end
        
        -- Player position (center)
        surface.DrawCircle(centerX, centerY, 3, Color(0, 255, 0, 255))
        
        -- Player direction indicator
        local dirLength = 15
        local dirX = centerX + math.sin(math.rad(ang.y)) * dirLength
        local dirY = centerY - math.cos(math.rad(ang.y)) * dirLength
        draw.Line(centerX, centerY, dirX, dirY, Color(0, 255, 0, 200))
        
        -- Detected entities
        local scale = 2000 / (w/2) -- 2000 units = minimap radius
        
        for _, ent in ipairs(ents.FindInSphere(pos, 2000)) do
            if IsValid(ent) and ent != ply then
                local entPos = ent:GetPos()
                local diff = entPos - pos
                local distance = diff:Length()
                
                if distance < 2000 then
                    local mapX = centerX + (diff.x / scale)
                    local mapY = centerY - (diff.y / scale)
                    
                    local color = Color(100, 100, 100, 150)
                    local size = 2
                    
                    if ent:IsPlayer() then
                        color = Color(255, 0, 0, 200)
                        size = 3
                    elseif ent:IsNPC() then
                        color = Color(255, 100, 0, 200)
                        size = 3
                    elseif ent:IsWeapon() then
                        color = Color(0, 200, 255, 150)
                        size = 2
                    elseif ent:IsVehicle() then
                        color = Color(255, 255, 0, 180)
                        size = 4
                    end
                    
                    surface.DrawCircle(mapX, mapY, size, color)
                end
            end
        end
        
        -- Compass rose
        local compassRadius = 15
        local compassX, compassY = x + w - 25, y + 25
        
        surface.DrawCircle(compassX, compassY, compassRadius, Color(0, 0, 0, 100))
        
        -- Cardinal directions
        draw.SimpleText("N", "DermaDefault", compassX, compassY - compassRadius - 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText("S", "DermaDefault", compassX, compassY + compassRadius + 5, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText("E", "DermaDefault", compassX + compassRadius + 5, compassY, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText("W", "DermaDefault", compassX - compassRadius - 5, compassY, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        
        -- Compass needle
        local needleLength = compassRadius - 3
        local needleX = compassX + math.sin(math.rad(ang.y)) * needleLength
        local needleY = compassY - math.cos(math.rad(ang.y)) * needleLength
        draw.Line(compassX, compassY, needleX, needleY, Color(255, 0, 0, 200))
    end
    
    -- ============================================================================
    -- VITALS MONITORING PANEL
    -- ============================================================================
    
    local function DrawVitalsPanel()
        local panel = HUDSystem.panels.vitals
        if not panel.active then return end
        
        local x, y, w, h = panel.x, panel.y, panel.w, panel.h
        
        -- Background
        draw.RoundedBox(8, x, y, w, h, Color(0, 0, 0, 150))
        draw.RoundedBox(8, x + 2, y + 2, w - 4, h - 4, Color(0, 50, 50, 100))
        
        -- Header
        draw.SimpleText("BIOMETRIC MONITOR", "DermaLarge", x + w/2, y + 15, Color(0, 255, 255), TEXT_ALIGN_CENTER)
        draw.RoundedBox(2, x + 10, y + 30, w - 20, 2, Color(0, 255, 255))
        
        local yOffset = 45
        
        -- Heart Rate
        local heartRate = 75 + math.sin(CurTime() * 3) * 10 + (threatLevel * 0.5)
        local heartColor = heartRate > 100 and Color(255, 100, 100) or Color(100, 255, 100)
        draw.SimpleText("HEART RATE: " .. math.floor(heartRate) .. " BPM", "DermaDefault", x + 15, y + yOffset, heartColor)
        
        -- Heart rate graph (simple)
        local graphY = y + yOffset + 15
        for i = 0, w - 30, 2 do
            local time = CurTime() - (i * 0.01)
            local value = math.sin(time * 3) * 5
            local pointY = graphY + value
            draw.RoundedBox(0, x + 15 + i, pointY, 1, 1, heartColor)
        end
        
        yOffset = yOffset + 35
        
        -- Stress Level
        local stressLevel = math.min(100, threatLevel + (systemTemp - 20) * 2)
        local stressColor = stressLevel > 70 and Color(255, 0, 0) or (stressLevel > 40 and Color(255, 255, 0) or Color(0, 255, 0))
        draw.SimpleText("STRESS LEVEL: " .. math.floor(stressLevel) .. "%", "DermaDefault", x + 15, y + yOffset, stressColor)
        yOffset = yOffset + 20
        
        -- Fatigue Level
        local fatigueLevel = math.max(0, 100 - energy)
        local fatigueColor = fatigueLevel > 70 and Color(255, 100, 0) or Color(100, 255, 100)
        draw.SimpleText("FATIGUE: " .. math.floor(fatigueLevel) .. "%", "DermaDefault", x + 15, y + yOffset, fatigueColor)
        yOffset = yOffset + 20
        
        -- Health Status
        local health = LocalPlayer():Health()
        local healthColor = health > 75 and Color(0, 255, 0) or (health > 50 and Color(255, 255, 0) or Color(255, 0, 0))
        draw.SimpleText("HEALTH: " .. health .. "%", "DermaDefault", x + 15, y + yOffset, healthColor)
    end
    
    -- ============================================================================
    -- THREAT ASSESSMENT PANEL
    -- ============================================================================
    
    local function DrawThreatAssessment()
        local panel = HUDSystem.panels.threat_assessment
        if not panel.active then return end
        
        local x, y, w, h = panel.x, panel.y, panel.w, panel.h
        
        -- Background
        draw.RoundedBox(8, x, y, w, h, Color(0, 0, 0, 150))
        draw.RoundedBox(8, x + 2, y + 2, w - 4, h - 4, Color(50, 0, 0, 100))
        
        -- Header
        draw.SimpleText("THREAT ASSESSMENT", "DermaLarge", x + w/2, y + 15, Color(255, 100, 100), TEXT_ALIGN_CENTER)
        draw.RoundedBox(2, x + 10, y + 30, w - 20, 2, Color(255, 100, 100))
        
        local yOffset = 45
        
        -- Overall threat level
        local threatColor = threatLevel > 60 and Color(255, 0, 0) or (threatLevel > 30 and Color(255, 255, 0) or Color(0, 255, 0))
        local threatText = threatLevel > 60 and "HIGH" or (threatLevel > 30 and "MODERATE" or "LOW")
        draw.SimpleText("THREAT LEVEL: " .. threatText, "DermaDefaultBold", x + 15, y + yOffset, threatColor)
        yOffset = yOffset + 25
        
        -- Detected threats
        local ply = LocalPlayer()
        local threats = {}
        
        for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 1500)) do
            if IsValid(ent) and ent != ply then
                local distance = ply:GetPos():Distance(ent:GetPos())
                local threat = {entity = ent, distance = distance, level = 0}
                
                if ent:IsPlayer() and ent:GetActiveWeapon():IsValid() then
                    threat.level = 80
                    threat.type = "ARMED PLAYER"
                elseif ent:IsPlayer() then
                    threat.level = 40
                    threat.type = "PLAYER"
                elseif ent:IsNPC() then
                    threat.level = 60
                    threat.type = "NPC"
                elseif ent:IsWeapon() then
                    threat.level = 20
                    threat.type = "WEAPON"
                end
                
                if threat.level > 0 then
                    table.insert(threats, threat)
                end
            end
        end
        
        -- Sort by threat level
        table.sort(threats, function(a, b) return a.level > b.level end)
        
        -- Display top threats
        for i = 1, math.min(4, #threats) do
            local threat = threats[i]
            local threatColor = threat.level > 60 and Color(255, 0, 0) or (threat.level > 30 and Color(255, 255, 0) or Color(255, 255, 255))
            
            draw.SimpleText(threat.type, "DermaDefault", x + 15, y + yOffset, threatColor)
            draw.SimpleText(string.format("%.0fm", threat.distance / 52.49), "DermaDefault", x + w - 50, y + yOffset, Color(200, 200, 200))
            yOffset = yOffset + 15
        end
        
        if #threats == 0 then
            draw.SimpleText("NO IMMEDIATE THREATS", "DermaDefault", x + 15, y + yOffset, Color(100, 255, 100))
        end
    end
    
    -- ============================================================================
    -- ADVANCED CROSSHAIR SYSTEM
    -- ============================================================================
    
    local function DrawAdvancedCrosshair()
        if not visionActive then return end
        
        local centerX, centerY = ScrW() / 2, ScrH() / 2
        local currentMode = visionModes[currentMode] or visionModes[1]
        local colors = HUDSystem.color_schemes[currentMode.id] or HUDSystem.color_schemes.night_vision
        
        -- Dynamic crosshair size based on movement
        local ply = LocalPlayer()
        local velocity = ply:GetVelocity():Length()
        local baseSize = 10
        local dynamicSize = baseSize + (velocity / 100)
        
        -- Crosshair lines
        draw.RoundedBox(0, centerX - dynamicSize, centerY - 1, dynamicSize - 3, 2, colors.primary)
        draw.RoundedBox(0, centerX + 3, centerY - 1, dynamicSize - 3, 2, colors.primary)
        draw.RoundedBox(0, centerX - 1, centerY - dynamicSize, 2, dynamicSize - 3, colors.primary)
        draw.RoundedBox(0, centerX - 1, centerY + 3, 2, dynamicSize - 3, colors.primary)
        
        -- Center dot
        surface.DrawCircle(centerX, centerY, 2, colors.accent)
        
        -- Range finder
        local trace = ply:GetEyeTrace()
        if trace.Hit then
            local distance = trace.StartPos:Distance(trace.HitPos)
            local distanceText = string.format("%.1fm", distance / 52.49)
            draw.SimpleText(distanceText, "DermaDefault", centerX + 20, centerY - 30, colors.text)
            
            -- Distance markers
            for i = 1, 5 do
                local markerSize = 20 - (i * 2)
                surface.DrawCircle(centerX, centerY, markerSize, Color(colors.primary.r, colors.primary.g, colors.primary.b, 50 / i))
            end
        end
    end
    
    -- ============================================================================
    -- MAIN HUD RENDERING HOOK
    -- ============================================================================
    
    local function DrawEnhancedHUD()
        if not HasSplinterCellAbilities() then return end
        if not visionActive then return end
        
        -- Draw all HUD components
        DrawTacticalOverlay()
        DrawMinimap()
        DrawVitalsPanel()
        DrawThreatAssessment()
        DrawAdvancedCrosshair()
        
        -- Mode-specific overlays
        local currentMode = visionModes[currentMode] or visionModes[1]
        
        if currentMode.id == "thermal" then
            -- Thermal overlay effects would go here
        elseif currentMode.id == "sonar" then
            -- Sonar overlay effects would go here
        elseif currentMode.id == "quantum" then
            -- Quantum overlay effects would go here
        end
    end
    
    -- Hook the HUD rendering
    hook.Add("HUDPaint", "SplinterCellEnhancedHUD", DrawEnhancedHUD)
    
    print("[SPLINTER CELL] Enhanced HUD System Loaded!")
    print("• Advanced Multi-Panel Display")
    print("• Real-time Tactical Overlay")
    print("• Interactive Minimap System")
    print("• Biometric Monitoring Panel")
    print("• Threat Assessment Display")
    print("• Dynamic Crosshair System")
    
end