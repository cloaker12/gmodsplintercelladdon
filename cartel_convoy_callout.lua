-- Cartel Convoy Interdiction - Tactical Callout
-- Black Operation: Suppress convoy, infiltrate compound, extract intel

local CartelConvoyCallout = {}

-- Mission Configuration
local MISSION_CONFIG = {
    name = "Operation Shadow Strike",
    description = "Intercept cartel weapons convoy before it reaches their stronghold",
    phases = {"INTERCEPT", "COMPOUND", "EXTRACTION"},
    currentPhase = 1,
    missionActive = false,
    stealthBroken = false,
    convoyEscaped = false,
    leaderCaptured = false,
    nightVisionEnabled = false
}

-- Vehicle and Ped Models
local MODELS = {
    vehicles = {
        leadSUV = "baller2",
        cargoTruck = "mule3", 
        rearSUV = "dubsta2",
        reinforcementSUV = "kuruma",
        annihilator = "annihilator2"
    },
    peds = {
        cartelMember = "g_m_y_mexgang_01",
        cartelLeader = "g_m_m_mexboss_01",
        ghostOperative = "s_m_y_blackops_01"
    }
}

-- Weapon Loadouts
local WEAPONS = {
    cartel = {
        "WEAPON_ASSAULTRIFLE",
        "WEAPON_PUMPSHOTGUN", 
        "WEAPON_MICROSMG",
        "WEAPON_MG",
        "WEAPON_SNIPERRIFLE",
        "WEAPON_RPG"
    },
    ghostSuppressed = {
        "WEAPON_SMG_MK2",
        "WEAPON_CARBINERIFLE_MK2", 
        "WEAPON_COMBATPISTOL",
        "WEAPON_PISTOL50",
        "WEAPON_SNIPERRIFLE"
    }
}

-- Mission State Variables
local convoy = {
    vehicles = {},
    peds = {},
    route = {},
    currentWaypoint = 1,
    speed = 20.0,
    formation = true,
    reinforcementsCalled = false
}

local ghostTeam = {
    helicopter = nil,
    operatives = {},
    sniper = nil,
    insertionComplete = false,
    onStation = false
}

local compound = {
    center = vector3(-1500.0, 4500.0, 50.0), -- Adjust coordinates as needed
    radius = 75.0,
    generator = nil,
    powerOn = true,
    guards = {},
    towers = {},
    leader = nil
}

-- Convoy Route Waypoints (adjust coordinates for your map)
local CONVOY_ROUTE = {
    vector3(-2000.0, 4000.0, 30.0),
    vector3(-1800.0, 4200.0, 35.0),
    vector3(-1600.0, 4400.0, 40.0),
    vector3(-1500.0, 4500.0, 50.0) -- Compound entrance
}

-- Initialize Mission
function CartelConvoyCallout:Initialize()
    MISSION_CONFIG.missionActive = true
    MISSION_CONFIG.currentPhase = 1
    
    -- Dispatch Handler Voice
    self:PlayDispatchAudio("Shadow Unit, satellite confirms cartel convoy moving heavy weapons. Black operation - suppressed weapons only.")
    
    -- Spawn convoy
    self:SpawnConvoy()
    
    -- Deploy Ghost team after short delay
    Citizen.SetTimeout(15000, function()
        self:DeployGhostTeam()
    end)
    
    -- Start mission monitoring
    self:StartMissionLoop()
    
    return true
end

