--[[
    Steal a Brainrot Script - Main UI System
    
    Modern, responsive user interface with advanced features.
    Provides intuitive controls for all script features.
    
    Features:
    - Modern design with dark/light themes
    - Draggable windows with snap-to-edge
    - Smooth animations and transitions
    - Categorized feature tabs
    - Real-time status indicators
    - Settings persistence
]]--

local ui = {}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Local Variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- UI State
local uiState = {
    initialized = false,
    visible = true,
    minimized = false,
    dragging = false,
    dragStart = nil,
    startPos = nil,
    connections = {},
    elements = {},
    currentTheme = "dark"
}

-- Theme Definitions
local themes = {
    dark = {
        primary = Color3.fromRGB(25, 25, 35),
        secondary = Color3.fromRGB(35, 35, 45),
        accent = Color3.fromRGB(100, 150, 255),
        success = Color3.fromRGB(75, 200, 100),
        warning = Color3.fromRGB(255, 200, 50),
        error = Color3.fromRGB(255, 100, 100),
        text = Color3.fromRGB(255, 255, 255),
        textSecondary = Color3.fromRGB(200, 200, 200),
        border = Color3.fromRGB(60, 60, 70),
        shadow = Color3.fromRGB(0, 0, 0),
        transparency = 0.1
    },
    light = {
        primary = Color3.fromRGB(245, 245, 250),
        secondary = Color3.fromRGB(235, 235, 240),
        accent = Color3.fromRGB(50, 100, 200),
        success = Color3.fromRGB(50, 150, 75),
        warning = Color3.fromRGB(200, 150, 25),
        error = Color3.fromRGB(200, 50, 50),
        text = Color3.fromRGB(25, 25, 35),
        textSecondary = Color3.fromRGB(75, 75, 85),
        border = Color3.fromRGB(200, 200, 210),
        shadow = Color3.fromRGB(0, 0, 0),
        transparency = 0.05
    }
}

-- Utility Functions
local function getCurrentTheme()
    return themes[uiState.currentTheme] or themes.dark
end

local function createCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    return corner
end

local function createStroke(thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or getCurrentTheme().border
    stroke.Transparency = 0.3
    return stroke
end

local function createShadow(parent)
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundColor3 = getCurrentTheme().shadow
    shadow.BackgroundTransparency = 0.8
    shadow.BorderSizePixel = 0
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent.Parent
    
    local corner = createCorner(10)
    corner.Parent = shadow
    
    return shadow
end

local function createButton(parent, text, size, position, callback)
    local theme = getCurrentTheme()
    
    local button = Instance.new("TextButton")
    button.Name = text .. "Button"
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = theme.secondary
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = theme.text
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    
    local corner = createCorner(6)
    corner.Parent = button
    
    local stroke = createStroke(1, theme.border)
    stroke.Parent = button
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.accent
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = theme.secondary
        }):Play()
    end)
    
    -- Click callback
    if callback then
        button.MouseButton1Click:Connect(callback)
    end
    
    return button
end

local function createToggle(parent, text, size, position, initialState, callback)
    local theme = getCurrentTheme()
    
    local frame = Instance.new("Frame")
    frame.Name = text .. "Toggle"
    frame.Size = size
    frame.Position = position
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.text
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local toggle = Instance.new("Frame")
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(1, -55, 0.5, -12.5)
    toggle.BackgroundColor3 = initialState and theme.success or theme.border
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    
    local toggleCorner = createCorner(12)
    toggleCorner.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 21, 0, 21)
    knob.Position = initialState and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
    knob.BackgroundColor3 = theme.text
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    local knobCorner = createCorner(10)
    knobCorner.Parent = knob
    
    local state = initialState
    
    local function updateToggle()
        local targetColor = state and theme.success or theme.border
        local targetPosition = state and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
        
        TweenService:Create(toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = targetColor
        }):Play()
        
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = targetPosition
        }):Play()
    end
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = toggle
    
    button.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
        if callback then
            callback(state)
        end
    end)
    
    return frame, function() return state end, function(newState) state = newState updateToggle() end
end

