--[[
    Steal a Brainrot Script - Stealing Features
    
    Advanced stealing mechanics and enhancements for the
    "Steal a Brainrot" game.
    
    Features:
    - Anti-Hit Protection
    - Auto Steal
    - Range Extension
    - Speed Multiplier
    - Silent Mode
    - Notifications
]]--

local stealing = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Local Variables
local player = Players.LocalPlayer
local utils = getgenv().StealBrainrot and getgenv().StealBrainrot.utils
local config = getgenv().StealBrainrot and getgenv().StealBrainrot.config

-- Feature State
local stealingState = {
    enabled = false,
    antiHit = false,
    autoSteal = false,
    rangeExtender = false,
    speedMultiplier = 1.0,
    silentMode = false,
    notifications = true,
    range = 10,
    connections = {},
    originalValues = {},
    targets = {},
    isStealingActive = false
}

-- Game-specific variables (these may need adjustment based on the actual game)
local STEAL_REMOTE = nil
local STEAL_ANIMATION = nil
local STEAL_TOOL = nil

-- Initialize stealing system
function stealing.initialize()
    -- Try to find game-specific remotes and tools
    stealing.findGameElements()
    
    -- Set up connections
    stealing.setupConnections()
    
    print("🔧 Stealing system initialized")
end

function stealing.findGameElements()
    -- Look for stealing-related remotes in ReplicatedStorage
    local remotes = ReplicatedStorage:GetDescendants()
    for _, remote in ipairs(remotes) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local name = string.lower(remote.Name)
            if string.find(name, "steal") or string.find(name, "rob") or string.find(name, "take") then
                STEAL_REMOTE = remote
                print("🎯 Found steal remote: " .. remote.Name)
                break
            end
        end
    end
    
    -- Look for stealing tool
    local character = utils and utils.getCharacter()
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                local name = string.lower(tool.Name)
                if string.find(name, "steal") or string.find(name, "rob") or string.find(name, "hand") then
                    STEAL_TOOL = tool
                    print("🔧 Found steal tool: " .. tool.Name)
                    break
                end
            end
        end
    end
    
    -- Look for stealing animation
    local humanoid = utils and utils.getHumanoid()
    if humanoid and humanoid:FindFirstChild("Animator") then
        local animator = humanoid.Animator
        -- This would need to be adjusted based on the actual game's animation system
    end
end

function stealing.setupConnections()
    -- Character respawn handling
    stealingState.connections.characterAdded = player.CharacterAdded:Connect(function()
        wait(2) -- Wait for character to fully load
        stealing.findGameElements()
        stealing.restoreFeatures()
    end)
    
    -- Auto steal loop
    stealingState.connections.autoSteal = RunService.Heartbeat:Connect(function()
        if stealingState.autoSteal and stealingState.enabled then
            stealing.performAutoSteal()
        end
    end)
end

-- Anti-Hit Protection
function stealing.setAntiHit(enabled)
    stealingState.antiHit = enabled
    
    if enabled then
        stealing.enableAntiHit()
        if stealingState.notifications then
            print("🛡️ Anti-Hit Protection enabled")
        end
    else
        stealing.disableAntiHit()
        if stealingState.notifications then
            print("❌ Anti-Hit Protection disabled")
        end
    end
    
    -- Save to config
    if config then
        config.set("features.stealing.antiHit", enabled)
    end
end

function stealing.enableAntiHit()
    local character = utils and utils.getCharacter()
    local humanoid = utils and utils.getHumanoid()
    local rootPart = utils and utils.getRootPart()
    
    if not character or not humanoid or not rootPart then return end
    
    -- Store original values
    stealingState.originalValues.walkSpeed = humanoid.WalkSpeed
    stealingState.originalValues.jumpPower = humanoid.JumpPower
    
    -- Create anti-hit connection
    stealingState.connections.antiHit = RunService.Heartbeat:Connect(function()
        if stealingState.isStealingActive then
            -- Make player temporarily invulnerable during stealing
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
            
            -- Prevent knockback
            if rootPart.AssemblyLinearVelocity.Magnitude > 50 then
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
            
            -- Maintain position stability
            rootPart.Anchored = true
            wait(0.1)
            rootPart.Anchored = false
        end
    end)