-- Spawn Convoy Formation
function CartelConvoyCallout:SpawnConvoy()
    local startPos = CONVOY_ROUTE[1]
    convoy.route = CONVOY_ROUTE
    
    -- Lead SUV (scouts)
    local leadVeh = self:CreateVehicle(MODELS.vehicles.leadSUV, startPos + vector3(0, 0, 0))
    local leadDriver = self:CreateCartelPed(leadVeh, -1)
    local leadGunner = self:CreateCartelPed(leadVeh, 0)
    self:GiveWeapon(leadGunner, "WEAPON_ASSAULTRIFLE")
    
    -- Cargo Truck 1
    local cargo1 = self:CreateVehicle(MODELS.vehicles.cargoTruck, startPos + vector3(0, -15, 0))
    local cargo1Driver = self:CreateCartelPed(cargo1, -1)
    
    -- Cargo Truck 2  
    local cargo2 = self:CreateVehicle(MODELS.vehicles.cargoTruck, startPos + vector3(0, -30, 0))
    local cargo2Driver = self:CreateCartelPed(cargo2, -1)
    
    -- Rear SUV (heavily armed)
    local rearVeh = self:CreateVehicle(MODELS.vehicles.rearSUV, startPos + vector3(0, -45, 0))
    local rearDriver = self:CreateCartelPed(rearVeh, -1)
    local rearGunner = self:CreateCartelPed(rearVeh, 0)
    self:GiveWeapon(rearGunner, "WEAPON_MG")
    
    convoy.vehicles = {leadVeh, cargo1, cargo2, rearVeh}
    convoy.peds = {leadDriver, leadGunner, cargo1Driver, cargo2Driver, rearDriver, rearGunner}
    
    -- Start convoy movement
    self:StartConvoyMovement()
end

-- Deploy Ghost Team via Annihilator 2
function CartelConvoyCallout:DeployGhostTeam()
    local playerPos = GetEntityCoords(PlayerPedId())
    local insertionPos = playerPos + vector3(100, 100, 80) -- Above player area
    
    -- Spawn Annihilator 2
    ghostTeam.helicopter = self:CreateVehicle(MODELS.vehicles.annihilator, insertionPos)
    SetVehicleLivery(ghostTeam.helicopter, 0) -- Black ops livery
    SetVehicleLights(ghostTeam.helicopter, 1) -- No lights
    
    local pilot = self:CreateGhostPed(ghostTeam.helicopter, -1)
    
    -- Approach insertion point
    local insertPoint = playerPos + vector3(50, 50, 30)
    TaskVehicleGoToCoord(pilot, ghostTeam.helicopter, insertPoint.x, insertPoint.y, insertPoint.z, 25.0, 0, GetHashKey(MODELS.vehicles.annihilator), 786603, 5.0, true)
    
    -- Wait for helicopter to arrive, then rappel operatives
    Citizen.SetTimeout(20000, function()
        self:RappelGhostTeam(insertPoint)
    end)
end

-- Rappel Ghost Operatives
function CartelConvoyCallout:RappelGhostTeam(insertPoint)
    self:PlayTacticalComms("Annihilator 2-1, on station. Deploying operatives.")
    
    -- Create rappel effect and spawn operatives
    for i = 1, 4 do
        local operative = self:CreateGhostPed(nil, nil)
        local spawnPos = insertPoint + vector3(math.random(-10, 10), math.random(-10, 10), 0)
        SetEntityCoords(operative, spawnPos.x, spawnPos.y, spawnPos.z)
        
        -- Equip suppressed weapons
        self:GiveWeapon(operative, "WEAPON_CARBINERIFLE_MK2", true) -- Suppressed
        self:GiveWeapon(operative, "WEAPON_COMBATPISTOL", true) -- Suppressed
        
        -- Set tactical behavior
        SetPedCombatAbility(operative, 2) -- High combat ability
        SetPedCombatMovement(operative, 2) -- Cover-to-cover
        SetPedAlertness(operative, 3) -- High alertness
        
        table.insert(ghostTeam.operatives, operative)
    end
    
    -- Deploy sniper on nearby rooftop
    local sniperPos = self:FindNearbyRooftop(insertPoint)
    ghostTeam.sniper = self:CreateGhostPed(nil, nil)
    SetEntityCoords(ghostTeam.sniper, sniperPos.x, sniperPos.y, sniperPos.z)
    self:GiveWeapon(ghostTeam.sniper, "WEAPON_SNIPERRIFLE", true) -- Suppressed
    
    ghostTeam.insertionComplete = true
    ghostTeam.onStation = true
    
    self:PlayTacticalComms("Ghost team on station. Awaiting your signal.")
    self:ShowNotification("~g~Ghost Team Deployed~w~\nPress ~INPUT_CONTEXT~ to signal synchronized strike")
end