local function createSlider(parent, text, size, position, min, max, initial, callback)
    local theme = getCurrentTheme()
    
    local frame = Instance.new("Frame")
    frame.Name = text .. "Slider"
    frame.Size = size
    frame.Position = position
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = theme.text
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0.15, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.85, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(initial)
    valueLabel.TextColor3 = theme.textSecondary
    valueLabel.TextScaled = true
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Name = "SliderBg"
    sliderBg.Size = UDim2.new(0.4, 0, 0, 6)
    sliderBg.Position = UDim2.new(0.45, 0, 0.5, -3)
    sliderBg.BackgroundColor3 = theme.border
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local sliderBgCorner = createCorner(3)
    sliderBgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((initial - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = theme.accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local sliderFillCorner = createCorner(3)
    sliderFillCorner.Parent = sliderFill
    
    local value = initial
    local dragging = false
    
    local function updateSlider()
        local percentage = (value - min) / (max - min)
        sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        valueLabel.Text = string.format("%.1f", value)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderBg.AbsolutePosition
            local sliderSize = sliderBg.AbsoluteSize
            
            local percentage = math.max(0, math.min(1, (mousePos.X - sliderPos.X) / sliderSize.X))
            value = min + (max - min) * percentage
            
            updateSlider()
            if callback then
                callback(value)
            end
        end
    end)
    
    return frame, function() return value end, function(newValue) value = newValue updateSlider() end
end

-- Main UI Creation
function ui.initialize()
    if uiState.initialized then
        ui.destroy()
    end
    
    local config = getgenv().StealBrainrot.config
    uiState.currentTheme = config.get("ui.theme") or "dark"
    local theme = getCurrentTheme()
    
    -- Main Screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StealBrainrotUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui
    
    uiState.elements.screenGui = screenGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = theme.primary
    mainFrame.BackgroundTransparency = theme.transparency
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = false
    mainFrame.Parent = screenGui
    
    local mainCorner = createCorner(12)
    mainCorner.Parent = mainFrame
    
    local mainStroke = createStroke(2, theme.border)
    mainStroke.Parent = mainFrame
    
    local shadow = createShadow(mainFrame)
    
    uiState.elements.mainFrame = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = theme.secondary
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = createCorner(12)
    titleCorner.Parent = titleBar
    
    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(0.6, 0, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🧠 Steal a Brainrot Script v1.0.0"
    titleText.TextColor3 = theme.text
    titleText.TextScaled = true
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.GothamBold
    titleText.Parent = titleBar
    
    -- Control Buttons
    local minimizeBtn = createButton(titleBar, "−", UDim2.new(0, 30, 0, 25), UDim2.new(1, -100, 0.5, -12.5), function()
        ui.minimize()
    end)
    
    local themeBtn = createButton(titleBar, "🎨", UDim2.new(0, 30, 0, 25), UDim2.new(1, -65, 0.5, -12.5), function()
        ui.toggleTheme()
    end)
    
    local closeBtn = createButton(titleBar, "×", UDim2.new(0, 30, 0, 25), UDim2.new(1, -30, 0.5, -12.5), function()
        ui.toggle()
    end)
    closeBtn.BackgroundColor3 = theme.error
    
    -- Make draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Content Area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Tab System
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "Tabs"
    tabFrame.Size = UDim2.new(1, 0, 0, 35)
    tabFrame.Position = UDim2.new(0, 0, 0, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = contentFrame
    
    local tabs = {"Stealing", "Movement", "Combat", "Protection", "Utilities", "Settings"}
    local tabButtons = {}
    local tabContents = {}
    local activeTab = 1
    
    -- Create tab buttons
    for i, tabName in ipairs(tabs) do
        local tabBtn = createButton(tabFrame, tabName, UDim2.new(1/#tabs, -5, 1, 0), UDim2.new((i-1)/#tabs, 2.5, 0, 0), function()
            ui.switchTab(i)
        end)
        tabButtons[i] = tabBtn
    end
    
    -- Tab content area
    local tabContentFrame = Instance.new("Frame")
    tabContentFrame.Name = "TabContent"
    tabContentFrame.Size = UDim2.new(1, 0, 1, -45)
    tabContentFrame.Position = UDim2.new(0, 0, 0, 45)
    tabContentFrame.BackgroundTransparency = 1
    tabContentFrame.Parent = contentFrame
    
    -- Create tab contents
    for i, tabName in ipairs(tabs) do
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 6
        tabContent.ScrollBarImageColor3 = theme.accent
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = i == 1
        tabContent.Parent = tabContentFrame
        
        tabContents[i] = tabContent
        
        -- Populate tab content
        ui.createTabContent(tabContent, tabName:lower())
    end
    
    uiState.elements.tabButtons = tabButtons
    uiState.elements.tabContents = tabContents
    
    -- Initialize keybinds
    ui.setupKeybinds()
    
    uiState.initialized = true
    print("✅ UI initialized successfully")
end

function ui.createTabContent(parent, tabType)
    local theme = getCurrentTheme()
    local yOffset = 10
    
    if tabType == "stealing" then
        -- Stealing features
        local antiHitToggle = createToggle(parent, "Anti-Hit Protection", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), false, function(state)
            if getgenv().StealBrainrot.features.stealing then
                getgenv().StealBrainrot.features.stealing.setAntiHit(state)
            end
        end)
        yOffset = yOffset + 40
        
        local autoStealToggle = createToggle(parent, "Auto Steal", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), false, function(state)
            if getgenv().StealBrainrot.features.stealing then
                getgenv().StealBrainrot.features.stealing.setAutoSteal(state)
            end
        end)
        yOffset = yOffset + 40
        
        local rangeSlider = createSlider(parent, "Steal Range", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), 1, 50, 10, function(value)
            if getgenv().StealBrainrot.features.stealing then
                getgenv().StealBrainrot.features.stealing.setRange(value)
            end
        end)
        yOffset = yOffset + 40
        
        local speedSlider = createSlider(parent, "Steal Speed", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), 0.5, 5, 1, function(value)
            if getgenv().StealBrainrot.features.stealing then
                getgenv().StealBrainrot.features.stealing.setSpeed(value)
            end
        end)
        yOffset = yOffset + 40
        
    elseif tabType == "movement" then
        -- Movement features
        local infiniteJumpToggle = createToggle(parent, "Infinite Jump", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), false, function(state)
            if getgenv().StealBrainrot.features.movement then
                getgenv().StealBrainrot.features.movement.setInfiniteJump(state)
            end
        end)
        yOffset = yOffset + 40
        
        local flyToggle = createToggle(parent, "Fly Mode", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), false, function(state)
            if getgenv().StealBrainrot.features.movement then
                getgenv().StealBrainrot.features.movement.setFly(state)
            end
        end)
        yOffset = yOffset + 40
        
        local speedSlider = createSlider(parent, "Walk Speed", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), 16, 100, 16, function(value)
            if getgenv().StealBrainrot.features.movement then
                getgenv().StealBrainrot.features.movement.setWalkSpeed(value)
            end
        end)
        yOffset = yOffset + 40
        
        local flySpeedSlider = createSlider(parent, "Fly Speed", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), 16, 200, 50, function(value)
            if getgenv().StealBrainrot.features.movement then
                getgenv().StealBrainrot.features.movement.setFlySpeed(value)
            end
        end)
        yOffset = yOffset + 40
        
    elseif tabType == "combat" then
        -- Combat features
        local cooldownBypassToggle = createToggle(parent, "Cooldown Bypass (Bat Spam)", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), false, function(state)
            if getgenv().StealBrainrot.features.combat then
                getgenv().StealBrainrot.features.combat.setCooldownBypass(state)
            end
        end)
        yOffset = yOffset + 40
        
        local autoAttackToggle = createToggle(parent, "Auto Attack", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), false, function(state)
            if getgenv().StealBrainrot.features.combat then
                getgenv().StealBrainrot.features.combat.setAutoAttack(state)
            end
        end)
        yOffset = yOffset + 40
        
        local reachSlider = createSlider(parent, "Reach Distance", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), 5, 50, 10, function(value)
            if getgenv().StealBrainrot.features.combat then
                getgenv().StealBrainrot.features.combat.setReach(value)
            end
        end)
        yOffset = yOffset + 40
        
    elseif tabType == "protection" then
        -- Protection features
        local baseProtectionToggle = createToggle(parent, "Base Protection", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), false, function(state)
            if getgenv().StealBrainrot.features.protection then
                getgenv().StealBrainrot.features.protection.setBaseProtection(state)
            end
        end)
        yOffset = yOffset + 40
        
        local autoRepairToggle = createToggle(parent, "Auto Repair", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), false, function(state)
            if getgenv().StealBrainrot.features.protection then
                getgenv().StealBrainrot.features.protection.setAutoRepair(state)
            end
        end)
        yOffset = yOffset + 40
        
    elseif tabType == "utilities" then
        -- Utility features
        local espToggle = createToggle(parent, "ESP (Player Highlighting)", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), false, function(state)
            if getgenv().StealBrainrot.features.utilities then
                getgenv().StealBrainrot.features.utilities.setESP(state)
            end
        end)
        yOffset = yOffset + 40
        
        local performanceToggle = createToggle(parent, "Performance Monitor", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, yOffset), false, function(state)
            if getgenv().StealBrainrot.features.utilities then
                getgenv().StealBrainrot.features.utilities.setPerformanceMonitor(state)
            end
        end)
        yOffset = yOffset + 40
        
    elseif tabType == "settings" then
        -- Settings
        local themeBtn = createButton(parent, "Toggle Theme", UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, yOffset), function()
            ui.toggleTheme()
        end)
        yOffset = yOffset + 45
        
        local saveBtn = createButton(parent, "Save Settings", UDim2.new(0.48, 0, 0, 35), UDim2.new(0, 10, 0, yOffset), function()
            if getgenv().StealBrainrot.config then
                getgenv().StealBrainrot.config.save()
            end
        end)
        
        local resetBtn = createButton(parent, "Reset Settings", UDim2.new(0.48, 0, 0, 35), UDim2.new(0.52, 0, 0, yOffset), function()
            if getgenv().StealBrainrot.config then
                getgenv().StealBrainrot.config.reset()
            end
        end)
        yOffset = yOffset + 45
    end
    
    -- Update canvas size
    parent.CanvasSize = UDim2.new(0, 0, 0, yOffset + 20)
