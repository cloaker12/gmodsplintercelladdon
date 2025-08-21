-- Enhanced AI System for The Hidden
-- Provides smarter behavior for both Hidden and Human players

local PLY = FindMetaTable("Player")

-- AI States for Human players
AI_STATE_IDLE = 1
AI_STATE_PATROL = 2
AI_STATE_INVESTIGATE = 3
AI_STATE_COMBAT = 4
AI_STATE_FLEE = 5
AI_STATE_REGROUP = 6

-- AI Memory system for tracking Hidden activity
GM.AIMemory = {}
GM.AIMemory.LastSeenPositions = {}
GM.AIMemory.SuspiciousAreas = {}
GM.AIMemory.DeathLocations = {}
GM.AIMemory.SoundEvents = {}

-- Enhanced AI decision making for humans
function GM:UpdateHumanAI(ply)
    if not IsValid(ply) or ply:IsHidden() or not ply:Alive() then return end
    
    local aiState = ply:GetNWInt("AIState", AI_STATE_IDLE)
    local nearbyPlayers = self:GetNearbyPlayers(ply, 500)
    local hiddenNearby = false
    
    -- Check for Hidden presence
    for _, p in pairs(nearbyPlayers) do
        if p:IsHidden() then
            hiddenNearby = true
            break
        end
    end
    
    -- State machine for AI behavior
    if hiddenNearby then
        self:SetAIState(ply, AI_STATE_COMBAT)
        self:HandleCombatAI(ply)
    elseif #nearbyPlayers < 2 and aiState ~= AI_STATE_REGROUP then
        self:SetAIState(ply, AI_STATE_REGROUP)
        self:HandleRegroupAI(ply)
    elseif self:ShouldInvestigate(ply) then
        self:SetAIState(ply, AI_STATE_INVESTIGATE)
        self:HandleInvestigateAI(ply)
    else
        self:SetAIState(ply, AI_STATE_PATROL)
        self:HandlePatrolAI(ply)
    end
end

-- Enhanced Hidden AI for more intelligent behavior
function GM:UpdateHiddenAI(ply)
    if not IsValid(ply) or not ply:IsHidden() or not ply:Alive() then return end
    
    local nearbyHumans = {}
    local isolatedTargets = {}
    
    -- Analyze human positions and find opportunities
    for _, human in pairs(team.GetPlayers(TEAM_HUMAN)) do
        if IsValid(human) and human:Alive() then
            local dist = ply:GetPos():Distance(human:GetPos())
            if dist < 1000 then
                table.insert(nearbyHumans, {player = human, distance = dist})
                
                -- Check if human is isolated
                local humanNearbyCount = 0
                for _, other in pairs(team.GetPlayers(TEAM_HUMAN)) do
                    if other ~= human and other:Alive() and other:GetPos():Distance(human:GetPos()) < 300 then
                        humanNearbyCount = humanNearbyCount + 1
                    end
                end
                
                if humanNearbyCount == 0 then
                    table.insert(isolatedTargets, {player = human, distance = dist})
                end
            end
        end
    end
    
    -- Prioritize isolated targets
    if #isolatedTargets > 0 then
        table.sort(isolatedTargets, function(a, b) return a.distance < b.distance end)
        self:SuggestHiddenTarget(ply, isolatedTargets[1].player)
    end
    
    -- Advanced stealth suggestions
    self:UpdateHiddenStealthAI(ply, nearbyHumans)
end

-- Combat AI for human players
function GM:HandleCombatAI(ply)
    local weapon = ply:GetActiveWeapon()
    if not IsValid(weapon) then return end
    
    -- Find nearest Hidden
    local nearestHidden = nil
    local nearestDist = math.huge
    
    for _, hidden in pairs(team.GetPlayers(TEAM_HIDDEN)) do
        if IsValid(hidden) and hidden:Alive() then
            local dist = ply:GetPos():Distance(hidden:GetPos())
            if dist < nearestDist then
                nearestHidden = hidden
                nearestDist = dist
            end
        end
    end
    
    if IsValid(nearestHidden) then
        -- Enhanced combat behavior
        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = nearestHidden:EyePos(),
            filter = ply
        })
        
        if tr.Entity == nearestHidden then
            -- Direct line of sight - engage
            ply:SetNWBool("ShouldFire", true)
            ply:SetNWVector("TargetPos", nearestHidden:GetPos())
        else
            -- No line of sight - move to better position
            self:FindBetterPosition(ply, nearestHidden)
        end
    end
end

-- Regroup AI - move towards other humans
function GM:HandleRegroupAI(ply)
    local nearestAlly = nil
    local nearestDist = math.huge
    
    for _, ally in pairs(team.GetPlayers(TEAM_HUMAN)) do
        if IsValid(ally) and ally:Alive() and ally ~= ply then
            local dist = ply:GetPos():Distance(ally:GetPos())
            if dist < nearestDist then
                nearestAlly = ally
                nearestDist = dist
            end
        end
    end
    
    if IsValid(nearestAlly) then
        ply:SetNWVector("MoveTarget", nearestAlly:GetPos())
        ply:SetNWBool("ShouldRegroup", true)
    end