-- Convoy Movement AI
function CartelConvoyCallout:StartConvoyMovement()
    Citizen.CreateThread(function()
        while MISSION_CONFIG.missionActive and convoy.currentWaypoint <= #CONVOY_ROUTE do
            if convoy.formation then
                -- Tight formation driving
                for i, vehicle in ipairs(convoy.vehicles) do
                    if DoesEntityExist(vehicle) then
                        local targetPos = CONVOY_ROUTE[convoy.currentWaypoint] + vector3(0, -(i-1) * 15, 0)
                        local driver = GetPedInVehicleSeat(vehicle, -1)
                        
                        if DoesEntityExist(driver) then
                            TaskVehicleDriveToCoord(driver, vehicle, targetPos.x, targetPos.y, targetPos.z, convoy.speed, 0, GetEntityModel(vehicle), 786603, 2.0, true)
                        end
                    end
                end
                
                -- Check if lead vehicle reached waypoint
                if DoesEntityExist(convoy.vehicles[1]) then
                    local leadPos = GetEntityCoords(convoy.vehicles[1])
                    local targetPos = CONVOY_ROUTE[convoy.currentWaypoint]
                    
                    if #(leadPos - targetPos) < 20.0 then
                        convoy.currentWaypoint = convoy.currentWaypoint + 1
                        
                        -- Check if convoy reached compound
                        if convoy.currentWaypoint > #CONVOY_ROUTE then
                            MISSION_CONFIG.convoyEscaped = true
                            MISSION_CONFIG.currentPhase = 2
                            self:InitiateCompoundPhase()
                            break
                        end
                    end
                end
            end
            
            Citizen.Wait(1000)
        end
    end)
end

-- Handle Combat Escalation
function CartelConvoyCallout:OnConvoyAttacked()
    if not convoy.reinforcementsCalled then
        convoy.reinforcementsCalled = true
        convoy.speed = 35.0 -- Accelerate
        MISSION_CONFIG.stealthBroken = true
        
        self:PlayTacticalComms("Contact! Convoy under fire!")
        
        -- Spawn reinforcement SUVs
        Citizen.SetTimeout(30000, function()
            self:SpawnReinforcements()
        end)
    end
end

-- Spawn Reinforcement Vehicles
function CartelConvoyCallout:SpawnReinforcements()
    local playerPos = GetEntityCoords(PlayerPedId())
    
    for i = 1, 2 do
        local spawnPos = playerPos + vector3(math.random(-200, 200), math.random(-200, 200), 0)
        local reinforcement = self:CreateVehicle(MODELS.vehicles.reinforcementSUV, spawnPos)
        
        for seat = -1, 2 do
            local gunner = self:CreateCartelPed(reinforcement, seat)
            if seat ~= -1 then
                self:GiveWeapon(gunner, "WEAPON_ASSAULTRIFLE")
            end
        end
        
        -- Attack player and operatives
        local driver = GetPedInVehicleSeat(reinforcement, -1)
        TaskVehicleChase(driver, PlayerPedId())
    end
end

-- Compound Infiltration Phase
function CartelConvoyCallout:InitiateCompoundPhase()
    self:PlayDispatchAudio("Convoy reached the compound. Initiate breach protocol.")
    
    -- Spawn compound defenses
    self:SpawnCompoundDefenses()
    
    self:ShowNotification("~r~Convoy Escaped~w~\nBreach the compound to complete mission\n~y~Press N for Night Vision")
end

