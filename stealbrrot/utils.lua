--[[
    Steal a Brainrot Script - Utility Functions
    
    Common utility functions used throughout the script.
    Provides helper functions for various operations.
    
    Features:
    - Math utilities
    - String utilities
    - Table utilities
    - Game-specific utilities
    - Performance utilities
    - Validation utilities
]]--

local utils = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Local Variables
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Math Utilities
function utils.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function utils.lerp(a, b, t)
    return a + (b - a) * t
end

function utils.round(number, decimals)
    local multiplier = 10 ^ (decimals or 0)
    return math.floor(number * multiplier + 0.5) / multiplier
end

function utils.randomFloat(min, max)
    return min + (max - min) * math.random()
end

function utils.distance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

function utils.distance2D(pos1, pos2)
    local diff = pos1 - pos2
    return math.sqrt(diff.X^2 + diff.Z^2)
end

function utils.angleBetween(pos1, pos2)
    local diff = pos2 - pos1
    return math.atan2(diff.Z, diff.X)
end

-- String Utilities
function utils.split(str, delimiter)
    local result = {}
    local pattern = "([^" .. delimiter .. "]+)"
    
    for match in string.gmatch(str, pattern) do
        table.insert(result, match)
    end
    
    return result
end

function utils.trim(str)
    return string.match(str, "^%s*(.-)%s*$")
end

function utils.startsWith(str, prefix)
    return string.sub(str, 1, string.len(prefix)) == prefix
end

function utils.endsWith(str, suffix)
    return string.sub(str, -string.len(suffix)) == suffix
end

function utils.capitalize(str)
    return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2))
end

function utils.formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%02d:%02d", minutes, secs)
    end
end

function utils.formatNumber(number)
    if number >= 1000000 then
        return string.format("%.1fM", number / 1000000)
    elseif number >= 1000 then
        return string.format("%.1fK", number / 1000)
    else
        return tostring(number)
    end
end

-- Table Utilities
function utils.deepCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = utils.deepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