end

-- Investigation AI - check suspicious areas
function GM:HandleInvestigateAI(ply)
    local suspiciousAreas = self.AIMemory.SuspiciousAreas
    local closestArea = nil
    local closestDist = math.huge
    
    for pos, data in pairs(suspiciousAreas) do
        if CurTime() - data.time < 30 then -- Only investigate recent events
            local dist = ply:GetPos():Distance(pos)
            if dist < closestDist then
                closestArea = pos
                closestDist = dist
            end
        end
    end
    
    if closestArea then
        ply:SetNWVector("InvestigatePos", closestArea)
        ply:SetNWBool("ShouldInvestigate", true)
    end
end

-- Patrol AI - move around the map systematically
function GM:HandlePatrolAI(ply)
    -- Simple patrol behavior - can be enhanced with waypoint system
    if not ply:GetNWBool("HasPatrolTarget", false) or 
       ply:GetPos():Distance(ply:GetNWVector("PatrolTarget", Vector(0,0,0))) < 100 then
        
        -- Find new patrol target
        local spawnPoints = {}
        for _, ent in pairs(ents.FindByClass("info_player_start")) do
            table.insert(spawnPoints, ent:GetPos())
        end
        
        if #spawnPoints > 0 then
            local target = spawnPoints[math.random(#spawnPoints)]
            ply:SetNWVector("PatrolTarget", target)
            ply:SetNWBool("HasPatrolTarget", true)
        end
    end
end

-- Enhanced stealth AI for Hidden
function GM:UpdateHiddenStealthAI(ply, nearbyHumans)
    local stealthLevel = self:CalculateStealthLevel(ply, nearbyHumans)
    
    if stealthLevel < 0.3 then
        -- High visibility - suggest retreat
        ply:SetNWBool("ShouldRetreat", true)
        self:FindHidingSpot(ply)
    elseif stealthLevel > 0.7 then
        -- Good stealth - suggest aggressive action
        ply:SetNWBool("CanAggress", true)
    end
    
    -- Suggest ambush positions
    self:SuggestAmbushPositions(ply, nearbyHumans)
end

-- Calculate stealth level based on visibility and positioning
function GM:CalculateStealthLevel(hiddenPly, nearbyHumans)
    local stealthLevel = 1.0
    
    for _, humanData in pairs(nearbyHumans) do
        local human = humanData.player
        local distance = humanData.distance
        
        -- Check line of sight
        local tr = util.TraceLine({
            start = human:EyePos(),
            endpos = hiddenPly:GetPos() + Vector(0, 0, 36),
            filter = human
        })
        
        if tr.Fraction > 0.9 then
            -- Visible - reduce stealth based on distance
            local visibilityPenalty = math.max(0, 1 - (distance / 500))
            stealthLevel = stealthLevel - visibilityPenalty
        end
    end
    
    return math.max(0, stealthLevel)
end

-- Find hiding spots for the Hidden
function GM:FindHidingSpot(hiddenPly)
    local hideSpots = {}
    local currentPos = hiddenPly:GetPos()
    
    -- Look for dark corners, vents, etc.
    for i = 1, 8 do
        local angle = (i - 1) * 45
        local dir = Vector(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0)
        local testPos = currentPos + dir * 500
        
        local tr = util.TraceLine({
            start = currentPos,
            endpos = testPos,
            filter = hiddenPly
        })
        
        if tr.Fraction < 1 and self:IsGoodHidingSpot(tr.HitPos, hiddenPly) then
            table.insert(hideSpots, tr.HitPos)
        end
    end
    
    if #hideSpots > 0 then
        local bestSpot = hideSpots[math.random(#hideSpots)]
        hiddenPly:SetNWVector("HideTarget", bestSpot)
    end
end

-- Check if a position is a good hiding spot
function GM:IsGoodHidingSpot(pos, hiddenPly)
    -- Check if position has cover from multiple angles (removed render dependency)
    -- Just check for cover without light level calculations
    
    -- Check for cover from multiple angles
    local coverCount = 0
    for i = 1, 4 do
        local angle = (i - 1) * 90
        local dir = Vector(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0)
        local tr = util.TraceLine({
            start = pos + Vector(0, 0, 36),
            endpos = pos + dir * 200,
            filter = hiddenPly
        })
        
        if tr.Fraction < 0.5 then
            coverCount = coverCount + 1
        end
    end
    
    return coverCount >= 2 -- Has cover from at least 2 directions
end

-- Suggest ambush positions for the Hidden
function GM:SuggestAmbushPositions(hiddenPly, nearbyHumans)
    if not IsValid(hiddenPly) or #nearbyHumans == 0 then return end
    
    local ambushSpots = {}
    local currentPos = hiddenPly:GetPos()
    
    -- Find potential ambush positions near human players
    for _, humanData in pairs(nearbyHumans) do
        local human = humanData.player
        local humanPos = human:GetPos()
        
        -- Look for positions that provide cover and good attack angles
        for i = 1, 12 do
            local angle = (i - 1) * 30
            local dir = Vector(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0)
            local testPos = humanPos + dir * math.random(150, 300)
            testPos.z = humanPos.z + math.random(-50, 100)
            
            -- Check if position is valid and provides good ambush opportunity
            local tr = util.TraceLine({
                start = humanPos + Vector(0, 0, 36),
                endpos = testPos + Vector(0, 0, 36),
                filter = human
            })
            
            if tr.Fraction < 0.8 and self:IsGoodHidingSpot(testPos, hiddenPly) then
                -- Check if Hidden can reach this position
                local pathTr = util.TraceLine({
                    start = currentPos,
                    endpos = testPos,
                    filter = hiddenPly
                })
                
                if pathTr.Fraction > 0.7 then
                    table.insert(ambushSpots, {
                        pos = testPos,
                        target = human,
                        score = self:CalculateAmbushScore(testPos, humanPos, currentPos)
                    })
                end
            end
        end
    end
    
    -- Sort by score and suggest best position
    if #ambushSpots > 0 then
        table.sort(ambushSpots, function(a, b) return a.score > b.score end)
        local bestSpot = ambushSpots[1]
        
        hiddenPly:SetNWVector("AmbushTarget", bestSpot.pos)
        hiddenPly:SetNWEntity("AmbushVictim", bestSpot.target)
        hiddenPly:SetNWBool("HasAmbushSuggestion", true)
    end
end

-- Calculate ambush position score
function GM:CalculateAmbushScore(ambushPos, targetPos, hiddenPos)
    local score = 0
    
    -- Distance from target (closer is better, but not too close)
    local targetDist = ambushPos:Distance(targetPos)
    if targetDist > 100 and targetDist < 250 then
        score = score + 50
    elseif targetDist <= 100 then
        score = score + 25 -- Too close might be risky
    end
    
    -- Distance from current Hidden position (closer is easier to reach)
    local hiddenDist = ambushPos:Distance(hiddenPos)
    score = score + math.max(0, 100 - (hiddenDist / 10))
    
    -- Height advantage
    if ambushPos.z > targetPos.z then
        score = score + 30
    end
    
    -- Check concealment (removed render dependency)
    -- Give bonus for positions that would typically be dark
    -- This is a simplified heuristic without render calculations
    score = score + 20
    
    return score
end

-- Memory system for tracking events
function GM:AddSuspiciousArea(pos, reason)
    self.AIMemory.SuspiciousAreas[pos] = {
        time = CurTime(),
        reason = reason
    }
end

function GM:AddSoundEvent(pos, volume, source)
    table.insert(self.AIMemory.SoundEvents, {
        pos = pos,
        volume = volume,
        source = source,
        time = CurTime()
    })
    
    -- Limit memory to prevent overflow
    if #self.AIMemory.SoundEvents > 50 then
        table.remove(self.AIMemory.SoundEvents, 1)
    end
end

-- Utility functions
function GM:GetNearbyPlayers(ply, distance)
    local nearby = {}
    for _, p in pairs(player.GetAll()) do
        if p ~= ply and p:Alive() and ply:GetPos():Distance(p:GetPos()) <= distance then
            table.insert(nearby, p)
        end
    end
    return nearby
end

function GM:SetAIState(ply, state)
    ply:SetNWInt("AIState", state)
end

function GM:ShouldInvestigate(ply)
    -- Check if there are recent suspicious events nearby
    for pos, data in pairs(self.AIMemory.SuspiciousAreas) do
        if CurTime() - data.time < 30 and ply:GetPos():Distance(pos) < 400 then
            return true
        end
    end
    return false
end

-- Hook into existing game events
hook.Add("PlayerDeath", "EnhancedAI_PlayerDeath", function(victim, inflictor, attacker)
    if IsValid(victim) and victim:IsPlayer() then
        GAMEMODE.AIMemory.DeathLocations[victim:GetPos()] = {
            time = CurTime(),
            victim = victim:Nick()
        }
        
        -- Mark death location as suspicious
        GAMEMODE:AddSuspiciousArea(victim:GetPos(), "player_death")
    end
end)

-- Update AI every few seconds
timer.Create("EnhancedAI_Update", 2, 0, function()
    for _, ply in pairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            if ply:IsHidden() then
                GAMEMODE:UpdateHiddenAI(ply)
            else
                GAMEMODE:UpdateHumanAI(ply)
            end
        end
    end
end)

-- Clean up old memory data
timer.Create("EnhancedAI_Cleanup", 60, 0, function()
    local currentTime = CurTime()
    
    -- Clean suspicious areas older than 2 minutes
    for pos, data in pairs(GAMEMODE.AIMemory.SuspiciousAreas) do
        if currentTime - data.time > 120 then
            GAMEMODE.AIMemory.SuspiciousAreas[pos] = nil
        end
    end
    
    -- Clean death locations older than 5 minutes
    for pos, data in pairs(GAMEMODE.AIMemory.DeathLocations) do
        if currentTime - data.time > 300 then
            GAMEMODE.AIMemory.DeathLocations[pos] = nil
        end
    end
end)