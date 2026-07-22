local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().SpinBotSettings = {
    Enabled = false,
    Mode = "Spin"
}

getgenv().AimbotSettings = {
    Enabled = false,
    Smoothness = 1,
    TargetPart = "Head",
    TeamCheck = false,
    FOV = 100,
    ShowFOV = false,
    VisibleOnly = false,
    RainbowFOV = false,
    FOVTransparency = 0.8
}

getgenv().EspSettings = {
    Boxes = false,
    Tracers = false,
    Skeleton = false,
    Name = false,
    Health = false,
    Tool = false,
    Rainbow = false
}

getgenv().HitboxSettings = {
    Enabled = false,
    Size = 4,
    WallCheck = false
}

getgenv().WalkSpeedValue = 16
getgenv().JumpPowerValue = 50
getgenv().TPWalkSpeed = 50
getgenv().CameraFOVEnabled = false
getgenv().CameraFOVValue = 70

local Connections = {
    Spin = nil,
    Noclip = nil,
    Backstab = nil,
    InfiniteAmmo = nil,
    TPWalk = nil,
    InfJump = nil,
    Esp = nil,
    Chams = nil,
    CameraFOV = nil
}

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local customThemes = {
    {
        Name = "Obsidian",
        Accent = Color3.fromHex("#1a1a1a"),
        Background = Color3.fromHex("#0d0d0d"),
        Outline = Color3.fromHex("#404040"),
        Text = Color3.fromHex("#e0e0e0"),
        Placeholder = Color3.fromHex("#6b6b6b"),
        Button = Color3.fromHex("#2b2b2b"),
        Icon = Color3.fromHex("#9e9e9e"),
    },
    {
        Name = "Crimson",
        Accent = Color3.fromHex("#2d1111"),
        Background = Color3.fromHex("#1a0a0a"),
        Outline = Color3.fromHex("#ff4444"),
        Text = Color3.fromHex("#ffffff"),
        Placeholder = Color3.fromHex("#8b5e5e"),
        Button = Color3.fromHex("#4a2020"),
        Icon = Color3.fromHex("#ff6666"),
    },
    {
        Name = "Ocean",
        Accent = Color3.fromHex("#0b1a2a"),
        Background = Color3.fromHex("#050d14"),
        Outline = Color3.fromHex("#3a8fd4"),
        Text = Color3.fromHex("#e6f0ff"),
        Placeholder = Color3.fromHex("#5b7a9e"),
        Button = Color3.fromHex("#1a2e42"),
        Icon = Color3.fromHex("#5aa9e6"),
    },
    {
        Name = "Sunset",
        Accent = Color3.fromHex("#2a1a1a"),
        Background = Color3.fromHex("#140a0a"),
        Outline = Color3.fromHex("#ff8c42"),
        Text = Color3.fromHex("#ffe0cc"),
        Placeholder = Color3.fromHex("#8c6242"),
        Button = Color3.fromHex("#3d2626"),
        Icon = Color3.fromHex("#ffb380"),
    },
    {
        Name = "Forest",
        Accent = Color3.fromHex("#1a2e1a"),
        Background = Color3.fromHex("#0d1a0d"),
        Outline = Color3.fromHex("#4caf50"),
        Text = Color3.fromHex("#e0ffe0"),
        Placeholder = Color3.fromHex("#5e8c5e"),
        Button = Color3.fromHex("#2b472b"),
        Icon = Color3.fromHex("#81c784"),
    },
}

for _, theme in ipairs(customThemes) do
    WindUI:AddTheme(theme)
end
WindUI:SetTheme("Ocean")

local Window = WindUI:CreateWindow({
    Title = "BR Hub | JailBird",
    Icon = "shield",
    Author = "by i41p on discord",
    Folder = "BR_Hub"
})

Window:EditOpenButton({
    Title = "BR Hub | Jailbird",
    Icon = "terminal",
    CornerRadius = UDim.new(0, 12),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FF0F7B"),
        Color3.fromHex("F89B29")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

local ConfigManager = Window.ConfigManager
local currentConfig = ConfigManager:CreateConfig("DefaultConfig")

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
end)

local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        uiVisible = not uiVisible
        pcall(function() Window.Main.Visible = uiVisible end)
    end
end)

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "FOVCircle"
fovGui.IgnoreGuiInset = true
fovGui.Parent = playerGui

local fovFrame = Instance.new("Frame")
fovFrame.Name = "Circle"
fovFrame.Size = UDim2.new(0, 200, 0, 200)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.BackgroundTransparency = 1
fovFrame.BorderSizePixel = 0
fovFrame.Parent = fovGui

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(255, 0, 100)
fovStroke.Thickness = 1.5
fovStroke.Transparency = 0.8
fovStroke.Parent = fovFrame

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovFrame

fovFrame.Visible = getgenv().AimbotSettings.ShowFOV

local function UpdateFOVCircle(radius)
    fovFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
end
UpdateFOVCircle(getgenv().AimbotSettings.FOV)

local function IsVisible(targetPart)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    rayParams.IgnoreWater = true
    local origin = Camera.CFrame.Position
    local dir = targetPart.Position - origin
    local result = workspace:Raycast(origin, dir, rayParams)
    return result == nil
end

local function GetClosestPlayer()
    local target = nil
    local shortest = math.huge
    local settings = getgenv().AimbotSettings
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local aimPart = plr.Character:FindFirstChild(settings.TargetPart)
            if not hrp or not aimPart then continue end

            if settings.TeamCheck and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                continue
            end

            if settings.VisibleOnly and not IsVisible(aimPart) then
                continue
            end

            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                if dist <= settings.FOV and dist < shortest then
                    target = plr
                    shortest = dist
                end
            end
        end
    end
    return target
