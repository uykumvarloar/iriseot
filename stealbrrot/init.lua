--[[
    Steal a Brainrot Script
    Main Initialization File
    
    A premium Roblox script for enhanced gameplay experience
    Compatible with major executors (Synapse X, KRNL, Fluxus, etc.)
    
    Author: StealBrainrot Development Team
    Version: 1.0.0
    Last Updated: January 8, 2025
]]--

-- Script Information
local SCRIPT_INFO = {
    name = "Steal a Brainrot Script",
    version = "1.0.0",
    author = "StealBrainrot Dev Team",
    description = "Premium Roblox script with advanced features",
    lastUpdated = "2025-01-08"
}

-- Security Check: Verify executor compatibility
local function checkExecutor()
    local executors = {
        "syn", "Synapse", "synapse",
        "KRNL", "krnl",
        "fluxus", "Fluxus",
        "oxygen", "Oxygen",
        "jjsploit", "JJSploit"
    }
    
    for _, executor in pairs(executors) do
        if getgenv()[executor] or _G[executor] then
            return true, executor
        end
    end
    
    -- Check for common executor functions
    if syn and syn.request then return true, "Synapse X" end
    if request or http_request or http.request then return true, "Generic" end
    
    return false, "Unknown"
end

-- Initialize Script
local function initializeScript()
    print("=" .. string.rep("=", 50) .. "=")
    print("  " .. SCRIPT_INFO.name .. " v" .. SCRIPT_INFO.version)
    print("  " .. SCRIPT_INFO.description)
    print("  Author: " .. SCRIPT_INFO.author)
    print("=" .. string.rep("=", 50) .. "=")
    
    -- Check executor compatibility
    local isCompatible, executorName = checkExecutor()
    if not isCompatible then
        warn("⚠️ Executor compatibility warning: " .. executorName)
        warn("⚠️ Some features may not work properly")
    else
        print("✅ Executor detected: " .. executorName)
    end
    
    -- Check if already loaded
    if getgenv().StealBrainrotLoaded then
        warn("⚠️ Script is already loaded!")
        return false
    end
    
    -- Mark as loaded
    getgenv().StealBrainrotLoaded = true
    
    return true
end

-- Error Handler
local function handleError(err)
    warn("❌ Script Error: " .. tostring(err))
    warn("📧 Please report this error to the development team")
end

-- Main Execution
local success, result = pcall(function()
    if not initializeScript() then
        return false
    end
    
    -- Load Core Modules
    print("🔄 Loading core modules...")
    
    -- Load configuration system
    local config = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/StealBrainrotScript/main/core/config.lua"))()
    if not config then
        error("Failed to load configuration module")
    end
    
    -- Load utility functions
    local utils = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/StealBrainrotScript/main/core/utils.lua"))()
    if not utils then
        error("Failed to load utility module")
    end
    
    -- Load UI system
    print("🎨 Loading user interface...")
    local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/StealBrainrotScript/main/ui/main.lua"))()
    if not ui then
        error("Failed to load UI module")
    end
    
    -- Load Features
    print("⚡ Loading features...")
    
    -- Stealing features
    local stealing = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/StealBrainrotScript/main/features/stealing.lua"))()
    
    -- Movement features
    local movement = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/StealBrainrotScript/main/features/movement.lua"))()
    
    -- Combat features
    local combat = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/StealBrainrotScript/main/features/combat.lua"))()
    
    -- Protection features
    local protection = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/StealBrainrotScript/main/features/protection.lua"))()
    
    -- Utility features
    local utilities = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/StealBrainrotScript/main/features/utilities.lua"))()
    
    -- Load Security
    print("🔒 Loading security modules...")
    local security = loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/StealBrainrotScript/main/security/detection.lua"))()
    
    -- Initialize Global Script Object
    getgenv().StealBrainrot = {
        info = SCRIPT_INFO,
        config = config,
        utils = utils,
        ui = ui,
        features = {
            stealing = stealing,
            movement = movement,
            combat = combat,
            protection = protection,
            utilities = utilities
        },
        security = security,
        
        -- Script Control Functions
        unload = function()
            print("🔄 Unloading Steal a Brainrot Script...")
            
            -- Disable all features
            if stealing then stealing.disable() end
            if movement then movement.disable() end
            if combat then combat.disable() end
            if protection then protection.disable() end
            if utilities then utilities.disable() end
            
            -- Close UI
            if ui then ui.destroy() end
            
            -- Clear global variables
            getgenv().StealBrainrotLoaded = nil
            getgenv().StealBrainrot = nil
            
            print("✅ Script unloaded successfully")
        end,
        
        reload = function()
            getgenv().StealBrainrot.unload()
            wait(1)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/StealBrainrotScript/main/init.lua"))()
        end
    }
    
    -- Initialize UI
    ui.initialize()
    
    print("✅ Steal a Brainrot Script loaded successfully!")
    print("💡 Use the GUI to control features")
    print("💡 Type '/sb help' in chat for commands")
    
    return true
end)

if not success then
    handleError(result)
end

-- Chat Commands Handler
local Players = game:GetService("Players")
local player = Players.LocalPlayer

if player and player.Chatted then
    player.Chatted:Connect(function(message)
        local args = string.split(string.lower(message), " ")
        
        if args[1] == "/sb" or args[1] == "/stealbrain" then
            if args[2] == "help" then
                print("=== Steal a Brainrot Commands ===")
                print("/sb help - Show this help menu")
                print("/sb reload - Reload the script")
                print("/sb unload - Unload the script")
                print("/sb version - Show script version")
                print("/sb toggle [feature] - Toggle a feature")
            elseif args[2] == "reload" then
                if getgenv().StealBrainrot then
                    getgenv().StealBrainrot.reload()
                end
            elseif args[2] == "unload" then
                if getgenv().StealBrainrot then
                    getgenv().StealBrainrot.unload()
                end
            elseif args[2] == "version" then
                print("Steal a Brainrot Script v" .. SCRIPT_INFO.version)
                print("Last Updated: " .. SCRIPT_INFO.lastUpdated)
            end
        end
    end)
end
