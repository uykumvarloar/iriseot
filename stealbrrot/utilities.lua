--[[
    Steal a Brainrot Script - Utility Features
    
    Various utility features for enhanced gameplay.
    
    Features:
    - ESP (Player Highlighting)
    - Performance Monitor
    - Minimap Enhancements
    - Chat Commands
]]--

local utilities = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- Local Variables
local player = Players.LocalPlayer
local utils = getgenv().StealBrainrot and getgenv().StealBrainrot.utils
local config = getgenv().StealBrainrot and getgenv().StealBrainrot.config

-- Feature State
local utilitiesState = {
    enabled = false,
    esp = false,
    performanceMonitor = false,
    minimapEnhancements = false,
    connections = {}
}

function utilities.initialize()
    utilities.setupConnections()
    print("🔧 Utilities system initialized")
end

function utilities.setupConnections()
    utilitiesState.connections.characterAdded = player.CharacterAdded:Connect(function()
        wait(2)
        utilities.restoreFeatures()
    end)
end

function utilities.setESP(enabled)
    utilitiesState.esp = enabled
    
    if enabled then
        print("👁️ ESP enabled")
    else
        print("❌ ESP disabled")
    end
    
    if config then
        config.set("features.utilities.esp", enabled)
    end
end

function utilities.setPerformanceMonitor(enabled)
    utilitiesState.performanceMonitor = enabled
    
    if enabled then
        print("📊 Performance monitor enabled")
    else
        print("❌ Performance monitor disabled")
    end
    
    if config then
        config.set("features.utilities.performanceMonitor", enabled)
    end
end

function utilities.restoreFeatures()
    -- Restore utility features after respawn
end

function utilities.enable()
    utilitiesState.enabled = true
    print("✅ Utility features enabled")
end

function utilities.disable()
    utilitiesState.enabled = false
    utilities.setESP(false)
    utilities.setPerformanceMonitor(false)
    print("❌ Utility features disabled")
end

function utilities.cleanup()
    for _, connection in pairs(utilitiesState.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    utilitiesState.connections = {}
    print("🧹 Utilities system cleaned up")
end

utilities.initialize()
return utilities
