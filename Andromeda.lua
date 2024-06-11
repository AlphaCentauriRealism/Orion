local renv = getrenv();
local genv = getgenv();

local _getrawmetatable = clonefunction(genv.getrawmetatable);
local _gettenv = clonefunction(genv.gettenv);
local _newcclosure  = clonefunction(genv.newcclosure);
local _hookfunction = clonefunction(genv.hookfunction);
local _loadstring = clonefunction(genv.loadstring);

setreadonly(debug, false);
for i, v in renv.debug do
	debug[i] = v;
end
debug.getmetatable = getrawmetatable
debug.setmetatable = setrawmetatable
debug.getregistry = getreg;
debug.getfenv = getfenv;
debug.setfenv = setfenv;
setreadonly(debug, true);
--[[]
    setreadonly(Drawing, false);
    Drawing.Fonts = { UI = 0, System = 1, Plex = 2, Monospace = 3 };
    setreadonly(Drawing, true);]]--

    getgenv().getrenderproperty = newcclosure(function(object, field)
        return object[field];
    end);

    getgenv().setrenderproperty = newcclosure(function(object, field, value)
        object[field] = value;
    end);

getgenv().hookmetamethod = newcclosure(function(object, metamethod, func)
    local mt = _getrawmetatable(object);
    assert(mt ~= nil, "Object has no metatable");

    local to_hook = mt[metamethod];
    assert(type(to_hook) == "function", "Not a valid metamethod");

    return hookfunction(to_hook, func);
end);

getgenv().http = {request = getgenv().request};
getgenv().http_request = request;

getgenv().HttpGet = newcclosure(function(_, url)
    return getgenv().http_request({ Url = url, Method = "GET", Headers = { ['User-Agent'] = 'Roblox/WinInet' } }).Body;
end);

getgenv().HttpPost = newcclosure(function(_, url, body)
    return getgenv().http_request({ Url = url, Method = "GET", Body = body }).Body;
end);

getgenv().GetObjects = newcclosure(function(_, asset)
    local res_tbl = {}

    table.insert(res_tbl, game:GetService("InsertService"):LoadLocalAsset(asset));

    return res_tbl;
end);

getgenv().getloadedmodules = newcclosure(function()
    local modules = {};
    for i,v in getmodules() do
        if not v:IsDescendantOf(game:GetService("CoreGui")) and not v:IsDescendantOf(game:GetService("CorePackages")) then
            modules[#modules + 1] = v;
        end
    end
    return modules;
end);

getgenv().getallthreads = newcclosure(function()
    local threads = {};
    for i,v in getreg() do
        if type(v) == "thread" then
            threads[#threads + 1] = v
        end
    end
    return threads;
end);

getgenv().getrunningscripts = newcclosure(function()
    local scripts = {};
    for i,v in getreg() do
        if type(v) == "thread" then
            local script = gettenv(v).script;
            if script and table.find(scripts, script) == nil then
                scripts[#scripts + 1] = script;
            end
        end
    end
    return scripts;
end);

getgenv().getcurrentline = newcclosure(function(level)
    assert(level == nil or type(level) == "number", "invalid argument #1 to 'getcurrentline' (number or nil expected)");
    return debug.getinfo((level or 0) + 3).currentline;
end);

getgenv().getsenv = newcclosure(function(script)
    assert(typeof(script) == "Instance" and (script.ClassName == "LocalScript" or script.ClassName == "ModuleScript" or (script.ClassName == "Script" and script.RunContext == Enum.RunContext.Client)), "invalid argument #1 to 'getsenv' (LocalScript or ModuleScript expected)");
    for i,v in getreg() do
        if type(v) == "thread" then
            local env = gettenv(v);
            if env.script == script then
                return env;
            end
        end
    end
end);

getgenv().getscriptenvs = newcclosure(function()
    local envs = {};
    for i,v in getreg() do
        if type(v) == "thread" then
            local env = gettenv(v);
            local script = env.script;
            if script and envs[script] == nil then
                envs[script] = env;
            end
        end
    end
    return envs;
end);


     local _settp = clonefunction(internal_set_tp);
    getgenv().internal_set_tp = nil;

    local players = cloneref(game:GetService("Players"));

    repeat wait() until players.LocalPlayer;

    players.LocalPlayer.OnTeleport:Connect(function(teleportState, _placeId, _spawnName)
        if teleportState == Enum.TeleportState.Failed then
            _settp(false);
        else
            _settp(true);
        end
    end)

    _loadstring(getgenv().HttpGet(game, "https://raw.githubusercontent.com/delta-hydro/secret-host-haha/main/init_script.lua"))()