end

function stealing.disableAntiHit()
    if stealingState.connections.antiHit then
        stealingState.connections.antiHit:Disconnect()
        stealingState.connections.antiHit = nil
    end
    
    -- Restore original values
    local humanoid = utils and utils.getHumanoid()
    if humanoid and stealingState.originalValues.walkSpeed then
        humanoid.WalkSpeed = stealingState.originalValues.walkSpeed
        humanoid.JumpPower = stealingState.originalValues.jumpPower
    end
end

-- Auto Steal
function stealing.setAutoSteal(enabled)
    stealingState.autoSteal = enabled
    
    if enabled then
        if stealingState.notifications then
            print("🤖 Auto Steal enabled")
        end
    else
        if stealingState.notifications then
            print("❌ Auto Steal disabled")
        end
    end
    
    -- Save to config
    if config then
        config.set("features.stealing.autoSteal", enabled)
    end
end

function stealing.performAutoSteal()
    if not utils or not utils.isAlive() then return end
    
    local nearestTarget = stealing.findBestTarget()
    if nearestTarget then
        stealing.stealFromTarget(nearestTarget)
    end
end

function stealing.findBestTarget()
    local playersInRange = utils.getPlayersInRange(stealingState.range, false)
    
    if #playersInRange == 0 then return nil end
    
    -- Filter targets based on criteria
    local validTargets = {}
    for _, playerData in ipairs(playersInRange) do
        if stealing.isValidTarget(playerData.player) then
            table.insert(validTargets, playerData)
        end
    end
    
    if #validTargets == 0 then return nil end
    
    -- Sort by priority (nearest, richest, etc.)
    local targetPriority = config and config.get("features.stealing.targetPriority") or "nearest"
    
    if targetPriority == "nearest" then
        return validTargets[1] -- Already sorted by distance
    elseif targetPriority == "richest" then
        -- Sort by money/items (would need game-specific implementation)
        table.sort(validTargets, function(a, b)
            return stealing.getPlayerWealth(a.player) > stealing.getPlayerWealth(b.player)
        end)
        return validTargets[1]
    elseif targetPriority == "weakest" then
        -- Sort by health
        table.sort(validTargets, function(a, b)
            local aHealth = a.player.Character and a.player.Character:FindFirstChild("Humanoid") and a.player.Character.Humanoid.Health or 0
            local bHealth = b.player.Character and b.player.Character:FindFirstChild("Humanoid") and b.player.Character.Humanoid.Health or 0
            return aHealth < bHealth
        end)
        return validTargets[1]
    end
    
    return validTargets[1]
end

function stealing.isValidTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then return false end
    
    -- Check if target is not in safe zone (game-specific)
    -- This would need to be implemented based on the actual game
    
    -- Check if target has stealable items
    if not stealing.hasStealableItems(targetPlayer) then return false end
    
    return true
end

function stealing.hasStealableItems(targetPlayer)
    -- This would need to be implemented based on the actual game's inventory system
    -- For now, assume all players have stealable items
    return true
end

function stealing.getPlayerWealth(targetPlayer)
    -- This would need to be implemented based on the actual game's money system
    -- For now, return a random value
    return math.random(1, 1000)
end

function stealing.stealFromTarget(targetData)
    if not targetData or not targetData.player then return end
    
    local targetPlayer = targetData.player
    local targetPosition = targetData.position
    
    -- Mark stealing as active for anti-hit protection
    stealingState.isStealingActive = true
    
    -- Move closer if needed (with range extension)
    local currentPosition = utils.getPosition()
    local distance = utils.distance(currentPosition, targetPosition)
    
    if distance > stealingState.range then
        -- Move closer
        local direction = (targetPosition - currentPosition).Unit
        local newPosition = targetPosition - direction * (stealingState.range * 0.8)
        utils.teleport(newPosition)
        wait(0.1)
    end
    
    -- Perform steal action
    if STEAL_REMOTE then
        -- Use remote event
        if stealingState.silentMode then
            -- Try to fire remote without triggering animations
            STEAL_REMOTE:FireServer(targetPlayer)
        else
            STEAL_REMOTE:FireServer(targetPlayer)
        end
    elseif STEAL_TOOL then
        -- Use tool activation
        STEAL_TOOL:Activate()
    else
        -- Fallback: try to find and use any stealing mechanism
        stealing.performGenericSteal(targetPlayer)
    end
    
    -- Apply speed multiplier
    if stealingState.speedMultiplier ~= 1.0 then
        local humanoid = utils.getHumanoid()
        if humanoid then
            local originalSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = originalSpeed * stealingState.speedMultiplier
            
            -- Restore speed after stealing
            wait(1 / stealingState.speedMultiplier)
            humanoid.WalkSpeed = originalSpeed
        end
    end
    
    -- Show notification
    if stealingState.notifications then
        print("💰 Attempted to steal from: " .. targetPlayer.Name)
    end
    
    -- Mark stealing as inactive
    stealingState.isStealingActive = false
    
    -- Cooldown to prevent spam
    wait(0.5)
