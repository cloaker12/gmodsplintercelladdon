-- Modern Splinter Cell Themed Loadout Menu
-- Enhanced UI with smooth animations and modern design

local PANEL = {}

-- Color scheme
local SC_GREEN = Color(0, 255, 100, 255)
local SC_GREEN_DARK = Color(0, 180, 70, 255)
local SC_GREEN_GLOW = Color(0, 255, 100, 100)
local SC_ORANGE = Color(255, 150, 0, 255)
local SC_RED = Color(255, 50, 50, 255)
local SC_WHITE = Color(255, 255, 255, 255)
local SC_BLACK = Color(0, 0, 0, 220)
local SC_GRAY = Color(100, 100, 100, 255)
local SC_DARK_GRAY = Color(40, 40, 40, 255)

-- Animation variables
local menu_alpha = 0
local selected_weapon_alpha = {}
local hover_animations = {}

-- Create modern fonts
surface.CreateFont("SC_Loadout_Title", {
    font = "Orbitron",
    size = 36,
    weight = 700,
    antialias = true,
})

surface.CreateFont("SC_Loadout_Header", {
    font = "Orbitron",
    size = 24,
    weight = 600,
    antialias = true,
})

surface.CreateFont("SC_Loadout_Text", {
    font = "Orbitron",
    size = 18,
    weight = 500,
    antialias = true,
})

surface.CreateFont("SC_Loadout_Small", {
    font = "Orbitron",
    size = 14,
    weight = 400,
    antialias = true,
})

-- Smooth text drawing with glow
local function DrawGlowText(text, font, x, y, color, glow_color, align_x, align_y)
    align_x = align_x or TEXT_ALIGN_LEFT
    align_y = align_y or TEXT_ALIGN_TOP
    
    -- Glow effect
    for i = 1, 2 do
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

-- Draw modern progress bar with animations
local function DrawStatBar(x, y, w, h, value, max_value, color, label, show_numbers)
    local progress = math.Clamp(value / max_value, 0, 1)
    
    -- Background
    surface.SetDrawColor(SC_DARK_GRAY)
    surface.DrawRect(x, y, w, h)
    
    -- Border
    surface.SetDrawColor(SC_GREEN)
    surface.DrawOutlinedRect(x - 1, y - 1, w + 2, h + 2)
    
    -- Fill with gradient effect
    local fill_w = w * progress
    for i = 0, fill_w do
        local alpha = 255 - (i / fill_w) * 100
        surface.SetDrawColor(color.r, color.g, color.b, alpha)
        surface.DrawRect(x + i, y, 1, h)
    end
    
    -- Animated glow effect
    local glow_pos = (math.sin(CurTime() * 2) * 0.5 + 0.5) * fill_w
    surface.SetDrawColor(SC_WHITE.r, SC_WHITE.g, SC_WHITE.b, 150)
    surface.DrawRect(x + glow_pos - 2, y, 4, h)
    
    -- Label and value
    if label then
        DrawGlowText(label, "SC_Loadout_Small", x, y - 18, SC_WHITE, SC_GREEN_GLOW)
    end
    
    if show_numbers then
        local value_text = string.format("%.1f", value)
        surface.SetFont("SC_Loadout_Small")
        local text_w = surface.GetTextSize(value_text)
        DrawGlowText(value_text, "SC_Loadout_Small", x + w - text_w, y + h + 2, SC_WHITE, SC_GREEN_GLOW)
    end
end

