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
WindUI:SetTheme("Obsidian")

local Window = WindUI:CreateWindow({
    Title = "BR Hub | JailBird Edition",
    Icon = "shield",
    Author = "by goth",
    Folder = "BR_Hub"
})

Window:EditOpenButton({
    Title = "BR Hub | Jailbird",
    Icon = "terminal",
    CornerRadius = UDim.new(0,12),
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

getgenv().SpinBotSettings = { Enabled = false, Mode = "Spin" }
getgenv().AimbotSettings = { Enabled = false, Smoothness = 1, TargetPart = "Head", TeamCheck = false, FOV = 100, ShowFOV = true, VisibleOnly = false }
getgenv().EspSettings = { Boxes = false, Tracers = false, Skeleton = false }
getgenv().HitboxSettings = { Enabled = false, Size = 4, WallCheck = false }

local SpinConnection = nil
local NoclipConnection = nil
local BackstabActive = false
local BackstabLoopConnection = nil
local InfiniteAmmoConnection = nil
local TPWalkConnection = nil

local vUser = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

local uiVisible = true
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        uiVisible = not uiVisible
        pcall(function() Window.Main.Visible = uiVisible end)
    end
end)

local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
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
    local camera = workspace.CurrentCamera
    local lp = game:GetService("Players").LocalPlayer
    if not lp.Character then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {lp.Character, targetPart.Parent}
    rayParams.IgnoreWater = true
    local origin = camera.CFrame.Position
    local dir = targetPart.Position - origin
    return workspace:Raycast(origin, dir, rayParams) == nil
end

local function GetClosestPlayer()
    local target = nil
    local shortest = math.huge
    local lp = game:GetService("Players").LocalPlayer
    local cam = workspace.CurrentCamera
    local settings = getgenv().AimbotSettings
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= lp and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local aimPart = plr.Character:FindFirstChild(settings.TargetPart)
            if not hrp or not aimPart then continue end
            if settings.TeamCheck and lp.Team and plr.Team == lp.Team then continue end
            if settings.VisibleOnly and not IsVisible(aimPart) then continue end
            local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
            local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
            if dist <= settings.FOV and dist < shortest then
                target = plr
                shortest = dist
            end
        end
    end
    return target
end

game:GetService("RunService").RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local lp = game:GetService("Players").LocalPlayer
    local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local aimSettings = getgenv().AimbotSettings
    local hitSettings = getgenv().HitboxSettings

    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= lp and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if head and hrp then
                local inFov = false
                local pos, onScreen = cam:WorldToViewportPoint(hrp.Position)
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
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, targetPos), 1 / aimSettings.Smoothness)
            if aimSettings.MouseLock then
                local mouse = lp:GetMouse()
                mouse.X, mouse.Y = screenCenter.X, screenCenter.Y
            end
        end
    end
end)

local espLines = {}
local function clearESP()
    for _, line in pairs(espLines) do
        line:Remove()
    end
    espLines = {}
end

