return {
    Init = function()
        local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
        getgenv().WindUI = WindUI  -- store for theme switching

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
    end
}
