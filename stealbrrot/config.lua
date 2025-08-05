--[[
    Steal a Brainrot Script - Configuration Management
    
    Handles all script configuration, settings persistence,
    and user preferences management.
    
    Features:
    - Settings persistence across sessions
    - Default configuration values
    - Configuration validation
    - Theme management
    - Keybind management
]]--

local config = {}

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- Local Variables
local player = Players.LocalPlayer
local configFolder = "StealBrainrotConfig"
local configFile = "settings.json"

-- Default Configuration
local DEFAULT_CONFIG = {
    -- UI Settings
    ui = {
        theme = "dark", -- "dark" or "light"
        transparency = 0.1,
        scale = 1.0,
        position = {x = 100, y = 100},
        minimized = false,
        alwaysOnTop = true,
        animations = true,
        soundEffects = true
    },
    
    -- Feature Settings
    features = {
        stealing = {
            enabled = false,
            antiHit = true,
            autoSteal = false,
            rangeExtender = false,
            speedMultiplier = 1.0,
            silentMode = false,
            notifications = true,
            targetPriority = "nearest" -- "nearest", "richest", "weakest"
        },
        
        movement = {
            enabled = false,
            infiniteJump = false,
            flyMode = false,
            speedBoost = false,
            walkSpeed = 16,
            flySpeed = 50,
            jumpPower = 50,
            teleportation = false,
            wallClimbing = false,
            noClip = false
        },
        
        combat = {
            enabled = false,
            cooldownBypass = false,
            autoAttack = false,
            damageMultiplier = 1.0,
            reachExtension = false,
            reachDistance = 10,
            notifications = true,
            autoWeaponSwitch = false
        },
        
        protection = {
            enabled = false,
            baseInvulnerability = false,
            autoRepair = false,
            intruderDetection = false,
            forceField = false,
            baseTeleport = false,
            resourceProtection = false
        },
        
        utilities = {
            enabled = false,
            esp = false,
            minimapEnhancements = false,
            performanceMonitor = false,
            chatCommands = true,
            autoSaveSettings = true
        }
    },
    
    -- Keybinds
    keybinds = {
        toggleUI = Enum.KeyCode.Insert,
        toggleStealing = Enum.KeyCode.F1,
        toggleMovement = Enum.KeyCode.F2,
        toggleCombat = Enum.KeyCode.F3,
        toggleProtection = Enum.KeyCode.F4,
        toggleUtilities = Enum.KeyCode.F5,
        emergencyStop = Enum.KeyCode.F12,
        flyToggle = Enum.KeyCode.F,
        speedToggle = Enum.KeyCode.G,
        teleportToBase = Enum.KeyCode.H
    },
    
    -- Security Settings
    security = {
        antiDetection = true,
        safeMode = false,
        logLevel = "info", -- "debug", "info", "warn", "error"
        reportErrors = true
    },
    
    -- Performance Settings
    performance = {
        maxFPS = 60,
        renderDistance = 1000,
        particleEffects = true,
        shadows = true,
        lighting = "automatic"
    }
}

-- Current Configuration
local currentConfig = {}

-- Configuration Functions
function config.load()
    -- Try to load from file system (if supported)
    local success, savedConfig = pcall(function()
        if readfile and isfile and isfile(configFolder .. "/" .. configFile) then
            local data = readfile(configFolder .. "/" .. configFile)
            return HttpService:JSONDecode(data)
        end
        return nil
    end)
    
    if success and savedConfig then
        -- Merge saved config with defaults
        currentConfig = config.mergeConfigs(DEFAULT_CONFIG, savedConfig)
        print("✅ Configuration loaded from file")
    else
        -- Use default configuration
        currentConfig = config.deepCopy(DEFAULT_CONFIG)
        print("📝 Using default configuration")
    end
    
    return currentConfig
end

function config.save()
    if not currentConfig then
        warn("⚠️ No configuration to save")
        return false
    end
    
    local success = pcall(function()
        if writefile and makefolder then
            -- Create config folder if it doesn't exist
            if not isfolder(configFolder) then
                makefolder(configFolder)
            end
            
            -- Save configuration
            local data = HttpService:JSONEncode(currentConfig)
            writefile(configFolder .. "/" .. configFile, data)
        end
    end)
    
    if success then
        print("✅ Configuration saved successfully")
        return true
    else
        warn("⚠️ Failed to save configuration")
        return false
    end
end

