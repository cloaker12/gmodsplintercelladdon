AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Networking for client-side effects
util.AddNetworkString("SplinterCellWhisper")
util.AddNetworkString("SplinterCellFlash")
util.AddNetworkString("SplinterCellFlashEffect")
util.AddNetworkString("SplinterCellSmokeDeploy")
util.AddNetworkString("SplinterCellWallClimb")
util.AddNetworkString("SplinterCellNightVision")
util.AddNetworkString("SplinterCellCombatUpdate")

-- Handle whisper messages
net.Receive("SplinterCellWhisper", function(len, ply)
    local message = net.ReadString()
    if IsValid(ply) then
        -- Send whisper to player
        ply:PrintMessage(HUD_PRINTTALK, "[Whisper] " .. message)
    end
end)

-- Handle flash effects
net.Receive("SplinterCellFlash", function(len, ply)
    local flashPos = net.ReadVector()
    if IsValid(ply) then
        -- Send flash effect to player
        net.Start("SplinterCellFlashEffect")
        net.WriteVector(flashPos)
        net.Send(ply)
    end
end)

-- Handle smoke deployment effects
net.Receive("SplinterCellSmokeDeploy", function(len, ply)
    local smokePos = net.ReadVector()
    local smokeRadius = net.ReadFloat()
    if IsValid(ply) then
        -- Create smoke effect for player
        local effect = EffectData()
        effect:SetOrigin(smokePos)
        effect:SetScale(smokeRadius / 100)
        util.Effect("smoke", effect)
    end
end)

-- Handle wall climbing effects
net.Receive("SplinterCellWallClimb", function(len, ply)
    local climbPos = net.ReadVector()
    local isClimbing = net.ReadBool()
    if IsValid(ply) then
        -- Create climbing effect for player
        if isClimbing then
            local effect = EffectData()
            effect:SetOrigin(climbPos)
            effect:SetScale(1)
            util.Effect("cball_bounce", effect)
        end
    end
end)

-- Handle night vision effects
net.Receive("SplinterCellNightVision", function(len, ply)
    local nvPos = net.ReadVector()
    local isActive = net.ReadBool()
    if IsValid(ply) then
        -- Create night vision effect for player
        if isActive then
            local effect = EffectData()
            effect:SetOrigin(nvPos)
            effect:SetScale(0.5)
            util.Effect("cball_bounce", effect)
        end
    end
end)

-- Splinter Cell NextBot - Advanced Tactical AI
-- Uses proper NextBot framework

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

-- Tactical AI Configuration
local TACTICAL_CONFIG = {
    STEALTH_RADIUS = 800,           -- Detection radius for stealth operations
    ENGAGEMENT_RANGE = 400,         -- Optimal engagement distance
    TAKEDOWN_RANGE = 100,          -- Range for silent takedowns
    RETREAT_HEALTH = 50,            -- Health threshold to trigger retreat
    SHADOW_PREFERENCE = 0.8,        -- Preference for dark areas (0-1)
    PATIENCE_TIMER = 5,             -- Seconds to wait before changing tactics
    SMOKE_COOLDOWN = 8,             -- Reduced cooldown for tactical smoke usage
    LIGHT_DISABLE_RANGE = 300,      -- Range to disable light sources
    WHISPER_RADIUS = 200,           -- Range for psychological operations
    FLASH_RANGE = 150,              -- Range for flashbang effects
    WEAPON_RANGE = 500,             -- Maximum effective weapon range
    ACCURACY_DECAY = 0.1,           -- Accuracy decay per shot
    RECOVERY_TIME = 2.0,            -- Time to recover accuracy
    
    -- New Navigation and Evasion
    NAVIGATION_UPDATE_RATE = 0.2,   -- How often to update navigation
    EVASION_RADIUS = 600,           -- Radius to detect threats for evasion
    WALL_CLIMB_HEIGHT = 200,        -- Maximum height for wall climbing
    WALL_CLIMB_SPEED = 150,         -- Speed when climbing walls
    NIGHT_VISION_RANGE = 1000,      -- Enhanced vision range in darkness
    NIGHT_VISION_ACTIVE = true,     -- Night vision always active
    
    -- Enhanced Smoke Grenade System
    SMOKE_DURATION = 15,            -- How long smoke lasts
    SMOKE_RADIUS = 300,             -- Radius of smoke effect
    SMOKE_TACTICAL_USES = {         -- Different tactical uses for smoke
        "cover_retreat",
        "block_line_of_sight", 
        "create_distraction",
        "mask_movement",
        "force_reposition"
    },
    
    -- Improved Combat Mechanics
    COMBAT_ACCURACY_BASE = 0.85,    -- Base accuracy in combat
    COMBAT_ACCURACY_MOVING = 0.6,   -- Accuracy while moving
    COMBAT_ACCURACY_COVER = 0.95,   -- Accuracy from cover
    BURST_FIRE_COUNT = 3,           -- Number of shots in burst fire
    BURST_FIRE_DELAY = 0.1,         -- Delay between burst shots
    COMBAT_STANCE_CHANGES = true,   -- Dynamic stance changes in combat
    TACTICAL_RELOAD = true,         -- Tactical reload system
    GRENADE_USAGE = true,           -- Enable grenade usage
    GRENADE_COOLDOWN = 20,          -- Cooldown between grenade uses
}

-- AI States
local AI_STATES = {
    IDLE_RECON = 1,        -- Patrolling and gathering intel
    INVESTIGATE = 2,       -- Moving toward sound/light sources
    STALKING = 3,          -- Tracking target from cover
    AMBUSH = 4,            -- Executing silent takedown
    ENGAGE_SUPPRESSED = 5, -- Firing from cover
    RETREAT_RESET = 6,     -- Breaking contact and repositioning
    WALL_CLIMBING = 7,     -- Climbing walls for tactical advantage
    EVASIVE_MANEUVER = 8,  -- Performing evasive movements
    TACTICAL_SMOKE = 9,    -- Using smoke grenades tactically
    NIGHT_VISION_HUNT = 10 -- Enhanced hunting with night vision
}

function ENT:Initialize()
    self:SetModel("models/splinter_cell_3/player/Sam_E.mdl")
    self:SetHealth(200)
    self:SetMaxHealth(200)
    self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 72))
    
    -- Set bodygroup for goggles
    self:SetBodygroup(1, 1) -- Goggles bodygroup
    
    -- Initialize weapon
    self.weaponModel = "models/weapons/w_fiveseven_ct.mdl"
    self.weaponEntity = nil
    self.lastShotTime = 0
    self.shotCooldown = 0.5
    self.accuracy = 1.0
    self.lastAccuracyUpdate = CurTime()
    
    -- Initialize tactical variables
    self.tacticalState = AI_STATES.IDLE_RECON
    self.targetPlayer = nil
    self.lastKnownPosition = Vector(0, 0, 0)
    self.lastStateChange = CurTime()
    self.smokeLastUsed = 0
    self.stealthLevel = 1.0  -- 1.0 = fully stealth, 0.0 = compromised
    self.patienceTimer = 0
    self.currentObjective = "patrol"
    self.currentPath = nil
    self.targetPosition = nil
    
    -- Enhanced Navigation and Evasion
    self.navigationUpdateTimer = 0
    self.lastNavigationUpdate = CurTime()
    self.evasionTargets = {}
    self.wallClimbTarget = nil
    self.isClimbing = false
    self.climbStartPos = Vector(0, 0, 0)
    self.climbEndPos = Vector(0, 0, 0)
    self.climbProgress = 0
    
    -- Night Vision System
    self.nightVisionActive = TACTICAL_CONFIG.NIGHT_VISION_ACTIVE
    self.nightVisionRange = TACTICAL_CONFIG.NIGHT_VISION_RANGE
    self.lastNightVisionUpdate = CurTime()
    
    -- Enhanced Smoke Grenade System
    self.smokeGrenades = 3  -- Number of smoke grenades available
    self.activeSmokeEffects = {}
    self.smokeTacticalUse = "cover_retreat"
    self.lastSmokeTacticalChange = CurTime()
    
    -- Improved Combat Mechanics
    self.combatAccuracy = TACTICAL_CONFIG.COMBAT_ACCURACY_BASE
    self.isInCover = false
    self.coverPosition = Vector(0, 0, 0)
    self.burstFireCount = 0
    self.lastBurstShot = 0
    self.combatStance = "standing"  -- standing, crouching, prone
    self.ammoCount = 30
    self.maxAmmo = 30
    self.isReloading = false
    self.lastReloadTime = 0
    self.grenadeLastUsed = 0
    self.grenadesAvailable = 2
    
    -- Animation variables
    self.currentAnimation = "idle"
    self.animationStartTime = CurTime()
    self.isMoving = false
    self.lastMoveTime = 0
    
    -- Network variables for client display
    self:SetNWInt("tacticalState", self.tacticalState)
    self:SetNWFloat("stealthLevel", self.stealthLevel)
    self:SetNWString("currentObjective", self.currentObjective)
    self:SetNWString("currentAnimation", self.currentAnimation)
    self:SetNWBool("nightVisionActive", self.nightVisionActive)
    self:SetNWInt("smokeGrenades", self.smokeGrenades)
    self:SetNWInt("ammoCount", self.ammoCount)
    self:SetNWInt("grenadesAvailable", self.grenadesAvailable)
    self:SetNWBool("isClimbing", self.isClimbing)
    self:SetNWString("combatStance", self.combatStance)
    self:SetNWBool("isInCover", self.isInCover)
    
    -- DRGBase integration
    if DRGBase then
        self:SetNWString("DRGBase_DisplayName", "Splinter Cell Operative")
        self:SetNWString("DRGBase_Description", "Advanced tactical AI specializing in stealth operations")
    end
    
    -- Set up AI behavior
    self:SetupTacticalAI()
    
    -- Create weapon entity
    self:CreateWeapon()
    
    -- Network the weapon entity
    self:SetNWEntity("weaponEntity", self.weaponEntity)
