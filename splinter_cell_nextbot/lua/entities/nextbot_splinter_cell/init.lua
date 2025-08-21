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
util.AddNetworkString("SplinterCellRequestLightLevel")
util.AddNetworkString("SplinterCellLightLevelResponse")

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

-- Handle light level responses from clients
net.Receive("SplinterCellLightLevelResponse", function(len, ply)
    local position = net.ReadVector()
    local lightLevel = net.ReadFloat()
    
    -- Store the light level data for use by the AI
    -- This could be expanded to cache light levels for different positions
    if IsValid(ply) then
        -- For now, we'll just use the basic server-side method
        -- Future enhancement: cache client-provided light levels
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
    
    -- Enhanced Movement and Animation
    PATROL_SPEED = 100,             -- Speed during patrol (slow pistol walk)
    SUSPICIOUS_SPEED = 80,          -- Speed during suspicious state (crouch walk)
    HUNT_SPEED = 120,               -- Speed during hunt (mix of walk/crouch)
    ENGAGE_SPEED = 150,             -- Speed during engagement
    DISAPPEAR_SPEED = 90,           -- Speed during disappear (crouch backwards)
    
    -- Suspicion System
    SUSPICION_DECAY_RATE = 0.5,     -- Rate at which suspicion decreases
    SUSPICION_INCREASE_RATE = 2.0,  -- Rate at which suspicion increases
    MAX_SUSPICION = 100,            -- Maximum suspicion level
    
    -- Navigation and Evasion
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
    COMBAT_ACCURACY_BASE = 0.65,    -- Base accuracy in combat (reduced from 0.85)
    COMBAT_ACCURACY_MOVING = 0.4,   -- Accuracy while moving (reduced from 0.6)
    COMBAT_ACCURACY_COVER = 0.75,   -- Accuracy from cover (reduced from 0.95)
    BURST_FIRE_COUNT = 3,           -- Number of shots in burst fire
    BURST_FIRE_DELAY = 0.1,         -- Delay between burst shots
    COMBAT_STANCE_CHANGES = true,   -- Dynamic stance changes in combat
    TACTICAL_RELOAD = true,         -- Tactical reload system
    GRENADE_USAGE = true,           -- Enable grenade usage
    GRENADE_COOLDOWN = 20,          -- Cooldown between grenade uses
}

-- AI States - Enhanced for Splinter Cell Tactical Behavior
local AI_STATES = {
    PATROL = 1,           -- Low alert, patrolling with stealth movement
    SUSPICIOUS = 2,       -- Searching, investigating noises
    HUNT = 3,             -- High alert, tactical stalking
    ENGAGE = 4,           -- Combat engagement
    DISAPPEAR = 5,        -- Reset/retreat with smoke
    WALL_CLIMBING = 6,    -- Vertical traversal
    EVASIVE_MANEUVER = 7, -- Performing evasive movements
    TACTICAL_SMOKE = 8,   -- Using smoke grenades tactically
    NIGHT_VISION_HUNT = 9 -- Enhanced hunting with night vision
}

function ENT:Initialize()
    self:SetModel("models/splinter_cell_3/player/Sam_E.mdl")
    self:SetHealth(200)
    self:SetMaxHealth(200)
    self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 72))
    
    -- CRITICAL FIX: Properly initialize NextBot movement system
    self:SetDesiredSpeed(100)
    self:SetMaxSpeed(150)
    self:SetAcceleration(500)
    self:SetDeceleration(500)
    
    -- Ensure NextBot is properly initialized
    if not self.IsNextBot then
        self.IsNextBot = true
    end
    
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
    self.tacticalState = AI_STATES.PATROL
    self.targetPlayer = nil
    self.lastKnownPosition = Vector(0, 0, 0)
    self.lastStateChange = CurTime()
    self.smokeLastUsed = 0
    self.stealthLevel = 1.0  -- 1.0 = fully stealth, 0.0 = compromised
    self.patienceTimer = 0
    self.currentObjective = "patrol"
    self.currentPath = nil
    self.targetPosition = nil
    
    -- Enhanced tactical variables
    self.suspicionMeter = 0
    self.lastSuspicionUpdate = CurTime()
    self.isCrouching = false
    self.isAiming = false
    self.lastMovementChange = CurTime()
    self.circleDirection = 1  -- 1 for clockwise, -1 for counter-clockwise
    self.lastCircleUpdate = CurTime()
    self.rappelling = false
    self.lastRappelAttempt = 0
    self.fakeNoiseTimer = 0
    self.lastFakeNoise = 0
    self.playerTrackLost = false
    self.lastPlayerSight = 0
    
    -- Improved AI behavior variables
    self.lastTargetChange = CurTime()
    self.targetChangeCooldown = 3.0  -- Minimum time between target changes
    self.engagementCooldown = 5.0    -- Cooldown before re-engaging same target
    self.lastEngagementTime = 0
    self.patienceLevel = 1.0         -- How patient the AI is (affects decision making)
    
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
    
    -- Ensure we start with a valid animation sequence to prevent T-posing
    local idleSeq = self:LookupSequence("idle")
    if idleSeq and idleSeq > 0 then
        self:SetSequence(idleSeq)
    else
        -- Fallback to first available sequence
        self:SetSequence(0)
    end
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

function ENT:OnRemove()
    -- Clean up timers when entity is removed
    timer.Remove("SplinterCellAI_" .. self:EntIndex())
    
    -- Remove weapon entity
    if IsValid(self.weaponEntity) then
        self.weaponEntity:Remove()
    end
    
    -- Clean up any active effects
    for _, effect in pairs(self.activeSmokeEffects or {}) do
        if IsValid(effect) then
            effect:Remove()
        end
    end
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
    if not animationName or not IsValid(self) then return end
    if self.currentAnimation == animationName then return end
    
    self.currentAnimation = animationName
    self.animationStartTime = CurTime()
    
    -- Set the appropriate sequence based on animation name
    local sequence = self:LookupSequence(animationName)
    if sequence and sequence > 0 then
        self:SetSequence(sequence)
    else
        -- Fallback sequences for common animations with HL2 pistol animations
        if animationName == "idle" then
            -- ACT_IDLE_PISTOL - pistol idle animation
            local idleSeq = self:LookupSequence("idle")
            if idleSeq and idleSeq > 0 then
                self:SetSequence(idleSeq)
            else
                -- Ultimate fallback - use first available sequence
                self:SetSequence(0)
            end
        elseif animationName == "walk" then
            -- ACT_WALK_PISTOL - slow pistol walk animation
            local walkSeq = self:LookupSequence("walk")
            if walkSeq and walkSeq > 0 then
                self:SetSequence(walkSeq)
            else
                local runSeq = self:LookupSequence("run")
                if runSeq and runSeq > 0 then
                    self:SetSequence(runSeq)
                else
                    self:SetSequence(0)
                end
            end
        elseif animationName == "crouch_walk" then
            -- ACT_WALK_CROUCH_PISTOL - pistol crouch-walk animation
            local crouchSeq = self:LookupSequence("crouch_walk")
            if crouchSeq and crouchSeq > 0 then
                self:SetSequence(crouchSeq)
            else
                local walkSeq = self:LookupSequence("walk")
                if walkSeq and walkSeq > 0 then
                    self:SetSequence(walkSeq)
                else
                    self:SetSequence(0)
                end
            end
        elseif animationName == "aim" then
            -- Aiming stance
            local aimSeq = self:LookupSequence("gesture_range_attack")
            if aimSeq and aimSeq > 0 then
                self:SetSequence(aimSeq)
            else
                self:SetSequence(0)
            end
        elseif animationName == "reload" then
            -- Reload animation
            local reloadSeq = self:LookupSequence("gesture_reload")
            if reloadSeq and reloadSeq > 0 then
                self:SetSequence(reloadSeq)
            else
                self:SetSequence(0)
            end
        elseif animationName == "run" then
            -- ACT_RUN_PISTOL - only in emergencies
            local runSeq = self:LookupSequence("run")
            if runSeq and runSeq > 0 then
                self:SetSequence(runSeq)
            else
                local walkSeq = self:LookupSequence("walk")
                if walkSeq and walkSeq > 0 then
                    self:SetSequence(walkSeq)
                else
                    self:SetSequence(0)
                end
            end
        else
            -- Default fallback
            self:SetSequence(0)
        end
    end
    
    -- Update networked variable
    if IsValid(self) then
        self:SetNWString("currentAnimation", self.currentAnimation)
    end