-- Spawn Compound Defenses
function CartelConvoyCallout:SpawnCompoundDefenses()
    local center = compound.center
    
    -- Guard towers with snipers
    local towerPositions = {
        center + vector3(40, 40, 15),
        center + vector3(-40, 40, 15),
        center + vector3(40, -40, 15),
        center + vector3(-40, -40, 15)
    }
    
    for _, pos in ipairs(towerPositions) do
        local sniper = self:CreateCartelPed(nil, nil)
        SetEntityCoords(sniper, pos.x, pos.y, pos.z)
        self:GiveWeapon(sniper, "WEAPON_SNIPERRIFLE")
        TaskGuardCurrentPosition(sniper, 15.0, 15.0, 1)
        table.insert(compound.guards, sniper)
    end
    
    -- Perimeter patrols
    for i = 1, 6 do
        local angle = (i / 6) * 2 * math.pi
        local patrolPos = center + vector3(math.cos(angle) * 50, math.sin(angle) * 50, 0)
        local guard = self:CreateCartelPed(nil, nil)
        SetEntityCoords(guard, patrolPos.x, patrolPos.y, patrolPos.z)
        self:GiveWeapon(guard, math.random() > 0.5 and "WEAPON_ASSAULTRIFLE" or "WEAPON_PUMPSHOTGUN")
        
        -- Patrol route
        TaskPatrol(guard, "WORLD_HUMAN_GUARD_STAND", center.x, center.y, center.z, 30.0, true, true)
        table.insert(compound.guards, guard)
    end
    
    -- Generator (for blackout mechanic)
    compound.generator = CreateObject(GetHashKey("prop_generator_03a"), center.x + 25, center.y + 25, center.z, true, true, true)
    
    -- Cartel leader in safehouse
    compound.leader = self:CreateCartelPed(nil, nil, MODELS.peds.cartelLeader)
    SetEntityCoords(compound.leader, center.x, center.y, center.z + 5)
    self:GiveWeapon(compound.leader, "WEAPON_PISTOL50")
    SetPedArmour(compound.leader, 100)
    
    -- Bodyguards
    for i = 1, 3 do
        local bodyguard = self:CreateCartelPed(nil, nil)
        local guardPos = center + vector3(math.random(-10, 10), math.random(-10, 10), 5)
        SetEntityCoords(bodyguard, guardPos.x, guardPos.y, guardPos.z)
        self:GiveWeapon(bodyguard, "WEAPON_MICROSMG")
        TaskGuardEntityToCursor(bodyguard, compound.leader, 10.0, 10.0, 1)
    end
end

-- Night Vision Toggle
function CartelConvoyCallout:ToggleNightVision()
    MISSION_CONFIG.nightVisionEnabled = not MISSION_CONFIG.nightVisionEnabled
    SetNightvision(MISSION_CONFIG.nightVisionEnabled)
    
    if MISSION_CONFIG.nightVisionEnabled then
        self:ShowNotification("~g~Night Vision: ON")
    else
        self:ShowNotification("~r~Night Vision: OFF")
    end
end

-- Generator Blackout
function CartelConvoyCallout:DestroyGenerator()
    if DoesEntityExist(compound.generator) then
        SetEntityHealth(compound.generator, 0)
        compound.powerOn = false
        
        -- Blackout effect
        self:CreateBlackoutEffect()
        self:PlayTacticalComms("Generator down. Compound is dark.")
        
        -- Enable night vision for operatives
        for _, operative in ipairs(ghostTeam.operatives) do
            if DoesEntityExist(operative) then
                SetPedNightvision(operative, true)
            end
        end
    end
end

-- Synchronized Strike
function CartelConvoyCallout:ExecuteSynchronizedStrike()
    if ghostTeam.onStation then
        self:PlayTacticalComms("Execute, execute, execute!")
        
        -- All operatives engage simultaneously
        for _, operative in ipairs(ghostTeam.operatives) do
            if DoesEntityExist(operative) then
                local nearestTarget = self:FindNearestCartelMember(operative)
                if nearestTarget then
                    TaskCombatPed(operative, nearestTarget, 0, 16)
                end
            end
        end
        
        -- Sniper engages
        if DoesEntityExist(ghostTeam.sniper) then
            local sniperTarget = self:FindNearestCartelMember(ghostTeam.sniper)
            if sniperTarget then
                TaskCombatPed(ghostTeam.sniper, sniperTarget, 0, 16)
            end
        end
    end
end

