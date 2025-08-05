--[[
    Steal a Brainrot Script - Combat Features
    
    Enhanced combat capabilities including cooldown bypass
    and other combat-related features.
    
    Features:
    - Cooldown Bypass (Bat Spam)
    - Auto Attack
    - Reach Extension
    - Damage Multiplier
    - Auto Weapon Switch
]]--

local combat = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Local Variables
local player = Players.LocalPlayer
local utils = getgenv().StealBrainrot and getgenv().StealBrainrot.utils
local config = getgenv().StealBrainrot and getgenv().StealBrainrot.config

-- Feature State
local combatState = {
    enabled = false,
    cooldownBypass = false,
    autoAttack = false,
    reachExtension = false,
    damageMultiplier = 1.0,
    reachDistance = 10,
    autoWeaponSwitch = false,
    notifications = true,
    connections = {},
    originalValues = {},
    attackRemote = nil,
    currentWeapon = nil
}

-- Initialize combat system
function combat.initialize()
    -- Find game-specific combat elements
    combat.findCombatElements()
    
    -- Set up connections
    combat.setupConnections()
    
    print("⚔️ Combat system initialized")
end

function combat.findCombatElements()
    -- Look for attack/combat remotes
    local remotes = ReplicatedStorage:GetDescendants()
    for _, remote in ipairs(remotes) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local name = string.lower(remote.Name)
            if string.find(name, "attack") or string.find(name, "hit") or string.find(name, "damage") or string.find(name, "combat") then
                combatState.attackRemote = remote
                print("🎯 Found attack remote: " .. remote.Name)
                break
            end
        end
    end
    
    -- Find current weapon
    combat.updateCurrentWeapon()
end

function combat.updateCurrentWeapon()
    local character = utils and utils.getCharacter()
    if not character then return end
    
    -- Look for equipped tools (weapons)
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            combatState.currentWeapon = tool
            print("🔧 Current weapon: " .. tool.Name)
            break
        end
    end
end

function combat.setupConnections()
    -- Character respawn handling
    combatState.connections.characterAdded = player.CharacterAdded:Connect(function()
        wait(2)
        combat.findCombatElements()
        combat.restoreFeatures()
    end)
    
    -- Auto attack loop
    combatState.connections.autoAttack = RunService.Heartbeat:Connect(function()
        if combatState.autoAttack and combatState.enabled then
            combat.performAutoAttack()
        end
    end)
    
    -- Weapon change detection
    combatState.connections.weaponChange = player.CharacterAdded:Connect(function(character)
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                combatState.currentWeapon = child
            end
        end)
        
        character.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") and child == combatState.currentWeapon then
                combatState.currentWeapon = nil
            end
        end)
    end)
end

-- Cooldown Bypass (Bat Spam)
function combat.setCooldownBypass(enabled)
    combatState.cooldownBypass = enabled
    
    if enabled then
        combat.enableCooldownBypass()
        if combatState.notifications then
            print("🏏 Cooldown Bypass (Bat Spam) enabled")
        end
    else
        combat.disableCooldownBypass()
        if combatState.notifications then
            print("❌ Cooldown Bypass disabled")
        end
    end
    
    -- Save to config
    if config then
        config.set("features.combat.cooldownBypass", enabled)
    end
end

function combat.enableCooldownBypass()
    -- Hook into the attack system to bypass cooldowns
    combatState.connections.cooldownBypass = RunService.Heartbeat:Connect(function()
        if combatState.cooldownBypass and combatState.currentWeapon then
            -- Remove or modify cooldown-related attributes
            local tool = combatState.currentWeapon
            
            -- Common cooldown attribute names in Roblox games
            local cooldownAttributes = {"Cooldown", "AttackCooldown", "LastAttack", "NextAttack"}
            
            for _, attrName in ipairs(cooldownAttributes) do
                if tool:GetAttribute(attrName) then
                    tool:SetAttribute(attrName, 0)
                end
            end
            
            -- Check for cooldown values in tool's children
            for _, child in ipairs(tool:GetDescendants()) do
                if child:IsA("NumberValue") or child:IsA("IntValue") then
                    local name = string.lower(child.Name)
                    if string.find(name, "cooldown") or string.find(name, "delay") then
                        child.Value = 0
                    end
                end
            end
        end
    end)
end

function combat.disableCooldownBypass()
    if combatState.connections.cooldownBypass then
        combatState.connections.cooldownBypass:Disconnect()
        combatState.connections.cooldownBypass = nil
    end
end

-- Auto Attack
function combat.setAutoAttack(enabled)
    combatState.autoAttack = enabled
    
    if enabled then
        if combatState.notifications then
            print("🤖 Auto Attack enabled")
        end
    else
        if combatState.notifications then
            print("❌ Auto Attack disabled")
        end
    end
    
    -- Save to config
    if config then
        config.set("features.combat.autoAttack", enabled)
    end
end

function combat.performAutoAttack()
    if not utils or not utils.isAlive() then return end
    
    local nearestTarget = combat.findNearestEnemy()
    if nearestTarget then
        combat.attackTarget(nearestTarget)
    end
end

function combat.findNearestEnemy()
    local playersInRange = utils.getPlayersInRange(combatState.reachDistance, false)
    
    if #playersInRange == 0 then return nil end
    
    -- Filter for valid targets
    local validTargets = {}
    for _, playerData in ipairs(playersInRange) do
        if combat.isValidTarget(playerData.player) then
            table.insert(validTargets, playerData)
        end
    end
    
    return validTargets[1] -- Return nearest valid target
end

function combat.isValidTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local targetHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then return false end
    
    -- Don't attack teammates (if applicable)
    -- This would need game-specific implementation
    
    return true
end

