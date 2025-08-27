-- ============================================================================
-- Splinter Cell Goggles SWEP - Server Initialization
-- ============================================================================
-- Server-side initialization and networking setup

if SERVER then
    -- Network strings for client/server communication
    util.AddNetworkString("SplinterCell_Goggles_State")
    util.AddNetworkString("SplinterCell_Goggles_Mode")
    util.AddNetworkString("SplinterCell_Sonar_Detection")
    util.AddNetworkString("SplinterCell_Settings_Update")
end

-- Include shared file
include("shared.lua")

-- Send client-side files to clients
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

-- Include client-side file on client
if CLIENT then
    include("cl_init.lua")
end