end

function ENT:UpdateAnimation()
    if not IsValid(self) then return end
    
    local velocity = self:GetVelocity():Length()
    local currentTime = CurTime()
    
    -- Determine if we're moving
    local wasMoving = self.isMoving
    self.isMoving = velocity > 10
    
    -- Update animation based on movement and tactical state
    if self.isMoving then
        if not wasMoving or self.currentAnimation ~= self:GetMovementAnimation() then
            self:PlayAnimation(self:GetMovementAnimation())
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
    if IsValid(self) then
        self:UpdateWeaponPosition()
    end
end

function ENT:GetMovementAnimation()
    -- Return appropriate animation based on tactical state and conditions
    if self.tacticalState == AI_STATES.PATROL then
        return "walk"  -- ACT_WALK_PISTOL
    elseif self.tacticalState == AI_STATES.SUSPICIOUS then
        return self.isCrouching and "crouch_walk" or "walk"  -- ACT_WALK_CROUCH_PISTOL or ACT_WALK_PISTOL
    elseif self.tacticalState == AI_STATES.HUNT then
        -- Mix of pistol walk + crouch-walk depending on cover
        local lightLevel = self:GetLightLevel(self:GetPos())
        return lightLevel < 0.3 and "walk" or "crouch_walk"
    elseif self.tacticalState == AI_STATES.ENGAGE then
        return self.isCrouching and "crouch_walk" or "walk"
    elseif self.tacticalState == AI_STATES.DISAPPEAR then
        return "crouch_walk"  -- Crouch-walk backwards
    else
        return "walk"  -- Default
    end
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
    -- Start the AI cycle using NextBot's RunBehavior system
    self.aiCycleStarted = true
end

function ENT:RunBehavior()
    -- This is the main NextBot behavior function that runs every frame
    if not IsValid(self) or not self.aiCycleStarted then return end
    
    -- Add error handling to prevent crashes
    local success, err = pcall(function()
        self:ExecuteTacticalAI()
    end)
    
    if not success then
        print("[SplinterCellAI] Error in AI cycle: " .. tostring(err))
        -- Reset to safe state
        if IsValid(self) then
            self.tacticalState = AI_STATES.PATROL
            self.currentPath = nil
            self.targetPlayer = nil
            -- Ensure we have a valid sequence to prevent T-posing
            self:SetSequence(self:LookupSequence("idle") or 0)
        end
    end
end

function ENT:ExecuteTacticalAI()
    if not IsValid(self) then return end
    
    -- Update tactical state based on current conditions
    self:UpdateTacticalState()
    
    -- Update animations
    self:UpdateAnimation()
    
    -- CRITICAL FIX: Update movement system
    self:UpdateMovement()
    
    -- Execute current state behavior
    if self.tacticalState == AI_STATES.PATROL then
        self:ExecutePatrol()
    elseif self.tacticalState == AI_STATES.SUSPICIOUS then
        self:ExecuteSuspicious()
    elseif self.tacticalState == AI_STATES.HUNT then
        self:ExecuteHunt()
    elseif self.tacticalState == AI_STATES.ENGAGE then
        self:ExecuteEngage()
    elseif self.tacticalState == AI_STATES.DISAPPEAR then
        self:ExecuteDisappear()
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
    if IsValid(self) then
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
end

function ENT:UpdateTacticalState()
    if not IsValid(self) then return end
    
    local currentTime = CurTime()
    
    -- Check for state transition conditions
    if self.tacticalState == AI_STATES.PATROL then
        if self:DetectPlayerActivity() then
            self:ChangeState(AI_STATES.SUSPICIOUS)
        end
    elseif self.tacticalState == AI_STATES.SUSPICIOUS then
        if self:HasVisualContact() then
            self:ChangeState(AI_STATES.HUNT)
        elseif currentTime - self.lastStateChange > TACTICAL_CONFIG.PATIENCE_TIMER then
            self:ChangeState(AI_STATES.PATROL)
        end
    elseif self.tacticalState == AI_STATES.HUNT then
        if self:CanExecuteTakedown() then
            self:ChangeState(AI_STATES.ENGAGE)
        elseif self:IsCompromised() then
            self:ChangeState(AI_STATES.DISAPPEAR)
        end
    elseif self.tacticalState == AI_STATES.ENGAGE then
        if self:ShouldRetreat() then
            self:ChangeState(AI_STATES.DISAPPEAR)
        end
    elseif self.tacticalState == AI_STATES.DISAPPEAR then
        if self:IsSafeToReset() then
            self:ChangeState(AI_STATES.PATROL)
        end
    elseif self.tacticalState == AI_STATES.WALL_CLIMBING then
        if not self.isClimbing then
            self:ChangeState(AI_STATES.PATROL)
        end
    elseif self.tacticalState == AI_STATES.EVASIVE_MANEUVER then
        if #self.evasionTargets == 0 then
            self:ChangeState(AI_STATES.PATROL)
        end
    elseif self.tacticalState == AI_STATES.TACTICAL_SMOKE then
        if self.smokeGrenades <= 0 then
            self:ChangeState(AI_STATES.ENGAGE)
        end
    elseif self.tacticalState == AI_STATES.NIGHT_VISION_HUNT then
        if not self.nightVisionActive or not IsValid(self.targetPlayer) then
            self:ChangeState(AI_STATES.HUNT)
        end
    end
end

function ENT:ChangeState(newState)
    if not IsValid(self) then return end
    if self.tacticalState ~= newState then
        self.tacticalState = newState
        self.lastStateChange = CurTime()
        self:OnStateChange(newState)
    end
end

function ENT:OnStateChange(newState)
    if not IsValid(self) then return end
    
    -- Handle state-specific initialization
    if newState == AI_STATES.PATROL then
        self.currentObjective = "patrol"
        self:FindPatrolRoute()
    elseif newState == AI_STATES.SUSPICIOUS then
        self.currentObjective = "investigate"
        self:MoveToLastKnownPosition()
    elseif newState == AI_STATES.HUNT then
        self.currentObjective = "stalk"
        self:FindCoverPosition()
    elseif newState == AI_STATES.ENGAGE then
        self.currentObjective = "execute_takedown"
        self:PrepareAmbush()
    elseif newState == AI_STATES.DISAPPEAR then
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
        -- Try alternative pathfinding with different parameters
        local altPath = Path("Follow")
        altPath:SetMinLookAheadDistance(200)
        altPath:SetGoalTolerance(50)
        altPath:Compute(self, targetPos)
        
        if altPath:IsValid() then
            self.currentPath = altPath
        else
            -- Direct movement if pathfinding fails
            self:SetLastPosition(targetPos)
            return
        end
    else
        self.currentPath = path
    end
end