end

function ui.switchTab(tabIndex)
    local theme = getCurrentTheme()
    
    for i, tabContent in ipairs(uiState.elements.tabContents) do
        tabContent.Visible = i == tabIndex
    end
    
    for i, tabButton in ipairs(uiState.elements.tabButtons) do
        if i == tabIndex then
            tabButton.BackgroundColor3 = theme.accent
        else
            tabButton.BackgroundColor3 = theme.secondary
        end
    end
end

function ui.toggle()
    if not uiState.initialized then return end
    
    uiState.visible = not uiState.visible
    uiState.elements.screenGui.Enabled = uiState.visible
    
    print(uiState.visible and "✅ UI shown" or "❌ UI hidden")
end

function ui.minimize()
    if not uiState.initialized then return end
    
    uiState.minimized = not uiState.minimized
    local targetSize = uiState.minimized and UDim2.new(0, 600, 0, 40) or UDim2.new(0, 600, 0, 400)
    
    TweenService:Create(uiState.elements.mainFrame, TweenInfo.new(0.3), {
        Size = targetSize
    }):Play()
end

function ui.toggleTheme()
    uiState.currentTheme = uiState.currentTheme == "dark" and "light" or "dark"
    
    if getgenv().StealBrainrot.config then
        getgenv().StealBrainrot.config.set("ui.theme", uiState.currentTheme)
    end
    
    -- Reinitialize UI with new theme
    ui.initialize()
    print("🎨 Theme switched to: " .. uiState.currentTheme)
end

function ui.updateTheme(themeName)
    uiState.currentTheme = themeName
    ui.initialize()
end

function ui.setupKeybinds()
    local config = getgenv().StealBrainrot.config
    
    -- UI Toggle
    local toggleUIKey = config.get("keybinds.toggleUI") or Enum.KeyCode.Insert
    uiState.connections.toggleUI = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleUIKey then
            ui.toggle()
        end
    end)
    
    -- Emergency stop
    local emergencyKey = config.get("keybinds.emergencyStop") or Enum.KeyCode.F12
    uiState.connections.emergency = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == emergencyKey then
            if getgenv().StealBrainrot then
                getgenv().StealBrainrot.unload()
            end
        end
    end)
end

function ui.destroy()
    if not uiState.initialized then return end
    
    -- Disconnect all connections
    for _, connection in pairs(uiState.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Destroy UI elements
    if uiState.elements.screenGui then
        uiState.elements.screenGui:Destroy()
    end
    
    -- Reset state
    uiState.initialized = false
    uiState.connections = {}
    uiState.elements = {}
    
    print("🗑️ UI destroyed")
end

return ui
