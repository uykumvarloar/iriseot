--[[
    Steal a Brainrot Script - Movement Features
    
    Enhanced movement capabilities for improved gameplay.
    
    Features:
    - Infinite Jump
    - Fly Mode
    - Speed Boost
    - Teleportation
    - Wall Climbing
    - No-Clip
]]--

local movement = {}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- Local Variables
local player = Players.LocalPlayer
local utils = getgenv().StealBrainrot and getgenv().StealBrainrot.utils
local config = getgenv().StealBrainrot and getgenv().StealBrainrot.config

-- Feature State
local movementState = {
    enabled = false,
    infiniteJump = false,
    flyMode = false,
    speedBoost = false,
    wallClimbing = false,
    noClip = false,
    walkSpeed = 16,
    flySpeed = 50,
    jumpPower = 50,
    connections = {},
    originalValues = {},
    flyBodyVelocity = nil,
    flyBodyAngularVelocity = nil
}

-- Initialize movement system
function movement.initialize()
    -- Set up connections
    movement.setupConnections()
    
    -- Store original values
    movement.storeOriginalValues()
    
    print("🚀 Movement system initialized")
end

function movement.setupConnections()
    -- Character respawn handling
    movementState.connections.characterAdded = player.CharacterAdded:Connect(function()
        wait(2) -- Wait for character to fully load
        movement.storeOriginalValues()
        movement.restoreFeatures()
    end)
    
    -- Fly mode controls
    movementState.connections.flyControls = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if movementState.flyMode then
            if input.KeyCode == Enum.KeyCode.Space then
                movement.flyUp()
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                movement.flyDown()
            end
        end
    end)
    
    -- Fly movement loop
    movementState.connections.flyLoop = RunService.Heartbeat:Connect(function()
        if movementState.flyMode then
            movement.updateFlyMovement()
        end
    end)
end

function movement.storeOriginalValues()
    local humanoid = utils and utils.getHumanoid()
    if humanoid then
        movementState.originalValues.walkSpeed = humanoid.WalkSpeed
        movementState.originalValues.jumpPower = humanoid.JumpPower
        movementState.originalValues.jumpHeight = humanoid.JumpHeight
    end
end

-- Infinite Jump
function movement.setInfiniteJump(enabled)
    movementState.infiniteJump = enabled
    
    if enabled then
        movement.enableInfiniteJump()
        print("🦘 Infinite Jump enabled")
    else
        movement.disableInfiniteJump()
        print("❌ Infinite Jump disabled")
    end
    
    -- Save to config
    if config then
        config.set("features.movement.infiniteJump", enabled)
    end
end

function movement.enableInfiniteJump()
    local humanoid = utils and utils.getHumanoid()
    if not humanoid then return end
    
    -- Remove jump cooldown and enable infinite jumping
    movementState.connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
        if movementState.infiniteJump then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

function movement.disableInfiniteJump()
    if movementState.connections.infiniteJump then
        movementState.connections.infiniteJump:Disconnect()
        movementState.connections.infiniteJump = nil
    end
end

-- Fly Mode
function movement.setFly(enabled)
    movementState.flyMode = enabled
    
    if enabled then
        movement.enableFly()
        print("✈️ Fly mode enabled")
        print("💡 Use WASD to move, Space to go up, Shift to go down")
    else
        movement.disableFly()
        print("❌ Fly mode disabled")
    end
    
    -- Save to config
    if config then
        config.set("features.movement.flyMode", enabled)
    end
end

function movement.enableFly()
    local character = utils and utils.getCharacter()
    local rootPart = utils and utils.getRootPart()
    local humanoid = utils and utils.getHumanoid()
    
    if not character or not rootPart or not humanoid then return end
    
    -- Create BodyVelocity for movement
    movementState.flyBodyVelocity = Instance.new("BodyVelocity")
    movementState.flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    movementState.flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    movementState.flyBodyVelocity.Parent = rootPart
    
    -- Create BodyAngularVelocity for rotation control
    movementState.flyBodyAngularVelocity = Instance.new("BodyAngularVelocity")
    movementState.flyBodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
    movementState.flyBodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
    movementState.flyBodyAngularVelocity.Parent = rootPart
    
    -- Disable default character physics
    humanoid.PlatformStand = true
end

function movement.disableFly()
    local humanoid = utils and utils.getHumanoid()
    
    -- Remove fly objects
    if movementState.flyBodyVelocity then
        movementState.flyBodyVelocity:Destroy()
        movementState.flyBodyVelocity = nil
    end
    
    if movementState.flyBodyAngularVelocity then
        movementState.flyBodyAngularVelocity:Destroy()
        movementState.flyBodyAngularVelocity = nil
    end
    
    -- Restore default character physics
    if humanoid then
        humanoid.PlatformStand = false
    end
