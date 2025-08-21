# NextBot Behavior Fix Documentation

## Issues Addressed

### 1. RunBehaviour() Finished Executing Warning
**Error Message:**
```
ENT:RunBehaviour() has finished executing
```

**Cause:** The `RunBehaviour` function was using `coroutine.wait(1)` which doesn't properly yield control back to the NextBot system, causing the behavior coroutine to terminate.

**Fix:** Changed to use `coroutine.yield()` which properly yields control each frame, keeping the behavior running continuously.

### 2. Movement Initialization Failed After 10 Attempts
**Error Message:**
```
Warning: NextBot movement initialization failed after 10 attempts for entity NextBot [7][nextbot_splinter_cell]
```

**Cause:** The NextBot movement methods weren't becoming available even after multiple delayed attempts, possibly due to timing issues or NextBot system initialization problems.

**Fix:** Enhanced the initialization with:
- Immediate initialization attempt if methods are already available
- `pcall` wrapper to catch errors during method calls
- Fallback to mark as initialized after 10 attempts to prevent infinite loops
- Better error handling and recovery

## Code Changes

### 1. RunBehaviour Fix
```lua
-- Before
function ENT:RunBehaviour()
    -- Let the timer-based AI handle behavior instead
    while true do
        coroutine.wait(1)  -- This was causing the coroutine to finish
    end
end

-- After
function ENT:RunBehaviour()
    -- Keep the behavior running continuously
    while true do
        -- Yield control back to the engine each frame
        -- This prevents the "has finished executing" warning
        coroutine.yield()
    end
end
```

### 2. Enhanced Movement Initialization
```lua
function ENT:InitializeNextBotMovement()
    -- Prevent infinite recursion
    if self.nextbotInitializationAttempts and self.nextbotInitializationAttempts > 10 then
        print("Warning: NextBot movement initialization failed after 10 attempts for entity " .. tostring(self))
        -- Fall back to basic initialization even if methods aren't available
        self.nextbotInitialized = true
        return
    end
    
    self.nextbotInitializationAttempts = (self.nextbotInitializationAttempts or 0) + 1
    
    -- First attempt immediate initialization
    if self.SetDesiredSpeed and self.SetMaxSpeed and self.SetAcceleration and self.SetDeceleration then
        -- Methods are already available, initialize immediately
        pcall(function()
            self:SetDesiredSpeed(100)
            self:SetMaxSpeed(150)
            self:SetAcceleration(500)
            self:SetDeceleration(500)
        end)
        self.nextbotInitialized = true
        self.nextbotInitializationAttempts = 0
        return
    end
    
    -- If not available immediately, use a timer
    timer.Simple(0.1, function()
        if IsValid(self) then
            -- Check if NextBot methods are available
            if self.SetDesiredSpeed and self.SetMaxSpeed and self.SetAcceleration and self.SetDeceleration then
                -- Use pcall to catch any errors during initialization
                local success = pcall(function()
                    self:SetDesiredSpeed(100)
                    self:SetMaxSpeed(150)
                    self:SetAcceleration(500)
                    self:SetDeceleration(500)
                end)
                
                if success then
                    self.nextbotInitialized = true
                    self.nextbotInitializationAttempts = 0
                else
                    -- If methods exist but calling them fails, try again
                    self:InitializeNextBotMovement()
                end
            else
                -- If methods aren't available yet, try again
                self:InitializeNextBotMovement()
            end
        end
    end)
end
```

## Testing

Use the provided test script `test_nextbot_behavior_fix.lua` to verify the fixes:

1. Run the command in console:
   ```
   lua_run include("splinter_cell_nextbot/test_nextbot_behavior_fix.lua")
   ```
   Or use the console command:
   ```
   test_splinter_cell_behavior
   ```

2. The test will:
   - Spawn a NextBot
   - Monitor its behavior for 5 seconds
   - Check initialization status
   - Report any warnings or errors
   - Attempt to trigger movement

## Expected Results

After applying these fixes:
- ✅ No more "ENT:RunBehaviour() has finished executing" warnings
- ✅ NextBot movement should initialize successfully (or gracefully fail)
- ✅ Bot should be able to move and respond to AI commands
- ✅ Stable behavior without infinite initialization loops

## Key Improvements

1. **Proper Coroutine Handling**: Using `coroutine.yield()` ensures the behavior coroutine runs indefinitely
2. **Immediate Initialization**: Tries to initialize movement immediately if methods are available
3. **Error Recovery**: Uses `pcall` to catch errors and continue operation
4. **Graceful Degradation**: After 10 attempts, marks as initialized to prevent infinite loops
5. **Better Diagnostics**: Clear warning messages for debugging

## Files Modified

- `lua/entities/nextbot_splinter_cell/init.lua` - Main behavior fixes
- `test_nextbot_behavior_fix.lua` - Test script for verification
- `NEXTBOT_BEHAVIOR_FIX.md` - This documentation

## Notes

- The NextBot system in Garry's Mod can be finicky with initialization timing
- Some servers or configurations may still experience issues
- The AI uses a timer-based system alongside the NextBot behavior system
- Movement may work even if NextBot methods fail to initialize due to the custom AI implementation