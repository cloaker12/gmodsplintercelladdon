-- Splinter Cell Themed HUD for The Hidden
-- Modern tactical interface with night vision aesthetics

local math_sin = math.sin
local math_cos = math.cos
local math_rad = math.rad
local CurTime = CurTime
local surface = surface
local draw = draw

-- Splinter Cell Color Scheme
local SC_GREEN = Color(0, 255, 100, 255)
local SC_GREEN_DARK = Color(0, 180, 70, 255)
local SC_GREEN_GLOW = Color(0, 255, 100, 100)
local SC_ORANGE = Color(255, 150, 0, 255)
local SC_RED = Color(255, 50, 50, 255)
local SC_WHITE = Color(255, 255, 255, 255)
local SC_BLACK = Color(0, 0, 0, 200)
local SC_GRAY = Color(100, 100, 100, 255)

-- Night vision overlay effect
local nvg_overlay_alpha = 0
local nvg_static_time = 0

-- HUD Animation variables
local health_lerp = 0
local stamina_lerp = 0
local armor_lerp = 0

-- Create fonts for Splinter Cell HUD
surface.CreateFont("SC_HUD_Large", {
    font = "Orbitron",
    size = 32,
    weight = 700,
    antialias = true,
    shadow = false,
})

surface.CreateFont("SC_HUD_Medium", {
    font = "Orbitron",
    size = 24,
    weight = 600,
    antialias = true,
    shadow = false,
})

surface.CreateFont("SC_HUD_Small", {
    font = "Orbitron",
    size = 18,
    weight = 500,
    antialias = true,
    shadow = false,
})

surface.CreateFont("SC_HUD_Tiny", {
    font = "Orbitron",
    size = 14,
    weight = 400,
    antialias = true,
    shadow = false,
})

-- Draw glowing text with Splinter Cell style
function DrawSCText(text, font, x, y, color, glow_color, align_x, align_y)
    align_x = align_x or TEXT_ALIGN_LEFT
    align_y = align_y or TEXT_ALIGN_TOP
    
    -- Glow effect
    for i = 1, 3 do
        surface.SetTextColor(glow_color.r, glow_color.g, glow_color.b, glow_color.a / (i + 1))
        surface.SetFont(font)
        surface.SetTextPos(x - i, y - i)
        surface.DrawText(text)
        surface.SetTextPos(x + i, y + i)
        surface.DrawText(text)
    end
    
    -- Main text
    surface.SetTextColor(color)
    surface.SetFont(font)
    surface.SetTextPos(x, y)
    surface.DrawText(text)
end

-- Draw animated progress bar
function DrawSCProgressBar(x, y, w, h, progress, color, bg_color, label)
    progress = math.Clamp(progress, 0, 1)
    
    -- Background
    surface.SetDrawColor(bg_color)
    surface.DrawRect(x, y, w, h)
    
    -- Border
    surface.SetDrawColor(SC_GREEN)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)
    
    -- Fill bar
    local fill_w = w * progress
    surface.SetDrawColor(color)
    surface.DrawRect(x, y, fill_w, h)
    
    -- Animated scanner line
    local scanner_x = x + (math_sin(CurTime() * 3) * 0.5 + 0.5) * w
    surface.SetDrawColor(SC_WHITE.r, SC_WHITE.g, SC_WHITE.b, 100)
    surface.DrawRect(scanner_x - 1, y, 2, h)
    
    -- Label
    if label then
        DrawSCText(label, "SC_HUD_Tiny", x, y - 18, SC_GREEN, SC_GREEN_GLOW)
    end
    
    -- Percentage text
    local percent_text = string.format("%.0f%%", progress * 100)
    surface.SetFont("SC_HUD_Tiny")
    local text_w, text_h = surface.GetTextSize(percent_text)
    DrawSCText(percent_text, "SC_HUD_Tiny", x + w - text_w, y + h + 2, SC_WHITE, SC_GREEN_GLOW)
end