end

-- Weapon functions
function ENT:CreateWeapon()
    -- Create weapon entity
    local weapon = ents.Create("prop_dynamic")
    if IsValid(weapon) then
        weapon:SetModel(self.weaponModel)
        weapon:SetParent(self)
        weapon:SetLocalPos(Vector(0, 0, 0))
        weapon:SetLocalAngles(Angle(0, 0, 0))
        weapon:SetNoDraw(false)
        weapon:DrawShadow(false)
        weapon:Spawn()
        
        self.weaponEntity = weapon
    end
end

function ENT:UpdateWeaponPosition()
    if not IsValid(self.weaponEntity) then return end
    
    local weaponPos = Vector(0, 0, 0)
    local weaponAng = Angle(0, 0, 0)
    
    -- Adjust weapon position based on animation state
    if self.currentAnimation == "walk" then
        weaponPos = Vector(5, -10, -5)
        weaponAng = Angle(0, -10, 0)
    elseif self.currentAnimation == "idle" then
        weaponPos = Vector(5, -8, -3)
        weaponAng = Angle(0, -5, 0)
    elseif self.currentAnimation == "aim" then
        weaponPos = Vector(8, -12, -2)
        weaponAng = Angle(0, -15, 0)
    end
    
    self.weaponEntity:SetLocalPos(weaponPos)
    self.weaponEntity:SetLocalAngles(weaponAng)
end

-- Animation functions
function ENT:PlayAnimation(animationName)
    if self.currentAnimation == animationName then return end
    
    self.currentAnimation = animationName
    self.animationStartTime = CurTime()
    
    -- Set the appropriate sequence based on animation name
    local sequence = self:LookupSequence(animationName)
    if sequence and sequence > 0 then
        self:SetSequence(sequence)
    else
        -- Fallback sequences for common animations
        if animationName == "idle" then
            self:SetSequence(self:LookupSequence("idle") or 0)
        elseif animationName == "walk" then
            self:SetSequence(self:LookupSequence("walk") or self:LookupSequence("run") or 0)
        elseif animationName == "aim" then
            self:SetSequence(self:LookupSequence("gesture_range_attack") or 0)
        end
    end
    
    -- Update networked variable
    self:SetNWString("currentAnimation", self.currentAnimation)
end

function ENT:UpdateAnimation()
    local velocity = self:GetVelocity():Length()
    local currentTime = CurTime()
    
    -- Determine if we're moving
    local wasMoving = self.isMoving
    self.isMoving = velocity > 10
    
    -- Update animation based on movement
    if self.isMoving then
        if not wasMoving or self.currentAnimation ~= "walk" then
            self:PlayAnimation("walk")
        end
        self.lastMoveTime = currentTime
    else
        -- Check if we should switch to idle
        if wasMoving or self.currentAnimation ~= "idle" then
            -- Small delay before switching to idle to prevent animation flickering
            if currentTime - self.lastMoveTime > 0.1 then
                self:PlayAnimation("idle")
            end
        end
    end
    
    -- Update weapon position
    self:UpdateWeaponPosition()
end

function ENT:SetupTacticalAI()
    -- Initialize tactical priorities
    self.tacticalPriorities = {
        "maintain_stealth",
        "control_environment", 
        "isolate_targets",
        "execute_ambush",
        "tactical_retreat"
    }
    
    -- Initialize environment control
    self.lightSources = {}
    self.coverPositions = {}
    self.escapeRoutes = {}
    
    -- Start AI cycle
    self:StartAICycle()
end

function ENT:StartAICycle()
    timer.Create("SplinterCellAI_" .. self:EntIndex(), 0.1, 0, function()
        if IsValid(self) then
            self:ExecuteTacticalAI()
        end
    end)
end

function ENT:ExecuteTacticalAI()
    -- Update tactical state based on current conditions
    self:UpdateTacticalState()
    
    -- Update animations
    self:UpdateAnimation()
    
    -- Execute current state behavior
    if self.tacticalState == AI_STATES.IDLE_RECON then
        self:ExecuteIdleRecon()
    elseif self.tacticalState == AI_STATES.INVESTIGATE then
        self:ExecuteInvestigate()
    elseif self.tacticalState == AI_STATES.STALKING then
        self:ExecuteStalking()
    elseif self.tacticalState == AI_STATES.AMBUSH then
        self:ExecuteAmbush()
    elseif self.tacticalState == AI_STATES.ENGAGE_SUPPRESSED then
        self:ExecuteEngageSuppressed()
    elseif self.tacticalState == AI_STATES.RETREAT_RESET then
        self:ExecuteRetreatReset()
    elseif self.tacticalState == AI_STATES.WALL_CLIMBING then
        self:ExecuteWallClimbing()
    elseif self.tacticalState == AI_STATES.EVASIVE_MANEUVER then
        self:ExecuteEvasiveManeuver()
    elseif self.tacticalState == AI_STATES.TACTICAL_SMOKE then
        self:ExecuteTacticalSmoke()
    elseif self.tacticalState == AI_STATES.NIGHT_VISION_HUNT then
        self:ExecuteNightVisionHunt()
    end
    
    -- Execute environment control
    self:ControlEnvironment()
    
    -- Execute psychological operations
    self:ExecutePsychologicalOps()
    
    -- Execute enhanced navigation and evasion
    self:ExecuteEnhancedNavigation()
    
    -- Execute night vision system
    self:ExecuteNightVisionSystem()
    
    -- Execute enhanced combat mechanics
    self:ExecuteEnhancedCombatMechanics()
    
    -- Update networked variables
    self:SetNWInt("tacticalState", self.tacticalState)
    self:SetNWFloat("stealthLevel", self.stealthLevel)
    self:SetNWString("currentObjective", self.currentObjective)
    self:SetNWBool("nightVisionActive", self.nightVisionActive)
    self:SetNWInt("smokeGrenades", self.smokeGrenades)
    self:SetNWInt("ammoCount", self.ammoCount)
    self:SetNWInt("grenadesAvailable", self.grenadesAvailable)
    self:SetNWBool("isClimbing", self.isClimbing)
    self:SetNWString("combatStance", self.combatStance)
    self:SetNWBool("isInCover", self.isInCover)
end

function ENT:UpdateTacticalState()
    local currentTime = CurTime()
    
    -- Check for state transition conditions
    if self.tacticalState == AI_STATES.IDLE_RECON then
        if self:DetectPlayerActivity() then
            self:ChangeState(AI_STATES.INVESTIGATE)
        end
    elseif self.tacticalState == AI_STATES.INVESTIGATE then
        if self:HasVisualContact() then
            self:ChangeState(AI_STATES.STALKING)
        elseif currentTime - self.lastStateChange > TACTICAL_CONFIG.PATIENCE_TIMER then
            self:ChangeState(AI_STATES.IDLE_RECON)
        end
    elseif self.tacticalState == AI_STATES.STALKING then
        if self:CanExecuteTakedown() then
            self:ChangeState(AI_STATES.AMBUSH)
        elseif self:IsCompromised() then
            self:ChangeState(AI_STATES.ENGAGE_SUPPRESSED)
        end
    elseif self.tacticalState == AI_STATES.AMBUSH then
        if self:IsTakedownComplete() then
            self:ChangeState(AI_STATES.RETREAT_RESET)
        end
    elseif self.tacticalState == AI_STATES.ENGAGE_SUPPRESSED then
        if self:ShouldRetreat() then
            self:ChangeState(AI_STATES.RETREAT_RESET)
        end
    elseif self.tacticalState == AI_STATES.RETREAT_RESET then
        if self:IsSafeToReset() then
            self:ChangeState(AI_STATES.IDLE_RECON)
        end
    elseif self.tacticalState == AI_STATES.WALL_CLIMBING then
        if not self.isClimbing then
            self:ChangeState(AI_STATES.IDLE_RECON)
        end
    elseif self.tacticalState == AI_STATES.EVASIVE_MANEUVER then
        if #self.evasionTargets == 0 then
            self:ChangeState(AI_STATES.IDLE_RECON)
        end
    elseif self.tacticalState == AI_STATES.TACTICAL_SMOKE then
        if self.smokeGrenades <= 0 then
            self:ChangeState(AI_STATES.ENGAGE_SUPPRESSED)
        end
    elseif self.tacticalState == AI_STATES.NIGHT_VISION_HUNT then
        if not self.nightVisionActive or not IsValid(self.targetPlayer) then
            self:ChangeState(AI_STATES.STALKING)
        end
    end
