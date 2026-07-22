return {
    Init = function()
        local tab = getgenv().Tabs.Visuals

        local toggle = tab:Toggle({ Title = "Skeleton ESP", Desc = "Draws lines connecting body parts", Icon = "activity", Flag = "SkeletonESP", Callback = function(v) getgenv().EspSettings.Skeleton = v end })
        getgenv().currentConfig:Register("SkeletonESP", toggle)

        local toggle2 = tab:Toggle({ Title = "Tracers ESP", Desc = "Draws a line from screen bottom to enemy HRP", Icon = "trending-up", Flag = "TracersESP", Callback = function(v) getgenv().EspSettings.Tracers = v end })
        getgenv().currentConfig:Register("TracersESP", toggle2)

        -- Check if Drawing is available (some executors don't have it)
        if not Drawing then
            warn("ESP: Drawing library not available – ESP will not draw lines")
            return
        end

        local espLines = {}
        local function clearESP()
            for _, line in pairs(espLines) do
                pcall(line.Remove, line)
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
                local pos, on = cam:WorldToViewportPoint(localHRP.Position)
                if on then tracerStart = Vector2.new(pos.X, pos.Y) end
            end
            for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                if plr == lp or not plr.Character then continue end
                local char = plr.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local torso = char:FindFirstChild("Torso")
                local lArm = char:FindFirstChild("Left Arm")
                local rArm = char:FindFirstChild("Right Arm")
                local lLeg = char:FindFirstChild("Left Leg")
                local rLeg = char:FindFirstChild("Right Leg")
                local teamColor
                if lp.Team and plr.Team and plr.Team == lp.Team then teamColor = Color3.fromRGB(50,150,255) else teamColor = Color3.fromRGB(255,50,50) end
                if espSettings.Skeleton and torso and head and lArm and rArm and lLeg and rLeg then
                    local function draw(fromW, toW, col)
                        local fromP, fromOn = cam:WorldToViewportPoint(fromW)
                        local toP, toOn = cam:WorldToViewportPoint(toW)
                        if fromOn and toOn then
                            local line = Drawing.new("Line")
                            line.Visible = true
                            line.Color = col
                            line.Thickness = 1.5
                            line.From = Vector2.new(fromP.X, fromP.Y)
                            line.To = Vector2.new(toP.X, toP.Y)
                            table.insert(espLines, line)
                        end
                    end
                    draw(torso.Position, head.Position, teamColor)
                    draw(torso.Position, lArm.Position, teamColor)
                    draw(torso.Position, rArm.Position, teamColor)
                    local lFoot = lLeg.CFrame * Vector3.new(0, -lLeg.Size.Y/2, 0)
                    local rFoot = rLeg.CFrame * Vector3.new(0, -rLeg.Size.Y/2, 0)
                    draw(torso.Position, lFoot, teamColor)
                    draw(torso.Position, rFoot, teamColor)
                end
                if espSettings.Tracers and hrp then
                    local toP, toOn = cam:WorldToViewportPoint(hrp.Position)
                    if toOn then
                        local line = Drawing.new("Line")
                        line.Visible = true
                        line.Color = teamColor
                        line.Thickness = 1.2
                        line.From = tracerStart
                        line.To = Vector2.new(toP.X, toP.Y)
                        table.insert(espLines, line)
                    end
                end
            end
        end

        getgenv().Connections.ESPRender = game:GetService("RunService").RenderStepped:Connect(updateESP)
    end
}
