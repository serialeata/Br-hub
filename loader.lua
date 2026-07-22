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
    print("Loading: " .. url)
    local success, chunk = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        warn("LOAD ERROR on " .. url .. ": " .. tostring(chunk))
    elseif type(chunk) == "table" and type(chunk.Init) == "function" then
        local ok, err = pcall(chunk.Init)
        if not ok then
            warn("INIT ERROR on " .. url .. ": " .. tostring(err))
        else
            print("Loaded: " .. url)
        end
    end
end
