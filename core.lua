return {
    Init = function()
        local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
        getgenv().WindUI = WindUI

        local customThemes = {
            { Name = "Obsidian", Accent = Color3.fromHex("#1a1a1a"), Background = Color3.fromHex("#0d0d0d"), Outline = Color3.fromHex("#404040"), Text = Color3.fromHex("#e0e0e0"), Placeholder = Color3.fromHex("#6b6b6b"), Button = Color3.fromHex("#2b2b2b"), Icon = Color3.fromHex("#9e9e9e") },
            { Name = "Crimson", Accent = Color3.fromHex("#2d1111"), Background = Color3.fromHex("#1a0a0a"), Outline = Color3.fromHex("#ff4444"), Text = Color3.fromHex("#ffffff"), Placeholder = Color3.fromHex("#8b5e5e"), Button = Color3.fromHex("#4a2020"), Icon = Color3.fromHex("#ff6666") },
            { Name = "Ocean", Accent = Color3.fromHex("#0b1a2a"), Background = Color3.fromHex("#050d14"), Outline = Color3.fromHex("#3a8fd4"), Text = Color3.fromHex("#e6f0ff"), Placeholder = Color3.fromHex("#5b7a9e"), Button = Color3.fromHex("#1a2e42"), Icon = Color3.fromHex("#5aa9e6") },
            { Name = "Sunset", Accent = Color3.fromHex("#2a1a1a"), Background = Color3.fromHex("#140a0a"), Outline = Color3.fromHex("#ff8c42"), Text = Color3.fromHex("#ffe0cc"), Placeholder = Color3.fromHex("#8c6242"), Button = Color3.fromHex("#3d2626"), Icon = Color3.fromHex("#ffb380") },
            { Name = "Forest", Accent = Color3.fromHex("#1a2e1a"), Background = Color3.fromHex("#0d1a0d"), Outline = Color3.fromHex("#4caf50"), Text = Color3.fromHex("#e0ffe0"), Placeholder = Color3.fromHex("#5e8c5e"), Button = Color3.fromHex("#2b472b"), Icon = Color3.fromHex("#81c784") },
        }
        for _, theme in ipairs(customThemes) do WindUI:AddTheme(theme) end
        WindUI:SetTheme("Obsidian")

        local Window = WindUI:CreateWindow({ Title = "BR Hub | JailBird Edition", Icon = "shield", Author = "by goth", Folder = "BR_Hub" })
        getgenv().Window = Window

        Window:EditOpenButton({
            Title = "BR Hub | Jailbird",
            Icon = "terminal",
            CornerRadius = UDim.new(0,12),
            StrokeThickness = 2,
            Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
            OnlyMobile = false,
            Enabled = true,
            Draggable = true,
        })

        getgenv().ConfigManager = Window.ConfigManager
        getgenv().currentConfig = getgenv().ConfigManager:CreateConfig("DefaultConfig")

        getgenv().SpinBotSettings = { Enabled = false, Mode = "Spin" }
        getgenv().AimbotSettings = { Enabled = false, Smoothness = 1, TargetPart = "Head", TeamCheck = false, FOV = 100, ShowFOV = true, VisibleOnly = false, MouseLock = false }
        getgenv().EspSettings = { Boxes = false, Tracers = false, Skeleton = false }
        getgenv().HitboxSettings = { Enabled = false, Size = 4, WallCheck = false }
        getgenv().Connections = {}

        getgenv().Tabs = {
            Info = Window:Tab({ Title = "Info", Icon = "home" }),
            Movement = Window:Tab({ Title = "Movement", Icon = "user" }),
            Aim = Window:Tab({ Title = "Aim", Icon = "crosshair" }),
            AntiAim = Window:Tab({ Title = "Anti Aim", Icon = "shield-off" }),
            Exploits = Window:Tab({ Title = "Exploits", Icon = "zap" }),
            Visuals = Window:Tab({ Title = "Visuals", Icon = "eye" }),
            Utility = Window:Tab({ Title = "Utility", Icon = "wrench" }),
            Settings = Window:Tab({ Title = "Settings", Icon = "settings" }),
        }

        -- Info tab content
        local info = getgenv().Tabs.Info
        info:Button({ Title = "Welcome to BR Hub", Desc = "Current Version: v2.4.0", Callback = function() end })
        info:Button({ Title = "Changelog", Desc = "- Config system added\n- Skeleton & Tracer ESP\n- Team-colored visuals\n- Custom themes", Callback = function() end })
        info:Button({ Title = "Script Credits", Desc = "Lead Developer: goth\nUI Framework: WindUI", Callback = function() end })

        -- AFK bypass
        local vUser = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            vUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)

        -- UI toggle with RightControl
        local uiVisible = true
        game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
                uiVisible = not uiVisible
                pcall(function() Window.Main.Visible = uiVisible end)
            end
        end)

        -- ------------------------------------------------------------
        -- FOV CIRCLE CREATION (moved from aimbot.lua)
        -- ------------------------------------------------------------
        pcall(function()
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
            getgenv().fovFrame = fovFrame
            getgenv().fovStroke = fovStroke

            function getgenv().UpdateFOVCircle(radius)
                fovFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
            end
            getgenv().UpdateFOVCircle(getgenv().AimbotSettings.FOV)
        end)

        -- ------------------------------------------------------------
        -- AIMBOT RENDER LOOP (hitbox expansion + camera locking)
        -- ------------------------------------------------------------
        pcall(function()
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

            getgenv().Connections.AimbotRender = game:GetService("RunService").RenderStepped:Connect(function()
                local cam = workspace.CurrentCamera
                local lp = game:GetService("Players").LocalPlayer
                local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                local aimSettings = getgenv().AimbotSettings
                local hitSettings = getgenv().HitboxSettings

                -- Hitbox expansion
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
                            if hitSettings.WallCheck then wallOk = IsVisible(hrp) end
                            if hitSettings.Enabled and inFov and wallOk then
                                local sz = Vector3.new(hitSettings.Size, hitSettings.Size, hitSettings.Size)
                                head.Size = sz; head.CanCollide = false
                                hrp.Size = sz; hrp.CanCollide = false
                            else
                                head.Size = Vector3.new(2, 1, 1); head.CanCollide = true
                                hrp.Size = Vector3.new(2, 2, 1); hrp.CanCollide = true
                            end
                        end
                    end
                end

                -- Aimbot
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
        end)
    end
}
