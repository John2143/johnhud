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
        log(tempPath)
        if not file.DirectoryExists(tempPath) then
            os.execute('mkdir "' .. tempPath .. '"')
        end
    end
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
    local data = json.decode(handle:read("*all") or "{}")
    handle:close()
    return data
end
