local split = ","
local splitnoval = ""
local val = "="
local tstart = "{"
local tend = "}"
local ttv = {
    number = function(a)
        return tostring(a)
    end,
    string = function(a)
        return '"'..a..'"'
    end,
    boolean = function(a)
        return a and "true" or "false"
    end
}
local tti = {
    string = function(a)
        return a
    end
}

local function safe(value, index)
    local typ = type(value)
    local def = ttv[typ]
    if index then
        if tti[typ] then
            return tti[typ](value)
        else
            return L:affix(def(value))
        end
    else
        return def(value) or "nil"
    end
end
local function write(h, tab)
    for i,v in pairs(tab) do
        if type(v) == "table" then
            h:write(safe(i, true)..val..tstart..splitnoval)
            write(h, v)
            h:write(tend..split)
        else
            h:write(safe(i, true)..val..safe(v, false)..split)
        end
    end
end
jhud.save = function(path, tab)
    local handle = io.open("johnhud/data/"..path, "w")
    if not handle then return false end
    write(handle, tab)
    handle:close()
    return true
end
jhud.load = function(path)
    local handle = io.open("johnhud/data/"..path, "r")
    if not handle then return {}, true end
    local func = loadstring(table.concat{"RETURN = {",handle:read("*all"), "}"})
    handle:close()
    local ret = {}
    setfenv(func, ret)
    local suc, err = pcall(func)
    if not suc then
        jhud.log("LOADERR", err)
        return {}, true
    else
        return ret.RETURN
    end
end
