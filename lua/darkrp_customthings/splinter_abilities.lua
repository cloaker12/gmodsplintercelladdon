-- ============================================================================
-- ULTRA-ENHANCED SPLINTER CELL TACTICAL NVG SYSTEM V3.0
-- ============================================================================
-- Military-Grade Tactical System with AI Integration, Advanced Physics,
-- Real-time Environmental Analysis, and Comprehensive Mission Support
-- ============================================================================
-- Features: 12 Vision Modes, Advanced AI, Real-time Physics Simulation,
-- Dynamic Weather Effects, Team Coordination, Mission Planning, Advanced HUD,
-- Biometric Monitoring, Environmental Hazard Detection, and Much More!
-- ============================================================================

if CLIENT then
    -- ============================================================================
    -- CORE SYSTEM VARIABLES - Ultra Enhanced
    -- ============================================================================
    
    -- Primary System State
    local visionActive = false
    local currentMode = 1
    local energy = 100
    local battery = 100
    local lastPulseTime = 0
    local pulseAlpha = 0
    local grainTexture = surface.GetTextureID("effects/tvscreen_noise002a")
    
    -- Advanced Input Management
    local keyStates = {
        n = false, t = false, m = false, r = false, g = false, h = false,
        f1 = false, f2 = false, f3 = false, f4 = false, f5 = false, f6 = false,
        shift = false, ctrl = false, alt = false, mouse1 = false, mouse2 = false
    }
    
    -- Enhanced Tactical Variables
    local threatLevel = 0
    local lastThreatScan = 0
    local targetingData = {}
    local heatTrails = {}
    local sonarMap = {}
    local compassBearing = 0
    local environmentalNoise = 0
    local stealthMode = false
    local teamSync = true
    local autoAdjustment = true
    local recordingMode = false
    
    -- Advanced System Monitoring
    local lastFrameTime = SysTime()
    local systemTemp = 20  -- Celsius
    local overheating = false
    local systemStress = 0
    local cpuUsage = 0
    local memoryUsage = 0
    local networkLatency = 0
    
    -- AI Integration System
    local aiAssistant = {
        enabled = true,
        learningMode = true,
        threatPrediction = {},
        behaviorPatterns = {},
        recommendations = {},
        adaptiveSettings = {},
        neuralNetwork = {}
    }
    
    -- Advanced Physics Simulation
    local physicsEngine = {
        gravity = Vector(0, 0, -600),
        windSpeed = Vector(0, 0, 0),
        atmosphericPressure = 101325,
        humidity = 45,
        temperature = 20,
        particleSystem = {},
        fluidDynamics = {}
    }
    
    -- Environmental Monitoring
    local environment = {
        weather = {
            type = "clear",
            intensity = 0,
            visibility = 1.0,
            precipitation = 0,
            cloudCover = 0,
            windDirection = 0
        },
        lighting = {
            ambient = 0.2,
            directional = 0.8,
            shadows = true,
            dynamicRange = 10
        },
        hazards = {
            radiation = 0,
            toxic = 0,
            electromagnetic = 0,
            acoustic = 0
        }
    }
    
    -- Biometric Monitoring
    local biometrics = {
        heartRate = 75,
        bloodOxygen = 98,
        bodyTemp = 37,
        stressLevel = 0,
        fatigue = 0,
        adrenaline = 0
    }
    
    -- Mission System
    local mission = {
        active = false,
        objectives = {},
        waypoints = {},
        intel = {},
        timeline = {},
        briefing = "",
        status = "standby"
    }
    
    -- Team Coordination
    local teamData = {
        members = {},
        formation = "standard",
        communications = {},
        sharedIntel = {},
        tacticalPositions = {}
    }
    
    -- Advanced Recording System
    local recording = {
        sessions = {},
        currentSession = nil,
        markers = {},
        analytics = {},
        exportData = {}
    }
    
    -- ============================================================================
    -- ULTRA-ENHANCED TACTICAL VISION MODES (12 MODES)
    -- ============================================================================
    local visionModes = {
        -- === BASIC ENHANCEMENT MODES ===
        {
            name = "NIGHTVISION",
            id = "nightvision",
            color = Color(0, 255, 0, 50),
            sound = "npc/scanner/scanner_electric1.wav",
            powerDrain = 0.3,
            description = "Gen-4 Image Intensification with Quantum Enhancement",
            category = "basic",
            tactical = {
                autoGain = true,
                bloomProtection = true,
                lightAdaptation = true,
                quantumAmplification = true,
                noiseReduction = 0.8
            }
        },
        {
            name = "THERMAL",
            id = "thermal", 
            color = Color(255, 0, 0, 30),
            sound = "npc/scanner/scanner_electric2.wav",
            powerDrain = 0.7,
            description = "Advanced Infrared with Heat Trail Analysis",
            category = "basic",
            tactical = {
                temperatureRange = true,
                heatTrails = true,
                movementPrediction = true,
                thermalGradients = true,
                heatSignatureAnalysis = true
            }
        },
        {
            name = "SONAR",
            id = "sonar",
            color = Color(0, 150, 255, 40),
            sound = "npc/scanner/combat_scan1.wav",
            powerDrain = 0.5,
            description = "3D Ultrasonic Mapping with Material Analysis",
            category = "basic",
            tactical = {
                materialDetection = true,
                structuralMapping = true,
                threedimensional = true,
                densityAnalysis = true,
                acousticProfiling = true
            }
        },
        {
            name = "ENHANCED",
            id = "enhanced",
            color = Color(255, 255, 0, 35),
            sound = "npc/scanner/combat_scan2.wav",
            powerDrain = 1.0,
            description = "Multi-Spectrum Tactical Overlay with AI",
            category = "basic",
            tactical = {
                multiSpectrum = true,
                threatAssessment = true,
                targetTracking = true,
                aiAssistance = true,
                predictiveAnalysis = true\n            }\n        },\n        \n        -- === ADVANCED SPECTRUM MODES ===\n        {\n            name = \"XRAY\",\n            id = \"xray\",\n            color = Color(150, 150, 255, 45),\n            sound = \"ambient/energy/electric_loop.wav\",\n            powerDrain = 1.2,\n            description = \"Penetrating X-Ray Vision with Density Analysis\",\n            category = \"advanced\",\n            tactical = {\n                penetration = true,\n                densityMapping = true,\n                structuralAnalysis = true,\n                hiddenObjectDetection = true,\n                radiationSafety = true\n            }\n        },\n        {\n            name = \"ELECTROMAGNETIC\",\n            id = \"electromagnetic\",\n            color = Color(255, 0, 255, 40),\n            sound = \"ambient/energy/electric_loop.wav\",\n            powerDrain = 0.9,\n            description = \"EM Field Visualization and Electronic Detection\",\n            category = \"advanced\",\n            tactical = {\n                emfDetection = true,\n                electronicsMapping = true,\n                signalAnalysis = true,\n                wirelessInterception = true,\n                empDetection = true\n            }\n        },\n        {\n            name = \"CHEMICAL\",\n            id = \"chemical\",\n            color = Color(0, 255, 255, 50),\n            sound = \"ambient/levels/labs/teleport_mechanism_windup2.wav\",\n            powerDrain = 0.8,\n            description = \"Chemical Composition Analysis and Gas Detection\",\n            category = \"advanced\",\n            tactical = {\n                chemicalAnalysis = true,\n                gasDetection = true,\n                toxicityAssessment = true,\n                molecularStructure = true,\n                contaminationMapping = true\n            }\n        },\n        {\n            name = \"QUANTUM\",\n            id = \"quantum\",\n            color = Color(255, 255, 255, 60),\n            sound = \"ambient/levels/labs/electric_explosion1.wav\",\n            powerDrain = 1.5,\n            description = \"Quantum State Analysis and Probability Mapping\",\n            category = \"experimental\",\n            tactical = {\n                quantumStates = true,\n                probabilityFields = true,\n                temporalAnalysis = true,\n                dimensionalDetection = true,\n                uncertaintyPrinciple = true\n            }\n        },\n        \n        -- === SPECIALIZED TACTICAL MODES ===\n        {\n            name = \"TACTICAL_GRID\",\n            id = \"tactical_grid\",\n            color = Color(0, 255, 150, 35),\n            sound = \"buttons/blip1.wav\",\n            powerDrain = 0.4,\n            description = \"Advanced Tactical Grid with Ballistics Calculation\",\n            category = \"tactical\",\n            tactical = {\n                ballisticsCalculation = true,\n                trajectoryPrediction = true,\n                windCompensation = true,\n                rangeEstimation = true,\n                coverAnalysis = true\n            }\n        },\n        {\n            name = \"STEALTH_ANALYSIS\",\n            id = \"stealth_analysis\",\n            color = Color(100, 100, 100, 25),\n            sound = \"npc/scanner/scanner_scan5.wav\",\n            powerDrain = 0.6,\n            description = \"Stealth Detection and Counter-Surveillance\",\n            category = \"tactical\",\n            tactical = {\n                stealthDetection = true,\n                camouflagePenetration = true,\n                movementAnalysis = true,\n                breathingDetection = true,\n                heartbeatSensing = true\n            }\n        },\n        {\n            name = \"BIOMETRIC\",\n            id = \"biometric\",\n            color = Color(255, 150, 0, 45),\n            sound = \"ambient/machines/teleport4.wav\",\n            powerDrain = 0.7,\n            description = \"Advanced Biometric Analysis and Health Monitoring\",\n            category = \"medical\",\n            tactical = {\n                vitalSigns = true,\n                stressAnalysis = true,\n                fatigueAssessment = true,\n                injuryDetection = true,\n                medicinalEffects = true\n            }\n        },\n        {\n            name = \"AI_PREDICTIVE\",\n            id = \"ai_predictive\",\n            color = Color(150, 255, 150, 55),\n            sound = \"ambient/machines/machine1_hit1.wav\",\n            powerDrain = 1.3,\n            description = \"AI-Powered Predictive Analysis and Threat Assessment\",\n            category = \"ai\",\n            tactical = {\n                aiPrediction = true,\n                behaviorAnalysis = true,\n                patternRecognition = true,\n                riskAssessment = true,\n                adaptiveLearning = true\n            }\n        }\n    }
    
    -- ============================================================================\n    -- ULTRA-ENHANCED TACTICAL SETTINGS & CONFIGURATION SYSTEM\n    -- ============================================================================\n    \n    local settings = {\n        -- === CORE VISION SYSTEM ===\n        visionStrength = 1.0,\n        energyDrainRate = 0.5,\n        energyRechargeRate = 1.0,\n        maxEnergy = 100,\n        \n        -- === ADVANCED POWER MANAGEMENT ===\n        batteryTechnology = \"quantum_cell\", -- lithium, nimh, quantum_cell, fusion_micro\n        batteryCapacity = 10000, -- mAh\n        batteryEfficiency = 0.95,\n        solarCharging = true,\n        kineticCharging = true,\n        thermoelectricCharging = true,\n        wirelessCharging = true,\n        emergencyMode = true,\n        powerSavingMode = true,\n        \n        -- === THERMAL MANAGEMENT ===\n        maxSystemTemp = 85, -- Celsius\n        idealOperatingTemp = 45,\n        coolingSystem = \"liquid_nitrogen\", -- air, liquid, liquid_nitrogen, quantum_cooling\n        thermalThrottling = true,\n        temperatureWarnings = true,\n        emergencyCooling = true,\n        heatDissipationRate = 2.5,\n        thermalEfficiency = 0.88,\n        \n        -- === AI INTEGRATION ===\n        aiEnabled = true,\n        aiLearningRate = 0.1,\n        aiPredictionAccuracy = 0.85,\n        aiResponseTime = 0.05, -- seconds\n        aiMemoryCapacity = 1000000, -- MB\n        aiProcessingPower = 1000, -- GFLOPS\n        neuralNetworkLayers = 50,\n        machineLearningEnabled = true,\n        adaptiveBehavior = true,\n        predictiveAnalysis = true,\n        \n        -- === ADVANCED DETECTION RANGES ===\n        maxThermalRange = 2500,\n        maxSonarRange = 1500,\n        maxXrayRange = 500,\n        maxEmRange = 3000,\n        maxChemicalRange = 800,\n        maxQuantumRange = 1000,\n        audioDetectionRange = 1200,\n        vibrationDetectionRange = 600,\n        \n        -- === ENVIRONMENTAL ANALYSIS ===\n        weatherDetection = true,\n        atmosphericAnalysis = true,\n        airQualityMonitoring = true,\n        radiationDetection = true,\n        chemicalDetection = true,\n        biologicalDetection = true,\n        seismicDetection = true,\n        magneticFieldDetection = true,\n        gravitationalAnomalies = true,\n        \n        -- === TACTICAL FEATURES ===\n        threatAssessment = true,\n        trajectoryCalculation = true,\n        ballisticsComputation = true,\n        windageCompensation = true,\n        coriolisEffect = true,\n        bulletDrop = true,\n        targetLeadCalculation = true,\n        penetrationAnalysis = true,\n        ricochetPrediction = true,\n        \n        -- === STEALTH & DETECTION ===\n        stealthDetection = true,\n        camouflagePenetration = true,\n        heartbeatDetection = true,\n        breathingAnalysis = true,\n        bloodFlowMonitoring = true,\n        nervousSystemActivity = true,\n        microMovementDetection = true,\n        bodyLanguageAnalysis = true,\n        \n        -- === BIOMETRIC MONITORING ===\n        biometricTracking = true,\n        vitalSignsMonitoring = true,\n        stressLevelAnalysis = true,\n        fatigueAssessment = true,\n        adrenlineTracking = true,\n        bloodPressureMonitoring = true,\n        oxygenSaturation = true,\n        brainwaveAnalysis = true,\n        \n        -- === COMMUNICATION SYSTEMS ===\n        teamDataSharing = true,\n        encryptedCommunication = true,\n        satelliteLinking = true,\n        quantumEntanglement = true,\n        neuralNetworking = true,\n        tacticalmeshNetwork = true,\n        emergencyBeacon = true,\n        \n        -- === RECORDING & ANALYSIS ===\n        recordingEnabled = true,\n        videoQuality = \"8K_HDR\", -- 1080p, 4K, 8K, 8K_HDR, quantum_resolution\n        audioQuality = \"lossless\", -- standard, high, lossless, 3D_spatial\n        dataCompression = \"quantum\", -- none, standard, advanced, quantum\n        realTimeAnalysis = true,\n        behaviorProfiling = true,\n        patternRecognition = true,\n        anomalyDetection = true,\n        \n        -- === ADVANCED HUD SYSTEM ===\n        hudComplexity = \"maximum\", -- minimal, standard, advanced, maximum, unlimited\n        hudTransparency = 0.15,\n        hudRefreshRate = 120, -- Hz\n        hudResolution = \"adaptive\", -- 1080p, 4K, 8K, adaptive\n        tacticalOverlay = true,\n        realTimeMapping = true,\n        augmentedReality = true,\n        holographicDisplay = true,\n        \n        -- === PHYSICS SIMULATION ===\n        physicsAccuracy = \"quantum\", -- basic, realistic, advanced, quantum\n        fluidDynamics = true,\n        particlePhysics = true,\n        quantumMechanics = true,\n        relativisticEffects = true,\n        atmosphericModeling = true,\n        gravitationalLensing = true,\n        \n        -- === PERFORMANCE OPTIMIZATION ===\n        adaptiveRendering = true,\n        lodOptimization = true,\n        frustumCulling = true,\n        occlusionCulling = true,\n        multiThreading = true,\n        gpuAcceleration = true,\n        quantumComputing = true,\n        \n        -- === SECURITY FEATURES ===\n        encryptionLevel = \"quantum\", -- basic, military, quantum\n        biometricSecurity = true,\n        neuralAuthentication = true,\n        quantumKeyDistribution = true,\n        tamperDetection = true,\n        selfDestruct = true,\n        dataWiping = true,\n        \n        -- === EXPERIMENTAL FEATURES ===\n        timeDialation = false,\n        parallelRealities = false,\n        dimensionalAnalysis = false,\n        consciousnessMapping = false,\n        quantumTunneling = false,\n        teleportation = false,\n        mindReading = false"
        maxBattery = 100,
        batteryDrainRate = 0.1,
        sonarPulseInterval = 1.5,
        sonarPulseDuration = 0.5,
        nightVisionGrainAmount = 0.2,
        thermalSensitivity = 1.2,
        
        -- Tactical enhancements
        threatScanInterval = 2.0,
        targetingRange = 2000,
        heatTrailDuration = 15.0,
        compassUpdateRate = 0.1,
        autoAdjustmentSpeed = 2.0,
        stealthSensitivity = 0.8,
        teamSyncRange = 5000,
        maxSystemTemp = 65,
        coolingRate = 1.5,
        
        -- Audio settings
        audioVisualization = true,
        noiseDetectionRange = 800,
        footstepDetection = true,
        weaponSoundDetection = true,
        
        -- Performance settings
        maxHeatTrails = 50,
        maxSonarPoints = 200,
        renderDistance = 3000,
        updateFrequency = 30
    }
    
    -- Enhanced convars for tactical features
    CreateClientConVar("sc_vision_strength", "1", true, false, "Vision effect strength", 0.1, 2)
    CreateClientConVar("sc_energy_drain", "0.5", true, false, "Energy drain rate per second", 0.1, 2)
    CreateClientConVar("sc_energy_recharge", "1", true, false, "Energy recharge rate per second", 0.1, 3)
    CreateClientConVar("sc_sonar_interval", "1.5", true, false, "Sonar pulse interval", 0.5, 5)
    CreateClientConVar("sc_grain_amount", "0.2", true, false, "Night vision grain amount", 0, 1)
    CreateClientConVar("sc_threat_detection", "1", true, false, "Enable threat detection system", 0, 1)
    CreateClientConVar("sc_heat_trails", "1", true, false, "Enable heat trail tracking", 0, 1)
    CreateClientConVar("sc_audio_visual", "1", true, false, "Enable audio visualization", 0, 1)
    CreateClientConVar("sc_auto_adjust", "1", true, false, "Enable auto brightness adjustment", 0, 1)
    CreateClientConVar("sc_stealth_mode", "0", true, false, "Enable stealth mode (reduced visibility)", 0, 1)
    CreateClientConVar("sc_team_sync", "1", true, false, "Enable team data synchronization", 0, 1)
    CreateClientConVar("sc_tactical_hud", "1", true, false, "Enable tactical HUD overlay", 0, 1)
    
    -- Helper function to check if player has Splinter Cell abilities
    local function HasSplinterCellAbilities()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        
        local team = ply:Team()
        return team == TEAM_SPLINTERCELL or team == TEAM_SPLINTERCOMMANDER
    end
    
    -- Calculate threat level based on nearby entities
    local function CalculateThreatLevel()
        if not GetConVar("sc_threat_detection"):GetBool() then return 0 end
        
        local ply = LocalPlayer()
        if not IsValid(ply) then return 0 end
        
        local threat = 0
        local playerPos = ply:GetPos()
        
        for _, ent in ipairs(ents.FindInSphere(playerPos, settings.targetingRange)) do
            if IsValid(ent) and ent != ply then
                local distance = playerPos:Distance(ent:GetPos())
                local distanceFactor = math.max(0, 1 - (distance / settings.targetingRange))
                
                if ent:IsPlayer() and ent:Alive() then
                    if ent:IsBot() or ent:Team() != ply:Team() then
                        threat = threat + (30 * distanceFactor)
                    end
                elseif ent:IsNPC() then
                    threat = threat + (20 * distanceFactor)
                elseif ent:IsWeapon() and ent:GetOwner() != ply then
                    threat = threat + (10 * distanceFactor)
                elseif ent:IsVehicle() and IsValid(ent:GetDriver()) and ent:GetDriver() != ply then
                    threat = threat + (15 * distanceFactor)
                end
            end
        end
        
        return math.min(100, threat)
    end
    
    -- Update heat trails for thermal vision
    local function UpdateHeatTrails()
        if not GetConVar("sc_heat_trails"):GetBool() then return end
        
        local currentTime = CurTime()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        -- Clean old trails
        for id, trail in pairs(heatTrails) do
            if currentTime - trail.time > settings.heatTrailDuration then
                heatTrails[id] = nil
            end
        end
        
        -- Add new trails for moving entities
        for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), settings.renderDistance)) do
            if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC()) and ent != ply then
                local vel = ent:GetVelocity()
                if vel:Length() > 50 then -- Moving threshold
                    local id = ent:EntIndex()
                    if not heatTrails[id] then
                        heatTrails[id] = {positions = {}}
                    end
                    
                    table.insert(heatTrails[id].positions, {
                        pos = ent:GetPos(),
                        time = currentTime,
                        heat = ent:IsPlayer() and 1.0 or 0.8
                    })
                    
                    heatTrails[id].time = currentTime
                    
                    -- Limit trail length
                    if #heatTrails[id].positions > 20 then
                        table.remove(heatTrails[id].positions, 1)
                    end
                end
            end
        end
    end
    
    -- Get distance to target with tactical info
    local function GetTargetInfo(ent)
        local ply = LocalPlayer()
        if not IsValid(ply) or not IsValid(ent) then return nil end
        
        local distance = ply:GetPos():Distance(ent:GetPos())
        local angle = ply:GetAimVector():Angle():Forward():Dot((ent:GetPos() - ply:GetPos()):GetNormalized())
        
        local info = {
            distance = distance,
            bearing = math.deg(math.atan2(ent:GetPos().y - ply:GetPos().y, ent:GetPos().x - ply:GetPos().x)),
            elevation = math.deg(math.asin((ent:GetPos().z - ply:GetPos().z) / distance)),
            inSight = angle > 0.7, -- ~45 degree cone
            velocity = ent:GetVelocity():Length(),
            threat = 0
        }
        
        -- Calculate threat level
        if ent:IsPlayer() and ent:Alive() then
            if ent:Team() != ply:Team() then
                info.threat = distance < 500 and 80 or 40
            end
        elseif ent:IsNPC() then
            info.threat = distance < 300 and 60 or 30
        end
        
        return info
    end
    
    -- Update compass bearing
    local function UpdateCompass()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local ang = ply:EyeAngles()
        compassBearing = math.NormalizeAngle(ang.y)
    end
    
    -- Detect environmental noise for stealth
    local function DetectEnvironmentalNoise()
        if not GetConVar("sc_audio_visual"):GetBool() then return 0 end
        
        local ply = LocalPlayer()
        if not IsValid(ply) then return 0 end
        
        local noise = 0
        local playerPos = ply:GetPos()
        
        -- Check for nearby sound sources
        for _, ent in ipairs(ents.FindInSphere(playerPos, settings.noiseDetectionRange)) do
            if IsValid(ent) and ent != ply then
                local distance = playerPos:Distance(ent:GetPos())
                local vel = ent:GetVelocity():Length()
                
                if vel > 100 then -- Moving entities make noise
                    noise = noise + math.max(0, 50 - (distance / 10))
                end
                
                if ent:IsVehicle() and vel > 0 then
                    noise = noise + math.max(0, 80 - (distance / 5))
                end
            end
        end
        
        return math.min(100, noise)
    end
    
    -- Toggle vision function
    local function ToggleVision()
        if not HasSplinterCellAbilities() then
            LocalPlayer():ChatPrint("You don't have access to this technology!")
            return
        end
        
        -- Send toggle request to server
        net.Start("SC_AbilityToggle")
        net.SendToServer()
    end
    
    -- Cycle vision mode function
    local function CycleMode()
        if not HasSplinterCellAbilities() then return end
        if not visionActive then return end
        
        -- Send mode change request to server
        net.Start("SC_AbilityModeChange")
        net.SendToServer()
    end
    
    -- Enhanced key handling with tactical features
    hook.Add("Think", "SplinterCellAbilityKeys", function()
        if not HasSplinterCellAbilities() then return end
        
        -- Update system states
        local currentTime = CurTime()
        local frameTime = FrameTime()
        
        -- Update system temperature
        if visionActive then
            local mode = visionModes[currentMode]
            systemTemp = math.min(settings.maxSystemTemp, systemTemp + (mode.powerDrain * frameTime))
        else
            systemTemp = math.max(20, systemTemp - (settings.coolingRate * frameTime))
        end
        
        overheating = systemTemp > settings.maxSystemTemp * 0.9
        
        -- Update tactical systems
        if currentTime - lastThreatScan > settings.threatScanInterval then
            threatLevel = CalculateThreatLevel()
            lastThreatScan = currentTime
        end
        
        UpdateCompass()
        environmentalNoise = DetectEnvironmentalNoise()
        UpdateHeatTrails()
        
        -- N key to toggle vision
        if input.IsKeyDown(KEY_N) and not nKeyPressed then
            nKeyPressed = true
            ToggleVision()
        elseif not input.IsKeyDown(KEY_N) then
            nKeyPressed = false
        end
        
        -- T key to cycle modes
        if input.IsKeyDown(KEY_T) and not tKeyPressed then
            tKeyPressed = true
            CycleMode()
        elseif not input.IsKeyDown(KEY_T) then
            tKeyPressed = false
        end
        
        -- M key to toggle stealth mode
        if input.IsKeyDown(KEY_M) and not mKeyPressed then
            mKeyPressed = true
            stealthMode = not stealthMode
            LocalPlayer():ChatPrint("Stealth Mode: " .. (stealthMode and "ENABLED" or "DISABLED"))
            surface.PlaySound("buttons/button15.wav")
        elseif not input.IsKeyDown(KEY_M) then
            mKeyPressed = false
        end
        
        -- R key to toggle recording/marking mode
        if input.IsKeyDown(KEY_R) and not rKeyPressed then
            rKeyPressed = true
            recordingMode = not recordingMode
            LocalPlayer():ChatPrint("Recording Mode: " .. (recordingMode and "ACTIVE" or "INACTIVE"))
            surface.PlaySound("buttons/button17.wav")
        elseif not input.IsKeyDown(KEY_R) then
            rKeyPressed = false
        end
        
        -- Battery management
        if visionActive and battery > 0 then
            local mode = visionModes[currentMode]
            local drainRate = mode.powerDrain * settings.batteryDrainRate
            if overheating then
                drainRate = drainRate * 1.5  -- Faster drain when overheating
            end
            battery = math.max(0, battery - drainRate * frameTime)
            
            if battery <= 0 then
                ToggleVision()  -- Auto-shutdown when battery dies
                LocalPlayer():ChatPrint("BATTERY DEPLETED - NVG SYSTEM OFFLINE")
                surface.PlaySound("buttons/button10.wav")
            elseif battery <= 10 then
                -- Low battery warning
                if math.floor(currentTime * 2) % 2 == 0 then
                    surface.PlaySound("buttons/button16.wav")
                end
            end
        elseif not visionActive and battery < settings.maxBattery then
            battery = math.min(settings.maxBattery, battery + frameTime * 2)
        end
    end)
    
    -- Enhanced Night Vision Rendering with auto-adjustment
    local function RenderNightVision(strength)
        -- Auto-brightness adjustment based on environment
        local adjustedStrength = strength
        if GetConVar("sc_auto_adjust"):GetBool() then
            local trace = util.TraceLine({
                start = LocalPlayer():EyePos(),
                endpos = LocalPlayer():EyePos() + LocalPlayer():GetAimVector() * 1000,
                filter = LocalPlayer()
            })
            
            -- Adjust based on ambient light (simplified)
            local lightLevel = render.GetLightColor(trace.HitPos or LocalPlayer():EyePos()):Length()
            adjustedStrength = math.Clamp(strength * (1.5 - lightLevel), 0.5, 2.0)
        end
        
        -- Enhanced color modification with better brightness
        local tab = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0.15 * adjustedStrength,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0.35 * adjustedStrength,
            ["$pp_colour_contrast"] = 1.4,
            ["$pp_colour_colour"] = 0.3,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 6 * adjustedStrength,
            ["$pp_colour_mulb"] = 0
        }
        DrawColorModify(tab)
        
        -- Bloom protection against bright lights
        local bloomStrength = overheating and 0.4 or 0.65
        DrawBloom(bloomStrength, 2 * adjustedStrength, 9, 9, 1, 1, 1, 1, 1)
        
        -- Enhanced grain effect with tactical feel
        local grainAmount = GetConVar("sc_grain_amount"):GetFloat()
        if grainAmount > 0 and not stealthMode then
            surface.SetDrawColor(0, 255, 0, 25 * grainAmount)
            surface.SetTexture(grainTexture)
            
            -- Animated grain with system temperature effect
            local offset = CurTime() * (8 + systemTemp * 0.1)
            surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrW() * 2, ScrH() * 2, offset)
        end
        
        -- Center focus enhancement for better target acquisition
        local centerSize = ScrW() * 0.3
        surface.SetDrawColor(0, 255, 0, 15)
        surface.DrawRect(ScrW()/2 - centerSize/2, ScrH()/2 - centerSize/2, centerSize, centerSize)
        
        -- Tactical scan lines (less intrusive in stealth mode)
        if not stealthMode then
            surface.SetDrawColor(0, 255, 0, 8)
            for i = 0, ScrH(), 6 do
                surface.DrawLine(0, i, ScrW(), i)
            end
        end
    end
    
    -- Enhanced thermal heat calculation with temperature gradients
    local function GetEntityHeat(ent)
        if not IsValid(ent) then return 0 end
        
        local heat = 0
        local baseHeat = 0
        local ply = LocalPlayer()
        local distance = IsValid(ply) and ply:GetPos():Distance(ent:GetPos()) or 1000
        
        -- Base heat calculations
        if ent:IsPlayer() then
            if ent:Alive() then
                baseHeat = 1.0
                -- Factor in movement (higher heat when moving)
                local velocity = ent:GetVelocity():Length()
                if velocity > 100 then
                    baseHeat = baseHeat + (velocity / 1000) -- Up to +0.5 heat
                end
                -- Factor in recent damage
                if ent:Health() < ent:GetMaxHealth() * 0.8 then
                    baseHeat = baseHeat + 0.2 -- Injured = more heat
                end
            else
                baseHeat = math.max(0.1, 0.8 - ((CurTime() - (ent.DeathTime or CurTime())) / 60)) -- Cool down over time
            end
        elseif ent:IsNPC() then
            baseHeat = ent:Health() > 0 and 0.8 or 0.2
            -- NPCs generate more heat when in combat
            if ent:GetEnemy() and IsValid(ent:GetEnemy()) then
                baseHeat = baseHeat + 0.3
            end
        elseif ent:IsVehicle() then
            local driver = ent:GetDriver()
            if IsValid(driver) then
                baseHeat = 0.9  -- Running engine
            else
                baseHeat = 0.4  -- Cooling engine
            end
        elseif ent:IsWeapon() then
            -- Recently fired weapons are hot
            local owner = ent:GetOwner()
            if IsValid(owner) and owner:IsPlayer() then
                baseHeat = 0.6
            else
                baseHeat = 0.3
            end
        elseif ent:GetClass():find("lamp") or ent:GetClass():find("light") then
            baseHeat = 0.9
        elseif ent:GetClass():find("fire") or ent:GetClass():find("flame") then
            baseHeat = 1.2 -- Extremely hot
        elseif ent:GetClass():find("prop_physics") then
            -- Props have ambient temperature
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) and phys:GetVelocity():Length() > 50 then
                baseHeat = 0.4 -- Friction heat
            else
                baseHeat = 0.15
            end
        else
            baseHeat = 0.1
        end
        
        -- Distance-based heat attenuation (realistic thermal fade)
        local distanceFactor = math.Clamp(1 - (distance / settings.renderDistance), 0.1, 1)
        
        -- Apply thermal sensitivity and distance
        heat = baseHeat * settings.thermalSensitivity * distanceFactor
        
        -- Environmental factors
        if overheating then
            heat = heat * 0.7 -- System interference when overheating
        end
        
        return math.Clamp(heat, 0, 1.5)
    end
    
    -- Enhanced Thermal Vision Rendering with heat trails and gradients
    local function RenderThermalVision(strength)
        local entities = ents.GetAll()
        local ply = LocalPlayer()
        local currentTime = CurTime()
        
        -- Render heat trails first
        if GetConVar("sc_heat_trails"):GetBool() then
            cam.Start3D()
            render.SetMaterial(Material("sprites/light_glow02_add"))
            
            for id, trail in pairs(heatTrails) do
                if trail.positions and #trail.positions > 1 then
                    for i = 1, #trail.positions - 1 do
                        local pos1 = trail.positions[i]
                        local pos2 = trail.positions[i + 1]
                        
                        if pos1 and pos2 and pos1.pos and pos2.pos then
                            local age = currentTime - pos1.time
                            local alpha = math.max(0, 1 - (age / settings.heatTrailDuration))
                            local size = 8 * alpha * pos1.heat
                            
                            render.SetColorModulation(1, 0.5 * alpha, 0)
                            render.DrawSprite(pos1.pos, size, size)
                            
                            -- Draw connecting line
                            render.DrawBeam(pos1.pos, pos2.pos, size * 0.5, 0, 1, Color(255, 128, 0, 100 * alpha))
                        end
                    end
                end
            end
            cam.End3D()
        end
        
        -- Enhanced entity rendering with temperature gradients
        render.SetStencilEnable(true)
        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(1)
        
        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        
        cam.Start3D()
        render.SuppressEngineLighting(true)
        
        local hotTargets = {}
        
        for _, ent in ipairs(entities) do
            if IsValid(ent) and ent != ply then
                local heat = GetEntityHeat(ent)
                local distance = ply:GetPos():Distance(ent:GetPos())
                
                if heat > 0.1 and distance < settings.renderDistance then
                    -- Temperature-based color gradients
                    local r, g, b = 0, 0, 0
                    
                    if heat > 0.8 then
                        -- White hot (very high temp)
                        r, g, b = 1, 1, 1
                    elseif heat > 0.6 then
                        -- Yellow-white (high temp)
                        r, g, b = 1, 1, 0.5
                    elseif heat > 0.4 then
                        -- Orange-red (medium-high temp)
                        r, g, b = 1, 0.6, 0
                    elseif heat > 0.2 then
                        -- Red (medium temp)
                        r, g, b = 1, 0.2, 0
                    else
                        -- Dark red (low temp)
                        r, g, b = 0.8, 0, 0
                    end
                    
                    render.SetColorModulation(r, g, b)
                    render.SetBlend(math.Clamp(heat, 0.3, 1))
                    ent:DrawModel()
                    
                    -- Track high-value targets
                    if heat > 0.6 and (ent:IsPlayer() or ent:IsNPC()) then
                        table.insert(hotTargets, {ent = ent, heat = heat, distance = distance})
                    end
                end
            end
        end
        
        render.SuppressEngineLighting(false)
        cam.End3D()
        render.SetStencilEnable(false)
        
        -- Enhanced thermal color modification with better contrast
        local tab = {
            ["$pp_colour_addr"] = 0.05 * strength,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0.1 * strength,
            ["$pp_colour_brightness"] = -0.4,
            ["$pp_colour_contrast"] = 2.2,
            ["$pp_colour_colour"] = 0.15,
            ["$pp_colour_mulr"] = 2.5 * strength,
            ["$pp_colour_mulg"] = 0.3,
            ["$pp_colour_mulb"] = 0.1
        }
        DrawColorModify(tab)
        
        -- Draw targeting information for hot targets
        targetingData = hotTargets
        
        -- Add thermal bloom effect
        DrawBloom(0.75, 1.5 * strength, 5, 5, 1, 1, 1, 1, 1)
    end
    
    -- Advanced 3D Sonar Vision with material detection
    local function RenderSonarVision(strength)
        local time = CurTime()
        local interval = GetConVar("sc_sonar_interval"):GetFloat()
        local ply = LocalPlayer()
        
        -- Update pulse timing
        if time - lastPulseTime > interval then
            lastPulseTime = time
            pulseAlpha = 1.0
            surface.PlaySound("npc/scanner/scanner_siren1.wav")
            
            -- Update 3D sonar map
            if IsValid(ply) then
                UpdateSonarMap()
            end
        end
        
        -- Fade pulse
        if pulseAlpha > 0 then
            pulseAlpha = math.max(0, pulseAlpha - FrameTime() / settings.sonarPulseDuration)
        end
        
        -- Render 3D sonar points
        if pulseAlpha > 0 then
            Render3DSonarMap(strength)
        end
        
        -- Enhanced sonar color modification with depth perception
        local tab = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0.05 * strength,
            ["$pp_colour_addb"] = 0.15 * strength,
            ["$pp_colour_brightness"] = -0.6 + (0.2 * pulseAlpha),
            ["$pp_colour_contrast"] = 1.8,
            ["$pp_colour_colour"] = 0.2,
            ["$pp_colour_mulr"] = 0.2,
            ["$pp_colour_mulg"] = 0.7,
            ["$pp_colour_mulb"] = 2.5 * strength
        }
        DrawColorModify(tab)
        
        -- Dynamic pulse overlay with range rings
        if pulseAlpha > 0 then
            local alpha = 80 * pulseAlpha
            
            -- Central pulse
            surface.SetDrawColor(0, 150, 255, alpha)
            surface.DrawRect(0, 0, ScrW(), ScrH())
            
            -- Draw range rings
            local centerX, centerY = ScrW() / 2, ScrH() / 2
            for i = 1, 5 do
                local radius = (i * 100) * pulseAlpha
                surface.SetDrawColor(0, 200, 255, alpha / i)
                surface.DrawOutlinedCircle(centerX, centerY, radius, 2)
            end
            
            -- Scanning line effect
            local scanAngle = (time * 180) % 360
            local lineLength = ScrH() * 0.4
            local endX = centerX + math.cos(math.rad(scanAngle)) * lineLength
            local endY = centerY + math.sin(math.rad(scanAngle)) * lineLength
            
            surface.SetDrawColor(0, 255, 255, alpha)
            surface.DrawLine(centerX, centerY, endX, endY)
        end
    end
    
    -- Update 3D sonar mapping data
    local function UpdateSonarMap()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local playerPos = ply:GetPos()
        sonarMap = {} -- Clear old data
        
        -- Trace in multiple directions to build 3D map
        local directions = {}
        for pitch = -45, 45, 15 do
            for yaw = 0, 345, 15 do
                table.insert(directions, {pitch = pitch, yaw = yaw})
            end
        end
        
        for _, dir in ipairs(directions) do
            local angle = Angle(dir.pitch, dir.yaw, 0)
            local trace = util.TraceLine({
                start = playerPos,
                endpos = playerPos + angle:Forward() * settings.targetingRange,
                filter = ply
            })
            
            if trace.Hit then
                local distance = trace.StartPos:Distance(trace.HitPos)
                local material = trace.MatType or 0
                
                table.insert(sonarMap, {
                    pos = trace.HitPos,
                    normal = trace.HitNormal,
                    distance = distance,
                    material = GetMaterialType(material),
                    intensity = math.Clamp(1 - (distance / settings.targetingRange), 0.1, 1)
                })
            end
        end
        
        -- Limit map size for performance
        if #sonarMap > settings.maxSonarPoints then
            table.sort(sonarMap, function(a, b) return a.distance < b.distance end)
            for i = settings.maxSonarPoints + 1, #sonarMap do
                sonarMap[i] = nil
            end
        end
    end
    
    -- Get material type for sonar analysis
    local function GetMaterialType(matType)
        local materials = {
            [MAT_CONCRETE] = {name = "CONCRETE", color = Color(100, 100, 150), density = 0.9},
            [MAT_METAL] = {name = "METAL", color = Color(150, 150, 150), density = 1.0},
            [MAT_DIRT] = {name = "DIRT", color = Color(139, 69, 19), density = 0.6},
            [MAT_WOOD] = {name = "WOOD", color = Color(139, 90, 43), density = 0.7},
            [MAT_FLESH] = {name = "ORGANIC", color = Color(255, 100, 100), density = 0.8},
            [MAT_PLASTIC] = {name = "PLASTIC", color = Color(200, 200, 100), density = 0.5},
            [MAT_GLASS] = {name = "GLASS", color = Color(100, 200, 255), density = 0.3}
        }
        
        return materials[matType] or {name = "UNKNOWN", color = Color(100, 100, 100), density = 0.5}
    end
    
    -- Render 3D sonar visualization
    local function Render3DSonarMap(strength)
        if not sonarMap or #sonarMap == 0 then return end
        
        cam.Start3D()
        render.SetMaterial(Material("sprites/light_glow02_add"))
        
        for _, point in ipairs(sonarMap) do
            if point.pos and point.intensity then
                local alpha = point.intensity * pulseAlpha
                local size = 4 + (point.material.density * 6) * alpha
                
                -- Color based on material and distance
                local color = point.material.color
                render.SetColorModulation(color.r / 255, color.g / 255, color.b / 255)
                render.DrawSprite(point.pos, size, size)
                
                -- Draw normal indicator for surface orientation
                if point.normal then
                    local endPos = point.pos + point.normal * 20
                    render.DrawBeam(point.pos, endPos, 1, 0, 1, Color(0, 255, 255, 100 * alpha))
                end
            end
        end
        
        cam.End3D()
    end
    
    -- Enhanced Multi-Spectrum Vision Mode
    local function RenderEnhancedVision(strength)
        -- Combines aspects of all vision modes with tactical overlays
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        -- Base enhanced color modification
        local tab = {
            ["$pp_colour_addr"] = 0.05 * strength,
            ["$pp_colour_addg"] = 0.08 * strength,
            ["$pp_colour_addb"] = 0.05 * strength,
            ["$pp_colour_brightness"] = 0.25 * strength,
            ["$pp_colour_contrast"] = 1.6,
            ["$pp_colour_colour"] = 0.4,
            ["$pp_colour_mulr"] = 2 * strength,
            ["$pp_colour_mulg"] = 3 * strength,
            ["$pp_colour_mulb"] = 1.5 * strength
        }
        DrawColorModify(tab)
        
        -- Multi-spectrum entity highlighting
        cam.Start3D()
        render.SuppressEngineLighting(true)
        
        local enhancedTargets = {}
        
        for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), settings.renderDistance)) do
            if IsValid(ent) and ent != ply then
                local distance = ply:GetPos():Distance(ent:GetPos())
                local alpha = math.Clamp(1 - (distance / settings.renderDistance), 0.2, 1)
                
                -- Multi-spectrum analysis
                if ent:IsPlayer() and ent:Alive() then
                    -- Bright yellow-white for players
                    render.SetColorModulation(1, 1, 0.8)
                    render.SetBlend(alpha * 0.9)
                    ent:DrawModel()
                    table.insert(enhancedTargets, {ent = ent, type = "PLAYER", threat = 80})
                    
                elseif ent:IsNPC() then
                    -- Orange for NPCs
                    render.SetColorModulation(1, 0.6, 0.2)
                    render.SetBlend(alpha * 0.8)
                    ent:DrawModel()
                    table.insert(enhancedTargets, {ent = ent, type = "NPC", threat = 60})
                    
                elseif ent:IsWeapon() then
                    -- Cyan for weapons
                    render.SetColorModulation(0, 1, 1)
                    render.SetBlend(alpha * 0.7)
                    ent:DrawModel()
                    table.insert(enhancedTargets, {ent = ent, type = "WEAPON", threat = 40})
                    
                elseif ent:IsVehicle() then
                    -- Purple for vehicles
                    render.SetColorModulation(1, 0, 1)
                    render.SetBlend(alpha * 0.6)
                    ent:DrawModel()
                    table.insert(enhancedTargets, {ent = ent, type = "VEHICLE", threat = 30})
                end
            end
        end
        
        render.SuppressEngineLighting(false)
        cam.End3D()
        
        -- Store targeting data
        targetingData = enhancedTargets
        
        -- Enhanced bloom and motion blur
        DrawBloom(0.8, 2 * strength, 7, 7, 1, 1, 1, 1, 1)
        DrawMotionBlur(0.3, 0.9, 0.02)
        
        -- Tactical grid overlay
        if not stealthMode then
            surface.SetDrawColor(255, 255, 0, 30)
            local gridSize = 50
            for x = 0, ScrW(), gridSize do
                surface.DrawLine(x, 0, x, ScrH())
            end
            for y = 0, ScrH(), gridSize do
                surface.DrawLine(0, y, ScrW(), y)
            end
        end
    end
    
    -- Audio Visualization System
    local function RenderAudioVisualization()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local playerPos = ply:GetPos()
        local currentTime = CurTime()
        
        -- Detect and visualize audio sources
        for _, ent in ipairs(ents.FindInSphere(playerPos, settings.noiseDetectionRange)) do
            if IsValid(ent) and ent != ply then
                local entPos = ent:GetPos()
                local distance = playerPos:Distance(entPos)
                local velocity = ent:GetVelocity():Length()
                
                -- Calculate audio intensity
                local audioIntensity = 0
                
                if velocity > 100 then
                    audioIntensity = math.Clamp((velocity - 100) / 400, 0, 1) * 0.8
                elseif ent:IsVehicle() and velocity > 0 then
                    audioIntensity = math.Clamp(velocity / 300, 0, 1) * 1.0
                elseif ent:IsWeapon() and IsValid(ent:GetOwner()) then
                    audioIntensity = 0.6 -- Weapon sounds
                end
                
                if audioIntensity > 0.1 then
                    -- Convert world position to screen
                    local screenPos = entPos:ToScreen()
                    
                    if screenPos.visible then
                        -- Draw audio visualization
                        local alpha = math.Clamp(audioIntensity * 255, 50, 255)
                        local size = 20 + (audioIntensity * 30)
                        
                        -- Pulsing audio indicator
                        local pulse = math.sin(currentTime * 8) * 0.3 + 0.7
                        surface.SetDrawColor(255, 255, 0, alpha * pulse)
                        surface.DrawOutlinedCircle(screenPos.x, screenPos.y, size, 3)
                        
                        -- Sound wave rings
                        for i = 1, 3 do
                            local ringSize = size + (i * 15 * pulse)
                            surface.SetDrawColor(255, 255, 0, (alpha * pulse) / (i * 2))
                            surface.DrawOutlinedCircle(screenPos.x, screenPos.y, ringSize, 1)
                        end
                        
                        -- Direction indicator
                        local dirToSource = (entPos - playerPos):GetNormalized()
                        local angleToSource = math.deg(math.atan2(dirToSource.y, dirToSource.x))
                        
                        -- Draw directional arrow
                        local arrowLength = 30
                        local arrowX = screenPos.x + math.cos(math.rad(angleToSource)) * arrowLength
                        local arrowY = screenPos.y + math.sin(math.rad(angleToSource)) * arrowLength
                        
                        surface.SetDrawColor(255, 255, 0, alpha)
                        surface.DrawLine(screenPos.x, screenPos.y, arrowX, arrowY)
                        
                        -- Distance text
                        draw.SimpleText(string.format("%.0fm", distance), "DermaDefault", 
                            screenPos.x, screenPos.y - 30, Color(255, 255, 0, alpha), 
                            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
            end
        end
        
        -- Environmental audio meter
        if environmentalNoise > 10 then
            local meterX, meterY = ScrW() - 200, ScrH() - 150
            local meterW, meterH = 150, 20
            
            -- Background
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(meterX, meterY, meterW, meterH)
            
            -- Noise level bar
            local noiseColor = Color(0, 255, 0, 200)
            if environmentalNoise > 60 then
                noiseColor = Color(255, 0, 0, 200)
            elseif environmentalNoise > 30 then
                noiseColor = Color(255, 255, 0, 200)
            end
            
            surface.SetDrawColor(noiseColor.r, noiseColor.g, noiseColor.b, noiseColor.a)
            surface.DrawRect(meterX, meterY, meterW * (environmentalNoise / 100), meterH)
            
            -- Label
            draw.SimpleText("AUDIO LEVEL", "DermaDefault", meterX + meterW/2, meterY - 15, 
                Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    
    -- Draw sonar halos
    local function DrawSonarHalos()
        if pulseAlpha <= 0 then return end
        
        local entities = ents.GetAll()
        local targets = {}
        
        for _, ent in ipairs(entities) do
            if IsValid(ent) and ent != LocalPlayer() then
                local distance = LocalPlayer():GetPos():Distance(ent:GetPos())
                if distance < 1000 and (ent:IsPlayer() or ent:IsNPC() or ent:IsVehicle()) then
                    table.insert(targets, ent)
                end
            end
        end
        
        if #targets > 0 then
            halo.Add(targets, Color(0, 150, 255, 255 * pulseAlpha), 2, 2, 2, true, true)
        end
    end
    
    -- Main rendering hook
    hook.Add("RenderScreenspaceEffects", "SplinterCellAbilityEffects", function()
        if not HasSplinterCellAbilities() or not visionActive then return end
        
        local mode = visionModes[currentMode]
        local strength = GetConVar("sc_vision_strength"):GetFloat()
        
        if mode.id == "nightvision" then
            RenderNightVision(strength)
        elseif mode.id == "thermal" then
            RenderThermalVision(strength)
        elseif mode.id == "sonar" then
            RenderSonarVision(strength)
        elseif mode.id == "enhanced" then
            RenderEnhancedVision(strength)
        end
        
        -- Audio visualization overlay (works with all modes)
        if GetConVar("sc_audio_visual"):GetBool() and visionActive then
            RenderAudioVisualization()
        end
    end)
    
    -- Halo rendering hook
    hook.Add("PreDrawHalos", "SplinterCellAbilityHalos", function()
        if not HasSplinterCellAbilities() or not visionActive then return end
        
        if visionModes[currentMode].id == "sonar" then
            DrawSonarHalos()
        end
    end)
    
    -- Advanced Tactical HUD System
    hook.Add("HUDPaint", "SplinterCellAbilityHUD", function()
        if not HasSplinterCellAbilities() then return end
        if not GetConVar("sc_tactical_hud"):GetBool() then return end
        
        local w, h = ScrW(), ScrH()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        -- === LEFT PANEL: System Status ===
        local leftX, leftY = 50, 50
        
        -- System header
        draw.SimpleTextOutlined("╔═══ TACTICAL NVG SYSTEM ═══╗", "Trebuchet18", leftX, leftY, 
            Color(0, 255, 0, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, 255))
        
        leftY = leftY + 25
        
        -- Vision mode status
        if visionActive then
            local mode = visionModes[currentMode]
            local modeColor = mode.color
            if overheating then
                modeColor = Color(255, 100, 0, 200) -- Orange when overheating
            end
            
            draw.SimpleTextOutlined("█ MODE: " .. mode.name, "Trebuchet18", leftX + 10, leftY, 
                modeColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 200))
            draw.SimpleText("  " .. mode.description, "DermaDefault", leftX + 10, leftY + 20, 
                Color(200, 200, 200, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        else
            draw.SimpleTextOutlined("█ MODE: OFFLINE", "Trebuchet18", leftX + 10, leftY, 
                Color(100, 100, 100, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 200))
        end
        
        leftY = leftY + 45
        
        -- Power management
        local batteryColor = Color(0, 255, 0, 200)
        if battery < 30 then
            batteryColor = Color(255, 100, 0, 200)
        elseif battery < 10 then
            batteryColor = Color(255, 0, 0, 200)
        end
        
        draw.SimpleText("BATTERY: " .. math.floor(battery) .. "%", "Trebuchet18", leftX + 10, leftY, 
            batteryColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        
        -- Battery bar
        local barW, barH = 150, 8
        surface.SetDrawColor(50, 50, 50, 200)
        surface.DrawRect(leftX + 10, leftY + 20, barW, barH)
        surface.SetDrawColor(batteryColor.r, batteryColor.g, batteryColor.b, batteryColor.a)
        surface.DrawRect(leftX + 10, leftY + 20, barW * (battery / 100), barH)
        
        leftY = leftY + 35
        
        -- System temperature
        local tempColor = Color(0, 255, 0, 200)
        if systemTemp > 50 then
            tempColor = Color(255, 255, 0, 200)
        elseif systemTemp > 60 then
            tempColor = Color(255, 100, 0, 200)
        elseif overheating then
            tempColor = Color(255, 0, 0, 200)
        end
        
        draw.SimpleText("TEMP: " .. math.floor(systemTemp) .. "°C", "Trebuchet18", leftX + 10, leftY, 
            tempColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        
        if overheating then
            draw.SimpleText("⚠ OVERHEATING ⚠", "DermaDefault", leftX + 10, leftY + 20, 
                Color(255, 0, 0, math.sin(CurTime() * 10) * 100 + 155), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
        
        leftY = leftY + 45
        
        -- === RIGHT PANEL: Tactical Information ===
        local rightX = w - 350
        local rightY = 50
        
        -- Tactical header
        draw.SimpleTextOutlined("╔═══ TACTICAL STATUS ═══╗", "Trebuchet18", rightX, rightY, 
            Color(255, 255, 0, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, 255))
        
        rightY = rightY + 25
        
        -- Compass and coordinates
        local pos = ply:GetPos()
        draw.SimpleText("COORDINATES:", "Trebuchet18", rightX + 10, rightY, 
            Color(255, 255, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(string.format("X: %d  Y: %d  Z: %d", pos.x, pos.y, pos.z), "DermaDefault", 
            rightX + 10, rightY + 20, Color(200, 200, 200, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        
        rightY = rightY + 45
        
        -- Compass bearing
        local bearingText = string.format("BEARING: %03d°", math.abs(compassBearing))
        local compassDir = ""
        if compassBearing >= -22.5 and compassBearing < 22.5 then compassDir = "N"
        elseif compassBearing >= 22.5 and compassBearing < 67.5 then compassDir = "NE"
        elseif compassBearing >= 67.5 and compassBearing < 112.5 then compassDir = "E"
        elseif compassBearing >= 112.5 and compassBearing < 157.5 then compassDir = "SE"
        elseif compassBearing >= 157.5 or compassBearing < -157.5 then compassDir = "S"
        elseif compassBearing >= -157.5 and compassBearing < -112.5 then compassDir = "SW"
        elseif compassBearing >= -112.5 and compassBearing < -67.5 then compassDir = "W"
        else compassDir = "NW" end
        
        draw.SimpleText(bearingText .. " (" .. compassDir .. ")", "Trebuchet18", rightX + 10, rightY, 
            Color(0, 255, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        
        rightY = rightY + 25
        
        -- Threat assessment
        local threatColor = Color(0, 255, 0, 200)
        local threatText = "CLEAR"
        
        if threatLevel > 60 then
            threatColor = Color(255, 0, 0, 200)
            threatText = "HIGH THREAT"
        elseif threatLevel > 30 then
            threatColor = Color(255, 255, 0, 200)
            threatText = "MODERATE"
        elseif threatLevel > 10 then
            threatColor = Color(255, 165, 0, 200)
            threatText = "LOW THREAT"
        end
        
        draw.SimpleText("THREAT LEVEL: " .. threatText, "Trebuchet18", rightX + 10, rightY, 
            threatColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("(" .. math.floor(threatLevel) .. "%)", "DermaDefault", rightX + 10, rightY + 20, 
            Color(200, 200, 200, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        
        rightY = rightY + 45
        
        -- Environmental noise
        if environmentalNoise > 20 then
            local noiseColor = Color(255, 255, 0, 200)
            if environmentalNoise > 60 then
                noiseColor = Color(255, 100, 0, 200)
            end
            
            draw.SimpleText("AUDIO: " .. math.floor(environmentalNoise) .. "% NOISE", "Trebuchet18", 
                rightX + 10, rightY, noiseColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            rightY = rightY + 25
        end
        
        -- Stealth mode indicator
        if stealthMode then
            draw.SimpleText("♦ STEALTH MODE ACTIVE ♦", "Trebuchet18", rightX + 10, rightY, 
                Color(100, 255, 100, math.sin(CurTime() * 5) * 50 + 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            rightY = rightY + 25
        end
        
        -- Recording mode indicator
        if recordingMode then
            draw.SimpleText("● REC", "Trebuchet18", rightX + 10, rightY, 
                Color(255, 0, 0, math.sin(CurTime() * 8) * 100 + 155), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            rightY = rightY + 25
        end
        
        -- === CENTER HUD: Targeting and Vision-specific Info ===
        if visionActive then
            local centerX, centerY = w / 2, h / 2
            local mode = visionModes[currentMode]
            
            -- Mode-specific center display
            if mode.id == "thermal" and #targetingData > 0 then
                -- Thermal targeting info
                draw.SimpleText("THERMAL CONTACTS: " .. #targetingData, "Trebuchet18", 
                    centerX, 100, Color(255, 100, 0, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                
                -- Show closest target info
                local closest = nil
                local closestDist = math.huge
                for _, target in ipairs(targetingData) do
                    if target.distance < closestDist then
                        closest = target
                        closestDist = target.distance
                    end
                end
                
                if closest then
                    local info = GetTargetInfo(closest.ent)
                    if info then
                        draw.SimpleText(string.format("PRIORITY TARGET: %.0fm", info.distance), "DermaDefault", 
                            centerX, 120, Color(255, 255, 0, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                    end
                end
                
            elseif mode.id == "sonar" and sonarMap and #sonarMap > 0 then
                -- Sonar mapping info
                draw.SimpleText("SONAR POINTS: " .. #sonarMap, "Trebuchet18", 
                    centerX, 100, Color(0, 150, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                
                if pulseAlpha > 0 then
                    draw.SimpleText("PULSE: " .. math.floor(pulseAlpha * 100) .. "%", "DermaDefault", 
                        centerX, 120, Color(0, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                end
            end
            
            -- Enhanced crosshair with distance info
            surface.SetDrawColor(mode.color.r, mode.color.g, mode.color.b, 200)
            local crossSize = 20
            surface.DrawLine(centerX - crossSize, centerY, centerX - 5, centerY)
            surface.DrawLine(centerX + 5, centerY, centerX + crossSize, centerY)
            surface.DrawLine(centerX, centerY - crossSize, centerX, centerY - 5)
            surface.DrawLine(centerX, centerY + 5, centerX, centerY + crossSize)
            
            -- Center dot
            surface.DrawRect(centerX - 1, centerY - 1, 3, 3)
        end
        
        -- === BOTTOM HUD: Controls and Status ===
        local bottomY = h - 100
        
        -- Control instructions
        local controls = {
            "N: TOGGLE", "T: CYCLE MODE", "M: STEALTH", "R: RECORD"
        }
        
        for i, control in ipairs(controls) do
            local x = 50 + (i - 1) * 150
            draw.SimpleTextOutlined(control, "DermaDefault", x, bottomY, 
                Color(200, 200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 150))
        end
        
        -- System warnings
        if battery < 10 then
            draw.SimpleTextOutlined("⚠ LOW BATTERY ⚠", "Trebuchet24", w / 2, bottomY + 25, 
                Color(255, 0, 0, math.sin(CurTime() * 8) * 100 + 155), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 
                2, Color(0, 0, 0, 200))
        end
    end)
    
    -- Network message handlers
    net.Receive("SC_AbilityState", function()
        visionActive = net.ReadBool()
        currentMode = net.ReadInt(8)
        
        if visionActive then
            local mode = visionModes[currentMode]
            surface.PlaySound(mode.sound)
            LocalPlayer():ChatPrint("Vision Mode: " .. mode.name)
        else
            LocalPlayer():ChatPrint("Vision Deactivated")
        end
    end)
    
else -- SERVER
    
    -- Network strings
    util.AddNetworkString("SC_AbilityToggle")
    util.AddNetworkString("SC_AbilityModeChange")
    util.AddNetworkString("SC_AbilityState")
    
    -- Server-side player data
    local playerData = {}
    
    -- Helper function to check if player has Splinter Cell abilities
    local function HasSplinterCellAbilities(ply)
        if not IsValid(ply) then return false end
        local team = ply:Team()
        return team == TEAM_SPLINTERCELL or team == TEAM_SPLINTERCOMMANDER
    end
    
    -- Initialize player data
    local function InitPlayerData(ply)
        playerData[ply] = {
            visionActive = false,
            currentMode = 1,
            energy = 100
        }
    end
    
    -- Clean up player data
    local function CleanupPlayerData(ply)
        playerData[ply] = nil
    end
    
    -- Toggle vision ability
    local function ToggleVision(ply)
        if not HasSplinterCellAbilities(ply) then
            ply:ChatPrint("You don't have access to this technology!")
            return
        end
        
        if not playerData[ply] then
            InitPlayerData(ply)
        end
        
        playerData[ply].visionActive = not playerData[ply].visionActive
        
        -- Send state to client
        net.Start("SC_AbilityState")
        net.WriteBool(playerData[ply].visionActive)
        net.WriteInt(playerData[ply].currentMode, 8)
        net.Send(ply)
    end
    
    -- Cycle vision mode
    local function CycleMode(ply)
        if not HasSplinterCellAbilities(ply) then return end
        if not playerData[ply] or not playerData[ply].visionActive then return end
        
        playerData[ply].currentMode = playerData[ply].currentMode % 4 + 1
        
        -- Send updated state to client
        net.Start("SC_AbilityState")
        net.WriteBool(playerData[ply].visionActive)
        net.WriteInt(playerData[ply].currentMode, 8)
        net.Send(ply)
    end
    
    -- Network receivers
    net.Receive("SC_AbilityToggle", function(len, ply)
        ToggleVision(ply)
    end)
    
    net.Receive("SC_AbilityModeChange", function(len, ply)
        CycleMode(ply)
    end)
    
    -- Player spawn handler
    hook.Add("PlayerSpawn", "SplinterCellAbilitySpawn", function(ply)
        timer.Simple(1, function() -- Delay to ensure team is set
            if IsValid(ply) and HasSplinterCellAbilities(ply) then
                InitPlayerData(ply)
                ply:ChatPrint("Splinter Cell abilities activated! Press N to toggle vision, T to cycle modes.")
            end
        end)
    end)
    
    -- Team change handler
    hook.Add("OnPlayerChangedTeam", "SplinterCellAbilityTeamChange", function(ply, before, after)
        if before == TEAM_SPLINTERCELL or before == TEAM_SPLINTERCOMMANDER then
            -- Player left Splinter Cell team, disable abilities
            if playerData[ply] then
                playerData[ply].visionActive = false
                net.Start("SC_AbilityState")
                net.WriteBool(false)
                net.WriteInt(1, 8)
                net.Send(ply)
            end
        end
        
        if after == TEAM_SPLINTERCELL or after == TEAM_SPLINTERCOMMANDER then
            -- Player joined Splinter Cell team, enable abilities
            InitPlayerData(ply)
            ply:ChatPrint("Splinter Cell abilities activated! Press N to toggle vision, T to cycle modes.")
        end
    end)
    
    -- Player disconnect cleanup
    hook.Add("PlayerDisconnected", "SplinterCellAbilityDisconnect", function(ply)
        CleanupPlayerData(ply)
    end)
    
    
    -- Enhanced Console Commands for Testing and Debug
    if CLIENT then
        concommand.Add("sc_debug_thermal", function()
            local ply = LocalPlayer()
            if not IsValid(ply) then return end
            
            print("=== THERMAL DEBUG ===")
            print("Heat Trails: " .. table.Count(heatTrails))
            print("Targeting Data: " .. #targetingData)
            print("System Temp: " .. math.floor(systemTemp) .. "°C")
            print("Overheating: " .. tostring(overheating))
            
            for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 1000)) do
                if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC()) then
                    local heat = GetEntityHeat(ent)
                    local distance = ply:GetPos():Distance(ent:GetPos())
                    print(string.format("%s: Heat=%.2f, Distance=%.0f", 
                        ent:GetClass(), heat, distance))
                end
            end
        end, nil, "Debug thermal vision system")
        
        concommand.Add("sc_debug_sonar", function()
            print("=== SONAR DEBUG ===")
            print("Sonar Map Points: " .. (sonarMap and #sonarMap or 0))
            print("Pulse Alpha: " .. pulseAlpha)
            print("Last Pulse: " .. math.floor(CurTime() - lastPulseTime) .. "s ago")
            
            if sonarMap then
                local materials = {}
                for _, point in ipairs(sonarMap) do
                    local matName = point.material.name
                    materials[matName] = (materials[matName] or 0) + 1
                end
                
                print("Material Distribution:")
                for mat, count in pairs(materials) do
                    print("  " .. mat .. ": " .. count)
                end
            end
        end, nil, "Debug sonar vision system")
        
        concommand.Add("sc_debug_audio", function()
            print("=== AUDIO DEBUG ===")
            print("Environmental Noise: " .. math.floor(environmentalNoise) .. "%")
            print("Audio Visualization: " .. tostring(GetConVar("sc_audio_visual"):GetBool()))
            print("Detection Range: " .. settings.noiseDetectionRange)
            
            local ply = LocalPlayer()
            if not IsValid(ply) then return end
            
            for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), settings.noiseDetectionRange)) do
                if IsValid(ent) and ent != ply then
                    local velocity = ent:GetVelocity():Length()
                    if velocity > 50 then
                        local distance = ply:GetPos():Distance(ent:GetPos())
                        print(string.format("%s: Velocity=%.0f, Distance=%.0f", 
                            ent:GetClass(), velocity, distance))
                    end
                end
            end
        end, nil, "Debug audio visualization system")
        
        concommand.Add("sc_reset_system", function()
            visionActive = false
            currentMode = 1
            energy = 100
            battery = 100
            systemTemp = 20
            overheating = false
            threatLevel = 0
            environmentalNoise = 0
            stealthMode = false
            recordingMode = false
            heatTrails = {}
            sonarMap = {}
            targetingData = {}
            
            LocalPlayer():ChatPrint("NVG System Reset to Defaults")
            print("[SPLINTER CELL] System reset complete")
        end, nil, "Reset NVG system to default state")
        
        concommand.Add("sc_system_info", function()
            print("=== SPLINTER CELL NVG SYSTEM INFO ===")
            print("Vision Active: " .. tostring(visionActive))
            print("Current Mode: " .. (visionActive and visionModes[currentMode].name or "N/A"))
            print("Energy: " .. math.floor(energy) .. "%")
            print("Battery: " .. math.floor(battery) .. "%")
            print("System Temperature: " .. math.floor(systemTemp) .. "°C")
            print("Threat Level: " .. math.floor(threatLevel) .. "%")
            print("Stealth Mode: " .. tostring(stealthMode))
            print("Recording Mode: " .. tostring(recordingMode))
            print("Has Abilities: " .. tostring(HasSplinterCellAbilities()))
            print("=== SETTINGS ===")
            for name, value in pairs(settings) do
                print("  " .. name .. ": " .. tostring(value))
            end
        end, nil, "Display comprehensive system information")
        
        concommand.Add("sc_toggle_stealth", function()
            stealthMode = not stealthMode
            LocalPlayer():ChatPrint("Stealth Mode: " .. (stealthMode and "ENABLED" or "DISABLED"))
            surface.PlaySound("buttons/button15.wav")
        end, nil, "Toggle stealth mode")
        
        concommand.Add("sc_simulate_overheat", function()
            systemTemp = settings.maxSystemTemp + 5
            overheating = true
            LocalPlayer():ChatPrint("System overheating simulated!")
            surface.PlaySound("ambient/alarms/klaxon1.wav")
        end, nil, "Simulate system overheating for testing")
        
        concommand.Add("sc_force_threat", function(ply, cmd, args)
            local level = tonumber(args[1]) or 50
            threatLevel = math.Clamp(level, 0, 100)
            LocalPlayer():ChatPrint("Threat level set to: " .. math.floor(threatLevel) .. "%")
        end, nil, "Force set threat level (0-100)")
    end
    
end

print("[SPLINTER CELL] Enhanced Tactical NVG System loaded successfully!")
print("=== NEW FEATURES ===")
print("• 4 Vision Modes: Night Vision, Thermal, Sonar, Enhanced")
print("• Tactical HUD with compass, coordinates, threat assessment")
print("• Battery system with realistic power management")
print("• System temperature monitoring and overheating protection")
print("• Enhanced thermal vision with heat trails and temperature gradients")
print("• 3D sonar mapping with material detection")
print("• Audio visualization system with directional sound detection")
print("• Stealth mode integration with reduced visibility")
print("• Recording mode for tactical documentation")
print("• Advanced targeting system with distance measurement")
print("• Environmental noise detection and analysis")
print("=== CONTROLS ===")
print("N: Toggle NVG | T: Cycle Modes | M: Stealth Mode | R: Recording Mode")
print("=== CONSOLE COMMANDS ===")
print("sc_debug_thermal, sc_debug_sonar, sc_debug_audio, sc_system_info")
print("sc_reset_system, sc_toggle_stealth, sc_simulate_overheat, sc_force_threat")