-- Mission Success/Failure Handling
function CartelConvoyCallout:CheckMissionStatus()
    -- Check if leader is captured/killed
    if DoesEntityExist(compound.leader) then
        if IsEntityDead(compound.leader) then
            MISSION_CONFIG.leaderCaptured = false
            self:EndMission("PANTHER_SUCCESS")
        elseif IsPedCuffed(compound.leader) then
            MISSION_CONFIG.leaderCaptured = true
            self:EndMission("GHOST_SUCCESS")
        end
    end
    
    -- Check if all convoy vehicles destroyed/stopped before compound
    if not MISSION_CONFIG.convoyEscaped then
        local allDestroyed = true
        for _, vehicle in ipairs(convoy.vehicles) do
            if DoesEntityExist(vehicle) and GetEntityHealth(vehicle) > 100 then
                allDestroyed = false
                break
            end
        end
        
        if allDestroyed then
            self:EndMission("GHOST_SUCCESS")
        end
    end
end

-- End Mission with Results
function CartelConvoyCallout:EndMission(result)
    MISSION_CONFIG.missionActive = false
    
    local messages = {
        GHOST_SUCCESS = "~g~Mission Complete - Ghost Success~w~\nSilent operation, convoy seized, leader captured",
        PANTHER_SUCCESS = "~y~Mission Complete - Panther Success~w~\nPartial stealth, leader eliminated",
        ASSAULT_SUCCESS = "~o~Mission Complete - Assault Success~w~\nLoud firefight, limited intel recovered",
        FAILURE = "~r~Mission Failed~w~\nConvoy escaped, operatives compromised"
    }
    
    self:ShowNotification(messages[result] or messages.FAILURE)
    self:PlayDispatchAudio("This mission never happened. Return to base.")
    
    -- Extraction sequence
    Citizen.SetTimeout(5000, function()
        self:InitiateExtraction()
    end)
end

-- Extraction Sequence
function CartelConvoyCallout:InitiateExtraction()
    if DoesEntityExist(ghostTeam.helicopter) then
        local playerPos = GetEntityCoords(PlayerPedId())
        local extractionPoint = playerPos + vector3(0, 0, 5)
        
        -- Helicopter returns for pickup
        local pilot = GetPedInVehicleSeat(ghostTeam.helicopter, -1)
        TaskVehicleGoToCoord(pilot, ghostTeam.helicopter, extractionPoint.x, extractionPoint.y, extractionPoint.z, 25.0, 0, GetHashKey(MODELS.vehicles.annihilator), 786603, 5.0, true)
        
        self:PlayTacticalComms("Annihilator 2-1 inbound for extraction. Prepare for dust-off.")
        
        -- Load operatives
        Citizen.SetTimeout(15000, function()
            for _, operative in ipairs(ghostTeam.operatives) do
                if DoesEntityExist(operative) then
                    TaskEnterVehicle(operative, ghostTeam.helicopter, 10000, -2, 1.0, 1, 0)
                end
            end
            
            self:ShowNotification("~g~Extraction Complete~w~\nPress ~INPUT_CONTEXT~ to board helicopter")
        end)
    end
end

-- Main Mission Loop
function CartelConvoyCallout:StartMissionLoop()
    Citizen.CreateThread(function()
        while MISSION_CONFIG.missionActive do
            -- Check for convoy attacks
            for _, vehicle in ipairs(convoy.vehicles) do
                if DoesEntityExist(vehicle) and HasEntityBeenDamagedByAnyPed(vehicle) then
                    self:OnConvoyAttacked()
                    break
                end
            end
            
            -- Check mission status
            self:CheckMissionStatus()
            
            -- Handle input
            if IsControlJustPressed(0, 51) then -- E key
                if ghostTeam.onStation then
                    self:ExecuteSynchronizedStrike()
                end
            end
            
            if IsControlJustPressed(0, 249) then -- N key
                self:ToggleNightVision()
            end
            
            Citizen.Wait(100)
        end
    end)
end

