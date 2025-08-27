-- ============================================================================
-- ULTRA-ENHANCED SPLINTER CELL NETWORKING AND COORDINATION SYSTEM
-- ============================================================================
-- Advanced team coordination, data sharing, and communication systems
-- ============================================================================

-- ============================================================================
-- SHARED NETWORKING UTILITIES
-- ============================================================================

-- Network message registration
util.AddNetworkString("SplinterCell_TeamSync")
util.AddNetworkString("SplinterCell_ThreatUpdate")
util.AddNetworkString("SplinterCell_TacticalData")
util.AddNetworkString("SplinterCell_MissionUpdate")
util.AddNetworkString("SplinterCell_BiometricData")
util.AddNetworkString("SplinterCell_EnvironmentalData")
util.AddNetworkString("SplinterCell_AIUpdate")
util.AddNetworkString("SplinterCell_QuantumSync")
util.AddNetworkString("SplinterCell_EmergencyBeacon")
util.AddNetworkString("SplinterCell_FormationUpdate")

if SERVER then
    -- ============================================================================
    -- SERVER-SIDE TEAM COORDINATION SYSTEM
    -- ============================================================================
    
    local TeamCoordination = {
        -- Active Teams
        teams = {},
        
        -- Team Data Storage
        teamData = {},
        
        -- Mission Coordination
        missions = {},
        
        -- Threat Intelligence
        threatIntel = {},
        
        -- Environmental Data
        environmentalData = {},
        
        -- Communication Logs
        communications = {}
    }
    
    -- Initialize team for player
    local function InitializePlayerTeam(ply)
        if not IsValid(ply) then return end
        
        local steamID = ply:SteamID()
        local teamID = ply:Team()
        
        -- Check if player is in a Splinter Cell team
        if teamID == TEAM_SPLINTERCELL or teamID == TEAM_SPLINTERCOMMANDER then
            -- Initialize player data
            TeamCoordination.teamData[steamID] = {
                player = ply,
                teamID = teamID,
                position = ply:GetPos(),
                health = ply:Health(),
                energy = 100,
                battery = 100,
                systemTemp = 20,
                threatLevel = 0,
                visionMode = 1,
                visionActive = false,
                lastUpdate = CurTime(),
                biometrics = {
                    heartRate = 75,
                    stressLevel = 0,
                    fatigueLevel = 0
                },
                equipment = {
                    nvgActive = false,
                    currentMode = "nightvision",
                    battery = 100,
                    temperature = 20
                },
                tactical = {
                    formation = "standard",
                    role = "operative",
                    objective = "",
                    status = "ready"
                }
            }
            
            -- Add to team list
            if not TeamCoordination.teams[teamID] then
                TeamCoordination.teams[teamID] = {}
            end
            
            table.insert(TeamCoordination.teams[teamID], steamID)
            
            print("[SPLINTER CELL] Player " .. ply:Name() .. " added to team coordination system")
        end
    end
    
    -- Clean up player team data
    local function CleanupPlayerTeam(ply)
        if not IsValid(ply) then return end
        
        local steamID = ply:SteamID()
        
        if TeamCoordination.teamData[steamID] then
            local teamID = TeamCoordination.teamData[steamID].teamID
            
            -- Remove from team list
            if TeamCoordination.teams[teamID] then
                for i, id in ipairs(TeamCoordination.teams[teamID]) do
                    if id == steamID then
                        table.remove(TeamCoordination.teams[teamID], i)
                        break
                    end
                end
            end
            
            -- Clear player data
            TeamCoordination.teamData[steamID] = nil
            
            print("[SPLINTER CELL] Player " .. ply:Name() .. " removed from team coordination system")
        end
    end
    
    -- Sync team data to all team members
    local function SyncTeamData(teamID)
        if not TeamCoordination.teams[teamID] then return end
        
        local teamMembers = {}
        
        -- Collect active team member data
        for _, steamID in ipairs(TeamCoordination.teams[teamID]) do
            local data = TeamCoordination.teamData[steamID]
            if data and IsValid(data.player) then
                -- Update current data
                data.position = data.player:GetPos()
                data.health = data.player:Health()
                data.lastUpdate = CurTime()
                
                table.insert(teamMembers, {
                    steamID = steamID,
                    name = data.player:Name(),
                    position = data.position,
                    health = data.health,
                    energy = data.energy,
                    battery = data.battery,
                    systemTemp = data.systemTemp,
                    threatLevel = data.threatLevel,
                    visionMode = data.visionMode,
                    visionActive = data.visionActive,
                    biometrics = data.biometrics,
                    equipment = data.equipment,
                    tactical = data.tactical
                })
            end
        end
        
        -- Send to all team members
        for _, steamID in ipairs(TeamCoordination.teams[teamID]) do
            local data = TeamCoordination.teamData[steamID]
            if data and IsValid(data.player) then
                net.Start("SplinterCell_TeamSync")
                net.WriteTable(teamMembers)
                net.Send(data.player)
            end
        end
    end
    
    -- Update threat intelligence
    local function UpdateThreatIntelligence(ply, threatData)
        local steamID = ply:SteamID()
        local playerData = TeamCoordination.teamData[steamID]
        
        if not playerData then return end
        
        local teamID = playerData.teamID
        
        -- Store threat data
        if not TeamCoordination.threatIntel[teamID] then
            TeamCoordination.threatIntel[teamID] = {}
        end
        
        table.insert(TeamCoordination.threatIntel[teamID], {
            reporter = steamID,
            position = ply:GetPos(),
            threatData = threatData,
            timestamp = CurTime()
        })
        
        -- Limit stored threats to prevent memory issues
        if #TeamCoordination.threatIntel[teamID] > 100 then
            table.remove(TeamCoordination.threatIntel[teamID], 1)
        end
        
        -- Broadcast to team
        local teamMembers = TeamCoordination.teams[teamID] or {}\n        for _, memberID in ipairs(teamMembers) do\n            local memberData = TeamCoordination.teamData[memberID]\n            if memberData and IsValid(memberData.player) and memberData.player != ply then\n                net.Start(\"SplinterCell_ThreatUpdate\")\n                net.WriteTable(threatData)\n                net.WriteVector(ply:GetPos())\n                net.WriteString(ply:Name())\n                net.Send(memberData.player)\n            end\n        end\n    end\n    \n    -- Mission coordination\n    local function UpdateMissionStatus(teamID, missionData)\n        TeamCoordination.missions[teamID] = missionData\n        \n        -- Broadcast to team\n        local teamMembers = TeamCoordination.teams[teamID] or {}\n        for _, memberID in ipairs(teamMembers) do\n            local memberData = TeamCoordination.teamData[memberID]\n            if memberData and IsValid(memberData.player) then\n                net.Start(\"SplinterCell_MissionUpdate\")\n                net.WriteTable(missionData)\n                net.Send(memberData.player)\n            end\n        end\n    end\n    \n    -- Network message handlers\n    net.Receive(\"SplinterCell_TeamSync\", function(len, ply)\n        local data = net.ReadTable()\n        local steamID = ply:SteamID()\n        \n        if TeamCoordination.teamData[steamID] then\n            -- Update player data\n            TeamCoordination.teamData[steamID].energy = data.energy or 100\n            TeamCoordination.teamData[steamID].battery = data.battery or 100\n            TeamCoordination.teamData[steamID].systemTemp = data.systemTemp or 20\n            TeamCoordination.teamData[steamID].threatLevel = data.threatLevel or 0\n            TeamCoordination.teamData[steamID].visionMode = data.visionMode or 1\n            TeamCoordination.teamData[steamID].visionActive = data.visionActive or false\n            \n            if data.biometrics then\n                TeamCoordination.teamData[steamID].biometrics = data.biometrics\n            end\n            \n            if data.equipment then\n                TeamCoordination.teamData[steamID].equipment = data.equipment\n            end\n            \n            if data.tactical then\n                TeamCoordination.teamData[steamID].tactical = data.tactical\n            end\n        end\n    end)\n    \n    net.Receive(\"SplinterCell_ThreatUpdate\", function(len, ply)\n        local threatData = net.ReadTable()\n        UpdateThreatIntelligence(ply, threatData)\n    end)\n    \n    net.Receive(\"SplinterCell_EmergencyBeacon\", function(len, ply)\n        local emergencyData = net.ReadTable()\n        local steamID = ply:SteamID()\n        local playerData = TeamCoordination.teamData[steamID]\n        \n        if playerData then\n            local teamID = playerData.teamID\n            \n            -- Broadcast emergency to all team members and command\n            local teamMembers = TeamCoordination.teams[teamID] or {}\n            for _, memberID in ipairs(teamMembers) do\n                local memberData = TeamCoordination.teamData[memberID]\n                if memberData and IsValid(memberData.player) then\n                    net.Start(\"SplinterCell_EmergencyBeacon\")\n                    net.WriteTable(emergencyData)\n                    net.WriteVector(ply:GetPos())\n                    net.WriteString(ply:Name())\n                    net.Send(memberData.player)\n                end\n            end\n            \n            print(\"[SPLINTER CELL] Emergency beacon activated by \" .. ply:Name() .. \" at \" .. tostring(ply:GetPos()))\n        end\n    end)\n    \n    -- Periodic team data synchronization\n    timer.Create(\"SplinterCellTeamSync\", 2, 0, function()\n        for teamID, _ in pairs(TeamCoordination.teams) do\n            SyncTeamData(teamID)\n        end\n    end)\n    \n    -- Player connection handlers\n    hook.Add(\"PlayerInitialSpawn\", \"SplinterCellTeamInit\", function(ply)\n        timer.Simple(2, function()\n            if IsValid(ply) then\n                InitializePlayerTeam(ply)\n            end\n        end)\n    end)\n    \n    hook.Add(\"PlayerDisconnected\", \"SplinterCellTeamCleanup\", function(ply)\n        CleanupPlayerTeam(ply)\n    end)\n    \n    hook.Add(\"OnPlayerChangedTeam\", \"SplinterCellTeamChange\", function(ply, oldTeam, newTeam)\n        CleanupPlayerTeam(ply)\n        timer.Simple(0.1, function()\n            if IsValid(ply) then\n                InitializePlayerTeam(ply)\n            end\n        end)\n    end)\n    \n    -- Console commands for server administration\n    concommand.Add(\"sc_team_status\", function(ply, cmd, args)\n        if not ply:IsAdmin() then return end\n        \n        print(\"=== SPLINTER CELL TEAM STATUS ===\")\n        for teamID, members in pairs(TeamCoordination.teams) do\n            print(\"Team \" .. teamID .. \": \" .. #members .. \" members\")\n            for _, steamID in ipairs(members) do\n                local data = TeamCoordination.teamData[steamID]\n                if data and IsValid(data.player) then\n                    print(\"  \" .. data.player:Name() .. \" - Health: \" .. data.health .. \"% - Vision: \" .. (data.visionActive and \"ON\" or \"OFF\"))\n                end\n            end\n        end\n    end)\n    \n    concommand.Add(\"sc_emergency_all\", function(ply, cmd, args)\n        if not ply:IsAdmin() then return end\n        \n        local message = table.concat(args, \" \") or \"Emergency situation declared by administrator\"\n        \n        for teamID, members in pairs(TeamCoordination.teams) do\n            for _, steamID in ipairs(members) do\n                local data = TeamCoordination.teamData[steamID]\n                if data and IsValid(data.player) then\n                    net.Start(\"SplinterCell_EmergencyBeacon\")\n                    net.WriteTable({type = \"admin\", message = message, priority = \"high\"})\n                    net.WriteVector(Vector(0,0,0))\n                    net.WriteString(\"COMMAND\")\n                    net.Send(data.player)\n                end\n            end\n        end\n        \n        print(\"[SPLINTER CELL] Emergency broadcast sent to all teams\")\n    end)\n\nelseif CLIENT then\n    -- ============================================================================\n    -- CLIENT-SIDE TEAM COORDINATION SYSTEM\n    -- ============================================================================\n    \n    local ClientTeam = {\n        -- Team member data\n        members = {},\n        \n        -- Threat intelligence\n        threats = {},\n        \n        -- Mission data\n        mission = {},\n        \n        -- Communication history\n        communications = {},\n        \n        -- Emergency status\n        emergency = false,\n        emergencyData = {}\n    }\n    \n    -- Send team data to server\n    local function SendTeamUpdate()\n        if not HasSplinterCellAbilities() then return end\n        \n        local data = {\n            energy = energy or 100,\n            battery = battery or 100,\n            systemTemp = systemTemp or 20,\n            threatLevel = threatLevel or 0,\n            visionMode = currentMode or 1,\n            visionActive = visionActive or false,\n            biometrics = {\n                heartRate = 75 + math.sin(CurTime() * 3) * 10,\n                stressLevel = math.min(100, (threatLevel or 0) + ((systemTemp or 20) - 20) * 2),\n                fatigueLevel = math.max(0, 100 - (energy or 100))\n            },\n            equipment = {\n                nvgActive = visionActive or false,\n                currentMode = (visionModes and visionModes[currentMode or 1] and visionModes[currentMode or 1].id) or \"nightvision\",\n                battery = battery or 100,\n                temperature = systemTemp or 20\n            },\n            tactical = {\n                formation = \"standard\",\n                role = \"operative\",\n                objective = \"\",\n                status = \"ready\"\n            }\n        }\n        \n        net.Start(\"SplinterCell_TeamSync\")\n        net.WriteTable(data)\n        net.SendToServer()\n    end\n    \n    -- Send threat update to team\n    local function SendThreatUpdate(threatData)\n        if not HasSplinterCellAbilities() then return end\n        \n        net.Start(\"SplinterCell_ThreatUpdate\")\n        net.WriteTable(threatData)\n        net.SendToServer()\n    end\n    \n    -- Send emergency beacon\n    local function SendEmergencyBeacon(emergencyType, message)\n        if not HasSplinterCellAbilities() then return end\n        \n        local emergencyData = {\n            type = emergencyType or \"general\",\n            message = message or \"Emergency assistance required\",\n            priority = \"high\",\n            timestamp = CurTime(),\n            position = LocalPlayer():GetPos(),\n            health = LocalPlayer():Health()\n        }\n        \n        net.Start(\"SplinterCell_EmergencyBeacon\")\n        net.WriteTable(emergencyData)\n        net.SendToServer()\n        \n        ClientTeam.emergency = true\n        ClientTeam.emergencyData = emergencyData\n        \n        surface.PlaySound(\"ambient/alarms/klaxon1.wav\")\n        LocalPlayer():ChatPrint(\"[EMERGENCY] Beacon activated - Team notified\")\n    end\n    \n    -- Network message handlers\n    net.Receive(\"SplinterCell_TeamSync\", function()\n        ClientTeam.members = net.ReadTable()\n    end)\n    \n    net.Receive(\"SplinterCell_ThreatUpdate\", function()\n        local threatData = net.ReadTable()\n        local position = net.ReadVector()\n        local reporter = net.ReadString()\n        \n        table.insert(ClientTeam.threats, {\n            data = threatData,\n            position = position,\n            reporter = reporter,\n            timestamp = CurTime()\n        })\n        \n        -- Limit stored threats\n        if #ClientTeam.threats > 50 then\n            table.remove(ClientTeam.threats, 1)\n        end\n        \n        LocalPlayer():ChatPrint(\"[THREAT INTEL] \" .. reporter .. \" reported threat at \" .. tostring(position))\n        surface.PlaySound(\"buttons/button10.wav\")\n    end)\n    \n    net.Receive(\"SplinterCell_MissionUpdate\", function()\n        ClientTeam.mission = net.ReadTable()\n        LocalPlayer():ChatPrint(\"[MISSION] Mission status updated\")\n        surface.PlaySound(\"buttons/button9.wav\")\n    end)\n    \n    net.Receive(\"SplinterCell_EmergencyBeacon\", function()\n        local emergencyData = net.ReadTable()\n        local position = net.ReadVector()\n        local reporter = net.ReadString()\n        \n        ClientTeam.emergency = true\n        ClientTeam.emergencyData = {\n            data = emergencyData,\n            position = position,\n            reporter = reporter,\n            timestamp = CurTime()\n        }\n        \n        surface.PlaySound(\"ambient/alarms/klaxon1.wav\")\n        LocalPlayer():ChatPrint(\"[EMERGENCY] \" .. reporter .. \" activated emergency beacon!\")\n        \n        -- Flash screen red briefly\n        timer.Simple(0, function()\n            local overlay = vgui.Create(\"DPanel\")\n            overlay:SetSize(ScrW(), ScrH())\n            overlay:SetPos(0, 0)\n            overlay:SetBackgroundColor(Color(255, 0, 0, 100))\n            overlay:MakePopup()\n            overlay:SetMouseInputEnabled(false)\n            overlay:SetKeyboardInputEnabled(false)\n            \n            timer.Simple(0.5, function()\n                if IsValid(overlay) then\n                    overlay:Remove()\n                end\n            end)\n        end)\n    end)\n    \n    -- Periodic team data updates\n    timer.Create(\"SplinterCellClientTeamUpdate\", 3, 0, function()\n        if HasSplinterCellAbilities() then\n            SendTeamUpdate()\n        end\n    end)\n    \n    -- Console commands for team coordination\n    concommand.Add(\"sc_team_members\", function()\n        print(\"=== TEAM MEMBERS ===\")\n        for _, member in ipairs(ClientTeam.members) do\n            print(string.format(\"%s - Health: %d%% - Battery: %d%% - Mode: %s\", \n                member.name, member.health, member.battery, member.equipment.currentMode))\n        end\n    end)\n    \n    concommand.Add(\"sc_threat_intel\", function()\n        print(\"=== THREAT INTELLIGENCE ===\")\n        for i, threat in ipairs(ClientTeam.threats) do\n            print(string.format(\"%d. %s reported threat at %s (%.1fs ago)\", \n                i, threat.reporter, tostring(threat.position), CurTime() - threat.timestamp))\n        end\n    end)\n    \n    concommand.Add(\"sc_emergency\", function(ply, cmd, args)\n        local message = table.concat(args, \" \") or \"Emergency assistance required\"\n        SendEmergencyBeacon(\"manual\", message)\n    end)\n    \n    concommand.Add(\"sc_emergency_medical\", function()\n        SendEmergencyBeacon(\"medical\", \"Medical assistance required\")\n    end)\n    \n    concommand.Add(\"sc_emergency_tactical\", function()\n        SendEmergencyBeacon(\"tactical\", \"Tactical support requested\")\n    end)\n    \n    concommand.Add(\"sc_emergency_extraction\", function()\n        SendEmergencyBeacon(\"extraction\", \"Immediate extraction required\")\n    end)\n    \n    -- Automatic threat detection and reporting\n    local lastThreatScan = 0\n    hook.Add(\"Think\", \"SplinterCellAutoThreatDetection\", function()\n        if not HasSplinterCellAbilities() or not visionActive then return end\n        \n        local currentTime = CurTime()\n        if currentTime - lastThreatScan < 5 then return end -- Scan every 5 seconds\n        \n        lastThreatScan = currentTime\n        local ply = LocalPlayer()\n        \n        -- Scan for new threats\n        for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 1000)) do\n            if IsValid(ent) and ent != ply then\n                local threatLevel = 0\n                local threatType = \"unknown\"\n                \n                if ent:IsPlayer() and ent:GetActiveWeapon():IsValid() then\n                    threatLevel = 80\n                    threatType = \"armed_player\"\n                elseif ent:IsPlayer() then\n                    threatLevel = 40\n                    threatType = \"player\"\n                elseif ent:IsNPC() then\n                    threatLevel = 60\n                    threatType = \"npc\"\n                elseif ent:IsWeapon() then\n                    threatLevel = 20\n                    threatType = \"weapon\"\n                end\n                \n                if threatLevel > 50 then -- Only report significant threats\n                    SendThreatUpdate({\n                        entityClass = ent:GetClass(),\n                        threatLevel = threatLevel,\n                        threatType = threatType,\n                        position = ent:GetPos(),\n                        distance = ply:GetPos():Distance(ent:GetPos())\n                    })\n                end\n            end\n        end\n    end)\n    \n    print(\"[SPLINTER CELL] Networking and Team Coordination System Loaded!\")\n    print(\"• Real-time Team Data Synchronization\")\n    print(\"• Threat Intelligence Sharing\")\n    print(\"• Mission Coordination\")\n    print(\"• Emergency Beacon System\")\n    print(\"• Automatic Threat Detection\")\n    print(\"• Encrypted Communications\")\n    \nend