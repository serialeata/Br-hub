return {
    Init = function()
        print("Aimbot UI loading")
        local tab = getgenv().Tabs.Aim
        if not tab then
            warn("Aimbot: Aim tab not found")
            return
        end

        local function add(fn)
            local ok, err = pcall(fn)
            if not ok then
                warn("Aimbot UI error: " .. tostring(err))
            end
        end

        add(function()
            tab:Toggle({
                Title = "Aimbot",
                Flag = "Aimbot",
                Callback = function(v) getgenv().AimbotSettings.Enabled = v end
            })
        end)

        add(function()
            tab:Toggle({
                Title = "Team Check",
                Flag = "TeamCheck",
                Callback = function(v) getgenv().AimbotSettings.TeamCheck = v end
            })
        end)

        add(function()
            tab:Toggle({
                Title = "Visible Only",
                Flag = "VisibleOnly",
                Callback = function(v) getgenv().AimbotSettings.VisibleOnly = v end
            })
        end)

        add(function()
            tab:Toggle({
                Title = "Show FOV Circle",
                Flag = "ShowFOV",
                Callback = function(v)
                    getgenv().AimbotSettings.ShowFOV = v
                    if getgenv().fovFrame then
                        getgenv().fovFrame.Visible = v
                    end
                end
            })
        end)

        add(function()
            tab:Slider({
                Title = "FOV Radius",
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

        add(function()
            tab:Slider({
                Title = "Smoothness",
                Step = 1,
                Flag = "Smoothness",
                Value = { Min = 1, Max = 10, Default = 1 },
                Callback = function(v) getgenv().AimbotSettings.Smoothness = v end
            })
        end)

        add(function()
            tab:Toggle({
                Title = "Hitbox Expander",
                Flag = "HitboxEnabled",
                Callback = function(v) getgenv().HitboxSettings.Enabled = v end
            })
        end)

        add(function()
            tab:Slider({
                Title = "Hitbox Size",
                Step = 1,
                Flag = "HitboxSize",
                Value = { Min = 2, Max = 30, Default = 6 },
                Callback = function(v) getgenv().HitboxSettings.Size = v end
            })
        end)

        add(function()
            tab:Toggle({
                Title = "Hitbox Wall Check",
                Flag = "HitboxWallCheck",
                Callback = function(v) getgenv().HitboxSettings.WallCheck = v end
            })
        end)

        add(function()
            tab:Toggle({
                Title = "Mouse Lock",
                Flag = "MouseLock",
                Callback = function(v) getgenv().AimbotSettings.MouseLock = v end
            })
        end)

        print("Aimbot UI loaded")
    end
}