local function updateESP()
    local lp = game:GetService("Players").LocalPlayer
    local cam = workspace.CurrentCamera
    local espSettings = getgenv().EspSettings
    if not (espSettings.Skeleton or espSettings.Tracers) then
        clearESP()
        return
    end
    clearESP()

    local localChar = lp.Character
    local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")

    local tracerStart = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
    if localHRP then
        local localScreenPos, localOnScreen = cam:WorldToViewportPoint(localHRP.Position)
        if localOnScreen then
            tracerStart = Vector2.new(localScreenPos.X, localScreenPos.Y)
        end
    end

    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr == lp or not plr.Character then continue end
        local char = plr.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local torso = char:FindFirstChild("Torso")
        local leftArm = char:FindFirstChild("Left Arm")
        local rightArm = char:FindFirstChild("Right Arm")
        local leftLeg = char:FindFirstChild("Left Leg")
        local rightLeg = char:FindFirstChild("Right Leg")

        local teamColor
        if lp.Team and plr.Team and plr.Team == lp.Team then
            teamColor = Color3.fromRGB(50, 150, 255)
        else
            teamColor = Color3.fromRGB(255, 50, 50)
        end

        if espSettings.Skeleton and torso and head and leftArm and rightArm and leftLeg and rightLeg then
            local function drawLine3D(fromWorld, toWorld, color)
                local fromPos, fromOn = cam:WorldToViewportPoint(fromWorld)
                local toPos, toOn = cam:WorldToViewportPoint(toWorld)
                if fromOn and toOn then
                    local line = Drawing.new("Line")
                    line.Visible = true
                    line.Color = color
                    line.Thickness = 1.5
                    line.From = Vector2.new(fromPos.X, fromPos.Y)
                    line.To = Vector2.new(toPos.X, toPos.Y)
                    table.insert(espLines, line)
                end
            end
            drawLine3D(torso.Position, head.Position, teamColor)
            drawLine3D(torso.Position, leftArm.Position, teamColor)
            drawLine3D(torso.Position, rightArm.Position, teamColor)
            local leftFootPos = leftLeg.CFrame * Vector3.new(0, -leftLeg.Size.Y/2, 0)
            local rightFootPos = rightLeg.CFrame * Vector3.new(0, -rightLeg.Size.Y/2, 0)
            drawLine3D(torso.Position, leftFootPos, teamColor)
            drawLine3D(torso.Position, rightFootPos, teamColor)
        end

        if espSettings.Tracers then
            local enemyRoot = hrp
            if enemyRoot then
                local toPos, toOn = cam:WorldToViewportPoint(enemyRoot.Position)
                if toOn then
                    local line = Drawing.new("Line")
                    line.Visible = true
                    line.Color = teamColor
                    line.Thickness = 1.2
                    line.From = tracerStart
                    line.To = Vector2.new(toPos.X, toPos.Y)
                    table.insert(espLines, line)
                end
            end
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(updateESP)

local InfoTab = Window:Tab({ Title = "Info", Icon = "home" })
InfoTab:Button({
    Title = "Welcome to BR Hub",
    Desc = "Current Version: v2.4.0",
    Callback = function() end
})
InfoTab:Button({
    Title = "Changelog",
    Desc = "- Config system added\n- Skeleton & Tracer ESP\n- Team-colored visuals\n- Custom themes",
    Callback = function() end
})
InfoTab:Button({
    Title = "Script Credits",
    Desc = "Lead Developer: goth\nUI Framework: WindUI",
    Callback = function() end
})

local MoveTab = Window:Tab({ Title = "Movement", Icon = "user" })
local walkSpeedSlider = MoveTab:Slider({
    Title = "WalkSpeed", Desc = "Movement speed", Step = 1, Flag = "WalkSpeed",
    Value = { Min = 16, Max = 200, Default = 16 },
    Callback = function(value)
        local hum = (game.Players.LocalPlayer.Character or {}):FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = value end
    end
})
currentConfig:Register("WalkSpeed", walkSpeedSlider)

local jumpPowerSlider = MoveTab:Slider({
    Title = "JumpPower", Desc = "Jump height", Step = 1, Flag = "JumpPower",
    Value = { Min = 50, Max = 300, Default = 50 },
    Callback = function(value)
        local hum = (game.Players.LocalPlayer.Character or {}):FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower = true; hum.JumpPower = value end
    end
})
currentConfig:Register("JumpPower", jumpPowerSlider)

local infJumpToggle = MoveTab:Toggle({
    Title = "Infinite Jump", Desc = "Jump continuously", Icon = "chevrons-up", Flag = "InfiniteJump",
    Callback = function(infj)
        if infj then
            getgenv().InfJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if getgenv().InfJumpConnection then
                getgenv().InfJumpConnection:Disconnect()
                getgenv().InfJumpConnection = nil
            end
        end
    end
})
currentConfig:Register("InfiniteJump", infJumpToggle)

local noclipToggle = MoveTab:Toggle({
    Title = "Noclip", Desc = "Through walls", Icon = "ghost", Flag = "Noclip",
    Callback = function(state)
        if state then
            NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, p in pairs(char:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        else
            if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
        end
    end
})
currentConfig:Register("Noclip", noclipToggle)

local tpWalkToggle = MoveTab:Toggle({
    Title = "TP Walk", Desc = "Forced high-speed movement", Icon = "zap", Flag = "TPWalk",
    Callback = function(state)
        local tpWalkEnabled = state
        if state then
            if TPWalkConnection then TPWalkConnection:Disconnect() end
            TPWalkConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
                if not tpWalkEnabled then return end
                local char = game.Players.LocalPlayer.Character
                if not char then return end
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if not humanoid or not rootPart then return end
                local moveDir = humanoid.MoveDirection
                if moveDir.Magnitude > 0.1 then
                    local delta = moveDir * 50 * dt
                    rootPart.CFrame = rootPart.CFrame + delta
                end
            end)
        else
            if TPWalkConnection then TPWalkConnection:Disconnect() TPWalkConnection = nil end
        end
    end
})
currentConfig:Register("TPWalk", tpWalkToggle)

