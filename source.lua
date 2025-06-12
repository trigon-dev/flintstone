local HttpService = game:GetService("HttpService")
local CONFIG_URL =
  "https://raw.githubusercontent.com/trigon-dev/flintstone/main/places.json"

local function safeLoad(url)
    local ok, res = pcall(function()
        return HttpService:GetAsync(url, true)
    end)
    if not ok then
        warn("safeLoad GET failed:", url, res)
        return
    end

    local fn, err = loadstring(res)
    if not fn then
        warn("safeLoad compile error:", url, err)
        return
    end

    local success, runtimeErr = pcall(fn)
    if not success then
        warn("safeLoad runtime error:", url, runtimeErr)
    end
end

local ok, raw = pcall(function()
    return HttpService:GetAsync(CONFIG_URL, true)
end)
if not ok then
    warn("Could not GET config:", raw)
    return
end

local config
local decodeOk, decodeErr = pcall(function()
    config = HttpService:JSONDecode(raw)
end)
if not decodeOk or type(config) ~= "table" then
    warn("Invalid JSON:", decodeErr or config)
    return
end

local urls = config[tostring(game.PlaceId)]
if urls and type(urls) == "table" then
    for _, url in ipairs(urls) do
        safeLoad(url)
        wait(config.delayBetween or 5)
    end
else
    warn("No scripts configured for PlaceId", game.PlaceId)
end
