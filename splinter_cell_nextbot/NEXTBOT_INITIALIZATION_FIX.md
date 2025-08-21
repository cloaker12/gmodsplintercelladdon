# NextBot Initialization Fix

## Problem
The Splinter Cell NextBot was throwing an error when spawned:
```
attempt to call method 'SetDesiredSpeed' (a nil value)
```

This error occurred because the NextBot movement methods (`SetDesiredSpeed`, `SetMaxSpeed`, `SetAcceleration`, `SetDeceleration`) were being called in the `Initialize` function before the NextBot system had fully initialized the entity.

## Root Cause
In Garry's Mod, NextBot entities need time to fully initialize before their movement methods become available. Calling these methods immediately in the `Initialize` function can cause errors because the NextBot framework hasn't finished setting up the entity yet.

## Solution
The fix implements a safe initialization system that:

1. **Delays NextBot movement initialization**: Instead of calling movement methods immediately in `Initialize`, we use a timer to delay the calls until the NextBot system is ready.

2. **Safety checks**: Before calling NextBot methods, we verify they exist to prevent nil value errors.

3. **Retry mechanism**: If the methods aren't available yet, the system retries initialization.

4. **Infinite recursion protection**: A counter prevents infinite retry loops.

5. **Think function integration**: The `Think` function also checks if NextBot movement is initialized and triggers initialization if needed.

## Code Changes

### 1. Modified Initialize Function
```lua
function ENT:Initialize()
    -- ... existing initialization code ...
    
    -- Initialize NextBot movement system safely
    self.nextbotInitialized = false
    self:InitializeNextBotMovement()
    
    -- ... rest of initialization ...
end
```

### 2. Added Safe Initialization Function
```lua
function ENT:InitializeNextBotMovement()
    -- Prevent infinite recursion
    if self.nextbotInitializationAttempts and self.nextbotInitializationAttempts > 10 then
        print("Warning: NextBot movement initialization failed after 10 attempts")
        return
    end
    
    self.nextbotInitializationAttempts = (self.nextbotInitializationAttempts or 0) + 1
    
    -- Use a timer to ensure NextBot methods are available
    timer.Simple(0.1, function()
        if IsValid(self) then
            -- Check if NextBot methods are available
            if self.SetDesiredSpeed and self.SetMaxSpeed and self.SetAcceleration and self.SetDeceleration then
                self:SetDesiredSpeed(100)
                self:SetMaxSpeed(150)
                self:SetAcceleration(500)
                self:SetDeceleration(500)
                self.nextbotInitialized = true
                self.nextbotInitializationAttempts = 0 -- Reset counter on success
            else
                -- If methods aren't available yet, try again
                self:InitializeNextBotMovement()
            end
        end
    end)
end
```

### 3. Enhanced Think Function
```lua
function ENT:Think()
    if not IsValid(self) then return end
    
    -- Ensure NextBot movement is initialized
    if not self.nextbotInitialized then
        self:InitializeNextBotMovement()
    end
    
    -- ... rest of think logic ...
end
```

## Testing
A test script (`test_nextbot_fix.lua`) has been created to verify the fix works:

1. Run the command `test_splinter_cell_nextbot` in console
2. The script will spawn a NextBot and monitor its initialization
3. Status checks are performed at 1, 3, and 5 seconds after spawn

## Benefits
- **Eliminates spawn errors**: The NextBot can now be spawned without throwing nil value errors
- **Robust initialization**: The system handles timing issues gracefully
- **Better error handling**: Clear warnings if initialization fails
- **Backward compatibility**: Existing functionality is preserved

## Files Modified
- `lua/entities/nextbot_splinter_cell/init.lua` - Main fix implementation
- `test_nextbot_fix.lua` - Test script for verification

## Usage
After applying this fix, the Splinter Cell NextBot should spawn without errors. The NextBot will automatically initialize its movement system when ready, and you can monitor the process through console output if needed.