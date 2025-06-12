local HttpService       = game:GetService("HttpService")
local DataStoreService  = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DataStore for tracking “missed” PlaceIds
local missStore = DataStoreService:GetDataStore("PlaceScriptMisses")

-- require our ModuleScript
local ScriptLoader = require(ReplicatedStorage
    :WaitForChild("Loaders")
    :WaitForChild("ScriptLoader")
)

-- CONFIG URL
local CONFIG_URL = "https://example.com/place-scripts.json"

-- 1. Fetch remote config
local ok, raw = pcall(function()
    return HttpService:GetAsync(CONFIG_URL, true)
end)
if not ok then
    warn("ScriptManager: could not GET config:", raw)
    return
end

-- 2. Decode JSON
local config
ok, config = pcall(function()
    return HttpService:JSONDecode(raw)
end)
if not ok or type(config) ~= "table" then
    warn("ScriptManager: bad config JSON:", config)
    return
end

-- 3. Choose key: PlaceId or GameId?
--    local idKey = tostring(game.GameId)   -- universe-wide
local idKey = tostring(game.PlaceId)      -- per-place only

-- 4. Lookup URL list
local urls = config[idKey]
if urls then
    for _, url in ipairs(urls) do
        ScriptLoader.load(url)
        wait(config.delayBetween or 5)
    end
else
    -- 5a. Log miss to DataStore
    pcall(function()
        missStore:IncrementAsync(idKey, 1)
    end)

    -- 5b. Ping webhook (if provided)
    if config.webhookUrl then
        pcall(function()
            HttpService:PostAsync(
                config.webhookUrl,
                HttpService:JSONEncode({
                    placeId   = game.PlaceId,
                    gameId    = game.GameId,
                    timestamp = os.time(),
                }),
                Enum.HttpContentType.ApplicationJson
            )
        end)
    end
end