end

RunService.Heartbeat:Connect(function()
    local aimSettings = getgenv().AimbotSettings
    local hitSettings = getgenv().HitboxSettings
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if head and hrp then
                local inFov = false
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    inFov = dist <= aimSettings.FOV
                end
                local wallOk = true
                if hitSettings.WallCheck then
                    wallOk = IsVisible(hrp)
                end

                if hitSettings.Enabled and inFov and wallOk then
                    local sz = Vector3.new(hitSettings.Size, hitSettings.Size, hitSettings.Size)
                    head.Size = sz
                    head.CanCollide = false
                    hrp.Size = sz
                    hrp.CanCollide = false
                else
                    head.Size = Vector3.new(2, 1, 1)
                    head.CanCollide = true
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.CanCollide = true
                end
            end
        end
    end

    if aimSettings.Enabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(aimSettings.TargetPart) then
            local targetPos = target.Character[aimSettings.TargetPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, targetPos),
                1 / aimSettings.Smoothness
            )
        end
    end

    if aimSettings.RainbowFOV and fovFrame.Visible then
        local hue = (tick() * 0.5) % 1
        fovStroke.Color = Color3.fromHSV(hue, 1, 1)
    end
end)

local espGui = Instance.new("ScreenGui")
espGui.Name = "ESP_Gui"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.Parent = playerGui

local espObjects = {}

local function clearESP()
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    espObjects = {}
end

local function createLine2D(from, to, color, thickness)
    local length = (to - from).Magnitude
    if length < 1 then return nil end
    local angle = math.atan2(to.Y - from.Y, to.X - from.X)
    local mid = (from + to) / 2

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, length, 0, thickness or 2)
    frame.Position = UDim2.new(0, mid.X - length/2, 0, mid.Y - (thickness or 2)/2)
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0
    frame.Rotation = math.deg(angle)
    frame.Parent = espGui
    return frame
end

local function createText(text, position, color, size, center)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = false
    label.TextSize = size or 14
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Size = UDim2.new(0, 200, 0, 30)
    label.Position = UDim2.new(0, position.X - 100, 0, position.Y - 15)
    if center then
        label.TextXAlignment = Enum.TextXAlignment.Center
    else
        label.TextXAlignment = Enum.TextXAlignment.Left
    end
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = espGui
    return label
end

local function updateESP()
    local espSettings = getgenv().EspSettings
    if not (espSettings.Skeleton or espSettings.Tracers or espSettings.Name or espSettings.Health or espSettings.Tool) then
        clearESP()
        return
    end

    clearESP()

    local rainbowColor
    if espSettings.Rainbow then
        local hue = (tick() * 0.2) % 1
        rainbowColor = Color3.fromHSV(hue, 1, 1)
    end

    local localChar = LocalPlayer.Character
    local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
    local tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    if localHRP then
        local localScreenPos, localOnScreen = Camera:WorldToViewportPoint(localHRP.Position)
        if localOnScreen then
            tracerStart = Vector2.new(localScreenPos.X, localScreenPos.Y)
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then continue end
        local char = plr.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("Torso")
        local leftArm = char:FindFirstChild("Left Arm")
        local rightArm = char:FindFirstChild("Right Arm")
        local leftLeg = char:FindFirstChild("Left Leg")
        local rightLeg = char:FindFirstChild("Right Leg")
        local humanoid = char:FindFirstChildOfClass("Humanoid")

        local teamColor
        if LocalPlayer.Team and plr.Team and plr.Team == LocalPlayer.Team then
            teamColor = Color3.fromRGB(50, 150, 255)
        else
            teamColor = Color3.fromRGB(255, 50, 50)
        end
        local displayColor = espSettings.Rainbow and rainbowColor or teamColor

        if espSettings.Skeleton and torso and head and leftArm and rightArm and leftLeg and rightLeg then
            local function worldToScreen(pos)
                local vec, onScreen = Camera:WorldToViewportPoint(pos)
                if onScreen then
                    return Vector2.new(vec.X, vec.Y), true
                end
                return nil, false
            end
            local function drawLine3D(fromWorld, toWorld, color)
                local from2D, fOn = worldToScreen(fromWorld)
                local to2D, tOn = worldToScreen(toWorld)
                if fOn and tOn then
                    local line = createLine2D(from2D, to2D, color, 2)
                    if line then table.insert(espObjects, line) end
                end
            end
            drawLine3D(torso.Position, head.Position, displayColor)
            drawLine3D(torso.Position, leftArm.Position, displayColor)
            drawLine3D(torso.Position, rightArm.Position, displayColor)
            local leftFootPos = leftLeg.CFrame * Vector3.new(0, -leftLeg.Size.Y / 2, 0)
            local rightFootPos = rightLeg.CFrame * Vector3.new(0, -rightLeg.Size.Y / 2, 0)
            drawLine3D(torso.Position, leftFootPos, displayColor)
            drawLine3D(torso.Position, rightFootPos, displayColor)
        end

        if espSettings.Tracers and hrp then
            local toPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local line = createLine2D(tracerStart, Vector2.new(toPos.X, toPos.Y), displayColor, 2)
                if line then table.insert(espObjects, line) end
            end
        end

        if (espSettings.Name or espSettings.Health or espSettings.Tool) and head then
            local headScreenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local basePos = Vector2.new(headScreenPos.X, headScreenPos.Y)
                local pixelOffsetAbove = 40
                local currentY = basePos.Y - pixelOffsetAbove
                local yOffset = 0

                if espSettings.Name and plr.Name then
                    local pos = Vector2.new(basePos.X, currentY - yOffset)
                    local label = createText(plr.Name, pos, displayColor, 14, true)
                    if label then table.insert(espObjects, label) end
                    yOffset = yOffset + 20
                end

                if espSettings.Health and humanoid then
                    local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                    local healthColor = espSettings.Rainbow and rainbowColor or Color3.fromRGB(255 - (healthPercent * 2.55), healthPercent * 2.55, 0)
                    local pos = Vector2.new(basePos.X, currentY - yOffset)
                    local label = createText(healthPercent .. "%", pos, healthColor, 12, true)
                    if label then table.insert(espObjects, label) end
                    yOffset = yOffset + 18
                end

                if espSettings.Tool then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        local pos = Vector2.new(basePos.X, currentY - yOffset)
                        local label = createText("[" .. tool.Name .. "]", pos, displayColor, 11, true)
                        if label then table.insert(espObjects, label) end
                    end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(updateESP)