local AimTab = Window:Tab({ Title = "Aim", Icon = "crosshair" })
local aimbotToggle = AimTab:Toggle({ Title = "Aimbot (lowk sucks)", Desc = "Locks camera onto target", Icon = "target", Flag = "Aimbot", Callback = function(v) getgenv().AimbotSettings.Enabled = v end })
currentConfig:Register("Aimbot", aimbotToggle)

local teamCheckToggle = AimTab:Toggle({ Title = "Team Check", Icon = "users", Flag = "TeamCheck", Callback = function(v) getgenv().AimbotSettings.TeamCheck = v end })
currentConfig:Register("TeamCheck", teamCheckToggle)

local visibleOnlyToggle = AimTab:Toggle({ Title = "Visible Only", Desc = "Raycast visibility", Icon = "eye", Flag = "VisibleOnly", Callback = function(v) getgenv().AimbotSettings.VisibleOnly = v end })
currentConfig:Register("VisibleOnly", visibleOnlyToggle)

local showFOVToggle = AimTab:Toggle({ Title = "Show FOV Circle", Icon = "circle", Flag = "ShowFOV", Callback = function(v) getgenv().AimbotSettings.ShowFOV = v; fovFrame.Visible = v end })
currentConfig:Register("ShowFOV", showFOVToggle)

local fovRadiusSlider = AimTab:Slider({ Title = "Aimbot FOV Radius", Step = 10, Flag = "FOVRadius", Value = { Min = 30, Max = 600, Default = 100 }, Callback = function(v) getgenv().AimbotSettings.FOV = v; UpdateFOVCircle(v) end })
currentConfig:Register("FOVRadius", fovRadiusSlider)

local fovThicknessSlider = AimTab:Slider({ Title = "FOV Circle Thickness", Step = 0.5, Flag = "FOVThickness", Value = { Min = 0.5, Max = 5, Default = 1.5 }, Callback = function(v) fovStroke.Thickness = v end })
currentConfig:Register("FOVThickness", fovThicknessSlider)

local smoothnessSlider = AimTab:Slider({ Title = "Aimbot Smoothness", Step = 1, Flag = "Smoothness", Value = { Min = 1, Max = 10, Default = 1 }, Callback = function(v) getgenv().AimbotSettings.Smoothness = v end })
currentConfig:Register("Smoothness", smoothnessSlider)

local hitboxToggle = AimTab:Toggle({ Title = "Adaptive Hitbox Expander", Icon = "maximize-2", Flag = "HitboxEnabled", Callback = function(v) getgenv().HitboxSettings.Enabled = v end })
currentConfig:Register("HitboxEnabled", hitboxToggle)

local hitboxSizeSlider = AimTab:Slider({ Title = "Hitbox Size Changer", Step = 1, Flag = "HitboxSize", Value = { Min = 2, Max = 30, Default = 6 }, Callback = function(v) getgenv().HitboxSettings.Size = v end })
currentConfig:Register("HitboxSize", hitboxSizeSlider)

local hitboxWallCheckToggle = AimTab:Toggle({ Title = "Hitbox Wall Check", Icon = "eye-off", Flag = "HitboxWallCheck", Callback = function(v) getgenv().HitboxSettings.WallCheck = v end })
currentConfig:Register("HitboxWallCheck", hitboxWallCheckToggle)

local mouseLockToggle = AimTab:Toggle({ Title = "Mouse Lock (Aimbot)", Desc = "Locks mouse to screen centre", Icon = "lock", Flag = "MouseLock", Callback = function(v) getgenv().AimbotSettings.MouseLock = v end })
currentConfig:Register("MouseLock", mouseLockToggle)

