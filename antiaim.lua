return {
    Init = function()
        local tab = getgenv().Window:Tab({ Title = "Anti Aim", Icon = "shield-off" })
        local spinConnection = nil
        local function StartSpinBot()
            if spinConnection then spinConnection:Disconnect() end
            local currentAngle = 0
            spinConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if getgenv().SpinBotSettings.Enabled then
                    local player = game:GetService("Players").LocalPlayer
                    local char = player.Character
                    if not char then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if not root or not hum then return end
                    hum.AutoRotate = false
                    if getgenv().SpinBotSettings.Mode == "Spin" then
                        currentAngle = (currentAngle + 160) % 360
                        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(currentAngle), 0)
                    elseif getgenv().SpinBotSettings.Mode == "MoonWalk" then
                        local cam = workspace.CurrentCamera
                        local dir = cam.CFrame.LookVector
                        local horiz = Vector3.new(dir.X, 0, dir.Z).Unit
                        if horiz.Magnitude < 0.001 then horiz = Vector3.new(0,0,-1) end
                        root.CFrame = CFrame.lookAt(root.Position, root.Position - horiz)
                    end
                end
            end)
        end
        local toggle = tab:Toggle({ Title = "Spin Bot", Desc = "Spins The Player In Circles", Icon = "refresh-cw", Flag = "SpinBotEnabled", Callback = function(state)
            getgenv().SpinBotSettings.Enabled = state
            if state then StartSpinBot()
            else
                if spinConnection then spinConnection:Disconnect() spinConnection = nil end
                local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.AutoRotate = true end
            end
        end })
        getgenv().currentConfig:Register("SpinBotEnabled", toggle)
        local dropdown = tab:Dropdown({ Title = "SpinBot Mode", Desc = "Select spin type", Flag = "SpinBotMode", Values = {
            { Title = "Spin", Desc = "Fast yaw spin", Icon = "refresh-cw", Callback = function()
                getgenv().SpinBotSettings.Mode = "Spin"
                if getgenv().SpinBotSettings.Enabled then StartSpinBot() end
            end },
            { Title = "MoonWalk", Desc = "Face opposite of camera", Icon = "arrow-left-right", Callback = function()
                getgenv().SpinBotSettings.Mode = "MoonWalk"
                if getgenv().SpinBotSettings.Enabled then StartSpinBot() end
            end }
        } })
        getgenv().currentConfig:Register("SpinBotMode", dropdown)
        game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if getgenv().SpinBotSettings.Enabled then StartSpinBot() end
        end)
    end
}