-- CRITICAL FIX: Add proper NextBot movement implementation
function ENT:UpdateMovement()
    if not IsValid(self) then return end
    
    -- Handle path following
    if self.currentPath and self.currentPath:IsValid() then
        self.currentPath:Update(self)
        
        -- Check if we've reached the goal
        if self.currentPath:GetAge() > 10 or self:GetPos():Distance(self.targetPosition) < 50 then
            self.currentPath:Invalidate()
            self.currentPath = nil
            self.targetPosition = nil
        end
    end
    
    -- Handle direct movement if no path
    if self.targetPosition and not self.currentPath then
        local direction = (self.targetPosition - self:GetPos()):GetNormalized()
        local distance = self:GetPos():Distance(self.targetPosition)
        
        if distance > 20 then
            -- Move towards target
            self:SetVelocity(direction * self:GetDesiredSpeed())
            
            -- Face the direction we're moving
            local angle = math.deg(math.atan2(direction.y, direction.x))
            self:SetAngles(Angle(0, angle, 0))
        else
            -- Reached target
            self.targetPosition = nil
        end
    end
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
function ENT:ExecutePatrol()
    -- PATROL STATE: Low alert, stealth movement
    -- Movement Style: Slow HL2 pistol walk anim (ACT_WALK_PISTOL)
    -- Occasionally pauses in pistol idle anim (ACT_IDLE_PISTOL)
    
    -- Set movement speed for patrol
    if IsValid(self) then
        self:SetDesiredSpeed(TACTICAL_CONFIG.PATROL_SPEED)
        self:SetMaxSpeed(TACTICAL_CONFIG.PATROL_SPEED)
    end
    
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
    
    -- Atmosphere: NVG hum when scanning dark areas
    if math.random() < 0.01 then
        self:PlayNVGHum()
    end
    
    -- Quiet radio whispers
    if math.random() < 0.005 then
        self:WhisperRadio()
    end
    
    -- Breaks light sources to create cover
    self:DisableNearbyLights()
    
    -- Keeps to shadows, walls, and alternative routes
    self:PreferShadowsAndWalls()
    
    -- Occasionally pause for scanning
    if math.random() < 0.02 then
        self:PauseForScanning()
    end
end

-- CRITICAL FIX: Add missing helper functions
function ENT:DisableNearbyLights()
    -- Find and disable nearby light sources
    local lights = ents.FindByClass("light*")
    for _, light in pairs(lights) do
        if IsValid(light) and self:GetPos():Distance(light:GetPos()) < TACTICAL_CONFIG.LIGHT_DISABLE_RANGE then
            if light:GetClass() == "light" or light:GetClass() == "light_spot" then
                light:Fire("TurnOff")
            end
        end
    end
end

function ENT:PreferShadowsAndWalls()
    -- Move towards darker areas when possible
    local currentLight = self:GetLightLevel(self:GetPos())
    if currentLight > 0.5 then
        -- Try to find a darker path
        local darkerPos = self:FindDarkerPosition()
        if darkerPos then
            self:MoveToPosition(darkerPos)
        end
    end
end

function ENT:FindDarkerPosition()
    local currentPos = self:GetPos()
    local searchRadius = 200
    
    for i = 1, 8 do
        local angle = i * 45
        local dir = Angle(0, angle, 0):Forward()
        local testPos = currentPos + dir * searchRadius
        
        local lightLevel = self:GetLightLevel(testPos)
        if lightLevel < 0.3 then
            return testPos
        end
    end
    
    return nil
end

function ENT:PauseForScanning()
    -- Pause movement and scan the area
    self:SetDesiredSpeed(0)
    self:SetMaxSpeed(0)
    
    -- Resume after a short delay
    timer.Simple(2, function()
        if IsValid(self) then
            self:SetDesiredSpeed(TACTICAL_CONFIG.PATROL_SPEED)
            self:SetMaxSpeed(TACTICAL_CONFIG.PATROL_SPEED)
        end
    end)
end

function ENT:PlayNVGHum()
    -- Play NVG hum sound effect
    self:EmitSound("ambient/machines/steam_release_1.wav", 50, 100, 0.3)
end

function ENT:WhisperRadio()
    -- Play radio whisper sound
    self:EmitSound("npc/metropolice/vo/takecover.wav", 30, 100, 0.2)
end

function ENT:FlashNVG()
    -- Flash NVG effect
    self:EmitSound("weapons/flashbang/flash_explode2.wav", 40, 120, 0.1)
end

function ENT:IsTakedownComplete()
    -- Check if takedown animation is finished
    return not self:IsMoving() and self.targetPlayer == nil
end

-- CRITICAL FIX: Add missing detection and utility functions
function ENT:DetectPlayerActivity()
    -- Check for nearby players
    local players = player.GetAll()
    for _, player in pairs(players) do
        if IsValid(player) and player:Alive() then
            local distance = self:GetPos():Distance(player:GetPos())
            if distance < TACTICAL_CONFIG.STEALTH_RADIUS then
                -- Check if player is making noise or visible
                if self:CanSeePlayer(player) or self:CanHearPlayer(player) then
                    self.targetPlayer = player
                    self.lastKnownPosition = player:GetPos()
                    return true
                end
            end
        end
    end
    return false
end

function ENT:CanSeePlayer(player)
    if not IsValid(player) then return false end
    
    local trace = util.TraceLine({
        start = self:GetPos() + Vector(0, 0, 50),
        endpos = player:GetPos() + Vector(0, 0, 50),
        filter = {self, player},
        mask = MASK_SOLID
    })
    
    return not trace.Hit and self:GetPos():Distance(player:GetPos()) < TACTICAL_CONFIG.STEALTH_RADIUS
end

function ENT:CanHearPlayer(player)
    if not IsValid(player) then return false end
    
    local distance = self:GetPos():Distance(player:GetPos())
    local velocity = player:GetVelocity():Length()
    
    -- Players make more noise when moving fast
    local noiseRadius = 100 + (velocity / 10)
    
    return distance < noiseRadius
end

function ENT:HasVisualContact()
    return IsValid(self.targetPlayer) and self:CanSeePlayer(self.targetPlayer)
end

function ENT:CanExecuteTakedown()
    if not IsValid(self.targetPlayer) then return false end
    
    local distance = self:GetPos():Distance(self.targetPlayer:GetPos())
    return distance < TACTICAL_CONFIG.TAKEDOWN_RANGE
end

function ENT:IsCompromised()
    return self.stealthLevel < 0.3
end

function ENT:ShouldRetreat()
    return self:Health() < TACTICAL_CONFIG.RETREAT_HEALTH
end

function ENT:IsSafeToReset()
    return not self:DetectPlayerActivity() and self:Health() > TACTICAL_CONFIG.RETREAT_HEALTH
end

function ENT:GetLightLevel(position)
    -- Simple light level calculation
    local trace = util.TraceLine({
        start = position + Vector(0, 0, 100),
        endpos = position + Vector(0, 0, 200),
        filter = self,
        mask = MASK_SOLID
    })
    
    if trace.Hit then
        return 0.2  -- In shadow
    else
        return 0.8  -- In light
    end
end

function ENT:HasCover(position)
    -- Check if position has cover
    local trace = util.TraceLine({
        start = position,
        endpos = position + Vector(0, 0, 50),
        filter = self,
        mask = MASK_SOLID
    })
    
    return trace.Hit
end