-- Draw tactical crosshair
function DrawSCCrosshair()
    local x, y = ScrW() / 2, ScrH() / 2
    local size = 20
    local gap = 8
    local thickness = 2
    
    -- Pulsing effect based on player health
    local ply = LocalPlayer()
    if IsValid(ply) then
        local health_ratio = ply:Health() / ply:GetMaxHealth()
        if health_ratio < 0.3 then
            local pulse = math_sin(CurTime() * 8) * 0.5 + 0.5
            size = size + pulse * 10
            surface.SetDrawColor(SC_RED.r, SC_RED.g, SC_RED.b, 255 * pulse)
        else
            surface.SetDrawColor(SC_GREEN)
        end
    else
        surface.SetDrawColor(SC_GREEN)
    end
    
    -- Draw crosshair lines
    surface.DrawRect(x - size, y - thickness/2, size - gap, thickness)
    surface.DrawRect(x + gap, y - thickness/2, size - gap, thickness)
    surface.DrawRect(x - thickness/2, y - size, thickness, size - gap)
    surface.DrawRect(x - thickness/2, y + gap, thickness, size - gap)
    
    -- Center dot
    surface.SetDrawColor(SC_WHITE)
    surface.DrawRect(x - 1, y - 1, 2, 2)
end

-- Draw night vision static effect
function DrawNightVisionStatic()
    nvg_static_time = nvg_static_time + FrameTime()
    
    if nvg_static_time > 0.1 then
        nvg_static_time = 0
        
        -- Random static lines
        for i = 1, 5 do
            local x = math.random(0, ScrW())
            local y = math.random(0, ScrH())
            local w = math.random(50, 200)
            local h = math.random(1, 3)
            
            surface.SetDrawColor(SC_GREEN.r, SC_GREEN.g, SC_GREEN.b, math.random(20, 60))
            surface.DrawRect(x, y, w, h)
        end
    end
    
    -- Scanline effect
    local scanline_y = (CurTime() * 200) % ScrH()
    surface.SetDrawColor(SC_GREEN.r, SC_GREEN.g, SC_GREEN.b, 30)
    surface.DrawRect(0, scanline_y, ScrW(), 2)
end

-- Draw tactical radar/minimap indicator
function DrawTacticalRadar(x, y, size)
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    -- Radar background
    surface.SetDrawColor(SC_BLACK)
    draw.Circle(x, y, size, 32)
    
    surface.SetDrawColor(SC_GREEN)
    draw.Circle(x, y, size, 32, true, 2)
    
    -- Radar sweep
    local sweep_angle = (CurTime() * 90) % 360
    local sweep_x = x + math_cos(math_rad(sweep_angle)) * size * 0.8
    local sweep_y = y + math_sin(math_rad(sweep_angle)) * size * 0.8
    
    surface.SetDrawColor(SC_GREEN.r, SC_GREEN.g, SC_GREEN.b, 100)
    surface.DrawLine(x, y, sweep_x, sweep_y)
    
    -- Player indicators
    for _, p in pairs(player.GetAll()) do
        if p ~= ply and p:Alive() then
            local dist = ply:GetPos():Distance(p:GetPos())
            if dist < 1000 then
                local relative_pos = p:GetPos() - ply:GetPos()
                local radar_x = x + (relative_pos.x / 1000) * size * 0.8
                local radar_y = y + (relative_pos.y / 1000) * size * 0.8
                
                if p:IsHidden() then
                    surface.SetDrawColor(SC_RED)
                else
                    surface.SetDrawColor(SC_ORANGE)
                end
                
                draw.Circle(radar_x, radar_y, 3, 8)
            end
        end
    end
    
    -- Center player dot
    surface.SetDrawColor(SC_WHITE)
    draw.Circle(x, y, 2, 8)
end

-- Main HUD drawing functions for each team
local DrawSCHud = {}