end

function movement.updateFlyMovement()
    if not movementState.flyBodyVelocity then return end
    
    local camera = Workspace.CurrentCamera
    local humanoid = utils and utils.getHumanoid()
    
    if not camera or not humanoid then return end
    
    local moveVector = humanoid.MoveDirection
    local cameraDirection = camera.CFrame.LookVector
    local cameraRight = camera.CFrame.RightVector
    
    -- Calculate movement direction
    local direction = Vector3.new(0, 0, 0)
    
    if moveVector.Magnitude > 0 then
        direction = (cameraDirection * moveVector.Z + cameraRight * moveVector.X).Unit
    end
    
    -- Apply fly speed
    movementState.flyBodyVelocity.Velocity = direction * movementState.flySpeed
end

function movement.flyUp()
    if movementState.flyBodyVelocity then
        local currentVelocity = movementState.flyBodyVelocity.Velocity
        movementState.flyBodyVelocity.Velocity = Vector3.new(currentVelocity.X, movementState.flySpeed, currentVelocity.Z)
    end
end

function movement.flyDown()
    if movementState.flyBodyVelocity then
        local currentVelocity = movementState.flyBodyVelocity.Velocity
        movementState.flyBodyVelocity.Velocity = Vector3.new(currentVelocity.X, -movementState.flySpeed, currentVelocity.Z)
    end
end

-- Speed Boost
function movement.setWalkSpeed(speed)
    movementState.walkSpeed = math.max(1, math.min(500, speed))
    
    local humanoid = utils and utils.getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = movementState.walkSpeed
    end
    
    print("🏃 Walk speed set to: " .. movementState.walkSpeed)
    
    -- Save to config
    if config then
        config.set("features.movement.walkSpeed", movementState.walkSpeed)
    end
end

function movement.setFlySpeed(speed)
    movementState.flySpeed = math.max(1, math.min(500, speed))
    
    print("✈️ Fly speed set to: " .. movementState.flySpeed)
    
    -- Save to config
    if config then
        config.set("features.movement.flySpeed", movementState.flySpeed)
    end
end

function movement.setJumpPower(power)
    movementState.jumpPower = math.max(1, math.min(500, power))
    
    local humanoid = utils and utils.getHumanoid()
    if humanoid then
        humanoid.JumpPower = movementState.jumpPower
    end
    
    print("🦘 Jump power set to: " .. movementState.jumpPower)
    
    -- Save to config
    if config then
        config.set("features.movement.jumpPower", movementState.jumpPower)
    end
end

-- Wall Climbing
function movement.setWallClimbing(enabled)
    movementState.wallClimbing = enabled
    
    if enabled then
        movement.enableWallClimbing()
        print("🧗 Wall climbing enabled")
    else
        movement.disableWallClimbing()
        print("❌ Wall climbing disabled")
    end
    
    -- Save to config
    if config then
        config.set("features.movement.wallClimbing", enabled)
    end
end

function movement.enableWallClimbing()
    local humanoid = utils and utils.getHumanoid()
    if not humanoid then return end
    
    -- Enable wall climbing by modifying humanoid states
    movementState.connections.wallClimbing = RunService.Heartbeat:Connect(function()
        if movementState.wallClimbing then
            local rootPart = utils.getRootPart()
            if rootPart then
                -- Check for walls in front
                local raycast = utils.raycast(rootPart.Position, rootPart.CFrame.LookVector * 3)
                if raycast and raycast.Instance then
                    -- Allow climbing by setting upward velocity
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        local bodyVelocity = rootPart:FindFirstChild("ClimbVelocity")
                        if not bodyVelocity then
                            bodyVelocity = Instance.new("BodyVelocity")
                            bodyVelocity.Name = "ClimbVelocity"
                            bodyVelocity.MaxForce = Vector3.new(0, 4000, 0)
                            bodyVelocity.Parent = rootPart
                        end
                        bodyVelocity.Velocity = Vector3.new(0, movementState.walkSpeed, 0)
                    else
                        local bodyVelocity = rootPart:FindFirstChild("ClimbVelocity")
                        if bodyVelocity then
                            bodyVelocity:Destroy()
                        end
                    end
                end
            end
        end
    end)
end

