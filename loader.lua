local CHUNK_URLS = {
    "https://raw.githubusercontent.com/serialeata/Br-hub/jailbird/core.lua",
    "https://raw.githubusercontent.com/serialeata/Br-hub/jailbird/movement.lua",
    "https://raw.githubusercontent.com/serialeata/Br-hub/jailbird/aimbot.lua",
    "https://raw.githubusercontent.com/serialeata/Br-hub/jailbird/esp.lua",
    "https://raw.githubusercontent.com/serialeata/Br-hub/jailbird/exploits.lua",
    "https://raw.githubusercontent.com/serialeata/Br-hub/jailbird/visuals.lua",
    "https://raw.githubusercontent.com/serialeata/Br-hub/jailbird/utility.lua",
    "https://raw.githubusercontent.com/serialeata/Br-hub/jailbird/settings.lua",
    "https://raw.githubusercontent.com/serialeata/Br-hub/jailbird/antiaim.lua",
}
for _, url in ipairs(CHUNK_URLS) do
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then warn("Failed: " .. url .. " | " .. tostring(result)) end
end