DrawSCHud[TEAM_HUMAN] = function(ply)
    local health = ply:Health()
    local max_health = ply:GetMaxHealth()
    local armor = ply:Armor()
    local stamina = ply:GetInt("Stamina", 0)
    local max_stamina = GAMEMODE.Hidden.Stamina
    
    -- Smooth lerping for animations
    health_lerp = Lerp(FrameTime() * 5, health_lerp, health / max_health)
    armor_lerp = Lerp(FrameTime() * 5, armor_lerp, armor / 100)
    stamina_lerp = Lerp(FrameTime() * 5, stamina_lerp, stamina / max_stamina)
    
    -- Bottom left status panel
    local panel_x, panel_y = 30, ScrH() - 150
    local panel_w, panel_h = 300, 120
    
    -- Panel background
    surface.SetDrawColor(SC_BLACK)
    surface.DrawRect(panel_x, panel_y, panel_w, panel_h)
    
    surface.SetDrawColor(SC_GREEN)
    surface.DrawOutlinedRect(panel_x - 1, panel_y - 1, panel_w + 2, panel_h + 2)
    
    -- Health bar
    local health_color = health < 30 and SC_RED or SC_GREEN
    DrawSCProgressBar(panel_x + 10, panel_y + 20, 200, 15, health_lerp, health_color, SC_BLACK, "HEALTH")
    
    -- Health text
    DrawSCText(string.format("%d / %d", health, max_health), "SC_HUD_Medium", panel_x + 220, panel_y + 18, SC_WHITE, SC_GREEN_GLOW)
    
    -- Armor bar (if player has armor)
    if armor > 0 then
        DrawSCProgressBar(panel_x + 10, panel_y + 50, 200, 15, armor_lerp, SC_ORANGE, SC_BLACK, "ARMOR")
        DrawSCText(string.format("%d", armor), "SC_HUD_Medium", panel_x + 220, panel_y + 48, SC_WHITE, SC_GREEN_GLOW)
    end
    
    -- Stamina bar
    DrawSCProgressBar(panel_x + 10, panel_y + 80, 200, 15, stamina_lerp, SC_GREEN_DARK, SC_BLACK, "STAMINA")
    DrawSCText(string.format("%d / %d", stamina, max_stamina), "SC_HUD_Medium", panel_x + 220, panel_y + 78, SC_WHITE, SC_GREEN_GLOW)
    
    -- Top right info panel
    local info_x, info_y = ScrW() - 250, 30
    local info_w, info_h = 220, 100
    
    surface.SetDrawColor(SC_BLACK)
    surface.DrawRect(info_x, info_y, info_w, info_h)
    
    surface.SetDrawColor(SC_GREEN)
    surface.DrawOutlinedRect(info_x - 1, info_y - 1, info_w + 2, info_h + 2)
    
    -- Round info
    local round_text = GetRoundTranslation()
    DrawSCText(round_text, "SC_HUD_Medium", info_x + 10, info_y + 10, SC_GREEN, SC_GREEN_GLOW)
    
    -- Time remaining
    local time_text = string.ToMinutesSeconds(GAMEMODE:GetRoundTime())
    DrawSCText("TIME: " .. time_text, "SC_HUD_Small", info_x + 10, info_y + 40, SC_WHITE, SC_GREEN_GLOW)
    
    -- Players alive
    local humans_alive = #team.GetPlayers(TEAM_HUMAN)
    local hidden_alive = #team.GetPlayers(TEAM_HIDDEN)
    DrawSCText(string.format("IRIS: %d  HIDDEN: %d", humans_alive, hidden_alive), "SC_HUD_Small", info_x + 10, info_y + 65, SC_WHITE, SC_GREEN_GLOW)
    
    -- Tactical radar
    DrawTacticalRadar(ScrW() - 80, ScrH() - 80, 50)
    
    -- Equipment indicators
    if ply:HasEquipment("NightVision") then
        DrawSCText("NVG", "SC_HUD_Small", 30, 30, SC_GREEN, SC_GREEN_GLOW)
        nvg_overlay_alpha = Lerp(FrameTime() * 3, nvg_overlay_alpha, 0.1)
    else
        nvg_overlay_alpha = Lerp(FrameTime() * 3, nvg_overlay_alpha, 0)
    end
    
    -- Night vision overlay
    if nvg_overlay_alpha > 0 then
        surface.SetDrawColor(SC_GREEN.r, SC_GREEN.g, SC_GREEN.b, nvg_overlay_alpha * 255)
        surface.DrawRect(0, 0, ScrW(), ScrH())
        DrawNightVisionStatic()
    end
end

