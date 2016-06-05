jhud.rmod("chat")

local mod = jhud.path .. "2" --Placeholder
local versionFile = mod .. "/version.txt"
jhud.log("Mod directory: " .. mod)

function this:getLatestCommit(cb)
    Steam:http_request("https://api.github.com/repos/" ..
                self.config.uname .. "/" ..
                self.config.project .. "/commits?sha=" ..
                self.config.branch, function(suc, data)
        if not suc then return end
        local commits = json.decode(data)
        cb(commits[1].sha)
    end)
end

function this:downloadAndUnpack(cb)
    dohttpreq("http://github.com/" ..
                self.config.uname .. "/" ..
                self.config.project .. "/archive/" ..
                self.config.branch .. ".zip", function(data, suc)

        if not suc then return end
        local path = "mods/downloads/johnhud"
        local zipPath = path .. ".zip"
        local out = io.open(zipPath, "wb")
        if not out then return true end
        out:write(data)
        out:close()

        --local function rcopy(from, to)
            --local function mkdir(x)
                --os.execute('mkdir "' .. x .. '"')
            --end
            --local function copyFile(f, t)
                --log("copy " .. '"' .. f .. '" "' .. t ..'"')
            --end
            --local function recurseDo(path)
                --path = path or "/"
                --for i,v in pairs(file.GetDirectories(from .. path)) do
                    --recurseDo(path .. v .. "/")
                    --mkdir(to .. path .. v)
                --end
                --for i,v in pairs(file.GetFiles(from .. path)) do
                    --copyFile(from .. path .. v, to .. path .. v)
                --end
            --end
            --if file.DirectoryExists(to) then
                --jhud.log("Removed old directory @ " ..  to)
                --os.execute("rd /s /q \"" .. to .. "\"")
            --end
            --mkdir(to)
            --recurseDo()
        --end
        local function deletedir(dir)
            os.execute("rd /S /Q \"" .. dir .. "\"")
        end
        local function delete(f)
            log("del /q " .. f .. "")

            os.execute("del /Q \"" .. f:gsub("/", "\\") .. "\"")
        end
        local function rcopy(from, to)
            os.execute('xcopy /E /I /Y "' .. from .. '" "' ..  to .. '"')
        end

        deletedir(mod)
        unzip(zipPath, path)
        delete(zipPath)
        rcopy(path .. "/johnhud-" .. self.config.branch, mod)
        deletedir(path)

        cb()
    end)
end

function this:getVersion()
    if not io.file_is_readable(versionFile) then return "unknown" end
    local verfile = io.open(versionFile, "r")
    if not verfile then return "unknown" end
    local version = verfile:read("*all")
    verfile:close()
    return version
end

function this:newVersionFile(text)
    local verfile = io.open(versionFile, "w")
    jhud.log(verfile, "WOW")
    if not verfile then return true end
    verfile:write(text)
    verfile:close()
end

function this:update(cb)
    self:downloadAndUnpack(function(err)
        if err then return cb(err) end
        if self:newVersionFile(self.newVersion) then
            return cb("Failed to create version file")
        end
        self.hashVersion = self.newVersion
        self.newVersion = nil
        cb(false)
    end)
end

function this:__init()
    if not Steam or not Steam.http_request then return end

    self.hashVersion = self:getVersion()

    self:getLatestCommit(function(sh)
        jhud.log("Version " .. self.hashVersion .. ". Newest Version " .. sh)
        if self.hashVersion ~= sh then
            self.newVersion = sh
            if jhud.chat then
                jhud.chat("UPDATE", "A new update is available for johnhud")
                jhud.chat("UPDATE", "Type '/update' to update to version " .. sh:sub(1, 6))
            end
        end
    end)

    jhud.chat:addCommand("update", function(chat, ...)
        local args = {...}
        if table.hasValue(args, "-f") then self.newVersion = self.hashVersion end
        if self.newVersion then
            chat("UPDATE", "Starting update... " .. self.hashVersion .. "->" .. self.newVersion, chat.config.spare1)
            self:update(function(err)
                if err then
                    chat("UPDATE", "Update failed: " .. err, chat.config.failed)
                else
                    chat("UPDATE", "Update complete.", chat.config.spare2)
                end
            end)
        else
            chat("UPDATE", "There is no new update on the " .. self.config.branch .. " branch", chat.config.failed)
        end
    end)

    jhud.chat:addCommand("version", function(chat, ...)
        chat("Version", self.hashVersion:sub(1, 6), chat.config.spare1)
        chat("Branch", self.config.branch, chat.config.spare1)
        chat("Author", self.config.uname, chat.config.spare1)
    end)
end

function this:createVerFile(pure)
    local verfile = io.open("johnhud/version", "w")
    if pure then
        verfile:write("version"..self.eqchar..self.vconf.version.."--EOF--")
    else
        for i,v in pairs(self.vconf) do
            verfile:write(i..self.eqchar..v..self.sepchar)
        end
        verfile:write("--EOF--")
    end
    verfile:close()
end
