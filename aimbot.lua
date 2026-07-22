return {
    Init = function()
        print("aimbot.lua Init started")

        local tab = getgenv().Tabs.Aim
        if not tab then
            warn("Aimbot: Aim tab not found")
            return
        end

        -- Add a test button to confirm tab works
        tab:Button({
            Title = "Aimbot Test",
            Desc = "If you see this, the Aim tab is alive",
            Callback = function()
                print("Test button clicked")
            end
        })

        -- Add the rest of the toggles/sliders (copy from your original, but wrap each in pcall)
        -- For now, just add a few basic ones to test
        local function safe(fn)
            local ok, err = pcall(fn)
            if not ok then warn("UI error: " .. tostring(err)) end
        end

        safe(function()
            tab:Toggle({ Title = "Aimbot Enabled", Flag = "Aimbot", Callback = function(v) getgenv().AimbotSettings.Enabled = v end })
        end)
        safe(function()
            tab:Toggle({ Title = "Team Check", Flag = "TeamCheck", Callback = function(v) getgenv().AimbotSettings.TeamCheck = v end })
        end)
        safe(function()
            tab:Toggle({ Title = "Visible Only", Flag = "VisibleOnly", Callback = function(v) getgenv().AimbotSettings.VisibleOnly = v end })
        end)
        safe(function()
            tab:Slider({ Title = "FOV Radius", Step = 10, Flag = "FOVRadius", Value = { Min = 30, Max = 600, Default = 100 }, Callback = function(v) getgenv().AimbotSettings.FOV = v end })
        end)
        -- Add more as needed

        print("aimbot.lua Init finished")
    end
}