function utils.merge(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" and type(target[key]) == "table" then
            utils.merge(target[key], value)
        else
            target[key] = value
        end
    end
    return target
end

function utils.contains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function utils.indexOf(table, value)
    for i, v in ipairs(table) do
        if v == value then
            return i
        end
    end
    return -1
end

function utils.keys(table)
    local keys = {}
    for key, _ in pairs(table) do
        table.insert(keys, key)
    end
    return keys
end

function utils.values(table)
    local values = {}
    for _, value in pairs(table) do
        table.insert(values, value)
    end
    return values
end

function utils.isEmpty(table)
    return next(table) == nil
end

function utils.count(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- Game Utilities
function utils.getCharacter()
    return player.Character
end

function utils.getHumanoid()
    local character = utils.getCharacter()
    return character and character:FindFirstChild("Humanoid")
end

function utils.getRootPart()
    local character = utils.getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

function utils.isAlive()
    local humanoid = utils.getHumanoid()
    return humanoid and humanoid.Health > 0
end

function utils.getPosition()
    local rootPart = utils.getRootPart()
    return rootPart and rootPart.Position or Vector3.new(0, 0, 0)
end

function utils.teleport(position)
    local rootPart = utils.getRootPart()
    if rootPart then
        rootPart.CFrame = CFrame.new(position)
        return true
    end
    return false
end

function utils.getPlayersInRange(range, includeLocalPlayer)
    local players = {}
    local localPosition = utils.getPosition()
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer == player and not includeLocalPlayer then
            continue
        end
        
        if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = utils.distance(localPosition, otherPlayer.Character.HumanoidRootPart.Position)
            if distance <= range then
                table.insert(players, {
                    player = otherPlayer,
                    distance = distance,
                    position = otherPlayer.Character.HumanoidRootPart.Position
                })
            end
        end
    end
    
    -- Sort by distance
    table.sort(players, function(a, b) return a.distance < b.distance end)
    
    return players
end

function utils.getNearestPlayer()
    local playersInRange = utils.getPlayersInRange(math.huge, false)
    return playersInRange[1] and playersInRange[1].player or nil
end

function utils.raycast(origin, direction, params)
    params = params or {}
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = params.FilterType or Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = params.FilterDescendantsInstances or {}
    
    return Workspace:Raycast(origin, direction, raycastParams)
end

function utils.getMousePosition()
    return UserInputService:GetMouseLocation()
end

function utils.worldToScreen(position)
    local screenPoint, onScreen = camera:WorldToScreenPoint(position)
    return Vector2.new(screenPoint.X, screenPoint.Y), onScreen
end

function utils.screenToWorld(screenPosition, distance)
    distance = distance or 100
    local ray = camera:ScreenPointToRay(screenPosition.X, screenPosition.Y)
    return ray.Origin + ray.Direction * distance
end

-- Performance Utilities
function utils.throttle(func, delay)
    local lastCall = 0
    return function(...)
        local now = tick()
        if now - lastCall >= delay then
            lastCall = now
            return func(...)
        end
    end
end

function utils.debounce(func, delay)
    local timer = nil
    return function(...)
        local args = {...}
        if timer then
            timer:Disconnect()
        end
        timer = task.wait(delay, function()
            func(unpack(args))
        end)
    end
end

function utils.benchmark(func, iterations)
    iterations = iterations or 1
    local startTime = tick()
    
    for i = 1, iterations do
        func()
    end
    
    local endTime = tick()
    local totalTime = endTime - startTime
    local averageTime = totalTime / iterations
    
    return {
        totalTime = totalTime,
        averageTime = averageTime,
        iterations = iterations
    }
end

-- Validation Utilities
function utils.isNumber(value)
    return type(value) == "number" and value == value -- NaN check
end

function utils.isString(value)
    return type(value) == "string"
end

function utils.isTable(value)
    return type(value) == "table"
end

function utils.isFunction(value)
    return type(value) == "function"
end

function utils.isInstance(value, className)
    return typeof(value) == "Instance" and (not className or value:IsA(className))
end

function utils.isVector3(value)
    return typeof(value) == "Vector3"
end

function utils.isCFrame(value)
    return typeof(value) == "CFrame"
end

function utils.isColor3(value)
    return typeof(value) == "Color3"
end

-- Animation Utilities
function utils.tween(object, properties, duration, easingStyle, easingDirection)
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(object, tweenInfo, properties)
    
    tween:Play()
    return tween
end

function utils.fadeIn(object, duration)
    if object:IsA("GuiObject") then
        return utils.tween(object, {BackgroundTransparency = 0}, duration or 0.3)
    elseif object:IsA("BasePart") then
        return utils.tween(object, {Transparency = 0}, duration or 0.3)
    end
end

function utils.fadeOut(object, duration)
    if object:IsA("GuiObject") then
        return utils.tween(object, {BackgroundTransparency = 1}, duration or 0.3)
    elseif object:IsA("BasePart") then
        return utils.tween(object, {Transparency = 1}, duration or 0.3)
    end
end

-- Color Utilities
function utils.hexToColor3(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    return Color3.new(r, g, b)
end

function utils.color3ToHex(color)
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    return string.format("#%02X%02X%02X", r, g, b)
end

function utils.lerpColor3(color1, color2, t)
    return Color3.new(
        utils.lerp(color1.R, color2.R, t),
        utils.lerp(color1.G, color2.G, t),
        utils.lerp(color1.B, color2.B, t)
    )
end

-- Logging Utilities
local logLevels = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4
}

function utils.log(level, message, ...)
    local config = getgenv().StealBrainrot and getgenv().StealBrainrot.config
    local currentLogLevel = config and config.get("security.logLevel") or "info"
    
    if logLevels[level] >= logLevels[currentLogLevel] then
        local timestamp = os.date("[%H:%M:%S]")
        local formattedMessage = string.format(message, ...)
        local fullMessage = timestamp .. " [" .. string.upper(level) .. "] " .. formattedMessage
        
        if level == "error" then
            error(fullMessage)
        elseif level == "warn" then
            warn(fullMessage)
        else
            print(fullMessage)
        end
    end
end

function utils.debug(message, ...)
    utils.log("debug", message, ...)
end

function utils.info(message, ...)
    utils.log("info", message, ...)
end

function utils.warn(message, ...)
    utils.log("warn", message, ...)
end

function utils.error(message, ...)
    utils.log("error", message, ...)
end

-- Network Utilities
function utils.httpGet(url, headers)
    local success, result = pcall(function()
        if syn and syn.request then
            local response = syn.request({
                Url = url,
                Method = "GET",
                Headers = headers or {}
            })
            return response.Body
        elseif request then
            local response = request({
                Url = url,
                Method = "GET",
                Headers = headers or {}
            })
            return response.Body
        elseif game.HttpGet then
            return game:HttpGet(url)
        end
        return nil
    end)
    
    if success then
        return result
    else
        utils.warn("HTTP GET failed: %s", tostring(result))
        return nil
    end
end

function utils.httpPost(url, data, headers)
    local success, result = pcall(function()
        if syn and syn.request then
            local response = syn.request({
                Url = url,
                Method = "POST",
                Headers = headers or {["Content-Type"] = "application/json"},
                Body = type(data) == "table" and HttpService:JSONEncode(data) or data
            })
            return response.Body
        elseif request then
            local response = request({
                Url = url,
                Method = "POST",
                Headers = headers or {["Content-Type"] = "application/json"},
                Body = type(data) == "table" and HttpService:JSONEncode(data) or data
            })
            return response.Body
        end
        return nil
    end)
    
    if success then
        return result
    else
        utils.warn("HTTP POST failed: %s", tostring(result))
        return nil
    end
end

-- Cleanup Utilities
function utils.cleanup(connections)
    if type(connections) == "table" then
        for _, connection in pairs(connections) do
            if connection and connection.Disconnect then
                connection:Disconnect()
            end
        end
    elseif connections and connections.Disconnect then
        connections:Disconnect()
    end
end

function utils.safeDestroy(object)
    if object and object.Destroy then
        pcall(function()
            object:Destroy()
        end)
    end
end

return utils
