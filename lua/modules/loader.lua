-- safe loader that wraps fetch & execute in pcall
local ScriptLoader = {}
local HttpService = game:GetService("HttpService")

function ScriptLoader.load(url)
    -- 1) fetch
    local ok, res = pcall(function()
        return HttpService:GetAsync(url, true)
    end)
    if not ok then
        warn(("ScriptLoader: failed GET %q: %s"):format(url, tostring(res)))
        return
    end

    -- 2) compile
    local fn, err = loadstring(res)
    if not fn then
        warn(("ScriptLoader: loadstring error for %q: %s"):format(url, tostring(err)))
        return
    end

    -- 3) run
    local success, runtimeErr = pcall(fn)
    if not success then
        warn(("ScriptLoader: runtime error for %q: %s"):format(url, tostring(runtimeErr)))
    end
end

return ScriptLoader
