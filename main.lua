jhud = jhud or {}
jhud.carry = jhud.carry or {}

if not managers then return end
for i,v in pairs(jhud) do
    if type(v) == "table" and v.__cleanup then
        pcall(v.__cleanup, v, jhud.carry)
    end
end
jhud.path = PersistScriptPath or "mods/johnhud/"
jhud.debug = true
--jhud.log = function(...)
    --for i,v in ipairs{...} do
        --io.write(tostring(v).."\t")
    --end
    --io.write("\n")
--end
function jhud.pt(tab, deep, tabdepth)
    if not tab then return end
    tabdepth = tabdepth or ""
    local longestindex = 0
    for i,v in pairs(tab) do
        if tostring(i):len() > longestindex then
            longestindex = tostring(i):len() + (type(i) == "string" and 2 or 0)
        end
    end
    for i,v in pairs(tab) do
        if type(i) == "string" then
            jhud.log(tabdepth, '"' .. i .. '"' .. string.rep(" ", longestindex - i:len()), "::", v)
        else
            jhud.log(tabdepth, tostring(i) .. string.rep(" ", longestindex - tostring(i):len()), "::", v)
        end
        if deep and deep > 0 and type(v) == "table" then
            jhud.pt(v, deep - 1, tabdepth .. "  ")
        end
    end
end
jhud.log = function(...)
    local newtab = {}
    for i, v in ipairs{...} do
        newtab[i] = tostring(v)
    end
    log(table.concat(newtab, " "))
end
jhud.log2 = function(...)
    jhud.log(string.format(...))
end
jhud.dlog = function(...)
    if not jhud.debug then return end
    jhud.log("DEBUG: ", ...)
end

jhud.log("JohnHUD started.")
table.hasValue = function(table, val)
    for i,v in ipairs(table) do
        if v == val then
            return true
        end
    end
    return false
end
string.split = function(text, reg, ind)
    ind = ind or 1
    reg = reg or ","
    local dat = {}
    for w in text:gmatch("[^"..reg.."]+") do
        dat[ind] = w
        ind = ind + 1
    end
    return dat
end
string.gloop = function(text, reg, ind)
    local ret, ind = {}, ind or 0
    for w in text:gmatch(reg or "%w+") do
        ret[ind] = w
        ind = ind + 1
    end
    return ret
end
jhud.digest = function(num)
    return Application:digest_value(num, true)
end
jhud.undigest = function(num)
    return Application:digest_value(num)
end
jhud.createPanel = function()
    if not RenderSettings then return end
    jhud.resolution = RenderSettings.resolution
    return Overlay:gui():create_scaled_screen_workspace(jhud.resolution.x, jhud.resolution.y, 0, 0, jhud.resolution.x, jhud.resolution.y):panel{name = "workspace_panel"}
end
jhud.keyboard = Input:keyboard()

jhud.die = function(err)
    if err then jhud.log(err) end
    error("Die", 2)
end

function jhud.localPlayer()
    return managers and managers.player and managers.player:player_unit()
end

function jhud.addModule(tab)
    for i,v in ipairs(tab) do
        table.insert(jhud.options.modules, v)
    end
end
function jhud.addCheatModule(tab)
    for i,v in ipairs(tab) do
        table.insert(jhud.options.cheaterModules, v)
    end
end

local errorMethods = {}
function jhud.callModuleMethod(method, ...)
    for i,v in pairs(jhud) do
        if type(v) == "table" and type(v[method]) == "function" and not errorMethods[i] then
            if method == "__init" then _("INITING ", i) end
            local suc, err = pcall(v[method], v, ...)
            if not suc then
                jhud.log("ERROR @", method, err)
                errorMethods[i] = true
            end
        end
    end
end

jhud.wantedModules = {}
jhud.requiredModules = {}
jhud.requiredLibraries = {}

function jhud.rlib(name)
    if not table.hasValue(jhud.requiredLibraries, name) then
        table.insert(jhud.requiredLibraries, name)
    end
end
function jhud.wmod(name)
    if not table.hasValue(jhud.wantedModules, name) then
        table.insert(jhud.wantedModules, name)
    end
end
function jhud.rmod(name)
    if not table.hasValue(jhud.requiredModules, name) then
        table.insert(jhud.requiredModules, name)
    end
end

function jhud.requireSTD(path)
    if io.file_is_readable(path) then
        local status, err = pcall(function() dofile(path) end)
        if status then
            return false
        else
            return err
        end
    else
        return "Cannot read file"
    end
end

function jhud.require(e)
    return jhud.requireSTD(jhud.path .. e .. ".lua")
end

function jhud.requirex(e)
    local res = jhud.require(e)
    if res then
        jhud.log("Load failed " .. e)
        jhud.die("  " .. res)
    end
end

jhud.requirex("jhopts")
jhud.requireSTD("mods/saves/johnhud/cfg.lua")

jhud.cheating = jhud.options.cheat
if jhud.cheating then
    jhud.addModule(jhud.options.cheaterModules)
end
--S
for i,v in ipairs(jhud.options.modules) do
    if v and not jhud.options.disabledModules[v] then
        jhud[v] = {config = jhud.options.m[v]}
        this = jhud[v] --want to avoid setfenv in case of strange behaviour
        jhud.dlog("Loading module::" .. v)
        jhud.requirex("modules/" .. v)
    end
end
--E
this = nil

jhud.rmod("net")
jhud.rmod("hook")
jhud.rmod("language")

for i,v in pairs(jhud.requiredModules) do
    if not jhud[v] then
        jhud.log("You are missing a requried module", v)
    end
end
for i,v in pairs(jhud.wantedModules) do
    if not jhud[v] then
        jhud.log("You may be missing functionality because module", v, "is not active")
    end
end
for i,v in pairs(jhud.requiredLibraries) do
    jhud.requirex("lib/" .. v)
end
jhud.log("Loaded modules")

for i,v in pairs(jhud.options.modules) do --keep this to preserve module order
    if jhud[v].__init then
        local suc, err = pcall(jhud[v].__init, jhud[v], jhud.carry or {})
        if err then jhud.log("INITERR", err) end
    end
end

jhud.hook("AchievementManager", "award_steam", function()
    if jhud.cheating then return true end
end)
jhud.hook("GameStateMachine", "update", function(GSMOBJ, t, dt)
    jhud.whisper = managers.groupai and managers.groupai:state().whisper_mode and managers.groupai:state():whisper_mode()
    jhud.callModuleMethod("__update", t, dt)
    if managers.groupai then
        jhud.callModuleMethod("__igupdate", t, dt)
    end
end)

jhud.lang = L:new("_")
if jhud.chat and jhud.options.m._.showload then
    jhud.chat(jhud.lang("start"))
    if jhud.cheating then
        jhud.chat(jhud.lang("cheater"))
    end
end
