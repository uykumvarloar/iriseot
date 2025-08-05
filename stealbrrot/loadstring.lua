--[[
    Steal a Brainrot Script - Loadstring Entry Point
    
    This is the main loadstring file that users will execute.
    It loads and initializes the entire script system.
    
    Usage: loadstring(game:HttpGet("https://raw.githubusercontent.com/uykumvarloar/iriseot/refs/heads/main/stealbrrot/loadstring.lua"))()
]]--

-- Check if script is already loaded
if getgenv().StealBrainrot then
    warn("⚠️ Steal a Brainrot Script is already loaded! Unloading previous instance...")
    getgenv().StealBrainrot.unload()
    wait(1)
end

-- Script Information
local SCRIPT_INFO = {
    name = "Steal a Brainrot Script",
    version = "1.0.0",
    author = "Anonymous",
    description = "Advanced script for Steal a Brainrot game",
    game = "Steal a Brainrot"
}

-- Print loading message
print("🧠 " .. SCRIPT_INFO.name .. " v" .. SCRIPT_INFO.version)
print("📝 " .. SCRIPT_INFO.description)
print("🎮 Game: " .. SCRIPT_INFO.game)
print("⏳ Loading script components...")

-- Base URL for script files (this would be replaced with actual URL)
local BASE_URL = "https://github.com/uykumvarloar/iriseot/tree/main/stealbrrot"

-- Function to load script modules
local function loadModule(moduleName)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. moduleName .. ".lua"))()
    end)
    
    if success then
        print("✅ Loaded: " .. moduleName)
        return result
    else
        warn("❌ Failed to load: " .. moduleName .. " - " .. tostring(result))
        return nil
    end
end

-- Initialize global environment
getgenv().StealBrainrot = {
    info = SCRIPT_INFO,
    loaded = false,
    modules = {},
    features = {},
    
    -- Core functions
    load = function() end,
    unload = function() end,
    reload = function() end
}

-- Load core modules
print("📦 Loading core modules...")
getgenv().StealBrainrot.modules.config = loadModule("core/config")
getgenv().StealBrainrot.modules.utils = loadModule("core/utils")

-- Load UI system
print("🎨 Loading UI system...")
getgenv().StealBrainrot.modules.ui = loadModule("ui/main")

-- Load feature modules
print("⚡ Loading feature modules...")
getgenv().StealBrainrot.features.stealing = loadModule("features/stealing")
getgenv().StealBrainrot.features.movement = loadModule("features/movement")
getgenv().StealBrainrot.features.combat = loadModule("features/combat")
getgenv().StealBrainrot.features.protection = loadModule("features/protection")
getgenv().StealBrainrot.features.utilities = loadModule("features/utilities")

-- Create shortcuts for easier access
getgenv().StealBrainrot.config = getgenv().StealBrainrot.modules.config
getgenv().StealBrainrot.utils = getgenv().StealBrainrot.modules.utils
getgenv().StealBrainrot.ui = getgenv().StealBrainrot.modules.ui

-- Main load function
function getgenv().StealBrainrot.load()
    if getgenv().StealBrainrot.loaded then
        warn("⚠️ Script is already loaded!")
        return
    end
    
    print("🚀 Initializing Steal a Brainrot Script...")
    
    -- Initialize core systems
    if getgenv().StealBrainrot.config then
        getgenv().StealBrainrot.config.initialize()
    end
    
    if getgenv().StealBrainrot.utils then
        getgenv().StealBrainrot.utils.initialize()
    end
    
    -- Initialize UI
    if getgenv().StealBrainrot.ui then
        getgenv().StealBrainrot.ui.initialize()
    end
    
    -- Enable all features
    for featureName, feature in pairs(getgenv().StealBrainrot.features) do
        if feature and feature.enable then
            feature.enable()
        end
    end
    
    getgenv().StealBrainrot.loaded = true
    
    print("✅ " .. SCRIPT_INFO.name .. " loaded successfully!")
    print("💡 Press INSERT to toggle UI")
    print("💡 Press F12 for emergency unload")
    
    -- Show welcome notification
    if getgenv().StealBrainrot.ui and getgenv().StealBrainrot.ui.showNotification then
        getgenv().StealBrainrot.ui.showNotification("Welcome to " .. SCRIPT_INFO.name .. "!", "success")
    end
end

-- Main unload function
function getgenv().StealBrainrot.unload()
    if not getgenv().StealBrainrot.loaded then
        warn("⚠️ Script is not loaded!")
        return
    end
    
    print("🗑️ Unloading Steal a Brainrot Script...")
    
    -- Cleanup all features
    for featureName, feature in pairs(getgenv().StealBrainrot.features) do
        if feature and feature.cleanup then
            feature.cleanup()
        end
    end
    
    -- Cleanup UI
    if getgenv().StealBrainrot.ui and getgenv().StealBrainrot.ui.destroy then
        getgenv().StealBrainrot.ui.destroy()
    end
    
    -- Cleanup core modules
    for moduleName, module in pairs(getgenv().StealBrainrot.modules) do
        if module and module.cleanup then
            module.cleanup()
        end
    end
    
    getgenv().StealBrainrot.loaded = false
    
    print("✅ Script unloaded successfully!")
    
    -- Clear global environment
    getgenv().StealBrainrot = nil
end

-- Reload function
function getgenv().StealBrainrot.reload()
    print("🔄 Reloading script...")
    getgenv().StealBrainrot.unload()
    wait(1)
    loadstring(game:HttpGet(BASE_URL .. "loadstring.lua"))()
end

-- Game detection and validation
local function validateGame()
    local gameId = game.PlaceId
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(gameId).Name
    
    print("🎮 Detected game: " .. gameName .. " (ID: " .. gameId .. ")")
    
    -- Add game-specific validation here if needed
    -- For now, we'll allow the script to run on any game
    return true
end

-- Auto-load the script
local function autoLoad()
    if not validateGame() then
        warn("❌ This script is not compatible with the current game!")
        return
    end
    
    -- Load the script
    getgenv().StealBrainrot.load()
end

-- Execute auto-load
autoLoad()

-- Return the main object for manual access
return getgenv().StealBrainrot