end

function ENT:ChangeState(newState)
    if self.tacticalState ~= newState then
        self.tacticalState = newState
        self.lastStateChange = CurTime()
        self:OnStateChange(newState)
    end
end

function ENT:OnStateChange(newState)
    -- Handle state-specific initialization
    if newState == AI_STATES.IDLE_RECON then
        self.currentObjective = "patrol"
        self:FindPatrolRoute()
    elseif newState == AI_STATES.INVESTIGATE then
        self.currentObjective = "investigate"
        self:MoveToLastKnownPosition()
    elseif newState == AI_STATES.STALKING then
        self.currentObjective = "stalk"
        self:FindCoverPosition()
    elseif newState == AI_STATES.AMBUSH then
        self.currentObjective = "execute_takedown"
        self:PrepareAmbush()
    elseif newState == AI_STATES.ENGAGE_SUPPRESSED then
        self.currentObjective = "suppress"
        self:FindCoverAndEngage()
    elseif newState == AI_STATES.RETREAT_RESET then
        self.currentObjective = "retreat"
        self:ExecuteTacticalRetreat()
    elseif newState == AI_STATES.WALL_CLIMBING then
        self.currentObjective = "climb_wall"
        self:PrepareWallClimb()
    elseif newState == AI_STATES.EVASIVE_MANEUVER then
        self.currentObjective = "evade_threats"
        self:PrepareEvasiveManeuver()
    elseif newState == AI_STATES.TACTICAL_SMOKE then
        self.currentObjective = "deploy_smoke"
        self:PrepareTacticalSmoke()
    elseif newState == AI_STATES.NIGHT_VISION_HUNT then
        self.currentObjective = "night_hunt"
        self:PrepareNightVisionHunt()
    end
end

-- Movement helper functions using proper NextBot methods
function ENT:MoveToPosition(targetPos)
    if not targetPos then return end
    
    self.targetPosition = targetPos
    local path = Path("Follow")
    path:SetMinLookAheadDistance(300)
    path:SetGoalTolerance(20)
    path:Compute(self, targetPos)
    
    if not path:IsValid() then
        -- Direct movement if pathfinding fails
        self:SetLastPosition(targetPos)
        return
    end
    
    self.currentPath = path
end

function ENT:MoveToLastKnownPosition()
    if self.lastKnownPosition and self.lastKnownPosition ~= Vector(0, 0, 0) then
        self:MoveToPosition(self.lastKnownPosition)
    end
end

function ENT:FindCoverPosition()
    if IsValid(self.targetPlayer) then
        local targetPos = self.targetPlayer:GetPos()
        local coverPos = self:FindOptimalCoverPosition(targetPos)
        if coverPos then
            self:MoveToPosition(coverPos)
        end
    end
end

function ENT:PrepareAmbush()
    -- Prepare for silent takedown
    if IsValid(self.targetPlayer) then
        -- Move closer to target if needed
        local distance = self:GetPos():Distance(self.targetPlayer:GetPos())
        if distance > TACTICAL_CONFIG.TAKEDOWN_RANGE then
            self:MoveToPosition(self.targetPlayer:GetPos())
        end
    end
end

function ENT:FindCoverAndEngage()
    if IsValid(self.targetPlayer) then
        local targetPos = self.targetPlayer:GetPos()
        local coverPos = self:FindOptimalCoverPosition(targetPos)
        if coverPos then
            self:MoveToPosition(coverPos)
        end
    end
end

function ENT:ExecuteTacticalRetreat()
    -- Find escape route and move away
    local escapePos = self:FindEscapeRoute()
    if escapePos then
        self:MoveToPosition(escapePos)
    end
end

-- New State Preparation Functions
function ENT:PrepareWallClimb()
    -- Find a suitable wall to climb
    self:FindWallToClimb()
end

function ENT:PrepareEvasiveManeuver()
    -- Identify threats and prepare evasive movements
    self:IdentifyEvasionTargets()
end

function ENT:PrepareTacticalSmoke()
    -- Determine the best tactical use for smoke
    self:DetermineSmokeTacticalUse()
end

function ENT:PrepareNightVisionHunt()
    -- Activate night vision and prepare for enhanced hunting
    self:ActivateNightVision()
end

-- State Execution Functions
function ENT:ExecuteIdleRecon()
    -- Handle current path movement
    if self.currentPath and self.currentPath:IsValid() then
        self.currentPath:Update(self)
        if self.currentPath:GetAge() > 3 then
            self.currentPath:Invalidate()
            self.currentPath = nil
        end
    else
        -- Find new patrol point if not moving
        self:FindNextPatrolPoint()
    end
    
    -- Disable nearby light sources
    self:DisableNearbyLights()
    
    -- Listen for player activity (handled in UpdateTacticalState)
end

function ENT:IsTakedownComplete()
    -- Check if takedown animation is finished
    return not self:IsMoving() and self.targetPlayer == nil
end

function ENT:ExecuteInvestigate()
    -- Handle current path movement
    if self.currentPath and self.currentPath:IsValid() then
        self.currentPath:Update(self)
    else
        -- Move to last known position if no path
        if self.lastKnownPosition and self:GetPos():Distance(self.lastKnownPosition) > 50 then
            self:MoveToPosition(self.lastKnownPosition)
        else
            -- Search the area
            self:SearchArea()
        end
    end
end

function ENT:ExecuteStalking()
    -- Track target while maintaining cover
    if IsValid(self.targetPlayer) then
        local targetPos = self.targetPlayer:GetPos()
        local coverPos = self:FindOptimalCoverPosition(targetPos)
        
        if coverPos then
            self:MoveToPosition(coverPos)
        end
        
        -- Maintain stealth level
        self:MaintainStealth()
    end
end

function ENT:ExecuteAmbush()
    -- Execute silent takedown
    if IsValid(self.targetPlayer) and self:CanExecuteTakedown() then
        self:PerformSilentTakedown()
    end
end

function ENT:ExecuteEngageSuppressed()
    -- Fire from cover with suppressed weapon
    if IsValid(self.targetPlayer) then
        self:FireSuppressedShot()
    end
end

function ENT:ExecuteRetreatReset()
    -- Handle path movement for retreat
    if self.currentPath and self.currentPath:IsValid() then
        self.currentPath:Update(self)
    end
    
    -- Deploy smoke and break contact
    if CurTime() - self.smokeLastUsed > TACTICAL_CONFIG.SMOKE_COOLDOWN then
        self:DeploySmoke()
    end
end

-- New State Execution Functions
function ENT:ExecuteWallClimbing()
    if self.isClimbing then
        -- Continue climbing animation and movement
        self:UpdateWallClimb()
    else
        -- Start climbing if we have a target
        if self.wallClimbTarget then
            self:StartWallClimb()
        else
            -- Find a wall to climb
            self:FindWallToClimb()
        end
    end
end

function ENT:ExecuteEvasiveManeuver()
    -- Perform evasive movements to avoid threats
    if #self.evasionTargets > 0 then
        self:PerformEvasiveMovement()
    else
        -- No immediate threats, return to normal behavior
        self:ChangeState(AI_STATES.IDLE_RECON)
    end
end

function ENT:ExecuteTacticalSmoke()
    -- Use smoke grenades for tactical advantage
    if self.smokeGrenades > 0 then
        self:DeployTacticalSmoke()
    else
        -- No smoke grenades available, return to previous state
        self:ChangeState(AI_STATES.ENGAGE_SUPPRESSED)
    end
end

function ENT:ExecuteNightVisionHunt()
    -- Enhanced hunting with night vision capabilities
    if self.nightVisionActive then
        self:PerformNightVisionHunt()
    else
        -- Night vision not available, use normal hunting
        self:ChangeState(AI_STATES.STALKING)
    end