function combat.attackTarget(targetData)
    if not targetData or not targetData.player then return end
    
    local targetPlayer = targetData.player
    
    -- Use attack remote if available
    if combatState.attackRemote then
        combatState.attackRemote:FireServer(targetPlayer)
    elseif combatState.currentWeapon then
        -- Use tool activation
        combatState.currentWeapon:Activate()
    else
        -- Fallback: simulate mouse click for attack
        combat.performGenericAttack(targetPlayer)
    end
    
    if combatState.notifications then
        print("⚔️ Attacked: " .. targetPlayer.Name)
    end
end

function combat.performGenericAttack(targetPlayer)
    -- Generic attack implementation
    local mouse = player:GetMouse()
    if mouse then
        -- Simulate click at target position
        local targetCharacter = targetPlayer.Character
        if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
            local targetPosition = targetCharacter.HumanoidRootPart.Position
            local screenPos, onScreen = utils.worldToScreen(targetPosition)
            
            if onScreen then
                -- This would need to be implemented with specific executor functions
                -- mouse1click() or similar
            end
        end
    end
end

-- Reach Extension
function combat.setReach(distance)
    combatState.reachDistance = math.max(1, math.min(100, distance))
    
    if combatState.notifications then
        print("📏 Reach distance set to: " .. combatState.reachDistance)
    end
    
    -- Save to config
    if config then
        config.set("features.combat.reachDistance", combatState.reachDistance)
    end
end

function combat.setReachExtension(enabled)
    combatState.reachExtension = enabled
    
    if enabled then
        combat.enableReachExtension()
        if combatState.notifications then
            print("🤏 Reach extension enabled")
        end
    else
        combat.disableReachExtension()
        if combatState.notifications then
            print("❌ Reach extension disabled")
        end
    end
    
    -- Save to config
    if config then
        config.set("features.combat.reachExtension", enabled)
    end
end

function combat.enableReachExtension()
    -- Modify weapon reach/range
    combatState.connections.reachExtension = RunService.Heartbeat:Connect(function()
        if combatState.reachExtension and combatState.currentWeapon then
            local tool = combatState.currentWeapon
            
            -- Modify tool handle size for extended reach
            local handle = tool:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                -- Store original size if not already stored
                if not combatState.originalValues.handleSize then
                    combatState.originalValues.handleSize = handle.Size
                end
                
                -- Extend handle size for reach
                local extendedSize = combatState.originalValues.handleSize * Vector3.new(1, 1, combatState.reachDistance / 5)
                handle.Size = extendedSize
                handle.Transparency = 0.9 -- Make it mostly invisible
            end
        end
    end)
end

function combat.disableReachExtension()
    if combatState.connections.reachExtension then
        combatState.connections.reachExtension:Disconnect()
        combatState.connections.reachExtension = nil
    end
    
    -- Restore original handle size
    if combatState.currentWeapon and combatState.originalValues.handleSize then
        local handle = combatState.currentWeapon:FindFirstChild("Handle")
        if handle then
            handle.Size = combatState.originalValues.handleSize
            handle.Transparency = 0
        end
    end
end

-- Damage Multiplier
function combat.setDamageMultiplier(multiplier)
    combatState.damageMultiplier = math.max(0.1, math.min(50, multiplier))
    
    if combatState.notifications then
        print("💥 Damage multiplier set to: " .. combatState.damageMultiplier .. "x")
    end
    
    -- Save to config
    if config then
        config.set("features.combat.damageMultiplier", combatState.damageMultiplier)
    end
end

-- Auto Weapon Switch
function combat.setAutoWeaponSwitch(enabled)
    combatState.autoWeaponSwitch = enabled
    
    if enabled then
        if combatState.notifications then
            print("🔄 Auto weapon switch enabled")
        end
    else
        if combatState.notifications then
            print("❌ Auto weapon switch disabled")
        end
    end
    
    -- Save to config
    if config then
        config.set("features.combat.autoWeaponSwitch", enabled)
    end
end

-- Manual attack function
function combat.attackPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local targetData = {
        player = targetPlayer,
        position = targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0),
        distance = utils.distance(utils.getPosition(), targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0))
    }
    
    combat.attackTarget(targetData)
    return true
end

-- Restore features after respawn
function combat.restoreFeatures()
    if combatState.cooldownBypass then
        combat.enableCooldownBypass()
    end
    
    if combatState.reachExtension then
        combat.enableReachExtension()
    end
    
    -- Update current weapon
    combat.updateCurrentWeapon()
end

-- Enable/Disable all combat features
function combat.enable()
    combatState.enabled = true
    print("✅ Combat features enabled")
end

function combat.disable()
    combatState.enabled = false
    
    -- Disable all sub-features
    combat.setCooldownBypass(false)
    combat.setAutoAttack(false)
    combat.setReachExtension(false)
    
    print("❌ Combat features disabled")
end

-- Cleanup function
function combat.cleanup()
    -- Disconnect all connections
    for _, connection in pairs(combatState.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Disable all features
    combat.disableCooldownBypass()
    combat.disableReachExtension()
    
    -- Reset state
    combatState.connections = {}
    combatState.originalValues = {}
    combatState.attackRemote = nil
    combatState.currentWeapon = nil
    
    print("🧹 Combat system cleaned up")
end

-- Get current state
function combat.getState()
    return {
        enabled = combatState.enabled,
        cooldownBypass = combatState.cooldownBypass,
        autoAttack = combatState.autoAttack,
        reachExtension = combatState.reachExtension,
        damageMultiplier = combatState.damageMultiplier,
        reachDistance = combatState.reachDistance,
        autoWeaponSwitch = combatState.autoWeaponSwitch,
        notifications = combatState.notifications
    }
end

-- Initialize on load
combat.initialize()

return combat