local InfoTab = Window:Tab({ Title = "Info", Icon = "home" })
InfoTab:Button({
    Title = "Welcome to BR Hub",
    Desc = "Current Version: v2.6.6",
    Callback = function() end
})
InfoTab:Button({
    Title = "Changelog",
    Desc = "- Config system added\n- Skeleton & Tracer ESP\n- Team-colored visuals\n- Custom themes\n- TP Walk Speed slider\n- Camera FOV slider\n- Name, Health, Tool ESP\n- Gun Spoofer button\n- Heartbeat loops\n- ESP anchored above head",
    Callback = function() end
})
InfoTab:Button({
    Title = "Script Credits",
    Desc = "Lead Developer: goth\nUI Framework: WindUI",
    Callback = function() end
})

local MoveTab = Window:Tab({ Title = "Movement", Icon = "user" })

local walkSpeedSlider = MoveTab:Slider({
    Title = "WalkSpeed",
    Desc = "Movement speed (max 50)",
    Step = 1,
    Flag = "WalkSpeed",
    Value = { Min = 16, Max = 50, Default = 16 },
    Callback = function(value)
        getgenv().WalkSpeedValue = value
        local hum = (LocalPlayer.Character or {}):FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = value end
    end
})
currentConfig:Register("WalkSpeed", walkSpeedSlider)

local jumpPowerSlider = MoveTab:Slider({
    Title = "JumpPower",
    Desc = "Jump height (max 50)",
    Step = 1,
    Flag = "JumpPower",
    Value = { Min = 16, Max = 50, Default = 50 },
    Callback = function(value)
        getgenv().JumpPowerValue = value
        local hum = (LocalPlayer.Character or {}):FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower = true; hum.JumpPower = value end
    end
})
currentConfig:Register("JumpPower", jumpPowerSlider)

local tpWalkSpeedSlider = MoveTab:Slider({
    Title = "TP Walk Speed",
    Desc = "Multiplier for TP Walk (10-200)",
    Step = 1,
    Flag = "TPWalkSpeed",
    Value = { Min = 0, Max = 50, Default = 0 },
    Callback = function(value)
        getgenv().TPWalkSpeed = value
    end
})
currentConfig:Register("TPWalkSpeed", tpWalkSpeedSlider)

local infJumpToggle = MoveTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump continuously",
    Icon = "chevrons-up",
    Flag = "InfiniteJump",
    Callback = function(state)
        if state then
            Connections.InfJump = UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if Connections.InfJump then
                Connections.InfJump:Disconnect()
                Connections.InfJump = nil
            end
        end
    end
})
currentConfig:Register("InfiniteJump", infJumpToggle)

local noclipToggle = MoveTab:Toggle({
    Title = "Noclip",
    Desc = "Through walls",
    Icon = "ghost",
    Flag = "Noclip",
    Callback = function(state)
        if state then
            Connections.Noclip = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, p in pairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        else
            if Connections.Noclip then
                Connections.Noclip:Disconnect()
                Connections.Noclip = nil
            end
        end
    end
})
currentConfig:Register("Noclip", noclipToggle)

local tpWalkToggle = MoveTab:Toggle({
    Title = "TP Walk",
    Desc = "Forced high-speed movement",
    Icon = "zap",
    Flag = "TPWalk",
    Callback = function(state)
        if state then
            if Connections.TPWalk then Connections.TPWalk:Disconnect() end
            Connections.TPWalk = RunService.Heartbeat:Connect(function(dt)
                if not getgenv().TPWalkEnabled then return end
                local char = LocalPlayer.Character
                if not char then return end
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if not humanoid or not rootPart then return end
                local moveDir = humanoid.MoveDirection
                if moveDir.Magnitude > 0.1 then
                    local speed = getgenv().TPWalkSpeed or 50
                    local delta = moveDir * speed * dt
                    rootPart.CFrame = rootPart.CFrame + delta
                end
            end)
            getgenv().TPWalkEnabled = true
        else
            if Connections.TPWalk then
                Connections.TPWalk:Disconnect()
                Connections.TPWalk = nil
            end
            getgenv().TPWalkEnabled = false
        end
    end
})
currentConfig:Register("TPWalk", tpWalkToggle)

local AimTab = Window:Tab({ Title = "Aim", Icon = "crosshair" })

local aimbotToggle = AimTab:Toggle({
    Title = "Aimbot (lowk sucks)",
    Desc = "Locks camera onto target",
    Icon = "target",
    Flag = "Aimbot",
    Callback = function(v) getgenv().AimbotSettings.Enabled = v end
})
currentConfig:Register("Aimbot", aimbotToggle)

local teamCheckToggle = AimTab:Toggle({
    Title = "Team Check",
    Icon = "users",
    Flag = "TeamCheck",
    Callback = function(v) getgenv().AimbotSettings.TeamCheck = v end
})
currentConfig:Register("TeamCheck", teamCheckToggle)

