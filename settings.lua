return {
    Init = function()
        local tab = getgenv().Tabs.Settings

        local themeValues = {}
        for _, t in ipairs({{Name="Obsidian"},{Name="Crimson"},{Name="Ocean"},{Name="Sunset"},{Name="Forest"}}) do
            table.insert(themeValues, { Title = t.Name, Icon = "palette", Callback = function()
                if getgenv().WindUI then getgenv().WindUI:SetTheme(t.Name) end
            end })
        end
        tab:Dropdown({ Title = "Select Interface Theme", Desc = "Custom themes", Values = themeValues })

        tab:Button({ Title = "Save Config", Desc = "Saves current settings to DefaultConfig.json", Callback = function()
            getgenv().currentConfig:Save()
        end })

        tab:Button({ Title = "Load Config", Desc = "Loads settings from DefaultConfig.json", Callback = function()
            getgenv().currentConfig:Load()
        end })
    end
}