local AntiAimTab = Window:Tab({ Title = "Anti Aim", Icon = "shield-off" })
local function StartSpinBot()
    if SpinConnection then SpinConnection:Disconnect() end
    local currentAngle = 0
    SpinConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if getgenv().SpinBotSettings.Enabled then
            local player = game:GetService("Players").LocalPlayer
            local character = player.Character
            if not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart or not humanoid then return end
            
            humanoid.AutoRotate = false
            if getgenv().SpinBotSettings.Mode == "Spin" then
                currentAngle = (currentAngle + 160) % 360
                rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, math.rad(currentAngle), 0)
            elseif getgenv().SpinBotSettings.Mode == "MoonWalk" then
                local camera = workspace.CurrentCamera
                local camDir = camera.CFrame.LookVector
                local horizontalDir = Vector3.new(camDir.X, 0, camDir.Z).Unit
                if horizontalDir.Magnitude < 0.001 then horizontalDir = Vector3.new(0, 0, -1) end
                rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position - horizontalDir)
            end
        end
    end)
end

local spinBotToggle = AntiAimTab:Toggle({
    Title = "Spin Bot", Desc = "Spins The Player In Circles", Icon = "refresh-cw", Flag = "SpinBotEnabled",
    Callback = function(state)
        getgenv().SpinBotSettings.Enabled = state
        if state then StartSpinBot()
        else
            if SpinConnection then SpinConnection:Disconnect() SpinConnection = nil end
            local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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
local killAllToggle = ExploitsTab:Toggle({
    Title = "Kill All (YOU HAVE TO MANUALLY SHOOT)", Desc = "Teleports above & behind enemies", Icon = "swords", Flag = "KillAll",
    Callback = function(state)
        BackstabActive = state
        if state then
            local TargetIndex = 1
            local LastTargetTime = 0
            BackstabLoopConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not BackstabActive then return end
                local localPlayer = game:GetService("Players").LocalPlayer
                local localChar = localPlayer.Character
                local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
                if not localHRP then return end
                local camera = workspace.CurrentCamera
                local allPlayers = game:GetService("Players"):GetPlayers()
                local validEnemies = {}
                for _, player in pairs(allPlayers) do
                    if player ~= localPlayer and player.Character then
                        if not localPlayer.Team or player.Team ~= localPlayer.Team then
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
                        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetHead.Position)
                    end
                end
            end)
        else
            if BackstabLoopConnection then BackstabLoopConnection:Disconnect() BackstabLoopConnection = nil end
        end
    end
})
currentConfig:Register("KillAll", killAllToggle)

local infiniteAmmoToggle = ExploitsTab:Toggle({
    Title = "Use Reserve Ammo (Reload Exploit)", Desc = "Uses ammo from reserve", Icon = "repeat", Flag = "InfiniteAmmo",
    Callback = function(state)
        if state then
            InfiniteAmmoConnection = game:GetService("RunService").Heartbeat:Connect(function()
                local re = game:GetService("ReplicatedStorage"):FindFirstChild("GameEvents")
                if re then re = re:FindFirstChild("Reload") end
                if re then re:FireServer("PPSH-41") end
            end)
        else
            if InfiniteAmmoConnection then InfiniteAmmoConnection:Disconnect() InfiniteAmmoConnection = nil end
        end
    end
})
currentConfig:Register("InfiniteAmmo", infiniteAmmoToggle)