function ENT:ExecuteSuspicious()
    -- SUSPICIOUS STATE: Searching, investigating noises
    -- Movement Style: HL2 pistol crouch-walk anim (ACT_WALK_CROUCH_PISTOL)
    -- Alternates between crouch-walk and pistol idle
    -- Aims weapon while sweeping corners
    
    -- Set movement speed for suspicious state
    if IsValid(self) then
        self:SetDesiredSpeed(TACTICAL_CONFIG.SUSPICIOUS_SPEED)
        self:SetMaxSpeed(TACTICAL_CONFIG.SUSPICIOUS_SPEED)
    end
    
    -- Build Suspicion Meter
    self.suspicionMeter = self.suspicionMeter or 0
    self.suspicionMeter = math.min(TACTICAL_CONFIG.MAX_SUSPICION, 
        self.suspicionMeter + TACTICAL_CONFIG.SUSPICION_INCREASE_RATE * FrameTime())
    
    -- Check if suspicion reaches 100 → Hunt Mode
    if self.suspicionMeter >= TACTICAL_CONFIG.MAX_SUSPICION then
        self:ChangeState(AI_STATES.HUNT)
        return
    end
    
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
    
    -- Behavior: Investigates noise sources tactically (doesn't rush head-on)
    self:InvestigateTactically()
    
    -- Flashes NVG on/off while scanning
    if math.random() < 0.03 then
        self:FlashNVG()
    end
end

-- CRITICAL FIX: Add missing state execution functions
function ENT:ExecuteHunt()
    -- HUNT STATE: High alert, tactical stalking
    if IsValid(self) then
        self:SetDesiredSpeed(TACTICAL_CONFIG.HUNT_SPEED)
        self:SetMaxSpeed(TACTICAL_CONFIG.HUNT_SPEED)
    end
    
    -- Move towards target while staying in cover
    if IsValid(self.targetPlayer) then
        local coverPos = self:FindOptimalCoverPosition(self.targetPlayer:GetPos())
        if coverPos then
            self:MoveToPosition(coverPos)
        else
            self:MoveToPosition(self.targetPlayer:GetPos())
        end
    end
end

function ENT:ExecuteEngage()
    -- ENGAGE STATE: Combat engagement
    if IsValid(self) then
        self:SetDesiredSpeed(TACTICAL_CONFIG.ENGAGE_SPEED)
        self:SetMaxSpeed(TACTICAL_CONFIG.ENGAGE_SPEED)
    end
    
    -- Execute takedown if close enough
    if self:CanExecuteTakedown() then
        self:ExecuteTakedown()
    else
        -- Move closer to target
        if IsValid(self.targetPlayer) then
            self:MoveToPosition(self.targetPlayer:GetPos())
        end
    end
end

function ENT:ExecuteTakedown()
    -- Execute silent takedown
    if IsValid(self.targetPlayer) then
        -- Damage the player
        self.targetPlayer:TakeDamage(50, self, self)
        
        -- Play takedown sound
        self:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 80, 100, 0.5)
        
        -- Clear target
        self.targetPlayer = nil
        self:ChangeState(AI_STATES.DISAPPEAR)
    end
end

function ENT:ExecuteDisappear()
    -- DISAPPEAR STATE: Reset/retreat with smoke
    if IsValid(self) then
        self:SetDesiredSpeed(TACTICAL_CONFIG.DISAPPEAR_SPEED)
        self:SetMaxSpeed(TACTICAL_CONFIG.DISAPPEAR_SPEED)
    end
    
    -- Use smoke grenade if available
    if self.smokeGrenades > 0 then
        self:UseSmokeGrenade()
    end
    
    -- Find escape route
    local escapePos = self:FindEscapeRoute()
    if escapePos then
        self:MoveToPosition(escapePos)
    end
end

function ENT:ExecuteWallClimbing()
    -- WALL_CLIMBING STATE: Vertical traversal
    if not self.isClimbing then
        self:ChangeState(AI_STATES.PATROL)
        return
    end
    
    -- Continue climbing animation
    self:PlayAnimation("crouch_walk")
end

function ENT:ExecuteEvasiveManeuver()
    -- EVASIVE_MANEUVER STATE: Performing evasive movements
    if #self.evasionTargets == 0 then
        self:ChangeState(AI_STATES.PATROL)
        return
    end
    
    -- Perform evasive movement
    local evasionPos = self.evasionTargets[1]
    self:MoveToPosition(evasionPos)
end

function ENT:ExecuteTacticalSmoke()
    -- TACTICAL_SMOKE STATE: Using smoke grenades tactically
    if self.smokeGrenades <= 0 then
        self:ChangeState(AI_STATES.ENGAGE)
        return
    end
    
    -- Use smoke grenade
    self:UseSmokeGrenade()
    self:ChangeState(AI_STATES.ENGAGE)
end

function ENT:ExecuteNightVisionHunt()
    -- NIGHT_VISION_HUNT STATE: Enhanced hunting with night vision
    if not self.nightVisionActive or not IsValid(self.targetPlayer) then
        self:ChangeState(AI_STATES.HUNT)
        return
    end
    
    -- Enhanced hunting with night vision
    self:ExecuteHunt()
end

function ENT:InvestigateTactically()
    -- Move to last known position tactically
    if self.lastKnownPosition and self.lastKnownPosition ~= Vector(0, 0, 0) then
        self:MoveToPosition(self.lastKnownPosition)
    end
end

function ENT:SearchArea()
    -- Search the current area
    local searchPos = self:GetPos() + VectorRand() * 200
    self:MoveToPosition(searchPos)
end

function ENT:UseSmokeGrenade()
    if self.smokeGrenades > 0 then
        self.smokeGrenades = self.smokeGrenades - 1
        
        -- Create smoke effect
        local smokePos = self:GetPos()
        local effect = EffectData()
        effect:SetOrigin(smokePos)
        effect:SetScale(TACTICAL_CONFIG.SMOKE_RADIUS / 100)
        util.Effect("smoke", effect)
        
        -- Play smoke sound
        self:EmitSound("weapons/smokegrenade/sg_explode.wav", 80, 100, 0.5)
    end
end
    
    -- Aims weapon while sweeping corners
    self:AimWhileSweeping()
    
    -- Alternates between crouch-walk and pistol idle
    if math.random() < 0.1 then
        self:AlternateCrouchAndIdle()
    end
end

function ENT:ExecuteHunt()
    -- HUNT STATE: High alert, tactical stalking
    -- Movement Style: Mix of pistol walk + crouch-walk depending on cover
    -- Uses walls, vents, and vertical traversal to flank
    
    -- Set movement speed for hunt
    if IsValid(self) then
        if self.SetDesiredSpeed then
            self:SetDesiredSpeed(TACTICAL_CONFIG.HUNT_SPEED)
        elseif self.SetMaxSpeed then
            self:SetMaxSpeed(TACTICAL_CONFIG.HUNT_SPEED)
        end
    end
    
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
    
    -- Behavior: Uses cover-to-cover movement (never open-field rushing)
    self:UseCoverToCoverMovement()
    
    -- Tries to circle the player instead of beelining
    self:CirclePlayer()
    
    -- Can rappel from ceilings/ledges for ambush
    if math.random() < 0.02 then
        self:AttemptRappel()
    end
    
    -- Will throw a flashbang or EMP if player holds a chokepoint
    if self:IsPlayerInChokepoint() then
        self:ThrowTacticalGrenade()
    end
    
    -- Mix of pistol walk + crouch-walk depending on cover
    self:AdaptMovementToCover()
    
    -- Uses walls, vents, and vertical traversal to flank
    self:UseVerticalTraversal()
end

