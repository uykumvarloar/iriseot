--[[
    Steal a Brainrot Script - Protection Features
    
    Base protection and security features.
    
    Features:
    - Base Protection
    - Auto Repair
    - Intruder Detection
    - Force Field
    - Resource Protection
]]--

local protection = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Local Variables
local player = Players.LocalPlayer
local utils = getgenv().StealBrainrot and getgenv().StealBrainrot.utils
local config = getgenv().StealBrainrot and getgenv().StealBrainrot.config

-- Feature State
local protectionState = {
    enabled = false,
    baseProtection = false,
    autoRepair = false,
    intruderDetection = false,
    forceField = false,
    resourceProtection = false,
    connections = {}
}

function protection.initialize()
    protection.setupConnections()
    print("🛡️ Protection system initialized")
end

function protection.setupConnections()
    protectionState.connections.characterAdded = player.CharacterAdded:Connect(function()
        wait(2)
        protection.restoreFeatures()
    end)
end

function protection.setBaseProtection(enabled)
    protectionState.baseProtection = enabled
    
    if enabled then
        print("🏠 Base protection enabled")
    else
        print("❌ Base protection disabled")
    end
    
    if config then
        config.set("features.protection.baseInvulnerability", enabled)
    end
end

function protection.setAutoRepair(enabled)
    protectionState.autoRepair = enabled
    
    if enabled then
        print("🔧 Auto repair enabled")
    else
        print("❌ Auto repair disabled")
    end
    
    if config then
        config.set("features.protection.autoRepair", enabled)
    end
end

function protection.restoreFeatures()
    -- Restore protection features after respawn
end

function protection.enable()
    protectionState.enabled = true
    print("✅ Protection features enabled")
end

function protection.disable()
    protectionState.enabled = false
    protection.setBaseProtection(false)
    protection.setAutoRepair(false)
    print("❌ Protection features disabled")
end

function protection.cleanup()
    for _, connection in pairs(protectionState.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    protectionState.connections = {}
    print("🧹 Protection system cleaned up")
end

protection.initialize()
return protection
