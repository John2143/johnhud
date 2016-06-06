jhud.rmod("chat")

local mod = jhud.path --Placeholder
local versionFile = mod .. "version.txt"

function this:getCommits(cb, force)
    if force or not self.commits then
        Steam:http_request("https://api.github.com/repos/" ..
                    self.config.uname .. "/" ..
                    self.config.project .. "/commits?sha=" ..
                    self.config.branch, function(suc, data)
            if not suc then return end
            local commits = json.decode(data)
            self.commits = commits
            cb(commits)
        end)
    else
        cb(self.commits)
    end
end

function this:getLatestCommitHash(cb, force)
    self:getCommits(function(commits) cb(commits[1].sha) end, force)
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
            --jhud.mkdir(to)
            --recurseDo()
        --end
        local function deletedir(dir)
            os.execute("rd /S /Q \"" .. dir .. "\"")
        end
        local function delete(f)
            os.execute("del /Q \"" .. f:gsub("/", "\\") .. "\"")
        end
        local function rcopy(from, to)
            jhud.mkdir(to)
            os.execute('%systemroot%\\System32\\robocopy /MOVE /E "' .. from .. '" "' ..  to .. '"')
        end

        jhud.log("Unzipping")
        unzip(zipPath, path)
        jhud.log("Deleting zip")
        delete(zipPath)
        jhud.log("Deleting old johnhud")
        deletedir(mod)
        jhud.log("Copying files")
        rcopy(path .. "/johnhud-" .. self.config.branch, mod)
        jhud.log("Cleaning up")
        deletedir(path)

        cb()
    end)
end

function this:getVersion()
    if not io.file_is_readable(versionFile) then return "unknwn" end
    local verfile = io.open(versionFile, "r")
    if not verfile then return "unknwn" end
    local version = verfile:read("*all")
    verfile:close()
    return version
end

function this:newVersionFile(text)
    local verfile = io.open(versionFile, "w")
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

function this:checkForUpdates(silent, cb)
    self:getLatestCommitHash(function(sh)
        if self.hashVersion ~= sh then
            self.newVersion = sh
            if jhud.chat and not silent then
                jhud.chat("UPDATE", self.lang("ud1"), jhud.chat.config.spare3)
                jhud.chat("UPDATE", self.lang("ud2"):format(self.config.branch, sh:sub(1, 6)), jhud.chat.config.spare3)
            end
        end
    end, true)
end

function this:__init()
    if not Steam or not Steam.http_request then return end

    self.lang = L:new("autoupdate")

    self.hashVersion = self:getVersion()
    self:checkForUpdates()

    jhud.chat:addCommand("update", function(chat, ...)
        local args = {...}
        local option = args[#args]
        if option == "apply" then
            if table.hasValue(args, "-f") then self.newVersion = self.hashVersion end
            if self.newVersion then
                chat("UPDATE", "Starting update... " .. self.hashVersion .. "->" .. self.newVersion, chat.config.spare1)
                self:update(function(err)
                    if err then
                        chat("UPDATE", self.lang("upfail") .. err, chat.config.failed)
                    else
                        chat("UPDATE", self.lang("upsucc"), chat.config.spare2)
                    end
                end)
            else
                chat("UPDATE", self.lang("navailable"):format(self.config.branch) , chat.config.failed)
            end
        elseif option == "check" then
            local silent = false
            if table.hasValue(args, "-s") then silent = true end
            self:checkForUpdates(silent)
        elseif option == "view" then
            local function viewUpdates()
                self:getCommits(function(commits)
                    for i = 1, 5 do
                        chat("U" .. commits[i].sha:sub(1, 6),
                             commits[i].commit.message,
                             chat.config.spare3, false)
                    end
                end)
            end
            if table.hasValue(args, "-c") then
                self:checkForUpdates(true, viewUpdates)
            else
                viewUpdates()
            end
        end
    end)

    jhud.chat:addCommand("version", function(chat, ...)
        chat(self.lang("version"), self.hashVersion:sub(1, 6), chat.config.spare1)
        chat(self.lang("branch"), self.config.branch, chat.config.spare1)
        chat(self.lang("author"), self.config.uname, chat.config.spare1)
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