function ENT:ExecuteEngage()
    -- ENGAGE STATE: Combat engagement
    -- Weapons: Suppressed pistol or SMG only
    -- Movement Style: Fires from pistol idle anim stance
    -- Crouch-walks during gunfights for smaller hitbox
    -- Dodges side-to-side while shooting (combat evasive walk)
    
    -- Set movement speed for engagement
    if IsValid(self) then
        if self.SetDesiredSpeed then
            self:SetDesiredSpeed(TACTICAL_CONFIG.ENGAGE_SPEED)
        elseif self.SetMaxSpeed then
            self:SetMaxSpeed(TACTICAL_CONFIG.ENGAGE_SPEED)
        end
    end
    
    -- Execute silent takedown if possible
    if IsValid(self.targetPlayer) and self:CanExecuteTakedown() then
        self:PerformSilentTakedown()
        return
    end
    
    -- Behavior: Prefers stealth melee takedown if behind the player
    if self:IsBehindPlayer() then
        self:AttemptStealthTakedown()
        return
    end
    
    -- Aims for quick precision shots, not spray
    if IsValid(self.targetPlayer) then
        self:FirePrecisionShots()
    end
    
    -- Fires from pistol idle anim stance
    self:FireFromIdleStance()
    
    -- Crouch-walks during gunfights for smaller hitbox
    self:CrouchDuringGunfight()
    
    -- Dodges side-to-side while shooting (combat evasive walk)
    self:DodgeWhileShooting()
    
    -- Can blind player by breaking lights or using gadgets
    if math.random() < 0.05 then
        self:BlindPlayer()
    end
end

function ENT:ExecuteDisappear()
    -- DISAPPEAR STATE: Reset/retreat with smoke
    -- Movement Style: Deploys smoke → crouch-walks backwards into shadows
    -- Resets into patrol mode if player loses track
    
    -- Set movement speed for disappear
    if IsValid(self) then
        if self.SetDesiredSpeed then
            self:SetDesiredSpeed(TACTICAL_CONFIG.DISAPPEAR_SPEED)
        elseif self.SetMaxSpeed then
            self:SetMaxSpeed(TACTICAL_CONFIG.DISAPPEAR_SPEED)
        end
    end
    
    -- Handle path movement for retreat
    if self.currentPath and self.currentPath:IsValid() then
        self.currentPath:Update(self)
    end
    
    -- Behavior: Deploys smoke → crouch-walks backwards into shadows
    if CurTime() - self.smokeLastUsed > TACTICAL_CONFIG.SMOKE_COOLDOWN then
        self:DeploySmoke()
    end
    
    -- Crouch-walks backwards into shadows
    self:CrouchWalkBackwards()
    
    -- May leave fake noise (thrown object) to mislead
    if math.random() < 0.1 then
        self:CreateFakeNoise()
    end
    
    -- Will not re-engage immediately; stalks again for ambush
    self:ResetForAmbush()
    
    -- Resets into patrol mode if player loses track
    if self:HasPlayerLostTrack() then
        self:ChangeState(AI_STATES.PATROL)
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
        self:ChangeState(AI_STATES.PATROL)
    end
end

function ENT:ExecuteTacticalSmoke()
    -- Use smoke grenades for tactical advantage
    if self.smokeGrenades > 0 then
        self:DeployTacticalSmoke()
    else
        -- No smoke grenades available, return to previous state
        self:ChangeState(AI_STATES.ENGAGE)
    end
end

function ENT:ExecuteNightVisionHunt()
    -- Enhanced hunting with night vision capabilities
    if self.nightVisionActive then
        self:PerformNightVisionHunt()
    else
        -- Night vision not available, use normal hunting
        self:ChangeState(AI_STATES.HUNT)
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
        -- Check if path is still valid with error handling
        local pathBlocked = false
        local success, err = pcall(function()
            pathBlocked = self:IsPathBlocked()
        end)
        
        if not success then
            print("[SplinterCellAI] Error checking path: " .. tostring(err))
            pathBlocked = true
        end
        
        if pathBlocked then
            if self.currentPath and self.currentPath.Invalidate then
                self.currentPath:Invalidate()
            end
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
    if nextSegment and nextSegment.pos then
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
    if self.tacticalState == AI_STATES.ENGAGE and IsValid(self.targetPlayer) then
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
        if self.tacticalState == AI_STATES.PATROL then
            self:ChangeState(AI_STATES.SUSPICIOUS)
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
    
    -- Ensure we always have a valid animation sequence to prevent T-posing
    if self:GetSequence() <= 0 then
        local idleSeq = self:LookupSequence("idle")
        if idleSeq and idleSeq > 0 then
            self:SetSequence(idleSeq)
        else
            self:SetSequence(0)
        end
    end
    
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
    
    -- Update networked stealth level for client-side effects
    self:SetNWFloat("stealthLevel", self.stealthLevel)
end

function ENT:HandleImmediateThreats()
    -- Check for immediate threats that require instant response
    local players = player.GetAll()
    local currentTime = CurTime()
    
    -- Don't change targets too frequently
    if currentTime - self.lastTargetChange < self.targetChangeCooldown then
        return
    end
    
    for _, player in pairs(players) do
        if IsValid(player) and player:Alive() then
            local distance = self:GetPos():Distance(player:GetPos())
            
            -- Immediate threat detection (reduced range for less aggressive behavior)
            if distance < 30 then
                -- Player is very close, immediate response needed
                if self.tacticalState == AI_STATES.PATROL then
                    self:ChangeState(AI_STATES.SUSPICIOUS)
                end
                self.targetPlayer = player
                self.lastKnownPosition = player:GetPos()
                self.lastTargetChange = currentTime
                return
            end
            
            -- Check if player is looking directly at us (reduced sensitivity)
            if self:IsPlayerLookingAtMe(player) and distance < 100 then
                self.stealthLevel = math.max(0.0, self.stealthLevel - 0.03) -- Reduced penalty
                if self.stealthLevel < 0.2 then -- Lower threshold
                    self:ChangeState(AI_STATES.ENGAGE)
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
        if self.tacticalState == AI_STATES.ENGAGE then
            -- Execute immediate takedown
            self:PerformSilentTakedown()
        elseif self.tacticalState == AI_STATES.HUNT then
            -- Player bumped into us, become aggressive
            self:ChangeState(AI_STATES.ENGAGE)
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
        if self.tacticalState == AI_STATES.PATROL then
            -- Surprise attack
            self.targetPlayer = activator
            self:ChangeState(AI_STATES.SUSPICIOUS)
        else
            -- Defensive response
            self:ChangeState(AI_STATES.ENGAGE)
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
        if self.tacticalState == AI_STATES.PATROL or self.tacticalState == AI_STATES.SUSPICIOUS then
            self:ChangeState(AI_STATES.ENGAGE)
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
    self:ChangeState(AI_STATES.PATROL)
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
        self:ChangeState(AI_STATES.HUNT)
    else
        self:ChangeState(AI_STATES.PATROL)
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
    self:ChangeState(AI_STATES.ENGAGE)
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
    
    -- Add more realistic spread and accuracy penalties
    local distance = self:GetPos():Distance(self.targetPlayer:GetPos())
    local distancePenalty = math.min(1.0, distance / 500) -- Accuracy decreases with distance
    local movementPenalty = self:IsMoving() and 0.3 or 0.0 -- Moving reduces accuracy
    local finalAccuracy = accuracy * (1.0 - distancePenalty) * (1.0 - movementPenalty)
    
    -- Add accuracy-based spread with more realistic values
    local spread = (1.0 - finalAccuracy) * 150  -- Increased spread for less aimbotty behavior
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

-- Enhanced Tactical Behavior Functions
-- Supporting functions for the new Splinter Cell AI states