local visibleOnlyToggle = AimTab:Toggle({
    Title = "Visible Only",
    Desc = "Raycast visibility",
    Icon = "eye",
    Flag = "VisibleOnly",
    Callback = function(v) getgenv().AimbotSettings.VisibleOnly = v end
})
currentConfig:Register("VisibleOnly", visibleOnlyToggle)

local showFOVToggle = AimTab:Toggle({
    Title = "Show FOV Circle",
    Icon = "circle",
    Flag = "ShowFOV",
    Callback = function(v)
        getgenv().AimbotSettings.ShowFOV = v
        fovFrame.Visible = v
    end
})
currentConfig:Register("ShowFOV", showFOVToggle)

local fovRadiusSlider = AimTab:Slider({
    Title = "Aimbot FOV Radius",
    Step = 10,
    Flag = "FOVRadius",
    Value = { Min = 30, Max = 600, Default = 100 },
    Callback = function(v)
        getgenv().AimbotSettings.FOV = v
        UpdateFOVCircle(v)
    end
})
currentConfig:Register("FOVRadius", fovRadiusSlider)

local fovThicknessSlider = AimTab:Slider({
    Title = "FOV Circle Thickness",
    Step = 0.5,
    Flag = "FOVThickness",
    Value = { Min = 0.5, Max = 5, Default = 1.5 },
    Callback = function(v) fovStroke.Thickness = v end
})
currentConfig:Register("FOVThickness", fovThicknessSlider)

local fovTransparencySlider = AimTab:Slider({
    Title = "FOV Circle Transparency",
    Desc = "Adjusts transparency of the FOV circle",
    Step = 0.05,
    Flag = "FOVTransparency",
    Value = { Min = 0, Max = 1, Default = 0.8 },
    Callback = function(v)
        fovStroke.Transparency = v
        getgenv().AimbotSettings.FOVTransparency = v
    end
})
currentConfig:Register("FOVTransparency", fovTransparencySlider)

local rainbowFOVToggle = AimTab:Toggle({
    Title = "Rainbow FOV",
    Desc = "Smoothly cycles the FOV circle color",
    Icon = "palette",
    Flag = "RainbowFOV",
    Callback = function(v)
        getgenv().AimbotSettings.RainbowFOV = v
        if not v then
            fovStroke.Color = Color3.fromRGB(255, 0, 100)
        end
    end
})
currentConfig:Register("RainbowFOV", rainbowFOVToggle)

local smoothnessSlider = AimTab:Slider({
    Title = "Aimbot Smoothness",
    Step = 1,
    Flag = "Smoothness",
    Value = { Min = 1, Max = 10, Default = 1 },
    Callback = function(v) getgenv().AimbotSettings.Smoothness = v end
})
currentConfig:Register("Smoothness", smoothnessSlider)

local hitboxToggle = AimTab:Toggle({
    Title = "Head Hitbox Size Changer",
    Icon = "maximize-2",
    Flag = "HitboxEnabled",
    Callback = function(v) getgenv().HitboxSettings.Enabled = v end
})
currentConfig:Register("HitboxEnabled", hitboxToggle)

local hitboxSizeSlider = AimTab:Slider({
    Title = "Hitbox Size",
    Step = 1,
    Flag = "HitboxSize",
    Value = { Min = 2, Max = 12, Default = 6 },
    Callback = function(v) getgenv().HitboxSettings.Size = v end
})
currentConfig:Register("HitboxSize", hitboxSizeSlider)

local hitboxWallCheckToggle = AimTab:Toggle({
    Title = "Hitbox Wall Check",
    Icon = "eye-off",
    Flag = "HitboxWallCheck",
    Callback = function(v) getgenv().HitboxSettings.WallCheck = v end
})
currentConfig:Register("HitboxWallCheck", hitboxWallCheckToggle)

local AntiAimTab = Window:Tab({ Title = "Anti Aim", Icon = "shield-off" })

local function StartSpinBot()
    if Connections.Spin then Connections.Spin:Disconnect() end
    local currentAngle = 0
    Connections.Spin = RunService.Heartbeat:Connect(function()
        if getgenv().SpinBotSettings.Enabled then
            local character = LocalPlayer.Character
            if not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart or not humanoid then return end

            humanoid.AutoRotate = false
            if getgenv().SpinBotSettings.Mode == "Spin" then
                currentAngle = (currentAngle + 160) % 360
                rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(currentAngle), 0)
            elseif getgenv().SpinBotSettings.Mode == "MoonWalk" then
                local camDir = Camera.CFrame.LookVector
                local horizontalDir = Vector3.new(camDir.X, 0, camDir.Z).Unit
                if horizontalDir.Magnitude < 0.001 then horizontalDir = Vector3.new(0, 0, -1) end
                rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position - horizontalDir)
            end
        end
    end)
end

local spinBotToggle = AntiAimTab:Toggle({
    Title = "Spin Bot",
    Desc = "Spins The Player In Circles",
    Icon = "refresh-cw",
    Flag = "SpinBotEnabled",
    Callback = function(state)
        getgenv().SpinBotSettings.Enabled = state
        if state then StartSpinBot()
        else
            if Connections.Spin then Connections.Spin:Disconnect() Connections.Spin = nil end
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.AutoRotate = true end
        end
    end
})
currentConfig:Register("SpinBotEnabled", spinBotToggle)