function movement.disableWallClimbing()
    if movementState.connections.wallClimbing then
        movementState.connections.wallClimbing:Disconnect()
        movementState.connections.wallClimbing = nil
    end
    
    -- Remove any climbing velocity objects
    local rootPart = utils and utils.getRootPart()
    if rootPart then
        local bodyVelocity = rootPart:FindFirstChild("ClimbVelocity")
        if bodyVelocity then
            bodyVelocity:Destroy()
        end
    end
end

-- No-Clip
function movement.setNoClip(enabled)
    movementState.noClip = enabled
    
    if enabled then
        movement.enableNoClip()
        print("👻 No-clip enabled")
    else
        movement.disableNoClip()
        print("❌ No-clip disabled")
    end
    
    -- Save to config
    if config then
        config.set("features.movement.noClip", enabled)
    end
end

function movement.enableNoClip()
    movementState.connections.noClip = RunService.Stepped:Connect(function()
        if movementState.noClip then
            local character = utils.getCharacter()
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end

function movement.disableNoClip()
    if movementState.connections.noClip then
        movementState.connections.noClip:Disconnect()
        movementState.connections.noClip = nil
    end
    
    -- Restore collision
    local character = utils and utils.getCharacter()
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

-- Teleportation
function movement.teleportToPosition(position)
    if not utils or not utils.isAlive() then return false end
    
    local rootPart = utils.getRootPart()
    if not rootPart then return false end
    
    -- Smooth teleportation with tween
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(position)})
    
    tween:Play()
    print("📍 Teleported to: " .. tostring(position))
    
    return true
end

function movement.teleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local targetRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRootPart then return false end
    
    -- Teleport near the player (not exactly on them)
    local offset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
    local targetPosition = targetRootPart.Position + offset
    
    return movement.teleportToPosition(targetPosition)
end

-- Restore features after respawn
function movement.restoreFeatures()
    local humanoid = utils and utils.getHumanoid()
    if not humanoid then return end
    
    -- Restore speed settings
    if movementState.walkSpeed ~= movementState.originalValues.walkSpeed then
        humanoid.WalkSpeed = movementState.walkSpeed
    end
    
    if movementState.jumpPower ~= movementState.originalValues.jumpPower then
        humanoid.JumpPower = movementState.jumpPower
    end
    
    -- Re-enable features that were active
    if movementState.infiniteJump then
        movement.enableInfiniteJump()
    end
    
    if movementState.flyMode then
        movement.enableFly()
    end
    
    if movementState.wallClimbing then
        movement.enableWallClimbing()
    end
    
    if movementState.noClip then
        movement.enableNoClip()
    end
end

-- Enable/Disable all movement features
function movement.enable()
    movementState.enabled = true
    print("✅ Movement features enabled")
end

function movement.disable()
    movementState.enabled = false
    
    -- Disable all sub-features
    movement.setInfiniteJump(false)
    movement.setFly(false)
    movement.setWallClimbing(false)
    movement.setNoClip(false)
    
    -- Restore original values
    local humanoid = utils and utils.getHumanoid()
    if humanoid and movementState.originalValues.walkSpeed then
        humanoid.WalkSpeed = movementState.originalValues.walkSpeed
        humanoid.JumpPower = movementState.originalValues.jumpPower
    end
    
    print("❌ Movement features disabled")
end

-- Cleanup function
function movement.cleanup()
    -- Disconnect all connections
    for _, connection in pairs(movementState.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Disable all features
    movement.disableFly()
    movement.disableInfiniteJump()
    movement.disableWallClimbing()
    movement.disableNoClip()
    
    -- Restore original values
    local humanoid = utils and utils.getHumanoid()
    if humanoid and movementState.originalValues.walkSpeed then
        humanoid.WalkSpeed = movementState.originalValues.walkSpeed
        humanoid.JumpPower = movementState.originalValues.jumpPower
    end
    
    -- Reset state
    movementState.connections = {}
    movementState.originalValues = {}
    movementState.flyBodyVelocity = nil
    movementState.flyBodyAngularVelocity = nil
    
    print("🧹 Movement system cleaned up")
end

-- Get current state
function movement.getState()
    return {
        enabled = movementState.enabled,
        infiniteJump = movementState.infiniteJump,
        flyMode = movementState.flyMode,
        speedBoost = movementState.speedBoost,
        wallClimbing = movementState.wallClimbing,
        noClip = movementState.noClip,
        walkSpeed = movementState.walkSpeed,
        flySpeed = movementState.flySpeed,
        jumpPower = movementState.jumpPower
    }
end

-- Initialize on load
movement.initialize()

return movement
