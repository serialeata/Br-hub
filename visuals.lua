return {
    Init = function()
        local tab = getgenv().Window:Tab({ Title = "Visuals", Icon = "eye" })
        local toggle = tab:Toggle({ Title = "Player Wallhack (Chams)", Desc = "See players outlines through walls", Icon = "users", Flag = "Chams", Callback = function(state)
            if state then
                local function apply(p)
                    if p == game:GetService("Players").LocalPlayer then return end
                    p.CharacterAdded:Connect(function(char)
                        local h = Instance.new("Highlight")
                        h.Name = "JB_ESP"
                        h.FillColor = Color3.fromRGB(255,0,100)
                        h.OutlineColor = Color3.fromRGB(255,255,255)
                        h.FillTransparency = 0.5
                        h.Parent = char
                    end)
                    if p.Character then
                        local h = Instance.new("Highlight")
                        h.Name = "JB_ESP"
                        h.FillColor = Color3.fromRGB(255,0,100)
                        h.OutlineColor = Color3.fromRGB(255,255,255)
                        h.FillTransparency = 0.5
                        h.Parent = p.Character
                    end
                end
                for _, p in pairs(game:GetService("Players"):GetPlayers()) do apply(p) end
                getgenv().Connections.ChamsPlayerAdded = game:GetService("Players").PlayerAdded:Connect(apply)
            else
                if getgenv().Connections.ChamsPlayerAdded then getgenv().Connections.ChamsPlayerAdded:Disconnect() end
                for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("JB_ESP") then p.Character.JB_ESP:Destroy() end
                end
            end
        end })
        getgenv().currentConfig:Register("Chams", toggle)

        local toggle2 = tab:Toggle({ Title = "Fullbright", Icon = "sun", Flag = "Fullbright", Callback = function(state)
            local lighting = game:GetService("Lighting")
            if state then
                lighting.Brightness = 4
                lighting.Ambient = Color3.fromRGB(255,255,255)
                lighting.GlobalShadows = false
            else
                lighting.Brightness = 2
                lighting.Ambient = Color3.fromRGB(130,130,130)
                lighting.GlobalShadows = true
            end
        end })
        getgenv().currentConfig:Register("Fullbright", toggle2)

        local stroke = getgenv().fovStroke
        local slider = tab:Slider({ Title = "FOV Red", Step = 1, Flag = "FOVRed", Value = { Min = 0, Max = 255, Default = 255 }, Callback = function(v)
            local r,g,b = stroke.Color.R*255, stroke.Color.G*255, stroke.Color.B*255
            stroke.Color = Color3.fromRGB(v, g, b)
        end })
        getgenv().currentConfig:Register("FOVRed", slider)
        local slider2 = tab:Slider({ Title = "FOV Green", Step = 1, Flag = "FOVGreen", Value = { Min = 0, Max = 255, Default = 0 }, Callback = function(v)
            local r,g,b = stroke.Color.R*255, stroke.Color.G*255, stroke.Color.B*255
            stroke.Color = Color3.fromRGB(r, v, b)
        end })
        getgenv().currentConfig:Register("FOVGreen", slider2)
        local slider3 = tab:Slider({ Title = "FOV Blue", Step = 1, Flag = "FOVBlue", Value = { Min = 0, Max = 255, Default = 100 }, Callback = function(v)
            local r,g,b = stroke.Color.R*255, stroke.Color.G*255, stroke.Color.B*255
            stroke.Color = Color3.fromRGB(r, g, v)
        end })
        getgenv().currentConfig:Register("FOVBlue", slider3)
    end
}