local spinModeDropdown = AntiAimTab:Dropdown({
    Title = "SpinBot Mode",
    Desc = "Select spin type",
    Flag = "SpinBotMode",
    Values = {
        { Title = "Spin", Desc = "Fast yaw spin", Icon = "refresh-cw", Callback = function()
            getgenv().SpinBotSettings.Mode = "Spin"
            if getgenv().SpinBotSettings.Enabled then StartSpinBot() end
        end },
        { Title = "MoonWalk", Desc = "Face opposite of camera", Icon = "arrow-left-right", Callback = function()
            getgenv().SpinBotSettings.Mode = "MoonWalk"
            if getgenv().SpinBotSettings.Enabled then StartSpinBot() end
        end }
    }
})
currentConfig:Register("SpinBotMode", spinModeDropdown)

local ExploitsTab = Window:Tab({ Title = "Exploits", Icon = "zap" })

-- ==================== PING CHANGER ====================
local pingChangerToggle = ExploitsTab:Toggle({
    Title = "Ping Changer",
    Desc = "Changes The Ping People See On The Leaderboard",
    Icon = "wifi",
    Flag = "PingChanger",
    Callback = function(state)
        if state then
            if Connections.PingChanger then Connections.PingChanger:Disconnect() end
            Connections.PingChanger = RunService.Heartbeat:Connect(function()
                local latencyValue = getgenv().PingChangerValue or 0
                local eventModule = ReplicatedStorage:FindFirstChild("GameEvents")
                if eventModule then
                    local latencyEvent = eventModule:FindFirstChild("Latency")
                    if latencyEvent then
                        latencyEvent:FireServer(latencyValue)
                    end
                end
            end)
        else
            if Connections.PingChanger then
                Connections.PingChanger:Disconnect()
                Connections.PingChanger = nil
            end
        end
    end
})
currentConfig:Register("PingChanger", pingChangerToggle)

local pingChangerSlider = ExploitsTab:Slider({
    Title = "Ping Value",
    Desc = "Sets the ping value (0 to 1000)",
    Step = 1,
    Flag = "PingChangerValue",
    Value = { Min = 0, Max = 1000, Default = 0 },
    Callback = function(value)
        getgenv().PingChangerValue = value
    end
})
currentConfig:Register("PingChangerValue", pingChangerSlider)


-- ==================== AUTO KILL V1 [BETA] + V2 WITH SAFE LOGGING ====================
-- Safe logging function – tries io, then writefile, then console only
local function LogToFile(message)
    local timestamp = os.date("%H:%M:%S")
    local formatted = string.format("[%s] %s", timestamp, message)
    print(formatted) -- always print to console

    local function writeToFile(content)
        -- Method 1: io (standard Lua)
        if io and io.open then
            local file, err = io.open("autokill_log.txt", "a")
            if file then
                file:write(content .. "\n")
                file:close()
                return true
            end
        end
        -- Method 2: writefile / appendfile (most executors)
        if writefile then
            local path = "autokill_log.txt"
            local exists = isfile and isfile(path)
            if exists then
                local current = readfile(path)
                writefile(path, current .. content .. "\n")
            else
                writefile(path, content .. "\n")
            end
            return true
        end
        -- Method 3: appendfile (alternative)
        if appendfile then
            appendfile("autokill_log.txt", content .. "\n")
            return true
        end
        return false
    end
    -- Wrap in pcall to catch any errors silently
    local success, err = pcall(writeToFile, formatted)
    if not success then
        -- If all fails, just print a warning once
        if not LogToFile._warned then
            print("[Log] Could not write to file – only console output available")
            LogToFile._warned = true
        end
    end
end

-- Write a header when the script loads (optional)
LogToFile(string.rep("=", 60))
LogToFile("Auto Kill Log started - " .. os.date("%Y-%m-%d %H:%M:%S"))
LogToFile(string.rep("=", 60))

-- ==================== AUTO KILL V1 [BETA] ====================
local autoKillV1Connection = nil
local autoKillV1Running = false

local function IsVisible(targetPart)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.IgnoreWater = true
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin).Unit * 1000
    local result = workspace:Raycast(origin, dir, params)
    return result == nil
end

local function AutoKillV1Loop()
    if not autoKillV1Running then
        LogToFile("[V1] Loop called but running is false – exiting")
        return
    end
    LogToFile("[V1] Heartbeat tick")

    local localChar = LocalPlayer.Character
    if not localChar then
        LogToFile("[V1] No local character")
        return
    end
    local lRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not lRoot then
        LogToFile("[V1] No humanoid root part")
        return
    end

    local remote = ReplicatedStorage:FindFirstChild("GameEvents")
    if remote then remote = remote:FindFirstChild("Damage") end
    if not remote then
        LogToFile("[V1] Remote not found! Check path: ReplicatedStorage.GameEvents.Damage")
        return
    end
    LogToFile("[V1] Remote found")

    local localTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local weaponName = (localTool and localTool.Name) or "Bayonet"
    LogToFile("[V1] Weapon name: " .. weaponName)

    local enemiesChecked = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if LocalPlayer.Team and plr.Team == LocalPlayer.Team then
            LogToFile("[V1] Skipping teammate: " .. plr.Name)
            continue
        end
        if not plr.Character then
            LogToFile("[V1] Player " .. plr.Name .. " has no character")
            continue
        end
        local head = plr.Character:FindFirstChild("Head")
        if not head then
            LogToFile("[V1] Player " .. plr.Name .. " has no Head")
            continue
        end
        enemiesChecked = enemiesChecked + 1
        LogToFile("[V1] Checking " .. plr.Name .. " Head visibility...")
        local visible = IsVisible(head)
        LogToFile("[V1] Head visible: " .. tostring(visible) .. " for " .. plr.Name)
        if visible then
            LogToFile("[V1] Firing remote for " .. plr.Name)
            local startPos = lRoot.Position
            local endPos = head.Position
            local direction = (endPos - startPos).Unit
            local normal = -direction
            local success, err = pcall(function()
                remote:FireServer(
                    plr,
                    200,
                    weaponName,
                    {
                        Normal = normal,
                        Direction = direction,
                        StartPosition = startPos,
                        Instance = head,
                        Material = Enum.Material.Plastic,
                        EndPosition = endPos
                    }
                )
            end)
            if success then
                LogToFile("[V1] Remote fired successfully for " .. plr.Name)
            else
                LogToFile("[V1] Remote fire error: " .. tostring(err))
            end
            break
        end
    end
    if enemiesChecked == 0 then
        LogToFile("[V1] No valid enemies found this tick")
    end
