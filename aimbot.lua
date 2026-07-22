return {
    Init = function()
        local tab = getgenv().Tabs.Aim
        if not tab then
            warn("Aimbot: Aim tab not found")
            return
        end

        -- Add a test button to confirm the tab is alive
        local testBtn = tab:Button({
            Title = "Aimbot Loaded",
            Desc = "If you see this, the tab works",
            Callback = function() print("Aimbot test button clicked") end
        })

        -- Wrap each UI addition in pcall to catch errors
        local function safeAdd(fn)
            local ok, err = pcall(fn)
            if not ok then
                warn("Aimbot UI error: " .. tostring(err))
            end
        end

        safeAdd(function()
            local toggle = tab:Toggle({ Title = "Aimbot (lowk sucks)", Desc = "Locks camera onto target", Icon = "target", Flag = "Aimbot", Callback = function(v) getgenv().AimbotSettings.Enabled = v end })
            getgenv().currentConfig:Register("Aimbot", toggle)
        end)

        safeAdd(function()
            local toggle2 = tab:Toggle({ Title = "Team Check", Icon = "users", Flag = "TeamCheck", Callback = function(v) getgenv().AimbotSettings.TeamCheck = v end })
            getgenv().currentConfig:Register("TeamCheck", toggle2)
        end)

        safeAdd(function()
            local toggle3 = tab:Toggle({ Title = "Visible Only", Desc = "Raycast visibility", Icon = "eye", Flag = "VisibleOnly", Callback = function(v) getgenv().AimbotSettings.VisibleOnly = v end })
            getgenv().currentConfig:Register("VisibleOnly", toggle3)
        end)

        safeAdd(function()
            local toggle4 = tab:Toggle({ Title = "Show FOV Circle", Icon = "circle", Flag = "ShowFOV", Callback = function(v) getgenv().AimbotSettings.ShowFOV = v; if getgenv().fovFrame then getgenv().fovFrame.Visible = v end end })
            getgenv().currentConfig:Register("ShowFOV", toggle4)
        end)

        safeAdd(function()
            local slider = tab:Slider({ Title = "Aimbot FOV Radius", Step = 10, Flag = "FOVRadius", Value = { Min = 30, Max = 600, Default = 100 }, Callback = function(v) getgenv().AimbotSettings.FOV = v; if getgenv().UpdateFOVCircle then getgenv().UpdateFOVCircle(v) end end })
            getgenv().currentConfig:Register("FOVRadius", slider)
        end)

        safeAdd(function()
            local slider2 = tab:Slider({ Title = "Aimbot Smoothness", Step = 1, Flag = "Smoothness", Value = { Min = 1, Max = 10, Default = 1 }, Callback = function(v) getgenv().AimbotSettings.Smoothness = v end })
            getgenv().currentConfig:Register("Smoothness", slider2)
        end)

        safeAdd(function()
            local toggle5 = tab:Toggle({ Title = "Adaptive Hitbox Expander", Icon = "maximize-2", Flag = "HitboxEnabled", Callback = function(v) getgenv().HitboxSettings.Enabled = v end })
            getgenv().currentConfig:Register("HitboxEnabled", toggle5)
        end)

        safeAdd(function()
            local slider3 = tab:Slider({ Title = "Hitbox Size Changer", Step = 1, Flag = "HitboxSize", Value = { Min = 2, Max = 30, Default = 6 }, Callback = function(v) getgenv().HitboxSettings.Size = v end })
            getgenv().currentConfig:Register("HitboxSize", slider3)
        end)

        safeAdd(function()
            local toggle6 = tab:Toggle({ Title = "Hitbox Wall Check", Icon = "eye-off", Flag = "HitboxWallCheck", Callback = function(v) getgenv().HitboxSettings.WallCheck = v end })
            getgenv().currentConfig:Register("HitboxWallCheck", toggle6)
        end)

        safeAdd(function()
            local toggle7 = tab:Toggle({ Title = "Mouse Lock (Aimbot)", Desc = "Locks mouse to screen centre", Icon = "lock", Flag = "MouseLock", Callback = function(v) getgenv().AimbotSettings.MouseLock = v end })
            getgenv().currentConfig:Register("MouseLock", toggle7)
        end)

        -- FOV Circle creation (may fail on some executors)
        local fovCreated = false
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

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(255, 0, 100)
            stroke.Thickness = 1.5
            stroke.Transparency = 0.8
            stroke.Parent = fovFrame

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = fovFrame

            fovFrame.Visible = getgenv().AimbotSettings.ShowFOV
            getgenv().fovFrame = fovFrame
            getgenv().fovStroke = stroke

            function getgenv().UpdateFOVCircle(radius)
                fovFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
            end
            getgenv().UpdateFOVCircle(getgenv().AimbotSettings.FOV)
            fovCreated = true
        end)
        if not fovCreated then
            warn("Aimbot: FOV circle creation failed – UI may still work without it")
        end

        -- Visibility check
        local function IsVisible(targetPart)
            local cam = workspace.CurrentCamera
            local lp = game:GetService("Players").LocalPlayer
            if not lp.Character then return false end
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {lp.Character, targetPart.Parent}
            params.IgnoreWater = true
            local origin = cam.CFrame.Position
            local dir = targetPart.Position - origin
            return workspace:Raycast(origin, dir, params) == nil
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

        -- Render loop
        getgenv().Connections.AimbotRender = game:GetService("RunService").RenderStepped:Connect(function()
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
    end
}