-- Utility Functions
function CartelConvoyCallout:CreateVehicle(model, position)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Citizen.Wait(1)
    end
    
    local vehicle = CreateVehicle(GetHashKey(model), position.x, position.y, position.z, 0.0, true, true)
    SetVehicleOnGroundProperly(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    
    return vehicle
end

function CartelConvoyCallout:CreateCartelPed(vehicle, seat, model)
    model = model or MODELS.peds.cartelMember
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Citizen.Wait(1)
    end
    
    local ped
    if vehicle and seat then
        ped = CreatePedInsideVehicle(vehicle, 4, GetHashKey(model), seat, true, true)
    else
        ped = CreatePed(4, GetHashKey(model), 0, 0, 0, 0, true, true)
    end
    
    SetPedArmour(ped, 50)
    SetPedAccuracy(ped, 60)
    SetEntityAsMissionEntity(ped, true, true)
    
    return ped
end

function CartelConvoyCallout:CreateGhostPed(vehicle, seat)
    local model = MODELS.peds.ghostOperative
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Citizen.Wait(1)
    end
    
    local ped
    if vehicle and seat then
        ped = CreatePedInsideVehicle(vehicle, 4, GetHashKey(model), seat, true, true)
    else
        ped = CreatePed(4, GetHashKey(model), 0, 0, 0, 0, true, true)
    end
    
    SetPedArmour(ped, 100)
    SetPedAccuracy(ped, 80)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedRelationshipGroupHash(ped, GetHashKey("PLAYER"))
    
    return ped
end

function CartelConvoyCallout:GiveWeapon(ped, weapon, suppressed)
    GiveWeaponToPed(ped, GetHashKey(weapon), 999, false, true)
    SetCurrentPedWeapon(ped, GetHashKey(weapon), true)
    
    if suppressed then
        GiveWeaponComponentToPed(ped, GetHashKey(weapon), GetHashKey("COMPONENT_AT_AR_SUPP_02"))
    end
end

function CartelConvoyCallout:FindNearbyRooftop(position)
    -- Simple rooftop finder - adjust based on map
    return position + vector3(0, 0, 20)
end

function CartelConvoyCallout:FindNearestCartelMember(ped)
    local pedPos = GetEntityCoords(ped)
    local nearestTarget = nil
    local nearestDistance = 999999
    
    for _, target in ipairs(convoy.peds) do
        if DoesEntityExist(target) and not IsEntityDead(target) then
            local distance = #(pedPos - GetEntityCoords(target))
            if distance < nearestDistance then
                nearestDistance = distance
                nearestTarget = target
            end
        end
    end
    
    for _, target in ipairs(compound.guards) do
        if DoesEntityExist(target) and not IsEntityDead(target) then
            local distance = #(pedPos - GetEntityCoords(target))
            if distance < nearestDistance then
                nearestDistance = distance
                nearestTarget = target
            end
        end
    end
    
    return nearestTarget
end

function CartelConvoyCallout:CreateBlackoutEffect()
    -- Create blackout visual effect
    Citizen.CreateThread(function()
        local originalTime = GetClockHours()
        SetClockTime(23, 0, 0) -- Set to night
        
        Citizen.Wait(5000)
        
        SetClockTime(originalTime, GetClockMinutes(), GetClockSeconds())
    end)
end

function CartelConvoyCallout:PlayDispatchAudio(text)
    -- Placeholder for audio system
    self:ShowNotification("~b~Dispatch:~w~ " .. text)
end

function CartelConvoyCallout:PlayTacticalComms(text)
    -- Placeholder for tactical communications
    self:ShowNotification("~g~Ghost Team:~w~ " .. text)
end

function CartelConvoyCallout:ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

-- Cleanup Function
function CartelConvoyCallout:Cleanup()
    MISSION_CONFIG.missionActive = false
    SetNightvision(false)
    
    -- Clean up entities
    for _, vehicle in ipairs(convoy.vehicles) do
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
    end
    
    for _, ped in ipairs(convoy.peds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    
    for _, operative in ipairs(ghostTeam.operatives) do
        if DoesEntityExist(operative) then
            DeleteEntity(operative)
        end
    end
    
    if DoesEntityExist(ghostTeam.helicopter) then
        DeleteEntity(ghostTeam.helicopter)
    end
    
    if DoesEntityExist(ghostTeam.sniper) then
        DeleteEntity(ghostTeam.sniper)
    end
    
    for _, guard in ipairs(compound.guards) do
        if DoesEntityExist(guard) then
            DeleteEntity(guard)
        end
    end
    
    if DoesEntityExist(compound.leader) then
        DeleteEntity(compound.leader)
    end
    
    if DoesEntityExist(compound.generator) then
        DeleteEntity(compound.generator)
    end
end

return CartelConvoyCallout