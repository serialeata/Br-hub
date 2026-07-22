return {
    Init = function()
        local tab = getgenv().Window:Tab({ Title = "Utility", Icon = "wrench" })
        tab:Button({ Title = "Teleport Upwards", Desc = "+25 studs", Callback = function()
            local r = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r then r.CFrame = r.CFrame + Vector3.new(0,25,0) end
        end })
        tab:Button({ Title = "Teleport Downwards", Desc = "-15 studs", Callback = function()
            local r = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r then r.CFrame = r.CFrame + Vector3.new(0,-15,0) end
        end })
        tab:Button({ Title = "Infinite Camera Zoom", Callback = function()
            game.Players.LocalPlayer.CameraMaxZoomDistance = 5000
        end })
        tab:Button({ Title = "Respawn / Reset Character", Callback = function()
            local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end })
    end
}