end

function stealing.performGenericSteal(targetPlayer)
    -- Generic stealing implementation
    -- This would need to be customized based on the actual game
    
    local character = utils.getCharacter()
    if not character then return end
    
    -- Try to find any tools that might be used for stealing
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            local name = string.lower(tool.Name)
            if string.find(name, "hand") or string.find(name, "steal") then
                tool:Activate()
                break
            end
        end
    end
end

-- Range Extension
function stealing.setRange(range)
    stealingState.range = math.max(1, math.min(50, range))
    
    if stealingState.notifications then
        print("📏 Steal range set to: " .. stealingState.range)
    end
    
    -- Save to config
    if config then
        config.set("features.stealing.rangeExtender", stealingState.range)
    end
end

-- Speed Multiplier
function stealing.setSpeed(multiplier)
    stealingState.speedMultiplier = math.max(0.1, math.min(10, multiplier))
    
    if stealingState.notifications then
        print("⚡ Steal speed set to: " .. stealingState.speedMultiplier .. "x")
    end
    
    -- Save to config
    if config then
        config.set("features.stealing.speedMultiplier", stealingState.speedMultiplier)
    end
end

-- Silent Mode
function stealing.setSilentMode(enabled)
    stealingState.silentMode = enabled
    
    if enabled then
        if stealingState.notifications then
            print("🤫 Silent steal mode enabled")
        end
    else
        if stealingState.notifications then
            print("❌ Silent steal mode disabled")
        end
    end
    
    -- Save to config
    if config then
        config.set("features.stealing.silentMode", enabled)
    end
end

-- Notifications
function stealing.setNotifications(enabled)
    stealingState.notifications = enabled
    
    -- Save to config
    if config then
        config.set("features.stealing.notifications", enabled)
    end
end

-- Manual steal function
function stealing.stealFromPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local targetData = {
        player = targetPlayer,
        position = targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0),
        distance = utils.distance(utils.getPosition(), targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0))
    }
    
    stealing.stealFromTarget(targetData)
    return true
end

-- Restore features after respawn
function stealing.restoreFeatures()
    if stealingState.antiHit then
        stealing.enableAntiHit()
    end
end

-- Enable/Disable all stealing features
function stealing.enable()
    stealingState.enabled = true
    print("✅ Stealing features enabled")
end

function stealing.disable()
    stealingState.enabled = false
    
    -- Disable all sub-features
    stealing.setAntiHit(false)
    stealing.setAutoSteal(false)
    
    print("❌ Stealing features disabled")
end

-- Cleanup function
function stealing.cleanup()
    -- Disconnect all connections
    for _, connection in pairs(stealingState.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Restore original values
    stealing.disableAntiHit()
    
    -- Reset state
    stealingState.connections = {}
    stealingState.originalValues = {}
    stealingState.targets = {}
    stealingState.isStealingActive = false
    
    print("🧹 Stealing system cleaned up")
end

-- Get current state
function stealing.getState()
    return {
        enabled = stealingState.enabled,
        antiHit = stealingState.antiHit,
        autoSteal = stealingState.autoSteal,
        range = stealingState.range,
        speedMultiplier = stealingState.speedMultiplier,
        silentMode = stealingState.silentMode,
        notifications = stealingState.notifications
    }
end

-- Initialize on load
stealing.initialize()

return stealing