end

-- Tactical Functions
function ENT:ControlEnvironment()
    -- Disable light sources to create shadows
    self:DisableNearbyLights()
    
    -- Create sound distractions
    if math.random() < 0.01 then
        self:CreateSoundDistraction()
    end
    
    -- Manipulate props for tactical advantage
    self:ManipulateProps()
end

function ENT:ExecutePsychologicalOps()
    -- Whisper to nearby players
    if math.random() < 0.005 then
        self:WhisperToPlayers()
    end
    
    -- Flash goggles effect
    if math.random() < 0.003 then
        self:FlashGoggles()
    end
end

-- Detection and Awareness
function ENT:DetectPlayerActivity()
    local players = player.GetAll()
    for _, player in pairs(players) do
        if IsValid(player) and player:Alive() then
            local distance = self:GetPos():Distance(player:GetPos())
            if distance < TACTICAL_CONFIG.STEALTH_RADIUS then
                -- Check if player is making noise
                if self:IsPlayerMakingNoise(player) then
                    self.targetPlayer = player
                    self.lastKnownPosition = player:GetPos()
                    return true
                end
                
                -- Check for visual contact
                if self:HasVisualContact() and distance < TACTICAL_CONFIG.STEALTH_RADIUS * 0.7 then
                    self.targetPlayer = player
                    self.lastKnownPosition = player:GetPos()
                    return true
                end
                
                -- Check for flashlight usage
                if player:FlashlightIsOn() and distance < TACTICAL_CONFIG.STEALTH_RADIUS * 0.5 then
                    self.targetPlayer = player
                    self.lastKnownPosition = player:GetPos()
                    return true
                end
            end
        end
    end
    return false
end

function ENT:HasVisualContact()
    if not IsValid(self.targetPlayer) then return false end
    
    local trace = util.TraceLine({
        start = self:GetPos() + Vector(0, 0, 50),
        endpos = self.targetPlayer:GetPos() + Vector(0, 0, 50),
        filter = {self, self.targetPlayer}
    })
    
    return not trace.Hit
end

function ENT:CanExecuteTakedown()
    if not IsValid(self.targetPlayer) then return false end
    
    local distance = self:GetPos():Distance(self.targetPlayer:GetPos())
    return distance < TACTICAL_CONFIG.TAKEDOWN_RANGE and self.stealthLevel > 0.7
end

function ENT:IsCompromised()
    return self.stealthLevel < 0.3
end

function ENT:ShouldRetreat()
    return self:Health() < TACTICAL_CONFIG.RETREAT_HEALTH or self.stealthLevel < 0.2
end

function ENT:IsSafeToReset()
    local players = player.GetAll()
    for _, player in pairs(players) do
        if IsValid(player) and player:Alive() then
            local distance = self:GetPos():Distance(player:GetPos())
            if distance < TACTICAL_CONFIG.STEALTH_RADIUS * 0.5 then
                return false
            end
        end
    end
    return true
end