-- Enhanced weapon card with hover effects
local function CreateWeaponCard(parent, weapon_data, index)
    local card = vgui.Create("DPanel", parent)
    card:SetSize(280, 120)
    card.WeaponData = weapon_data
    card.Index = index
    card.HoverAlpha = 0
    card.SelectedAlpha = 0
    
    -- Initialize animation values
    if not hover_animations[index] then
        hover_animations[index] = 0
    end
    if not selected_weapon_alpha[index] then
        selected_weapon_alpha[index] = 0
    end
    
    card.Paint = function(self, w, h)
        -- Animate hover effect
        if self:IsHovered() then
            hover_animations[index] = Lerp(FrameTime() * 8, hover_animations[index], 1)
        else
            hover_animations[index] = Lerp(FrameTime() * 8, hover_animations[index], 0)
        end
        
        -- Background with hover glow
        local bg_color = ColorAlpha(SC_BLACK, 180 + hover_animations[index] * 50)
        surface.SetDrawColor(bg_color)
        surface.DrawRect(0, 0, w, h)
        
        -- Border with glow effect
        local border_color = ColorAlpha(SC_GREEN, 150 + hover_animations[index] * 105)
        surface.SetDrawColor(border_color)
        surface.DrawOutlinedRect(0, 0, w, h)
        
        -- Selection highlight
        if parent.SelectedWeapon == index then
            selected_weapon_alpha[index] = Lerp(FrameTime() * 5, selected_weapon_alpha[index], 1)
            local sel_color = ColorAlpha(SC_ORANGE, selected_weapon_alpha[index] * 100)
            surface.SetDrawColor(sel_color)
            surface.DrawRect(2, 2, w - 4, h - 4)
        else
            selected_weapon_alpha[index] = Lerp(FrameTime() * 5, selected_weapon_alpha[index], 0)
        end
        
        -- Weapon name
        DrawGlowText(weapon_data.PrintName or "Unknown", "SC_Loadout_Text", 10, 10, SC_WHITE, SC_GREEN_GLOW)
        
        -- Weapon type badge
        local type_text = weapon_data.Type or "weapon"
        surface.SetDrawColor(SC_GREEN_DARK)
        surface.DrawRect(w - 80, 5, 75, 20)
        DrawGlowText(string.upper(type_text), "SC_Loadout_Small", w - 75, 8, SC_WHITE, SC_GREEN_GLOW)
        
        -- Quick stats preview
        local stats_y = 35
        if weapon_data.Primary then
            DrawGlowText("DMG: " .. (weapon_data.Primary.Damage or 0), "SC_Loadout_Small", 10, stats_y, SC_WHITE, SC_GREEN_GLOW)
            DrawGlowText("ACC: " .. string.format("%.3f", weapon_data.Primary.Cone or 0), "SC_Loadout_Small", 10, stats_y + 15, SC_WHITE, SC_GREEN_GLOW)
            DrawGlowText("MAG: " .. (weapon_data.Primary.ClipSize or 0), "SC_Loadout_Small", 10, stats_y + 30, SC_WHITE, SC_GREEN_GLOW)
        end
    end
    
    card.DoClick = function(self)
        parent.SelectedWeapon = index
        parent:UpdateWeaponStats(weapon_data)
        
        -- Send selection to server
        net.Start("SelectWeapon")
        net.WriteString(weapon_data.ClassName)
        net.SendToServer()
        
        surface.PlaySound("buttons/weapon_confirm.wav")
    end
    
    card.OnCursorEntered = function(self)
        surface.PlaySound("buttons/lightswitch2.wav")
    end
    
    return card
end