DrawSCHud[TEAM_HIDDEN] = function(ply)
    local health = ply:Health()
    local max_health = ply:GetMaxHealth()
    local stamina = ply:GetInt("Stamina", 0)
    local max_stamina = GAMEMODE.Hidden.Stamina
    
    -- Smooth lerping
    health_lerp = Lerp(FrameTime() * 5, health_lerp, health / max_health)
    stamina_lerp = Lerp(FrameTime() * 5, stamina_lerp, stamina / max_stamina)
    
    -- Hidden HUD has a more sinister appearance
    local panel_x, panel_y = 30, ScrH() - 120
    local panel_w, panel_h = 350, 90
    
    -- Panel background with red tint
    surface.SetDrawColor(20, 0, 0, 200)
    surface.DrawRect(panel_x, panel_y, panel_w, panel_h)
    
    surface.SetDrawColor(SC_RED)
    surface.DrawOutlinedRect(panel_x - 1, panel_y - 1, panel_w + 2, panel_h + 2)
    
    -- Health bar (red theme for Hidden)
    DrawSCProgressBar(panel_x + 10, panel_y + 20, 250, 18, health_lerp, SC_RED, Color(50, 0, 0, 200), "VITALITY")
    DrawSCText(string.format("%d", health), "SC_HUD_Large", panel_x + 270, panel_y + 15, SC_WHITE, Color(255, 100, 100, 100))
    
    -- Stamina bar
    DrawSCProgressBar(panel_x + 10, panel_y + 55, 250, 18, stamina_lerp, SC_ORANGE, Color(50, 25, 0, 200), "ENERGY")
    DrawSCText(string.format("%d", stamina), "SC_HUD_Large", panel_x + 270, panel_y + 50, SC_WHITE, Color(255, 150, 0, 100))
    
    -- Prey counter (humans alive)
    local humans_alive = #team.GetPlayers(TEAM_HUMAN)
    DrawSCText("PREY: " .. humans_alive, "SC_HUD_Medium", ScrW() - 150, 30, SC_RED, Color(255, 100, 100, 100))
    
    -- Hunt mode indicator
    if ply:GetNWBool("HiddenVision", false) then
        DrawSCText("HUNT MODE", "SC_HUD_Medium", ScrW() / 2 - 60, 50, SC_RED, Color(255, 100, 100, 100))
        
        -- Draw vision overlay
        surface.SetDrawColor(255, 0, 0, 20)
        surface.DrawRect(0, 0, ScrW(), ScrH())
    end
    
    -- Ability cooldown indicators
    local pounce_ready = ply:GetNWBool("CanPounce", true)
    if not pounce_ready then
        DrawSCText("POUNCE RECHARGING", "SC_HUD_Small", 30, 30, SC_ORANGE, Color(255, 150, 0, 100))
    end
end

DrawSCHud[TEAM_SPECTATOR] = function(ply)
    local ob = ply:GetObserverTarget()
    
    if IsValid(ob) and ob:IsPlayer() then
        local t = ob:Team()
        DrawSCHud[t](ob)
        
        -- Spectator overlay
        DrawSCText("OBSERVING: " .. ob:Nick(), "SC_HUD_Medium", ScrW() / 2 - 100, 15, SC_WHITE, SC_GREEN_GLOW)
    else
        -- Waiting to spawn
        DrawSCText("MISSION BRIEFING", "SC_HUD_Large", ScrW() / 2 - 100, ScrH() / 2 - 50, SC_GREEN, SC_GREEN_GLOW)
        DrawSCText("Prepare for deployment...", "SC_HUD_Medium", ScrW() / 2 - 100, ScrH() / 2 - 10, SC_WHITE, SC_GREEN_GLOW)
    end
end

-- Override the original HUD paint function
function GM:HUDPaint()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    -- Draw crosshair
    DrawSCCrosshair()
    
    -- Draw team-specific HUD
    if DrawSCHud[ply:Team()] then
        DrawSCHud[ply:Team()](ply)
    end
end

-- Hide default HUD elements
function GM:HUDShouldDraw(name)
    local hide_elements = {
        "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", 
        "CHudVoiceStatus", "CHudCrosshair"
    }
    
    for _, element in pairs(hide_elements) do
        if name == element then return false end
    end
    
    if name == "CHudDamageIndicator" and not LocalPlayer():Alive() then
        return false
    end
    
    return true
end

-- Helper function for circle drawing
function draw.Circle(x, y, radius, segments, outline, thickness)
    segments = segments or 32
    thickness = thickness or 1
    
    local points = {}
    for i = 1, segments do
        local angle = (i / segments) * 2 * math.pi
        local px = x + math.cos(angle) * radius
        local py = y + math.sin(angle) * radius
        table.insert(points, {x = px, y = py})
    end
    
    if outline then
        for i = 1, #points do
            local next_i = (i % #points) + 1
            surface.DrawLine(points[i].x, points[i].y, points[next_i].x, points[next_i].y)
        end
    else
        surface.DrawPoly(points)
    end
end