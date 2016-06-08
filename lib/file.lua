local split = ","
local splitnoval = ""
local val = "="
local tstart = "{"
local tend = "}"

local dataDirectory = "mods/saves/johnhud/"

local function checkFileHeirarchy(directory)
    local folders = directory:split("/")
    for i = 1, #folders - 1 do
        local tempPath = table.concat(folders, "/", 1, i)
        if not file.DirectoryExists(tempPath) then
            jhud.mkdir(tempPath)
        end
    end
end

jhud.mkdir = function(path)
    if not path then return end
    os.execute('mkdir "' .. path .. '"')
end

jhud.serialize = function(data)
    return json.encode(data or "{}")
end

jhud.deserialize = function(data)
    local tab
    local succ, err = pcall(function()
        tab = json.decode(data or "{}")
    end)
    if not succ then
        tab = {}
        jhud.log("JSON sucks Asseaegaseg", err)
    end

    local function fixJSON(new, tab)
        for i,v in pairs(tab) do
            local index = tonumber(i) or i
            if type(v) == "table" then
                new[index] = {}
                fixJSON(new[index], v)
            else
                new[index] = v
            end
        end
    end

    local new = {}
    fixJSON(new, tab)
    return new
end

jhud.save = function(path, tab)
    local fullPath = dataDirectory .. path
    checkFileHeirarchy(fullPath)

    local handle = io.open(fullPath, "w")
    if not handle then return false end
    handle:write(json.encode(tab) or "{}")
    handle:close()
    return true
end

jhud.load = function(path)
    local handle = io.open(dataDirectory .. path, "r")
    if not handle then return {}, true end
    local data = jhud.deserialize(handle:read("*all"))
    handle:close()
    return data
end