function PANEL:Init()
    menu_alpha = 0
    
    -- Get screen dimensions
    local w, h = ScrW() * 0.8, ScrH() * 0.8
    
    self:SetTitle("")
    self:SetSize(w, h)
    self:SetVisible(true)
    self:SetBackgroundBlur(true)
    self:Center()
    self:MakePopup()
    self:ShowCloseButton(false)
    
    self.SelectedWeapon = 0
    
    -- Animate menu appearance
    self.Alpha = 0
    self:AlphaTo(255, 0.3, 0)
    
    -- Header panel
    self.Header = vgui.Create("DPanel", self)
    self.Header:SetPos(0, 0)
    self.Header:SetSize(w, 60)
    self.Header.Paint = function(panel, pw, ph)
        surface.SetDrawColor(SC_BLACK)
        surface.DrawRect(0, 0, pw, ph)
        
        surface.SetDrawColor(SC_GREEN)
        surface.DrawRect(0, ph - 2, pw, 2)
        
        DrawGlowText("IRIS TACTICAL LOADOUT", "SC_Loadout_Title", 20, 15, SC_GREEN, SC_GREEN_GLOW)
        DrawGlowText("SELECT YOUR EQUIPMENT", "SC_Loadout_Small", 20, 45, SC_WHITE, SC_GREEN_GLOW)
    end
    
    -- Close button
    self.CloseBtn = vgui.Create("DButton", self.Header)
    self.CloseBtn:SetSize(100, 40)
    self.CloseBtn:SetPos(w - 120, 10)
    self.CloseBtn:SetText("")
    self.CloseBtn.Paint = function(btn, bw, bh)
        local hover_alpha = btn:IsHovered() and 255 or 150
        surface.SetDrawColor(SC_RED.r, SC_RED.g, SC_RED.b, hover_alpha)
        surface.DrawRect(0, 0, bw, bh)
        
        surface.SetDrawColor(SC_WHITE)
        surface.DrawOutlinedRect(0, 0, bw, bh)
        
        DrawGlowText("CLOSE", "SC_Loadout_Text", bw/2 - 25, bh/2 - 10, SC_WHITE, Color(255, 100, 100, 100))
    end
    self.CloseBtn.DoClick = function()
        self:SetVisible(false)
        surface.PlaySound("buttons/button19.wav")
    end
    
    -- Main content area
    local content_y = 70
    local content_h = h - content_y - 20
    
    -- Weapons panel
    self.WeaponsPanel = vgui.Create("DPanel", self)
    self.WeaponsPanel:SetPos(20, content_y)
    self.WeaponsPanel:SetSize(w * 0.6, content_h)
    self.WeaponsPanel.Paint = function(panel, pw, ph)
        surface.SetDrawColor(SC_DARK_GRAY)
        surface.DrawRect(0, 0, pw, ph)
        
        surface.SetDrawColor(SC_GREEN)
        surface.DrawOutlinedRect(0, 0, pw, ph)
        
        DrawGlowText("AVAILABLE WEAPONS", "SC_Loadout_Header", 10, 10, SC_GREEN, SC_GREEN_GLOW)
    end
    
    -- Weapon scroll panel
    self.WeaponScroll = vgui.Create("DScrollPanel", self.WeaponsPanel)
    self.WeaponScroll:SetPos(10, 40)
    self.WeaponScroll:SetSize(self.WeaponsPanel:GetWide() - 20, self.WeaponsPanel:GetTall() - 50)
    
    -- Customize scrollbar
    local sbar = self.WeaponScroll:GetVBar()
    sbar.Paint = function() end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    sbar.btnGrip.Paint = function(panel, w, h)
        surface.SetDrawColor(SC_GREEN)
        surface.DrawRect(0, 0, w, h)
    end
    
    -- Stats panel
    self.StatsPanel = vgui.Create("DPanel", self)
    self.StatsPanel:SetPos(w * 0.6 + 40, content_y)
    self.StatsPanel:SetSize(w * 0.35, content_h)
    self.StatsPanel.Paint = function(panel, pw, ph)
        surface.SetDrawColor(SC_DARK_GRAY)
        surface.DrawRect(0, 0, pw, ph)
        
        surface.SetDrawColor(SC_GREEN)
        surface.DrawOutlinedRect(0, 0, pw, ph)
        
        DrawGlowText("WEAPON ANALYSIS", "SC_Loadout_Header", 10, 10, SC_GREEN, SC_GREEN_GLOW)
    end
    
    -- Equipment panel
    self.EquipmentPanel = vgui.Create("DPanel", self.StatsPanel)
    self.EquipmentPanel:SetPos(10, 300)
    self.EquipmentPanel:SetSize(self.StatsPanel:GetWide() - 20, 200)
    self.EquipmentPanel.Paint = function(panel, pw, ph)
        surface.SetDrawColor(Color(20, 20, 20, 200))
        surface.DrawRect(0, 0, pw, ph)
        
        surface.SetDrawColor(SC_ORANGE)
        surface.DrawOutlinedRect(0, 0, pw, ph)
        
        DrawGlowText("EQUIPMENT", "SC_Loadout_Text", 10, 10, SC_ORANGE, Color(255, 150, 0, 100))
    end
    
    -- Load weapons
    self:LoadWeapons()
    
    -- Initialize with first weapon selected
    if #self.WeaponCards > 0 then
        self.SelectedWeapon = 1
        self:UpdateWeaponStats(self.WeaponCards[1].WeaponData)
    end
end

function PANEL:LoadWeapons()
    self.WeaponCards = {}
    
    -- Get valid weapons
    local weapons = {}
    for _, wep in pairs(weapons.GetList()) do
        if wep.InLoadoutMenu then
            table.insert(weapons, wep)
        end
    end
    
    -- Create weapon cards
    for i, weapon in ipairs(weapons) do
        local card = CreateWeaponCard(self, weapon, i)
        card:SetParent(self.WeaponScroll)
        card:Dock(TOP)
        card:DockMargin(5, 5, 5, 5)
        
        table.insert(self.WeaponCards, card)
    end
end

