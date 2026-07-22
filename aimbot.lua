return {
    Init = function()
        print("Aimbot Init started")
        local tab = getgenv().Tabs.Aim
        if not tab then
            warn("Aimbot: Aim tab not found")
            return
        end

        -- Helper to safely add UI elements
        local function safe(fn)
            local ok, err = pcall(fn)
            if not ok then
                warn("Aimbot UI error: " .. tostring(err))
            end
        end

        -- Aimbot toggle
        safe(function()
            tab:Toggle({
                Title = "Aimbot (lowk sucks)",
                Desc = "Locks camera onto target",
                Icon = "target",
                Flag = "Aimbot",
                Callback = function(v)
                    getgenv().AimbotSettings.Enabled = v
                end
            })
        end)

        -- Team Check
        safe(function()
            tab:Toggle({
                Title = "Team Check",
                Icon = "users",
                Flag = "TeamCheck",
                Callback = function(v)
                    getgenv().AimbotSettings.TeamCheck = v
                end
            })
        end)

        -- Visible Only
        safe(function()
            tab:Toggle({
                Title = "Visible Only",
                Desc = "Raycast visibility",
                Icon = "eye",
                Flag = "VisibleOnly",
                Callback = function(v)
                    getgenv().AimbotSettings.VisibleOnly = v
                end
            })
        end)

        -- Show FOV Circle
        safe(function()
            tab:Toggle({
                Title = "Show FOV Circle",
                Icon = "circle",
                Flag = "ShowFOV",
                Callback = function(v)
                    getgenv().AimbotSettings.ShowFOV = v
                    if getgenv().fovFrame then
                        getgenv().fovFrame.Visible = v
                    end
                end
            })
        end)

        -- FOV Radius
        safe(function()
            tab:Slider({
                Title = "Aimbot FOV Radius",
                Step = 10,
                Flag = "FOVRadius",
                Value = { Min = 30, Max = 600, Default = 100 },
                Callback = function(v)
                    getgenv().AimbotSettings.FOV = v
                    if getgenv().UpdateFOVCircle then
                        getgenv().UpdateFOVCircle(v)
                    end
                end
            })
        end)

        -- FOV Circle Thickness
        safe(function()
            tab:Slider({
                Title = "FOV Circle Thickness",
                Step = 0.5,
                Flag = "FOVThickness",
                Value = { Min = 0.5, Max = 5, Default = 1.5 },
                Callback = function(v)
                    if getgenv().fovStroke then
                        getgenv().fovStroke.Thickness = v
                    end
                end
            })
        end)

        -- Aimbot Smoothness
        safe(function()
            tab:Slider({
                Title = "Aimbot Smoothness",
                Step = 1,
                Flag = "Smoothness",
                Value = { Min = 1, Max = 10, Default = 1 },
                Callback = function(v)
                    getgenv().AimbotSettings.Smoothness = v
                end
            })
        end)

        -- Hitbox Expander
        safe(function()
            tab:Toggle({
                Title = "Adaptive Hitbox Expander",
                Icon = "maximize-2",
                Flag = "HitboxEnabled",
                Callback = function(v)
                    getgenv().HitboxSettings.Enabled = v
                end
            })
        end)

        -- Hitbox Size
        safe(function()
            tab:Slider({
                Title = "Hitbox Size Changer",
                Step = 1,
                Flag = "HitboxSize",
                Value = { Min = 2, Max = 30, Default = 6 },
                Callback = function(v)
                    getgenv().HitboxSettings.Size = v
                end
            })
        end)

        -- Hitbox Wall Check
        safe(function()
            tab:Toggle({
                Title = "Hitbox Wall Check",
                Icon = "eye-off",
                Flag = "HitboxWallCheck",
                Callback = function(v)
                    getgenv().HitboxSettings.WallCheck = v
                end
            })
        end)

        -- Mouse Lock
        safe(function()
            tab:Toggle({
                Title = "Mouse Lock (Aimbot)",
                Desc = "Locks mouse to screen centre",
                Icon = "lock",
                Flag = "MouseLock",
                Callback = function(v)
                    getgenv().AimbotSettings.MouseLock = v
                end
            })
        end)

        -- ------------------------------------------------------------
        -- FOV Circle Creation (runs once, safe)
        -- ------------------------------------------------------------
        safe(function()
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
        -- Aimbot logic (visibility, closest player, render loop)
        -- ------------------------------------------------------------
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

        -- Render loop for aimbot and hitbox expansion
        safe(function()
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

                -- Aimbot camera lock
                if aimSettings.Enabled then
                    local target = GetClosestPlayer()
                    if target and target.Character and target.Character:FindFirstChild(aimSettings.TargetPart) then
                        local targetPos = target.Character[aimSettings.TargetPart].Position
                        cam.CFrame = cam.CFrame:Lerp(
                            CFrame.new(cam.CFrame.Position, targetPos),
                            1 / aimSettings.Smoothness
                        )
                        if aimSettings.MouseLock then
                            local mouse = lp:GetMouse()
                            mouse.X, mouse.Y = screenCenter.X, screenCenter.Y
                        end
                    end
                end
            end)
        end)

        print("Aimbot Init finished")
    end
}