end

local autoKillV1Toggle = ExploitsTab:Toggle({
    Title = "Auto Kill V1 [BETA]",
    Desc = "Targets only if head is visible",
    Icon = "target",
    Flag = "AutoKillV1",
    Callback = function(state)
        LogToFile("[V1] Toggle state: " .. tostring(state))
        if state then
            if autoKillV1Connection then
                autoKillV1Connection:Disconnect()
                autoKillV1Connection = nil
            end
            autoKillV1Running = true
            autoKillV1Connection = RunService.Heartbeat:Connect(AutoKillV1Loop)
            LogToFile("[V1] Heartbeat connection established")
        else
            autoKillV1Running = false
            if autoKillV1Connection then
                autoKillV1Connection:Disconnect()
                autoKillV1Connection = nil
                LogToFile("[V1] Heartbeat connection stopped")
            end
        end
    end
})
currentConfig:Register("AutoKillV1", autoKillV1Toggle)

-- ==================== AUTO KILL V2 [BETA] ====================
local autoKillV2Connection = nil
local autoKillV2Running = false

local function AutoKillV2Loop()
    if not autoKillV2Running then
        LogToFile("[V2] Loop called but running is false – exiting")
        return
    end
    LogToFile("[V2] Heartbeat tick")

    local localChar = LocalPlayer.Character
    if not localChar then
        LogToFile("[V2] No local character")
        return
    end
    local lRoot = localChar:FindFirstChild("HumanoidRootPart")
    if not lRoot then
        LogToFile("[V2] No humanoid root part")
        return
    end

    local remote = ReplicatedStorage:FindFirstChild("GameEvents")
    if remote then remote = remote:FindFirstChild("Damage") end
    if not remote then
        LogToFile("[V2] Remote not found! Check path: ReplicatedStorage.GameEvents.Damage")
        return
    end
    LogToFile("[V2] Remote found")

    local localTool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local weaponName = (localTool and localTool.Name) or "Bayonet"
    LogToFile("[V2] Weapon name: " .. weaponName)

    local priority = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
    local enemiesChecked = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if LocalPlayer.Team and plr.Team == LocalPlayer.Team then
            LogToFile("[V2] Skipping teammate: " .. plr.Name)
            continue
        end
        if not plr.Character then
            LogToFile("[V2] Player " .. plr.Name .. " has no character")
            continue
        end
        enemiesChecked = enemiesChecked + 1
        local targetPart = nil
        for _, name in ipairs(priority) do
            local part = plr.Character:FindFirstChild(name)
            if part then
                LogToFile("[V2] Checking " .. plr.Name .. " " .. name .. " visibility...")
                local visible = IsVisible(part)
                LogToFile("[V2] Part " .. name .. " visible: " .. tostring(visible))
                if visible then
                    targetPart = part
                    break
                end
            else
                LogToFile("[V2] Part " .. name .. " not found for " .. plr.Name)
            end
        end
        if targetPart then
            LogToFile("[V2] Firing remote for " .. plr.Name .. " target part: " .. targetPart.Name)
            local startPos = lRoot.Position
            local endPos = targetPart.Position
            local direction = (endPos - startPos).Unit
            local normal = -direction
            local success, err = pcall(function()
                remote:FireServer(
                    plr,
                    200,
                    weaponName,
                    {
                        Normal = normal,
                        Direction = direction,
                        StartPosition = startPos,
                        Instance = targetPart,
                        Material = Enum.Material.Plastic,
                        EndPosition = endPos
                    }
                )
            end)
            if success then
                LogToFile("[V2] Remote fired successfully for " .. plr.Name)
            else
                LogToFile("[V2] Remote fire error: " .. tostring(err))
            end
            break
        else
            LogToFile("[V2] No visible part found for " .. plr.Name)
        end
    end
    if enemiesChecked == 0 then
        LogToFile("[V2] No valid enemies found this tick")
    end
end