-- Movement and Navigation
function ENT:FindPatrolRoute()
    local areas = navmesh.GetAllNavAreas()
    if #areas > 0 then
        local randomArea = areas[math.random(1, #areas)]
        local randomPos = randomArea:GetRandomPoint()
        self:MoveToPosition(randomPos)
    else
        -- Fallback if no navmesh
        local randomPos = self:GetPos() + VectorRand() * 500
        randomPos.z = self:GetPos().z  -- Keep same height
        self:SetLastPosition(randomPos)
    end
end

function ENT:FindNextPatrolPoint()
    local currentPos = self:GetPos()
    local searchRadius = 500
    
    -- Try to find nav areas first
    local areas = navmesh.GetAllNavAreas()
    if #areas > 0 then
        local nearbyAreas = {}
        
        for _, area in pairs(areas) do
            local areaPos = area:GetCenter()
            if currentPos:Distance(areaPos) < searchRadius then
                table.insert(nearbyAreas, area)
            end
        end
        
        if #nearbyAreas > 0 then
            local randomArea = nearbyAreas[math.random(1, #nearbyAreas)]
            local randomPos = randomArea:GetRandomPoint()
            self:MoveToPosition(randomPos)
            return
        end
    end
    
    -- Fallback to random movement
    local randomDir = VectorRand()
    randomDir.z = 0  -- Keep on same plane
    local randomPos = currentPos + randomDir:GetNormalized() * math.random(200, 400)
    self:SetLastPosition(randomPos)
end

function ENT:IsMoving()
    local velocity = self:GetVelocity():Length()
    return velocity > 10
end

function ENT:FindOptimalCoverPosition(targetPos)
    local searchRadius = 300
    local areas = navmesh.GetAllNavAreas()
    local bestCover = nil
    local bestScore = -1
    
    -- Try navmesh areas first
    if #areas > 0 then
        for _, area in pairs(areas) do
            local areaPos = area:GetCenter()
            local distanceToTarget = areaPos:Distance(targetPos)
            local distanceFromSelf = self:GetPos():Distance(areaPos)
            
            if distanceToTarget < searchRadius and distanceFromSelf < 400 then
                -- Calculate cover score based on distance and shadow preference
                local coverScore = self:CalculateCoverScore(areaPos, targetPos)
                if coverScore > bestScore then
                    bestScore = coverScore
                    bestCover = areaPos
                end
            end
        end
    else
        -- Fallback cover finding
        for i = 1, 8 do
            local angle = i * 45
            local dir = Angle(0, angle, 0):Forward()
            local testPos = self:GetPos() + dir * math.random(100, 300)
            
            local coverScore = self:CalculateCoverScore(testPos, targetPos)
            if coverScore > bestScore then
                bestScore = coverScore
                bestCover = testPos
            end
        end
    end
    
    return bestCover
end

function ENT:CalculateCoverScore(position, targetPos)
    local score = 0
    
    -- Prefer positions closer to target
    local distanceToTarget = position:Distance(targetPos)
    score = score + (300 - distanceToTarget) / 3
    
    -- Prefer positions in shadows
    local lightLevel = self:GetLightLevel(position)
    score = score + (1 - lightLevel) * 100
    
    -- Prefer positions with good cover
    if self:HasCover(position) then
        score = score + 50
    end
    
    return score
end

function ENT:FindEscapeRoute()
    local currentPos = self:GetPos()
    local areas = navmesh.GetAllNavAreas()
    local bestEscape = nil
    local bestDistance = 0
    
    if #areas > 0 then
        for _, area in pairs(areas) do
            local areaPos = area:GetCenter()
            local distance = currentPos:Distance(areaPos)
            
            -- Prefer areas far from current position
            if distance > bestDistance and distance < 800 then
                bestDistance = distance
                bestEscape = areaPos
            end
        end
    else
        -- Fallback escape route
        local escapeDir = VectorRand()
        escapeDir.z = 0
        bestEscape = currentPos + escapeDir:GetNormalized() * 600
    end
    
    return bestEscape
end

-- Enhanced Navigation and Evasion System
function ENT:ExecuteEnhancedNavigation()
    local currentTime = CurTime()
    
    -- Update navigation at regular intervals
    if currentTime - self.lastNavigationUpdate > TACTICAL_CONFIG.NAVIGATION_UPDATE_RATE then
        self:UpdateNavigation()
        self.lastNavigationUpdate = currentTime
    end
    
    -- Check for threats that require evasion
    self:CheckForEvasionThreats()
end

function ENT:UpdateNavigation()
    -- Update pathfinding with better obstacle avoidance
    if self.currentPath and self.currentPath:IsValid() then
        -- Check if path is still valid
        if self:IsPathBlocked() then
            self.currentPath:Invalidate()
            self.currentPath = nil
            self:FindAlternativePath()
        end
    end
    
    -- Update evasion targets
    self:UpdateEvasionTargets()
end

function ENT:CheckForEvasionThreats()
    local players = player.GetAll()
    local threats = {}
    
    for _, player in pairs(players) do
        if IsValid(player) and player:Alive() then
            local distance = self:GetPos():Distance(player:GetPos())
            if distance < TACTICAL_CONFIG.EVASION_RADIUS then
                -- Check if player is a direct threat
                if self:IsPlayerThreat(player) then
                    table.insert(threats, player)
                end
            end
        end
    end
    
    -- Update evasion targets
    self.evasionTargets = threats
    
    -- Trigger evasive maneuver if needed
    if #threats > 0 and self.tacticalState ~= AI_STATES.EVASIVE_MANEUVER then
        self:ChangeState(AI_STATES.EVASIVE_MANEUVER)
    end
end

function ENT:IsPlayerThreat(player)
    if not IsValid(player) then return false end
    
    -- Check if player is looking at us
    if self:IsPlayerLookingAtMe(player) then
        return true
    end
    
    -- Check if player has a weapon and is close
    local weapon = player:GetActiveWeapon()
    if IsValid(weapon) then
        local distance = self:GetPos():Distance(player:GetPos())
        if distance < 200 then
            return true
        end
    end
    
    return false
end

function ENT:IsPathBlocked()
    if not self.currentPath or not self.currentPath:IsValid() then return true end
    
    -- Check if there are obstacles in the path
    local nextSegment = self.currentPath:GetNextSegment()
    if nextSegment then
        local trace = util.TraceLine({
            start = self:GetPos() + Vector(0, 0, 50),
            endpos = nextSegment.pos + Vector(0, 0, 50),
            filter = {self}
        })
        
        return trace.Hit
    end
    
    return false
end

function ENT:FindAlternativePath()
    if self.targetPosition then
        -- Try to find an alternative route
        self:MoveToPosition(self.targetPosition)
    else
        -- Find a new patrol point
        self:FindNextPatrolPoint()
    end
end

function ENT:UpdateEvasionTargets()
    -- Remove invalid targets
    for i = #self.evasionTargets, 1, -1 do
        if not IsValid(self.evasionTargets[i]) then
            table.remove(self.evasionTargets, i)
        end
    end
end

function ENT:IdentifyEvasionTargets()
    -- Already handled in CheckForEvasionThreats
    -- This function can be used for additional threat analysis
end

function ENT:PerformEvasiveMovement()
    if #self.evasionTargets == 0 then return end
    
    -- Calculate evasion direction
    local evasionDir = Vector(0, 0, 0)
    local myPos = self:GetPos()
    
    for _, threat in pairs(self.evasionTargets) do
        if IsValid(threat) then
            local threatDir = (myPos - threat:GetPos()):GetNormalized()
            evasionDir = evasionDir + threatDir
        end
    end
    
    -- Normalize and apply evasion movement
    if evasionDir:Length() > 0 then
        evasionDir = evasionDir:GetNormalized()
        local evasionPos = myPos + evasionDir * 200
        
        -- Check if we can climb to escape
        if self:CanClimbWall(evasionPos) then
            self:ChangeState(AI_STATES.WALL_CLIMBING)
            self.wallClimbTarget = evasionPos
        else
            -- Move to evasion position
            self:MoveToPosition(evasionPos)
        end
    end
end

-- Environment Control
function ENT:DisableNearbyLights()
    local lights = ents.FindByClass("light*")
    for _, light in pairs(lights) do
        if IsValid(light) then
            local distance = self:GetPos():Distance(light:GetPos())
            if distance < TACTICAL_CONFIG.LIGHT_DISABLE_RANGE then
                -- Disable light source
                if light:GetClass() == "light" then
                    light:Fire("TurnOff")
                elseif light:GetClass() == "light_spot" then
                    light:Fire("TurnOff")
                elseif light:GetClass() == "light_dynamic" then
                    light:Fire("TurnOff")
                end
            end
        end
    end
end

function ENT:CreateSoundDistraction()
    local nearbyProps = ents.FindInSphere(self:GetPos(), 200)
    for _, prop in pairs(nearbyProps) do
        if IsValid(prop) and (prop:GetClass() == "prop_physics" or prop:GetClass() == "prop_physics_multiplayer") then
            -- Knock over prop to create distraction
            if math.random() < 0.3 then
                local phys = prop:GetPhysicsObject()
                if IsValid(phys) then
                    phys:ApplyForceCenter(VectorRand() * 100)
                end
            end
        end
    end
end

function ENT:ManipulateProps()
    -- Move props to create tactical advantages
    local nearbyProps = ents.FindInSphere(self:GetPos(), 150)
    for _, prop in pairs(nearbyProps) do
        if IsValid(prop) and prop:GetClass() == "prop_physics" then
            if math.random() < 0.01 then
                local phys = prop:GetPhysicsObject()
                if IsValid(phys) then
                    -- Move prop slightly to create noise
                    phys:ApplyForceCenter(VectorRand() * 50)
                end
            end
        end
    end
end

-- Psychological Operations
function ENT:WhisperToPlayers()
    local players = player.GetAll()
    for _, player in pairs(players) do
        if IsValid(player) and player:Alive() then
            local distance = self:GetPos():Distance(player:GetPos())
            if distance < TACTICAL_CONFIG.WHISPER_RADIUS then
                -- Send whisper message
                net.Start("SplinterCellWhisper")
                net.WriteString("You're being watched...")
                net.Send(player)
            end
        end
    end
end

function ENT:FlashGoggles()
    local players = player.GetAll()
    for _, player in pairs(players) do
        if IsValid(player) and player:Alive() then
            local distance = self:GetPos():Distance(player:GetPos())
            if distance < TACTICAL_CONFIG.FLASH_RANGE then
                -- Flash effect
                net.Start("SplinterCellFlash")
                net.WriteVector(self:GetPos())
                net.Send(player)
            end
        end
    end
end

-- Combat Functions
function ENT:PerformSilentTakedown()
    if not IsValid(self.targetPlayer) then return end
    
    -- Execute takedown animation
    self:SetSequence(self:LookupSequence("gesture_melee"))
    
    -- Damage player
    local dmg = DamageInfo()
    dmg:SetDamage(100)
    dmg:SetAttacker(self)
    dmg:SetDamageType(DMG_SLASH)
    
    self.targetPlayer:TakeDamageInfo(dmg)
    
    -- Play takedown sound
    self:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 75, 100)
    
    -- Reset target
    self.targetPlayer = nil
end

function ENT:FireSuppressedShot()
    if not IsValid(self.targetPlayer) then return end
    
    -- Check cooldown
    if CurTime() - self.lastShotTime < self.shotCooldown then return end
    
    -- Check range
    local distance = self:GetPos():Distance(self.targetPlayer:GetPos())
    if distance > TACTICAL_CONFIG.WEAPON_RANGE then return end
    
    -- Play aim animation
    self:PlayAnimation("aim")
    
    -- Calculate accuracy-based shot
    local accuracy = self.accuracy
    local targetPos = self.targetPlayer:GetPos() + Vector(0, 0, 50)
    local myPos = self:GetPos() + Vector(0, 0, 50)
    
    -- Add accuracy-based spread
    local spread = (1.0 - accuracy) * 100
    local spreadVector = VectorRand() * spread
    local finalTarget = targetPos + spreadVector
    
    -- Fire suppressed weapon
    local trace = util.TraceLine({
        start = myPos,
        endpos = finalTarget,
        filter = {self, self.targetPlayer}
    })
    
    if not trace.Hit then
        -- Create bullet effect
        local effect = EffectData()
        effect:SetOrigin(trace.HitPos)
        effect:SetNormal(trace.HitNormal)
        util.Effect("cball_bounce", effect)
        
        -- Damage player with improved accuracy
        local dmg = DamageInfo()
        dmg:SetDamage(35) -- Increased damage
        dmg:SetAttacker(self)
        dmg:SetDamageType(DMG_BULLET)
        
        self.targetPlayer:TakeDamageInfo(dmg)
        
        -- Play suppressed shot sound
        self:EmitSound("weapons/silencer.wav", 50, 100)
        
        -- Update last shot time
        self.lastShotTime = CurTime()
        
        -- Reduce accuracy and stealth
        self.accuracy = math.max(0.3, self.accuracy - TACTICAL_CONFIG.ACCURACY_DECAY)
        self.stealthLevel = math.max(0.0, self.stealthLevel - 0.1)
    end
end

function ENT:DeploySmoke()
    if CurTime() - self.smokeLastUsed < TACTICAL_CONFIG.SMOKE_COOLDOWN then return end
    
    -- Create smoke effect
    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    effect:SetScale(2)
    util.Effect("smoke", effect)
    
    self.smokeLastUsed = CurTime()
end

-- Utility Functions
function ENT:GetLightLevel(position)
    -- Simple light level calculation
    local light = util.PointContents(position)
    if bit.band(light, CONTENTS_SOLID) ~= 0 then
        return 0  -- Inside solid = dark
    end
    
    -- Check for nearby lights
    local lights = ents.FindByClass("light*")
    local totalLight = 0
    
    for _, light in pairs(lights) do
        if IsValid(light) then
            local distance = position:Distance(light:GetPos())
            if distance < 300 then
                totalLight = totalLight + (300 - distance) / 300
            end
        end
    end
    
    return math.Clamp(totalLight, 0, 1)
end

function ENT:HasCover(position)
    -- Check if position has cover from multiple angles
    local coverAngles = {0, 45, 90, 135, 180, 225, 270, 315}
    local coverCount = 0
    
    for _, angle in pairs(coverAngles) do
        local forward = Angle(0, angle, 0):Forward()
        local trace = util.TraceLine({
            start = position,
            endpos = position + forward * 100,
            filter = self
        })
        
        if trace.Hit then
            coverCount = coverCount + 1
        end
    end
    
    return coverCount >= 3
end

function ENT:IsPlayerMakingNoise(player)
    -- Check if player is moving, shooting, or making other noise
    local velocity = player:GetVelocity():Length()
    if velocity > 50 then
        return true
    end
    
    -- Check for weapon firing
    local weapon = player:GetActiveWeapon()
    if IsValid(weapon) and weapon:GetNextPrimaryFire() > CurTime() - 0.1 then
        return true
    end
    
    return false
end

function ENT:MaintainStealth()
    -- Gradually recover stealth level when not compromised
    if self.stealthLevel < 1.0 then
        self.stealthLevel = math.min(1.0, self.stealthLevel + 0.01)
    end
    
    -- Reduce stealth when in light
    local lightLevel = self:GetLightLevel(self:GetPos())
    if lightLevel > 0.5 then
        self.stealthLevel = math.max(0.0, self.stealthLevel - 0.02)
    end
end

function ENT:SearchArea()
    -- Search the last known position area
    local searchRadius = 100
    local searchPoints = 8
    
    for i = 1, searchPoints do
        local angle = (i - 1) * (360 / searchPoints)
        local forward = Angle(0, angle, 0):Forward()
        local searchPos = self.lastKnownPosition + forward * searchRadius
        
        -- Move to search position
        timer.Simple(i * 0.5, function()
            if IsValid(self) then
                self:MoveToPosition(searchPos)
            end
        end)
    end
end

-- Override base NextBot functions
function ENT:RunBehaviour()
    -- Let the timer-based AI handle behavior instead
    while true do
        coroutine.wait(1)
    end
end

-- NextBot movement handling
function ENT:BodyUpdate()
    -- Let the animation system handle movement
    self:FrameAdvance()
    
    -- Update pose parameters for better animation
    local velocity = self:GetVelocity():Length()
    local speed = math.Clamp(velocity / 200, 0, 1)
    
    -- Set pose parameters for movement
    self:SetPoseParameter("move_x", speed)
    self:SetPoseParameter("move_y", 0)
    
    -- Set pose parameters for aiming
    if self.tacticalState == AI_STATES.ENGAGE_SUPPRESSED and IsValid(self.targetPlayer) then
        local aimDir = (self.targetPlayer:GetPos() - self:GetPos()):GetNormalized()
        local aimAng = aimDir:Angle()
        local yawDiff = math.AngleDifference(aimAng.yaw, self:GetAngles().yaw)
        
        self:SetPoseParameter("aim_yaw", yawDiff)
        self:SetPoseParameter("aim_pitch", aimAng.pitch)
    else
        self:SetPoseParameter("aim_yaw", 0)
        self:SetPoseParameter("aim_pitch", 0)
    end
end

function ENT:OnKilled(dmg)
    -- Clean up timers
    timer.Remove("SplinterCellAI_" .. self:EntIndex())
    
    -- Handle death effects
    local effect = EffectData()
    effect:SetOrigin(self:GetPos())
    effect:SetScale(1)
    util.Effect("bloodspray", effect)
    
    -- Remove entity
    self:Remove()
end

function ENT:OnTakeDamage(dmg)
    -- Reduce stealth when taking damage
    self.stealthLevel = math.max(0.0, self.stealthLevel - 0.3)
    
    -- Update last known position to damage source
    local attacker = dmg:GetAttacker()
    if IsValid(attacker) and attacker:IsPlayer() then
        self.lastKnownPosition = attacker:GetPos()
        self.targetPlayer = attacker
        
        -- Become more aggressive when damaged
        if self.tacticalState == AI_STATES.IDLE_RECON then
            self:ChangeState(AI_STATES.INVESTIGATE)
        end
    end
    
    -- Call parent function
    self.BaseClass.OnTakeDamage(self, dmg)
end

-- Path handling for proper NextBot movement
function ENT:MoveTowards(pos)
    local path = Path("Follow")
    path:SetMinLookAheadDistance(300)
    path:SetGoalTolerance(20)
    path:Compute(self, pos)
    
    if not path:IsValid() then
        return false
    end
    
    path:Update(self)
    
    if path:GetAge() > 0.1 then
        path:Invalidate()
    end
    
    return true
end

-- Cleanup
function ENT:OnRemove()
    timer.Remove("SplinterCellAI_" .. self:EntIndex())
    
    -- Clean up weapon entity
    if IsValid(self.weaponEntity) then
        self.weaponEntity:Remove()
    end
end

-- Additional NextBot lifecycle functions for better AI behavior
function ENT:Think()
    -- Called every frame, handle immediate AI decisions
    if not IsValid(self) then return end
    
    -- Update stealth level based on current conditions
    self:UpdateStealthLevel()
    
    -- Handle immediate threats
    self:HandleImmediateThreats()
    
    -- Recover accuracy over time
    self:RecoverAccuracy()
    
    -- Set next think time
    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:RecoverAccuracy()
    local currentTime = CurTime()
    if currentTime - self.lastAccuracyUpdate > TACTICAL_CONFIG.RECOVERY_TIME then
        self.accuracy = math.min(1.0, self.accuracy + 0.1)
        self.lastAccuracyUpdate = currentTime
    end
end

function ENT:UpdateStealthLevel()
    -- Update stealth based on current environment
    local lightLevel = self:GetLightLevel(self:GetPos())
    local nearbyPlayers = self:GetNearbyPlayers()
    
    -- Reduce stealth in bright light
    if lightLevel > 0.6 then
        self.stealthLevel = math.max(0.0, self.stealthLevel - 0.01)
    end
    
    -- Reduce stealth when players are very close
    for _, player in pairs(nearbyPlayers) do
        local distance = self:GetPos():Distance(player:GetPos())
        if distance < 100 then
            self.stealthLevel = math.max(0.0, self.stealthLevel - 0.02)
        end
    end
    
    -- Gradually recover stealth when safe
    if lightLevel < 0.3 and #nearbyPlayers == 0 then
        self.stealthLevel = math.min(1.0, self.stealthLevel + 0.005)
    end
end

function ENT:HandleImmediateThreats()
    -- Check for immediate threats that require instant response
    local players = player.GetAll()
    for _, player in pairs(players) do
        if IsValid(player) and player:Alive() then
            local distance = self:GetPos():Distance(player:GetPos())
            
            -- Immediate threat detection
            if distance < 50 then
                -- Player is very close, immediate response needed
                if self.tacticalState == AI_STATES.IDLE_RECON then
                    self:ChangeState(AI_STATES.AMBUSH)
                end
                self.targetPlayer = player
                self.lastKnownPosition = player:GetPos()
                return
            end
            
            -- Check if player is looking directly at us
            if self:IsPlayerLookingAtMe(player) then
                self.stealthLevel = math.max(0.0, self.stealthLevel - 0.05)
                if self.stealthLevel < 0.3 then
                    self:ChangeState(AI_STATES.ENGAGE_SUPPRESSED)
                end
            end
        end
    end
end

function ENT:GetNearbyPlayers()
    local nearbyPlayers = {}
    local players = player.GetAll()
    
    for _, player in pairs(players) do
        if IsValid(player) and player:Alive() then
            local distance = self:GetPos():Distance(player:GetPos())
            if distance < TACTICAL_CONFIG.STEALTH_RADIUS then
                table.insert(nearbyPlayers, player)
            end
        end
    end
    
    return nearbyPlayers
end

function ENT:IsPlayerLookingAtMe(player)
    if not IsValid(player) then return false end
    
    local playerEyePos = player:EyePos()
    local myPos = self:GetPos() + Vector(0, 0, 50)
    local playerForward = player:EyeAngles():Forward()
    local toMe = (myPos - playerEyePos):GetNormalized()
    
    local dot = playerForward:Dot(toMe)
    local distance = playerEyePos:Distance(myPos)
    
    -- Player is looking at us if dot product is high and we're within view distance
    return dot > 0.7 and distance < 300
end

function ENT:Touch(entity)
    -- Handle collision with other entities
    if not IsValid(entity) then return end
    
    -- Handle player collision
    if entity:IsPlayer() then
        if self.tacticalState == AI_STATES.AMBUSH then
            -- Execute immediate takedown
            self:PerformSilentTakedown()
        elseif self.tacticalState == AI_STATES.STALKING then
            -- Player bumped into us, become aggressive
            self:ChangeState(AI_STATES.ENGAGE_SUPPRESSED)
        end
    end
    
    -- Handle prop collision for sound creation
    if entity:GetClass() == "prop_physics" or entity:GetClass() == "prop_physics_multiplayer" then
        if math.random() < 0.1 then
            -- Create noise when bumping props
            self:EmitSound("physics/wood/wood_box_impact_hard" .. math.random(1, 3) .. ".wav", 50, 100)
        end
    end
end

function ENT:Use(activator, caller)
    -- Handle player interaction
    if IsValid(activator) and activator:IsPlayer() then
        -- Player is trying to interact with us
        if self.tacticalState == AI_STATES.IDLE_RECON then
            -- Surprise attack
            self.targetPlayer = activator
            self:ChangeState(AI_STATES.AMBUSH)
        else
            -- Defensive response
            self:ChangeState(AI_STATES.ENGAGE_SUPPRESSED)
        end
    end
end

function ENT:OnInjured(dmg)
    -- Called when the NextBot is injured
    local attacker = dmg:GetAttacker()
    
    -- Reduce stealth significantly when injured
    self.stealthLevel = math.max(0.0, self.stealthLevel - 0.4)
    
    -- Update target if attacked by player
    if IsValid(attacker) and attacker:IsPlayer() then
        self.targetPlayer = attacker
        self.lastKnownPosition = attacker:GetPos()
        
        -- Become more aggressive when injured
        if self.tacticalState == AI_STATES.IDLE_RECON or self.tacticalState == AI_STATES.INVESTIGATE then
            self:ChangeState(AI_STATES.ENGAGE_SUPPRESSED)
        end
    end
    
    -- Play injury sound
    self:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 75, 100)
    
    -- Deploy smoke if available
    if CurTime() - self.smokeLastUsed > TACTICAL_CONFIG.SMOKE_COOLDOWN then
        self:DeploySmoke()
    end
end

function ENT:OnLandOnGround()
    -- Called when the NextBot lands on the ground
    -- Reduce noise when landing
    local velocity = self:GetVelocity():Length()
    if velocity > 100 then
        self:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 30, 100)
    end
end

function ENT:OnStuck()
    -- Called when the NextBot gets stuck
    -- Try to unstuck by jumping or finding alternative path
    if self.currentPath and self.currentPath:IsValid() then
        self.currentPath:Invalidate()
        self.currentPath = nil
    end
    
    -- Try to jump to unstuck
    self:SetVelocity(Vector(0, 0, 200))
    
    -- Find new path
    if self.targetPosition then
        self:MoveToPosition(self.targetPosition)
    else
        self:FindNextPatrolPoint()
    end
end

function ENT:OnUnStuck()
    -- Called when the NextBot becomes unstuck
    -- Resume normal behavior
    if self.targetPosition then
        self:MoveToPosition(self.targetPosition)
    end
end

-- Wall Climbing System
function ENT:FindWallToClimb()
    local myPos = self:GetPos()
    local searchRadius = 300
    
    -- Search for climbable walls in all directions
    for angle = 0, 360, 45 do
        local forward = Angle(0, angle, 0):Forward()
        local testPos = myPos + forward * searchRadius
        
        -- Check if there's a wall at this position
        local trace = util.TraceLine({
            start = myPos + Vector(0, 0, 50),
            endpos = testPos + Vector(0, 0, 50),
            filter = {self}
        })
        
        if trace.Hit then
            -- Check if the wall is climbable
            if self:IsWallClimbable(trace.HitPos, trace.HitNormal) then
                self.wallClimbTarget = trace.HitPos
                self:StartWallClimb()
                return
            end
        end
    end
    
    -- No climbable wall found, return to previous state
    self:ChangeState(AI_STATES.IDLE_RECON)
end

function ENT:IsWallClimbable(wallPos, wallNormal)
    -- Check if wall is vertical enough
    local upVector = Vector(0, 0, 1)
    local wallAngle = math.acos(wallNormal:Dot(upVector))
    
    if wallAngle > math.rad(30) then
        return false -- Wall is too steep
    end
    
    -- Check if there's enough space above the wall
    local aboveWall = wallPos + Vector(0, 0, TACTICAL_CONFIG.WALL_CLIMB_HEIGHT)
    local trace = util.TraceLine({
        start = wallPos,
        endpos = aboveWall,
        filter = {self}
    })
    
    return not trace.Hit -- No obstruction above
end

function ENT:CanClimbWall(targetPos)
    local myPos = self:GetPos()
    local direction = (targetPos - myPos):GetNormalized()
    
    -- Check if there's a wall in the direction
    local trace = util.TraceLine({
        start = myPos + Vector(0, 0, 50),
        endpos = myPos + direction * 100 + Vector(0, 0, 50),
        filter = {self}
    })
    
    if trace.Hit then
        return self:IsWallClimbable(trace.HitPos, trace.HitNormal)
    end
    
    return false
end

function ENT:StartWallClimb()
    if not self.wallClimbTarget then return end
    
    self.isClimbing = true
    self.climbStartPos = self:GetPos()
    self.climbEndPos = self.wallClimbTarget + Vector(0, 0, TACTICAL_CONFIG.WALL_CLIMB_HEIGHT)
    self.climbProgress = 0
    
    -- Play climbing animation
    self:PlayAnimation("climb")
    
    -- Set climbing velocity
    self:SetVelocity(Vector(0, 0, TACTICAL_CONFIG.WALL_CLIMB_SPEED))
    
    -- Send wall climbing effect to all players
    net.Start("SplinterCellWallClimb")
    net.WriteVector(self:GetPos())
    net.WriteBool(true)
    net.Broadcast()
end

function ENT:UpdateWallClimb()
    if not self.isClimbing then return end
    
    -- Update climb progress
    self.climbProgress = self.climbProgress + 0.02
    
    if self.climbProgress >= 1.0 then
        -- Climbing complete
        self:FinishWallClimb()
    else
        -- Continue climbing
        local currentPos = LerpVector(self.climbProgress, self.climbStartPos, self.climbEndPos)
        self:SetPos(currentPos)
    end
end

function ENT:FinishWallClimb()
    self.isClimbing = false
    self.wallClimbTarget = nil
    self.climbProgress = 0
    
    -- Land on the top of the wall
    self:SetPos(self.climbEndPos)
    
    -- Play landing animation
    self:PlayAnimation("land")
    
    -- Send wall climbing end effect to all players
    net.Start("SplinterCellWallClimb")
    net.WriteVector(self:GetPos())
    net.WriteBool(false)
    net.Broadcast()
    
    -- Return to previous state or find new objective
    if self.targetPlayer then
        self:ChangeState(AI_STATES.STALKING)
    else
        self:ChangeState(AI_STATES.IDLE_RECON)
    end
end

-- Night Vision System
function ENT:ExecuteNightVisionSystem()
    if not self.nightVisionActive then return end
    
    local currentTime = CurTime()
    if currentTime - self.lastNightVisionUpdate > 0.5 then
        self:UpdateNightVision()
        self.lastNightVisionUpdate = currentTime
    end
end

function ENT:UpdateNightVision()
    -- Enhanced detection in darkness
    local players = player.GetAll()
    for _, player in pairs(players) do
        if IsValid(player) and player:Alive() then
            local distance = self:GetPos():Distance(player:GetPos())
            if distance < self.nightVisionRange then
                -- Check if area is dark (night vision advantage)
                local lightLevel = self:GetLightLevel(player:GetPos())
                if lightLevel < 0.3 then
                    -- Night vision gives us advantage in darkness
                    if not self.targetPlayer then
                        self.targetPlayer = player
                        self.lastKnownPosition = player:GetPos()
                        self:ChangeState(AI_STATES.NIGHT_VISION_HUNT)
                    end
                end
            end
        end
    end
end

function ENT:ActivateNightVision()
    self.nightVisionActive = true
    self.nightVisionRange = TACTICAL_CONFIG.NIGHT_VISION_RANGE
    
    -- Send night vision effect to all players
    net.Start("SplinterCellNightVision")
    net.WriteVector(self:GetPos())
    net.WriteBool(true)
    net.Broadcast()
end

function ENT:PerformNightVisionHunt()
    if not IsValid(self.targetPlayer) then return end
    
    -- Enhanced hunting with night vision
    local targetPos = self.targetPlayer:GetPos()
    local lightLevel = self:GetLightLevel(targetPos)
    
    -- Night vision gives us better accuracy in darkness
    if lightLevel < 0.3 then
        self.combatAccuracy = TACTICAL_CONFIG.COMBAT_ACCURACY_COVER
    end
    
    -- Move to optimal night vision position
    local coverPos = self:FindOptimalCoverPosition(targetPos)
    if coverPos then
        self:MoveToPosition(coverPos)
    end
    
    -- Enhanced stealth in darkness
    if lightLevel < 0.2 then
        self.stealthLevel = math.min(1.0, self.stealthLevel + 0.02)
    end
end

-- Enhanced Smoke Grenade System
function ENT:DetermineSmokeTacticalUse()
    local currentTime = CurTime()
    if currentTime - self.lastSmokeTacticalChange > 2.0 then
        -- Randomly choose a tactical use
        local useIndex = math.random(1, #TACTICAL_CONFIG.SMOKE_TACTICAL_USES)
        self.smokeTacticalUse = TACTICAL_CONFIG.SMOKE_TACTICAL_USES[useIndex]
        self.lastSmokeTacticalChange = currentTime
    end
end

function ENT:DeployTacticalSmoke()
    if self.smokeGrenades <= 0 then return end
    
    local smokePos = self:GetPos()
    
    -- Determine smoke position based on tactical use
    if self.smokeTacticalUse == "cover_retreat" then
        -- Deploy smoke behind us for cover
        local retreatDir = (self:GetPos() - self.lastKnownPosition):GetNormalized()
        smokePos = self:GetPos() + retreatDir * 100
    elseif self.smokeTacticalUse == "block_line_of_sight" then
        -- Deploy smoke between us and target
        if IsValid(self.targetPlayer) then
            local midPoint = (self:GetPos() + self.targetPlayer:GetPos()) / 2
            smokePos = midPoint
        end
    elseif self.smokeTacticalUse == "create_distraction" then
        -- Deploy smoke away from our position
        local randomDir = VectorRand()
        randomDir.z = 0
        smokePos = self:GetPos() + randomDir:GetNormalized() * 150
    elseif self.smokeTacticalUse == "mask_movement" then
        -- Deploy smoke at our position to mask movement
        smokePos = self:GetPos()
    elseif self.smokeTacticalUse == "force_reposition" then
        -- Deploy smoke near target to force them to move
        if IsValid(self.targetPlayer) then
            smokePos = self.targetPlayer:GetPos() + VectorRand() * 50
        end
    end
    
    -- Create enhanced smoke effect
    self:CreateSmokeEffect(smokePos)
    
    -- Reduce smoke grenade count
    self.smokeGrenades = self.smokeGrenades - 1
    
    -- Update networked variable
    self:SetNWInt("smokeGrenades", self.smokeGrenades)
    
    -- Return to previous state
    self:ChangeState(AI_STATES.ENGAGE_SUPPRESSED)
end

function ENT:CreateSmokeEffect(position)
    -- Create enhanced smoke effect
    local effect = EffectData()
    effect:SetOrigin(position)
    effect:SetScale(TACTICAL_CONFIG.SMOKE_RADIUS / 100)
    util.Effect("smoke", effect)
    
    -- Add smoke to active effects
    table.insert(self.activeSmokeEffects, {
        pos = position,
        startTime = CurTime(),
        duration = TACTICAL_CONFIG.SMOKE_DURATION
    })
    
    -- Send smoke effect to all players
    net.Start("SplinterCellSmokeDeploy")
    net.WriteVector(position)
    net.WriteFloat(TACTICAL_CONFIG.SMOKE_RADIUS)
    net.Broadcast()
    
    -- Clean up old smoke effects
    self:CleanupSmokeEffects()
end

function ENT:CleanupSmokeEffects()
    local currentTime = CurTime()
    for i = #self.activeSmokeEffects, 1, -1 do
        local smoke = self.activeSmokeEffects[i]
        if currentTime - smoke.startTime > smoke.duration then
            table.remove(self.activeSmokeEffects, i)
        end
    end
end

-- Enhanced Combat Mechanics
function ENT:ExecuteEnhancedCombatMechanics()
    -- Update combat accuracy based on current conditions
    self:UpdateCombatAccuracy()
    
    -- Handle tactical reload
    if TACTICAL_CONFIG.TACTICAL_RELOAD then
        self:HandleTacticalReload()
    end
    
    -- Handle burst fire
    if self.burstFireCount > 0 then
        self:HandleBurstFire()
    end
    
    -- Update combat stance
    if TACTICAL_CONFIG.COMBAT_STANCE_CHANGES then
        self:UpdateCombatStance()
    end
end

function ENT:UpdateCombatAccuracy()
    local baseAccuracy = TACTICAL_CONFIG.COMBAT_ACCURACY_BASE
    
    -- Reduce accuracy while moving
    if self:IsMoving() then
        baseAccuracy = TACTICAL_CONFIG.COMBAT_ACCURACY_MOVING
    end
    
    -- Increase accuracy from cover
    if self.isInCover then
        baseAccuracy = TACTICAL_CONFIG.COMBAT_ACCURACY_COVER
    end
    
    -- Apply night vision bonus in darkness
    if self.nightVisionActive then
        local lightLevel = self:GetLightLevel(self:GetPos())
        if lightLevel < 0.3 then
            baseAccuracy = baseAccuracy + 0.1
        end
    end
    
    self.combatAccuracy = math.Clamp(baseAccuracy, 0.3, 1.0)
end

function ENT:HandleTacticalReload()
    if self.isReloading then
        local currentTime = CurTime()
        if currentTime - self.lastReloadTime > 2.0 then
            -- Reload complete
            self.ammoCount = self.maxAmmo
            self.isReloading = false
            self:SetNWInt("ammoCount", self.ammoCount)
        end
    elseif self.ammoCount <= 5 and not self.isReloading then
        -- Start tactical reload
        self.isReloading = true
        self.lastReloadTime = CurTime()
        self:PlayAnimation("reload")
    end
end

function ENT:HandleBurstFire()
    local currentTime = CurTime()
    if currentTime - self.lastBurstShot > TACTICAL_CONFIG.BURST_FIRE_DELAY then
        if self.burstFireCount > 0 then
            self:FireSuppressedShot()
            self.burstFireCount = self.burstFireCount - 1
            self.lastBurstShot = currentTime
        end
    end
end

function ENT:UpdateCombatStance()
    if not IsValid(self.targetPlayer) then return end
    
    local distance = self:GetPos():Distance(self.targetPlayer:GetPos())
    
    if distance < 100 then
        -- Close combat - crouch for better accuracy
        if self.combatStance ~= "crouching" then
            self.combatStance = "crouching"
            self:SetNWString("combatStance", self.combatStance)
        end
    elseif distance > 300 then
        -- Long range - standing for better mobility
        if self.combatStance ~= "standing" then
            self.combatStance = "standing"
            self:SetNWString("combatStance", self.combatStance)
        end
    end
end

-- Enhanced Fire Suppressed Shot with new mechanics
function ENT:FireSuppressedShot()
    if not IsValid(self.targetPlayer) then return end
    
    -- Check if reloading
    if self.isReloading then return end
    
    -- Check ammo
    if self.ammoCount <= 0 then
        self:HandleTacticalReload()
        return
    end
    
    -- Check cooldown
    if CurTime() - self.lastShotTime < self.shotCooldown then return end
    
    -- Check range
    local distance = self:GetPos():Distance(self.targetPlayer:GetPos())
    if distance > TACTICAL_CONFIG.WEAPON_RANGE then return end
    
    -- Play aim animation
    self:PlayAnimation("aim")
    
    -- Calculate accuracy-based shot with enhanced combat accuracy
    local accuracy = self.combatAccuracy
    local targetPos = self.targetPlayer:GetPos() + Vector(0, 0, 50)
    local myPos = self:GetPos() + Vector(0, 0, 50)
    
    -- Add accuracy-based spread
    local spread = (1.0 - accuracy) * 80  -- Reduced spread for better accuracy
    local spreadVector = VectorRand() * spread
    local finalTarget = targetPos + spreadVector
    
    -- Fire suppressed weapon
    local trace = util.TraceLine({
        start = myPos,
        endpos = finalTarget,
        filter = {self, self.targetPlayer}
    })
    
    if not trace.Hit then
        -- Create bullet effect
        local effect = EffectData()
        effect:SetOrigin(trace.HitPos)
        effect:SetNormal(trace.HitNormal)
        util.Effect("cball_bounce", effect)
        
        -- Damage player with improved accuracy
        local dmg = DamageInfo()
        dmg:SetDamage(40) -- Increased damage
        dmg:SetAttacker(self)
        dmg:SetDamageType(DMG_BULLET)
        
        self.targetPlayer:TakeDamageInfo(dmg)
        
        -- Play suppressed shot sound
        self:EmitSound("weapons/silencer.wav", 50, 100)
        
        -- Update last shot time and ammo
        self.lastShotTime = CurTime()
        self.ammoCount = self.ammoCount - 1
        self:SetNWInt("ammoCount", self.ammoCount)
        
        -- Reduce accuracy and stealth
        self.accuracy = math.max(0.3, self.accuracy - TACTICAL_CONFIG.ACCURACY_DECAY)
        self.stealthLevel = math.max(0.0, self.stealthLevel - 0.1)
    end
end