function config.get(path)
    if not currentConfig then
        config.load()
    end
    
    local keys = string.split(path, ".")
    local value = currentConfig
    
    for _, key in ipairs(keys) do
        if type(value) == "table" and value[key] ~= nil then
            value = value[key]
        else
            return nil
        end
    end
    
    return value
end

function config.set(path, value)
    if not currentConfig then
        config.load()
    end
    
    local keys = string.split(path, ".")
    local current = currentConfig
    
    -- Navigate to the parent of the target key
    for i = 1, #keys - 1 do
        local key = keys[i]
        if type(current[key]) ~= "table" then
            current[key] = {}
        end
        current = current[key]
    end
    
    -- Set the value
    current[keys[#keys]] = value
    
    -- Auto-save if enabled
    if config.get("features.utilities.autoSaveSettings") then
        config.save()
    end
    
    return true
end

function config.reset()
    currentConfig = config.deepCopy(DEFAULT_CONFIG)
    config.save()
    print("🔄 Configuration reset to defaults")
    return currentConfig
end

function config.getAll()
    if not currentConfig then
        config.load()
    end
    return currentConfig
end

function config.validate()
    if not currentConfig then
        return false, "No configuration loaded"
    end
    
    -- Validate UI settings
    local ui = currentConfig.ui
    if ui.theme ~= "dark" and ui.theme ~= "light" then
        ui.theme = "dark"
    end
    
    if ui.transparency < 0 or ui.transparency > 1 then
        ui.transparency = 0.1
    end
    
    if ui.scale < 0.5 or ui.scale > 2.0 then
        ui.scale = 1.0
    end
    
    -- Validate feature settings
    local features = currentConfig.features
    
    -- Validate movement settings
    if features.movement.walkSpeed < 1 or features.movement.walkSpeed > 100 then
        features.movement.walkSpeed = 16
    end
    
    if features.movement.flySpeed < 1 or features.movement.flySpeed > 200 then
        features.movement.flySpeed = 50
    end
    
    -- Validate combat settings
    if features.combat.damageMultiplier < 0.1 or features.combat.damageMultiplier > 10 then
        features.combat.damageMultiplier = 1.0
    end
    
    if features.combat.reachDistance < 1 or features.combat.reachDistance > 50 then
        features.combat.reachDistance = 10
    end
    
    return true, "Configuration is valid"
end

-- Utility Functions
function config.deepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = config.deepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

function config.mergeConfigs(default, saved)
    local merged = config.deepCopy(default)
    
    local function merge(target, source)
        for key, value in pairs(source) do
            if type(value) == "table" and type(target[key]) == "table" then
                merge(target[key], value)
            else
                target[key] = value
            end
        end
    end
    
    merge(merged, saved)
    return merged
end

-- Theme Management
function config.setTheme(themeName)
    if themeName ~= "dark" and themeName ~= "light" then
        warn("⚠️ Invalid theme name: " .. tostring(themeName))
        return false
    end
    
    config.set("ui.theme", themeName)
    print("🎨 Theme changed to: " .. themeName)
    
    -- Notify UI to update
    if getgenv().StealBrainrot and getgenv().StealBrainrot.ui then
        getgenv().StealBrainrot.ui.updateTheme(themeName)
    end
    
    return true
end

function config.getTheme()
    return config.get("ui.theme") or "dark"
end

-- Keybind Management
function config.setKeybind(action, keyCode)
    if not action or not keyCode then
        warn("⚠️ Invalid keybind parameters")
        return false
    end
    
    config.set("keybinds." .. action, keyCode)
    print("⌨️ Keybind set: " .. action .. " = " .. keyCode.Name)
    
    return true
end

function config.getKeybind(action)
    return config.get("keybinds." .. action)
end

-- Export Configuration Module
function config.export()
    if not currentConfig then
        config.load()
    end
    
    local exportData = {
        timestamp = os.time(),
        version = "1.0.0",
        config = currentConfig
    }
    
    return HttpService:JSONEncode(exportData)
end

function config.import(data)
    local success, importData = pcall(function()
        return HttpService:JSONDecode(data)
    end)
    
    if not success or not importData.config then
        warn("⚠️ Invalid configuration data")
        return false
    end
    
    currentConfig = config.mergeConfigs(DEFAULT_CONFIG, importData.config)
    config.save()
    
    print("✅ Configuration imported successfully")
    return true
end

-- Initialize configuration on load
config.load()

return config