local autoKillV2Toggle = ExploitsTab:Toggle({
    Title = "Auto Kill V2 [BETA]",
    Desc = "Targets any visible part with priority (Head > Torso > Arms > Legs)",
    Icon = "crosshair",
    Flag = "AutoKillV2",
    Callback = function(state)
        LogToFile("[V2] Toggle state: " .. tostring(state))
        if state then
            if autoKillV2Connection then
                autoKillV2Connection:Disconnect()
                autoKillV2Connection = nil
            end
            autoKillV2Running = true
            autoKillV2Connection = RunService.Heartbeat:Connect(AutoKillV2Loop)
            LogToFile("[V2] Heartbeat connection established")
        else
            autoKillV2Running = false
            if autoKillV2Connection then
                autoKillV2Connection:Disconnect()
                autoKillV2Connection = nil
                LogToFile("[V2] Heartbeat connection stopped")
            end
        end
    end
})
currentConfig:Register("AutoKillV2", autoKillV2Toggle)
local killAllToggle = ExploitsTab:Toggle({
    Title = "Kill All (YOU HAVE TO MANUALLY SHOOT)",
    Desc = "Teleports above & behind enemies",
    Icon = "swords",
    Flag = "KillAll",
    Callback = function(state)
        if state then
            local TargetIndex = 1
            local LastTargetTime = 0
            Connections.Backstab = RunService.Heartbeat:Connect(function()
                if not getgenv().BackstabActive then return end
                local localChar = LocalPlayer.Character
                local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
                if not localHRP then return end
                local allPlayers = Players:GetPlayers()
                local validEnemies = {}
                for _, player in pairs(allPlayers) do
                    if player ~= LocalPlayer and player.Character then
                        if not LocalPlayer.Team or player.Team ~= LocalPlayer.Team then
                            local enemyHum = player.Character:FindFirstChildOfClass("Humanoid")
                            local enemyHRP = player.Character:FindFirstChild("HumanoidRootPart")
                            if enemyHum and enemyHRP and enemyHum.Health > 0 then
                                table.insert(validEnemies, player.Character)
                            end
                        end
                    end
                end
                if #validEnemies == 0 then return end
                if os.clock() - LastTargetTime >= 2 then
                    TargetIndex = TargetIndex + 1
                    if TargetIndex > #validEnemies then TargetIndex = 1 end
                    LastTargetTime = os.clock()
                end
                local targetChar = validEnemies[TargetIndex] or validEnemies[1]
                if targetChar then
                    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                    local targetHead = targetChar:FindFirstChild("Head")
                    if targetHRP then
                        localChar.HumanoidRootPart.CFrame = targetHRP.CFrame * CFrame.new(0, 3.5, 0.5)
                    end
                    if targetHead then
                        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
                    end
                end
            end)
            getgenv().BackstabActive = true
        else
            if Connections.Backstab then Connections.Backstab:Disconnect() Connections.Backstab = nil end
            getgenv().BackstabActive = false
        end
    end
})
currentConfig:Register("KillAll", killAllToggle)

local infiniteAmmoToggle = ExploitsTab:Toggle({
    Title = "Use Reserve Ammo (Reload Exploit)",
    Desc = "Uses ammo from reserve",
    Icon = "repeat",
    Flag = "InfiniteAmmo",
    Callback = function(state)
        if state then
            Connections.InfiniteAmmo = RunService.Heartbeat:Connect(function()
                local re = ReplicatedStorage:FindFirstChild("GameEvents")
                if re then re = re:FindFirstChild("Reload") end
                if re then re:FireServer("PPSH-41") end
            end)
        else
            if Connections.InfiniteAmmo then
                Connections.InfiniteAmmo:Disconnect()
                Connections.InfiniteAmmo = nil
            end
        end
    end
})
currentConfig:Register("InfiniteAmmo", infiniteAmmoToggle)

ExploitsTab:Button({
    Title = "Anti Kick",
    Desc = "Prevents kicks (leave button breaks)",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-anti-kick-211995"))()
    end
})

ExploitsTab:Button({
    Title = "Gun Spoofer",
    Desc = "Equip any tool from workspace",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Game-tool-equipper-12139"))()
    end
})

local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })

local skeletonToggle = VisualsTab:Toggle({
    Title = "Skeleton ESP",
    Desc = "Draws lines connecting body parts",
    Icon = "activity",
    Flag = "SkeletonESP",
    Callback = function(state) getgenv().EspSettings.Skeleton = state end
})
currentConfig:Register("SkeletonESP", skeletonToggle)

local tracersToggle = VisualsTab:Toggle({
    Title = "Tracers ESP",
    Desc = "Draws a line from screen bottom to enemy HRP",
    Icon = "trending-up",
    Flag = "TracersESP",
    Callback = function(state) getgenv().EspSettings.Tracers = state end
})
currentConfig:Register("TracersESP", tracersToggle)

local nameEspToggle = VisualsTab:Toggle({
    Title = "Name ESP",
    Desc = "Shows player names above head",
    Icon = "user",
    Flag = "NameESP",
    Callback = function(state) getgenv().EspSettings.Name = state end
})
currentConfig:Register("NameESP", nameEspToggle)

local healthEspToggle = VisualsTab:Toggle({
    Title = "Health ESP",
    Desc = "Shows health percentage above head",
    Icon = "heart",
    Flag = "HealthESP",
    Callback = function(state) getgenv().EspSettings.Health = state end
})
currentConfig:Register("HealthESP", healthEspToggle)

local toolEspToggle = VisualsTab:Toggle({
    Title = "Tool ESP",
    Desc = "Shows current tool name near player",
    Icon = "wrench",
    Flag = "ToolESP",
    Callback = function(state) getgenv().EspSettings.Tool = state end
})
currentConfig:Register("ToolESP", toolEspToggle)

local rainbowEspToggle = VisualsTab:Toggle({
    Title = "Rainbow ESP",
    Desc = "Cycles ESP colors smoothly",
    Icon = "palette",
    Flag = "RainbowESP",
    Callback = function(v) getgenv().EspSettings.Rainbow = v end
})
currentConfig:Register("RainbowESP", rainbowEspToggle)