-- Patrol State Functions
function ENT:PlayNVGHum()
    -- Play NVG hum sound when scanning dark areas
    self:EmitSound("ambient/machines/steam_release_1.wav", 30, 80)
    
    -- Create visual effect for NVG
    local effect = EffectData()
    effect:SetOrigin(self:GetPos() + Vector(0, 0, 50))
    effect:SetScale(0.5)
    util.Effect("cball_bounce", effect)
end

function ENT:WhisperRadio()
    -- Quiet radio whispers for atmosphere
    local whispers = {
        "Target area clear...",
        "Maintaining position...",
        "No activity detected...",
        "Continuing patrol..."
    }
    
    local whisper = whispers[math.random(1, #whispers)]
    
    -- Send whisper to nearby players
    local players = player.GetAll()
    for _, player in pairs(players) do
        if IsValid(player) and player:Alive() then
            local distance = self:GetPos():Distance(player:GetPos())
            if distance < TACTICAL_CONFIG.WHISPER_RADIUS then
                net.Start("SplinterCellWhisper")
                net.WriteString(whisper)
                net.Send(player)
            end
        end
    end
end

function ENT:PreferShadowsAndWalls()
    -- Prefer movement along walls and in shadows
    local currentPos = self:GetPos()
    local lightLevel = self:GetLightLevel(currentPos)
    
    -- If in bright light, try to move to shadows
    if lightLevel > 0.7 then
        local shadowPos = self:FindNearestShadow()
        if shadowPos then
            self:MoveToPosition(shadowPos)
        end
    end
    
    -- Prefer movement along walls
    self:PreferWallMovement()
end

function ENT:PauseForScanning()
    -- Pause movement and scan the area
    self:PlayAnimation("idle")
    
    -- Look around slowly
    local currentAngles = self:GetAngles()
    local newYaw = currentAngles.yaw + math.random(-45, 45)
    self:SetAngles(Angle(currentAngles.pitch, newYaw, currentAngles.roll))
    
    -- Play scanning sound
    self:EmitSound("ambient/machines/steam_release_2.wav", 25, 90)
end

-- Suspicious State Functions
function ENT:InvestigateTactically()
    -- Investigate noise sources without rushing head-on
    if self.lastKnownPosition and self.lastKnownPosition ~= Vector(0, 0, 0) then
        local distance = self:GetPos():Distance(self.lastKnownPosition)
        
        -- Approach from cover if possible
        if distance > 100 then
            local coverPos = self:FindCoverApproach(self.lastKnownPosition)
            if coverPos then
                self:MoveToPosition(coverPos)
            else
                self:MoveToPosition(self.lastKnownPosition)
            end
        end
    end
end

function ENT:FlashNVG()
    -- Flash NVG on/off while scanning
    self.nightVisionActive = not self.nightVisionActive
    self:SetNWBool("nightVisionActive", self.nightVisionActive)
    
    -- Create flash effect
    local effect = EffectData()
    effect:SetOrigin(self:GetPos() + Vector(0, 0, 50))
    effect:SetScale(1.0)
    util.Effect("cball_bounce", effect)
    
    -- Play NVG toggle sound
    self:EmitSound("buttons/button14.wav", 40, 100)
end

function ENT:AimWhileSweeping()
    -- Aim weapon while sweeping corners
    if not self.isAiming then
        self.isAiming = true
        self:PlayAnimation("aim")
    end
    
    -- Sweep weapon left and right
    local currentAngles = self:GetAngles()
    local sweepAmount = math.sin(CurTime() * 2) * 30
    self:SetAngles(Angle(currentAngles.pitch, currentAngles.yaw + sweepAmount, currentAngles.roll))
end

function ENT:AlternateCrouchAndIdle()
    -- Alternate between crouch-walk and pistol idle
    if not self.isCrouching then
        self.isCrouching = true
        self:PlayAnimation("crouch_walk")
    else
        self.isCrouching = false
        self:PlayAnimation("idle")
    end
end

-- Hunt State Functions
function ENT:UseCoverToCoverMovement()
    -- Use cover-to-cover movement instead of open-field rushing
    if IsValid(self.targetPlayer) then
        local targetPos = self.targetPlayer:GetPos()
        local currentPos = self:GetPos()
        
        -- Find next cover position
        local nextCover = self:FindNextCoverPosition(targetPos)
        if nextCover then
            self:MoveToPosition(nextCover)
        end
    end
end

function ENT:CirclePlayer()
    -- Try to circle the player instead of beelining
    if IsValid(self.targetPlayer) then
        local currentTime = CurTime()
        if currentTime - self.lastCircleUpdate > 2.0 then
            -- Change circle direction occasionally
            if math.random() < 0.3 then
                self.circleDirection = self.circleDirection * -1
            end
            self.lastCircleUpdate = currentTime
        end
        
        local targetPos = self.targetPlayer:GetPos()
        local myPos = self:GetPos()
        local direction = (myPos - targetPos):GetNormalized()
        
        -- Calculate perpendicular direction for circling
        local perpendicular = Vector(-direction.y, direction.x, 0) * self.circleDirection
        local circlePos = targetPos + direction * 200 + perpendicular * 150
        
        self:MoveToPosition(circlePos)
    end
end

function ENT:AttemptRappel()
    -- Attempt to rappel from ceilings/ledges for ambush
    if CurTime() - self.lastRappelAttempt < 10.0 then return end
    
    local rappelPos = self:FindRappelPosition()
    if rappelPos then
        self.rappelling = true
        self.lastRappelAttempt = CurTime()
        self:MoveToPosition(rappelPos)
        
        -- Create rappel effect
        local effect = EffectData()
        effect:SetOrigin(rappelPos)
        effect:SetScale(1.0)
        util.Effect("cball_bounce", effect)
    end
end

function ENT:IsPlayerInChokepoint()
    -- Check if player is in a chokepoint
    if not IsValid(self.targetPlayer) then return false end
    
    local targetPos = self.targetPlayer:GetPos()
    local exits = self:FindExits(targetPos)
    
    -- If there are few exits, it's a chokepoint
    return #exits <= 2
end

function ENT:ThrowTacticalGrenade()
    -- Throw flashbang or EMP if player holds a chokepoint
    if self.grenadesAvailable <= 0 then return end
    
    if IsValid(self.targetPlayer) then
        local grenadeType = math.random() < 0.5 and "flashbang" or "emp"
        self:ThrowGrenade(grenadeType, self.targetPlayer:GetPos())
        self.grenadesAvailable = self.grenadesAvailable - 1
        self:SetNWInt("grenadesAvailable", self.grenadesAvailable)
    end
end

function ENT:AdaptMovementToCover()
    -- Mix of pistol walk + crouch-walk depending on cover
    local lightLevel = self:GetLightLevel(self:GetPos())
    
    if lightLevel < 0.3 then
        -- In shadows, use normal walk
        if self.isCrouching then
            self.isCrouching = false
            self:PlayAnimation("walk")
        end
    else
        -- In light, use crouch walk
        if not self.isCrouching then
            self.isCrouching = true
            self:PlayAnimation("crouch_walk")
        end
    end
end

function ENT:UseVerticalTraversal()
    -- Use walls, vents, and vertical traversal to flank
    if math.random() < 0.01 then
        -- Try to find vertical path
        local verticalPath = self:FindVerticalPath()
        if verticalPath then
            self:MoveToPosition(verticalPath)
        end
    end
end

-- Engage State Functions
function ENT:IsBehindPlayer()
    -- Check if we're behind the player
    if not IsValid(self.targetPlayer) then return false end
    
    local playerForward = self.targetPlayer:GetForward()
    local toMe = (self:GetPos() - self.targetPlayer:GetPos()):GetNormalized()
    local dot = playerForward:Dot(toMe)
    
    return dot < -0.7  -- Behind the player
end

function ENT:AttemptStealthTakedown()
    -- Attempt stealth melee takedown from behind
    if not IsValid(self.targetPlayer) then return end
    
    local distance = self:GetPos():Distance(self.targetPlayer:GetPos())
    if distance < TACTICAL_CONFIG.TAKEDOWN_RANGE then
        -- Perform stealth takedown
        self:PerformSilentTakedown()
    else
        -- Move closer for takedown
        self:MoveToPosition(self.targetPlayer:GetPos())
    end
end

function ENT:FirePrecisionShots()
    -- Fire precision shots instead of spray
    if CurTime() - self.lastShotTime < 0.8 then return end
    
    if IsValid(self.targetPlayer) then
        self:FireSuppressedShot()
    end
end

function ENT:FireFromIdleStance()
    -- Fire from pistol idle anim stance
    if not self.isAiming then
        self.isAiming = true
        self:PlayAnimation("aim")
    end
end

function ENT:CrouchDuringGunfight()
    -- Crouch-walk during gunfights for smaller hitbox
    if not self.isCrouching then
        self.isCrouching = true
        self:PlayAnimation("crouch_walk")
    end
end

function ENT:DodgeWhileShooting()
    -- Dodge side-to-side while shooting
    local dodgeAmount = math.sin(CurTime() * 4) * 20
    local currentPos = self:GetPos()
    local dodgePos = currentPos + Vector(dodgeAmount, 0, 0)
    
    self:SetLastPosition(dodgePos)
end

function ENT:BlindPlayer()
    -- Blind player by breaking lights or using gadgets
    if IsValid(self.targetPlayer) then
        -- Break nearby lights
        self:BreakNearbyLights()
        
        -- Flash goggles effect
        net.Start("SplinterCellFlash")
        net.WriteVector(self:GetPos())
        net.Send(self.targetPlayer)
    end
end

-- CRITICAL FIX: Add missing environment control and utility functions
function ENT:ControlEnvironment()
    -- Control lighting and environment
    self:DisableNearbyLights()
end

function ENT:ExecutePsychologicalOps()
    -- Execute psychological operations
    if math.random() < 0.01 then
        self:WhisperRadio()
    end
end

function ENT:ExecuteEnhancedNavigation()
    -- Enhanced navigation and evasion
    if self.tacticalState == AI_STATES.HUNT then
        self:UseVerticalTraversal()
    end
end

function ENT:ExecuteNightVisionSystem()
    -- Night vision system
    if self.nightVisionActive then
        -- Enhanced vision in darkness
        local lightLevel = self:GetLightLevel(self:GetPos())
        if lightLevel < 0.3 then
            -- Activate night vision effects
            self:PlayNVGHum()
        end
    end
end

function ENT:ExecuteEnhancedCombatMechanics()
    -- Enhanced combat mechanics
    if self.tacticalState == AI_STATES.ENGAGE then
        self:FirePrecisionShots()
    end
end

function ENT:BreakNearbyLights()
    -- Break nearby light sources
    local lights = ents.FindByClass("light*")
    for _, light in pairs(lights) do
        if IsValid(light) and self:GetPos():Distance(light:GetPos()) < TACTICAL_CONFIG.LIGHT_DISABLE_RANGE then
            if light:GetClass() == "light" or light:GetClass() == "light_spot" then
                light:Fire("TurnOff")
            end
        end
    end
end

function ENT:FindVerticalPath()
    -- Find vertical path for traversal
    local currentPos = self:GetPos()
    local searchRadius = 300
    
    for i = 1, 8 do
        local angle = i * 45
        local dir = Angle(0, angle, 0):Forward()
        local testPos = currentPos + dir * searchRadius
        
        -- Check if there's a wall or climbable surface
        local trace = util.TraceLine({
            start = testPos,
            endpos = testPos + Vector(0, 0, 100),
            filter = self,
            mask = MASK_SOLID
        })
        
        if trace.Hit then
            return testPos
        end
    end
    
    return nil
end

function ENT:PerformSilentTakedown()
    -- Perform silent takedown
    if IsValid(self.targetPlayer) then
        -- Damage the player
        self.targetPlayer:TakeDamage(100, self, self)
        
        -- Play takedown sound
        self:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 80, 100, 0.5)
        
        -- Clear target
        self.targetPlayer = nil
        self:ChangeState(AI_STATES.DISAPPEAR)
    end
end

function ENT:FireSuppressedShot()
    -- Fire suppressed shot
    if CurTime() - self.lastShotTime < self.shotCooldown then return end
    
    if IsValid(self.targetPlayer) then
        -- Calculate accuracy
        local accuracy = self.combatAccuracy or 0.65
        local spread = (1 - accuracy) * 10
        
        -- Fire shot
        local bullet = {}
        bullet.Num = 1
        bullet.Src = self:GetPos() + Vector(0, 0, 50)
        bullet.Dir = (self.targetPlayer:GetPos() - self:GetPos()):GetNormalized() + VectorRand() * spread
        bullet.Spread = Vector(0, 0, 0)
        bullet.Tracer = 0
        bullet.Force = 5
        bullet.Damage = 25
        bullet.AmmoType = "Pistol"
        
        self:FireBullets(bullet)
        
        -- Play suppressed sound
        self:EmitSound("weapons/silenced/sil-1.wav", 60, 100, 0.3)
        
        -- Update shot timer
        self.lastShotTime = CurTime()
        
        -- Reduce accuracy for next shot
        self.combatAccuracy = math.max(0.3, self.combatAccuracy - TACTICAL_CONFIG.ACCURACY_DECAY)
    end
end

function ENT:AimWhileSweeping()
    -- Aim weapon while sweeping corners
    if not self.isAiming then
        self.isAiming = true
        self:PlayAnimation("aim")
    end
end
end

-- Disappear State Functions
function ENT:CrouchWalkBackwards()
    -- Crouch-walk backwards into shadows
    if not self.isCrouching then
        self.isCrouching = true
        self:PlayAnimation("crouch_walk")
    end
    
    -- Move backwards
    local backwardPos = self:GetPos() - self:GetForward() * 50
    self:SetLastPosition(backwardPos)
end

function ENT:CreateFakeNoise()
    -- Create fake noise to mislead player
    if CurTime() - self.lastFakeNoise < 5.0 then return end
    
    local fakePos = self:GetPos() + VectorRand() * 200
    fakePos.z = self:GetPos().z
    
    -- Create sound effect
    sound.Play("physics/plastic/plastic_box_impact_soft" .. math.random(1, 3) .. ".wav", fakePos, 60, 100, 1)
    
    self.lastFakeNoise = CurTime()
end

function ENT:ResetForAmbush()
    -- Reset for future ambush
    self.suspicionMeter = 0
    self.stealthLevel = math.min(1.0, self.stealthLevel + 0.1)
    self.targetPlayer = nil
end

function ENT:HasPlayerLostTrack()
    -- Check if player has lost track of us
    if not IsValid(self.targetPlayer) then return true end
    
    local distance = self:GetPos():Distance(self.targetPlayer:GetPos())
    local timeSinceLastSight = CurTime() - self.lastPlayerSight
    
    -- Player has lost track if we're far away and haven't been seen recently
    return distance > TACTICAL_CONFIG.STEALTH_RADIUS * 1.5 and timeSinceLastSight > 10.0
end

-- Utility Functions
function ENT:GetLightLevel(position)
    -- Get light level at position (0 = dark, 1 = bright)
    -- Since render.GetLightColor is client-side only, we'll use a server-side approximation
    -- based on time of day and environment
    local time = os.date("*t")
    local hour = time.hour
    
    -- Basic time-based lighting (0 = dark, 1 = bright)
    local baseLight = 0.5
    
    -- Adjust based on time of day
    if hour >= 6 and hour <= 18 then
        -- Daytime
        baseLight = 0.8
    elseif hour >= 19 and hour <= 21 then
        -- Evening
        baseLight = 0.6
    elseif hour >= 22 or hour <= 5 then
        -- Night
        baseLight = 0.2
    end
    
    -- Add some randomness to simulate dynamic lighting
    local randomFactor = math.random() * 0.2 - 0.1
    baseLight = math.Clamp(baseLight + randomFactor, 0.0, 1.0)
    
    -- Check for nearby light sources (props, etc.)
    local nearbyLights = ents.FindInSphere(position, 200)
    for _, ent in pairs(nearbyLights) do
        if ent:GetClass() == "light" or ent:GetClass() == "light_spot" or ent:GetClass() == "light_environment" then
            local distance = position:Distance(ent:GetPos())
            local lightInfluence = math.max(0, 1 - (distance / 200))
            baseLight = math.min(1.0, baseLight + lightInfluence * 0.3)
        end
    end
    
    return baseLight
end

-- Enhanced light level detection using client-side data when available
function ENT:GetEnhancedLightLevel(position)
    -- Try to get light level from nearby players (client-side)
    local players = player.GetAll()
    local bestLightLevel = nil
    
    for _, player in pairs(players) do
        if IsValid(player) and player:GetPos():Distance(position) < 500 then
            -- Request light level from this player
            net.Start("SplinterCellRequestLightLevel")
            net.WriteVector(position)
            net.Send(player)
            
            -- For now, use the basic method and let client-side handle the response
            -- This is a placeholder for future enhancement
        end
    end
    
    -- Fall back to server-side approximation
    return self:GetLightLevel(position)
end

function ENT:FindNearestShadow()
    -- Find nearest shadow position
    local currentPos = self:GetPos()
    local searchRadius = 200
    
    for i = 1, 8 do
        local angle = (i - 1) * 45
        local testPos = currentPos + Vector(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0) * searchRadius
        
        if self:GetLightLevel(testPos) < 0.3 then
            return testPos
        end
    end
    
    return nil
end

function ENT:FindCoverApproach(targetPos)
    -- Find cover position to approach target
    local searchRadius = 300
    local areas = navmesh.GetAllNavAreas()
    
    for _, area in pairs(areas) do
        local areaPos = area:GetCenter()
        local distanceToTarget = areaPos:Distance(targetPos)
        local distanceFromSelf = self:GetPos():Distance(areaPos)
        
        if distanceToTarget < searchRadius and distanceFromSelf < 400 then
            -- Check if this provides cover
            local trace = util.TraceLine({
                start = areaPos + Vector(0, 0, 50),
                endpos = targetPos + Vector(0, 0, 50),
                filter = {self}
            })
            
            if trace.Hit then
                return areaPos
            end
        end
    end
    
    return nil
end

function ENT:FindNextCoverPosition(targetPos)
    -- Find next cover position for cover-to-cover movement
    local currentPos = self:GetPos()
    local searchRadius = 250
    
    local areas = navmesh.GetAllNavAreas()
    for _, area in pairs(areas) do
        local areaPos = area:GetCenter()
        local distanceToTarget = areaPos:Distance(targetPos)
        local distanceFromSelf = currentPos:Distance(areaPos)
        
        if distanceToTarget < searchRadius and distanceFromSelf < 300 then
            -- Check if this provides cover
            local trace = util.TraceLine({
                start = areaPos + Vector(0, 0, 50),
                endpos = targetPos + Vector(0, 0, 50),
                filter = {self}
            })
            
            if trace.Hit then
                return areaPos
            end
        end
    end
    
    return nil
end

function ENT:FindRappelPosition()
    -- Find position to rappel from
    local currentPos = self:GetPos()
    local searchRadius = 300
    
    -- Look for higher positions
    for i = 1, 6 do
        local angle = (i - 1) * 60
        local testPos = currentPos + Vector(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0) * searchRadius
        testPos.z = testPos.z + 100  -- Look for higher position
        
        -- Check if position is accessible
        local trace = util.TraceLine({
            start = currentPos,
            endpos = testPos,
            filter = {self}
        })
        
        if not trace.Hit then
            return testPos
        end
    end
    
    return nil
end

function ENT:FindExits(position)
    -- Find exit points from a position
    local exits = {}
    local searchRadius = 200
    
    local areas = navmesh.GetAllNavAreas()
    for _, area in pairs(areas) do
        local areaPos = area:GetCenter()
        if areaPos:Distance(position) < searchRadius then
            table.insert(exits, areaPos)
        end
    end
    
    return exits
end

function ENT:FindVerticalPath()
    -- Find vertical path for traversal
    local currentPos = self:GetPos()
    
    -- Look for ladders or climbable surfaces
    local trace = util.TraceLine({
        start = currentPos,
        endpos = currentPos + Vector(0, 0, 100),
        filter = {self}
    })
    
    if trace.Hit then
        return trace.HitPos
    end
    
    return nil
end

function ENT:BreakNearbyLights()
    -- Break nearby light sources
    local lights = ents.FindByClass("light*")
    for _, light in pairs(lights) do
        if IsValid(light) then
            local distance = self:GetPos():Distance(light:GetPos())
            if distance < TACTICAL_CONFIG.LIGHT_DISABLE_RANGE then
                light:Remove()
                
                -- Create breaking effect
                local effect = EffectData()
                effect:SetOrigin(light:GetPos())
                effect:SetScale(1.0)
                util.Effect("GlassImpact", effect)
            end
        end
    end
end

function ENT:ThrowGrenade(grenadeType, targetPos)
    -- Throw tactical grenade
    local grenade = ents.Create("prop_physics")
    if IsValid(grenade) then
        grenade:SetModel("models/props_junk/watermelon01.mdl")  -- Placeholder model
        grenade:SetPos(self:GetPos() + Vector(0, 0, 50))
        grenade:SetAngles(Angle(0, 0, 0))
        grenade:Spawn()
        
        -- Apply physics to throw grenade
        local phys = grenade:GetPhysicsObject()
        if IsValid(phys) then
            local throwDir = (targetPos - self:GetPos()):GetNormalized()
            phys:SetVelocity(throwDir * 500 + Vector(0, 0, 200))
        end
        
        -- Remove grenade after a delay
        timer.Simple(3.0, function()
            if IsValid(grenade) then
                grenade:Remove()
            end
        end)
    end
end

function ENT:PreferWallMovement()
    -- Prefer movement along walls
    local currentPos = self:GetPos()
    local forward = self:GetForward()
    
    -- Check for walls on either side
    local leftTrace = util.TraceLine({
        start = currentPos,
        endpos = currentPos + forward:Cross(Vector(0, 0, 1)) * 50,
        filter = {self}
    })
    
    local rightTrace = util.TraceLine({
        start = currentPos,
        endpos = currentPos - forward:Cross(Vector(0, 0, 1)) * 50,
        filter = {self}
    })
    
    -- If near a wall, adjust movement to follow it
    if leftTrace.Hit or rightTrace.Hit then
        local wallNormal = leftTrace.Hit and leftTrace.HitNormal or rightTrace.HitNormal
        local adjustedForward = forward - wallNormal * forward:Dot(wallNormal)
        self:SetAngles(adjustedForward:Angle())
    end
end