ExploitsTab:Button({ Title = "Anti Kick", Desc = "Prevents kicks (leave button breaks)", Callback = function() loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-anti-kick-211995"))() end })

local VisualsTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local skeletonToggle = VisualsTab:Toggle({
    Title = "Skeleton ESP", Desc = "Draws lines connecting body parts", Icon = "activity", Flag = "SkeletonESP",
    Callback = function(state) getgenv().EspSettings.Skeleton = state end
})
currentConfig:Register("SkeletonESP", skeletonToggle)

local tracersToggle = VisualsTab:Toggle({
    Title = "Tracers ESP", Desc = "Draws a line from screen bottom to enemy HRP", Icon = "trending-up", Flag = "TracersESP",
    Callback = function(state) getgenv().EspSettings.Tracers = state end
})
currentConfig:Register("TracersESP", tracersToggle)

local chamsToggle = VisualsTab:Toggle({
    Title = "Player Wallhack (Chams)", Desc = "See players outlines through walls", Icon = "users", Flag = "Chams",
    Callback = function(state)
        if state then
            local function ApplyChams(player)
                if player ~= game:GetService("Players").LocalPlayer then
                    player.CharacterAdded:Connect(function(char)
                        local h = Instance.new("Highlight"); h.Name = "JB_ESP"; h.FillColor = Color3.fromRGB(255,0,100); h.OutlineColor = Color3.fromRGB(255,255,255); h.FillTransparency = 0.5; h.Parent = char
                    end)
                    if player.Character then
                        local h = Instance.new("Highlight"); h.Name = "JB_ESP"; h.FillColor = Color3.fromRGB(255,0,100); h.OutlineColor = Color3.fromRGB(255,255,255); h.FillTransparency = 0.5; h.Parent = player.Character
                    end
                end
            end
            for _, p in pairs(game:GetService("Players"):GetPlayers()) do ApplyChams(p) end
            getgenv().EspConnection = game:GetService("Players").PlayerAdded:Connect(ApplyChams)
        else
            if getgenv().EspConnection then getgenv().EspConnection:Disconnect() end
            for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("JB_ESP") then p.Character.JB_ESP:Destroy() end
            end
        end
    end
})
currentConfig:Register("Chams", chamsToggle)

local fullbrightToggle = VisualsTab:Toggle({
    Title = "Fullbright", Icon = "sun", Flag = "Fullbright",
    Callback = function(state)
        local lighting = game:GetService("Lighting")
        if state then lighting.Brightness = 4; lighting.Ambient = Color3.fromRGB(255,255,255); lighting.GlobalShadows = false
        else lighting.Brightness = 2; lighting.Ambient = Color3.fromRGB(130,130,130); lighting.GlobalShadows = true end
    end
})
currentConfig:Register("Fullbright", fullbrightToggle)

local fovRedSlider = VisualsTab:Slider({ Title = "FOV Red", Step = 1, Flag = "FOVRed", Value = { Min = 0, Max = 255, Default = 255 }, Callback = function(v) local r,g,b = fovStroke.Color.R*255, fovStroke.Color.G*255, fovStroke.Color.B*255; fovStroke.Color = Color3.fromRGB(v,g,b) end })
currentConfig:Register("FOVRed", fovRedSlider)

local fovGreenSlider = VisualsTab:Slider({ Title = "FOV Green", Step = 1, Flag = "FOVGreen", Value = { Min = 0, Max = 255, Default = 0 }, Callback = function(v) local r,g,b = fovStroke.Color.R*255, fovStroke.Color.G*255, fovStroke.Color.B*255; fovStroke.Color = Color3.fromRGB(r,v,b) end })
currentConfig:Register("FOVGreen", fovGreenSlider)

local fovBlueSlider = VisualsTab:Slider({ Title = "FOV Blue", Step = 1, Flag = "FOVBlue", Value = { Min = 0, Max = 255, Default = 100 }, Callback = function(v) local r,g,b = fovStroke.Color.R*255, fovStroke.Color.G*255, fovStroke.Color.B*255; fovStroke.Color = Color3.fromRGB(r,g,v) end })
currentConfig:Register("FOVBlue", fovBlueSlider)

local UtilTab = Window:Tab({ Title = "Utility", Icon = "wrench" })
UtilTab:Button({ Title = "Teleport Upwards", Desc = "+25 studs", Callback = function() local r = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if r then r.CFrame = r.CFrame + Vector3.new(0,25,0) end end })
UtilTab:Button({ Title = "Teleport Downwards", Desc = "-15 studs", Callback = function() local r = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if r then r.CFrame = r.CFrame + Vector3.new(0,-15,0) end end })
UtilTab:Button({ Title = "Infinite Camera Zoom", Callback = function() game.Players.LocalPlayer.CameraMaxZoomDistance = 5000 end })
UtilTab:Button({ Title = "Respawn / Reset Character", Callback = function() local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.Health = 0 end end })

local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })
local themeDropdownValues = {}
for _, t in ipairs(customThemes) do
    table.insert(themeDropdownValues, { Title = t.Name, Icon = "palette", Callback = function() WindUI:SetTheme(t.Name) end })
end
SettingsTab:Dropdown({ Title = "Select Interface Theme", Desc = "Custom themes", Values = themeDropdownValues })

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

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if getgenv().SpinBotSettings.Enabled then StartSpinBot() end
end)

pcall(function()
    currentConfig:Load()
end)