function PANEL:UpdateWeaponStats(weapon_data)
    self.CurrentWeapon = weapon_data
    
    -- Clear previous stats display
    if IsValid(self.StatsDisplay) then
        self.StatsDisplay:Remove()
    end
    
    -- Create new stats display
    self.StatsDisplay = vgui.Create("DPanel", self.StatsPanel)
    self.StatsDisplay:SetPos(10, 50)
    self.StatsDisplay:SetSize(self.StatsPanel:GetWide() - 20, 240)
    self.StatsDisplay.Paint = function(panel, pw, ph)
        if not weapon_data then return end
        
        local y_offset = 10
        
        -- Weapon name
        DrawGlowText(weapon_data.PrintName or "Unknown Weapon", "SC_Loadout_Text", 10, y_offset, SC_WHITE, SC_GREEN_GLOW)
        y_offset = y_offset + 30
        
        -- Primary stats
        if weapon_data.Primary then
            local primary = weapon_data.Primary
            
            -- Damage
            DrawStatBar(10, y_offset, pw - 20, 20, primary.Damage or 0, 100, SC_RED, "DAMAGE", true)
            y_offset = y_offset + 45
            
            -- Accuracy (inverse of cone)
            local accuracy = primary.Cone and (1 / math.max(primary.Cone, 0.001)) * 10 or 50
            DrawStatBar(10, y_offset, pw - 20, 20, accuracy, 100, SC_GREEN, "ACCURACY", true)
            y_offset = y_offset + 45
            
            -- Fire rate (inverse of delay)
            local fire_rate = primary.Delay and (1 / math.max(primary.Delay, 0.1)) * 20 or 50
            DrawStatBar(10, y_offset, pw - 20, 20, fire_rate, 100, SC_ORANGE, "FIRE RATE", true)
            y_offset = y_offset + 45
            
            -- Magazine size
            DrawStatBar(10, y_offset, pw - 20, 20, primary.ClipSize or 0, 50, SC_GREEN_DARK, "MAGAZINE", true)
            y_offset = y_offset + 45
        end
    end
    
    -- Load equipment options
    self:LoadEquipment()
end

function PANEL:LoadEquipment()
    -- Clear previous equipment
    if IsValid(self.EquipmentScroll) then
        self.EquipmentScroll:Remove()
    end
    
    self.EquipmentScroll = vgui.Create("DScrollPanel", self.EquipmentPanel)
    self.EquipmentScroll:SetPos(5, 30)
    self.EquipmentScroll:SetSize(self.EquipmentPanel:GetWide() - 10, self.EquipmentPanel:GetTall() - 35)
    
    -- Equipment options from LDT.Equipment
    if LDT and LDT.Equipment then
        for name, data in pairs(LDT.Equipment) do
            local equip_btn = vgui.Create("DButton", self.EquipmentScroll)
            equip_btn:SetSize(self.EquipmentScroll:GetWide() - 10, 30)
            equip_btn:Dock(TOP)
            equip_btn:DockMargin(2, 2, 2, 2)
            equip_btn:SetText("")
            
            equip_btn.Paint = function(btn, bw, bh)
                local hover_alpha = btn:IsHovered() and 200 or 100
                surface.SetDrawColor(SC_DARK_GRAY.r, SC_DARK_GRAY.g, SC_DARK_GRAY.b, hover_alpha)
                surface.DrawRect(0, 0, bw, bh)
                
                surface.SetDrawColor(SC_ORANGE)
                surface.DrawOutlinedRect(0, 0, bw, bh)
                
                DrawGlowText(name, "SC_Loadout_Small", 5, bh/2 - 7, SC_WHITE, Color(255, 150, 0, 100))
            end
            
            equip_btn.DoClick = function()
                -- Handle equipment selection
                surface.PlaySound("buttons/weapon_confirm.wav")
            end
        end
    end
end

function PANEL:Paint(w, h)
    -- Animated background
    menu_alpha = Lerp(FrameTime() * 3, menu_alpha, 255)
    
    -- Dark overlay
    surface.SetDrawColor(0, 0, 0, menu_alpha * 0.8)
    surface.DrawRect(0, 0, w, h)
    
    -- Animated grid pattern
    surface.SetDrawColor(SC_GREEN.r, SC_GREEN.g, SC_GREEN.b, menu_alpha * 0.1)
    local grid_size = 50
    for x = 0, w, grid_size do
        surface.DrawLine(x, 0, x, h)
    end
    for y = 0, h, grid_size do
        surface.DrawLine(0, y, w, y)
    end
    
    -- Animated scanner lines
    local scanner_y = (CurTime() * 100) % h
    surface.SetDrawColor(SC_GREEN.r, SC_GREEN.g, SC_GREEN.b, menu_alpha * 0.3)
    surface.DrawRect(0, scanner_y, w, 2)
    surface.DrawRect(0, scanner_y + h/2, w, 2)
end

vgui.Register("ModernLoadoutMenu", PANEL, "DFrame")

-- Override the original loadout menu
function OpenLoadoutMenu()
    if IsValid(LoadoutMenu) then
        LoadoutMenu:Remove()
    end
    
    LoadoutMenu = vgui.Create("ModernLoadoutMenu")
end