local chamsToggle = VisualsTab:Toggle({
    Title = "Player Wallhack (Chams)",
    Desc = "See players outlines through walls",
    Icon = "users",
    Flag = "Chams",
    Callback = function(state)
        if state then
            local function ApplyChams(player)
                if player ~= LocalPlayer then
                    player.CharacterAdded:Connect(function(char)
                        local h = Instance.new("Highlight"); h.Name = "JB_ESP"; h.FillColor = Color3.fromRGB(255,0,100); h.OutlineColor = Color3.fromRGB(255,255,255); h.FillTransparency = 0.5; h.Parent = char
                    end)
                    if player.Character then
                        local h = Instance.new("Highlight"); h.Name = "JB_ESP"; h.FillColor = Color3.fromRGB(255,0,100); h.OutlineColor = Color3.fromRGB(255,255,255); h.FillTransparency = 0.5; h.Parent = player.Character
                    end
                end
            end
            for _, p in pairs(Players:GetPlayers()) do ApplyChams(p) end
            Connections.Chams = Players.PlayerAdded:Connect(ApplyChams)
        else
            if Connections.Chams then Connections.Chams:Disconnect() end
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("JB_ESP") then p.Character.JB_ESP:Destroy() end
            end
        end
    end
})
currentConfig:Register("Chams", chamsToggle)

local fullbrightToggle = VisualsTab:Toggle({
    Title = "Fullbright",
    Icon = "sun",
    Flag = "Fullbright",
    Callback = function(state)
        if state then
            Lighting.Brightness = 4
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.fromRGB(130,130,130)
            Lighting.GlobalShadows = true
        end
    end
})
currentConfig:Register("Fullbright", fullbrightToggle)

local fovRedSlider = VisualsTab:Slider({
    Title = "FOV Red",
    Step = 1,
    Flag = "FOVRed",
    Value = { Min = 0, Max = 255, Default = 255 },
    Callback = function(v)
        local r,g,b = fovStroke.Color.R*255, fovStroke.Color.G*255, fovStroke.Color.B*255
        fovStroke.Color = Color3.fromRGB(v,g,b)
    end
})
currentConfig:Register("FOVRed", fovRedSlider)

local fovGreenSlider = VisualsTab:Slider({
    Title = "FOV Green",
    Step = 1,
    Flag = "FOVGreen",
    Value = { Min = 0, Max = 255, Default = 0 },
    Callback = function(v)
        local r,g,b = fovStroke.Color.R*255, fovStroke.Color.G*255, fovStroke.Color.B*255
        fovStroke.Color = Color3.fromRGB(r,v,b)
    end
})
currentConfig:Register("FOVGreen", fovGreenSlider)

local fovBlueSlider = VisualsTab:Slider({
    Title = "FOV Blue",
    Step = 1,
    Flag = "FOVBlue",
    Value = { Min = 0, Max = 255, Default = 100 },
    Callback = function(v)
        local r,g,b = fovStroke.Color.R*255, fovStroke.Color.G*255, fovStroke.Color.B*255
        fovStroke.Color = Color3.fromRGB(r,g,v)
    end
})
currentConfig:Register("FOVBlue", fovBlueSlider)

local UtilTab = Window:Tab({ Title = "Utility", Icon = "wrench" })

local cameraFOVToggle = UtilTab:Toggle({
    Title = "Camera FOV Override",
    Desc = "Override camera field of view",
    Icon = "eye",
    Flag = "CameraFOVEnabled",
    Callback = function(state)
        getgenv().CameraFOVEnabled = state
        if state then
            Camera.FieldOfView = getgenv().CameraFOVValue or 70
            if Connections.CameraFOV then Connections.CameraFOV:Disconnect() end
            Connections.CameraFOV = RunService.Heartbeat:Connect(function()
                if getgenv().CameraFOVEnabled then
                    Camera.FieldOfView = getgenv().CameraFOVValue or 70
                end
            end)
        else
            if Connections.CameraFOV then
                Connections.CameraFOV:Disconnect()
                Connections.CameraFOV = nil
            end
            Camera.FieldOfView = 70
        end
    end
})
currentConfig:Register("CameraFOVEnabled", cameraFOVToggle)

local cameraFOVSlider = UtilTab:Slider({
    Title = "Camera FOV Value",
    Desc = "Field of view (60-150)",
    Step = 1,
    Flag = "CameraFOVValue",
    Value = { Min = 60, Max = 150, Default = 70 },
    Callback = function(value)
        getgenv().CameraFOVValue = value
        if getgenv().CameraFOVEnabled then
            Camera.FieldOfView = value
        end
    end
})
currentConfig:Register("CameraFOVValue", cameraFOVSlider)

UtilTab:Button({
    Title = "Teleport Upwards",
    Desc = "+25 studs",
    Callback = function()
        local r = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame = r.CFrame + Vector3.new(0,25,0) end
    end
})
UtilTab:Button({
    Title = "Teleport Downwards",
    Desc = "-15 studs",
    Callback = function()
        local r = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame = r.CFrame + Vector3.new(0,-15,0) end
    end
})
UtilTab:Button({
    Title = "Infinite Camera Zoom",
    Callback = function()
        LocalPlayer.CameraMaxZoomDistance = 5000
    end
})
UtilTab:Button({
    Title = "Respawn / Reset Character",
    Callback = function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
})

local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

local themeDropdownValues = {}
for _, t in ipairs(customThemes) do
    table.insert(themeDropdownValues, { Title = t.Name, Icon = "palette", Callback = function() WindUI:SetTheme(t.Name) end })
end
SettingsTab:Dropdown({
    Title = "Select Interface Theme",
    Desc = "Custom themes",
    Values = themeDropdownValues
})

SettingsTab:Button({
    Title = "Save Config",
    Desc = "Saves current settings to DefaultConfig.json",
    Callback = function()
        currentConfig:Save()
    end
})

SettingsTab:Button({
    Title = "Load Config",
    Desc = "Loads settings from DefaultConfig.json",
    Callback = function()
        currentConfig:Load()
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if getgenv().SpinBotSettings.Enabled then StartSpinBot() end
end)

pcall(function()
    currentConfig:Load()
end)