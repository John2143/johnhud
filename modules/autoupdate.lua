this.vconf = {}

this.vconf.uname = "John2143658709"
this.vconf.project = "johnhud"
this.vconf.branch = "dev"

this.ignore = {
	"cfg.lua",
	"version",
}

this.URLz = "https://codeload.github.com/%s/%s/zip/%s"
this.URLn = "https://raw.githubusercontent.com/%s/%s/%s/%s"
this.sepchar = "\n"
this.eqchar = "="


function this:format(url, file)
	return string.format(url, self.vconf.uname, self.vconf.project, self.vconf.branch, file or "")
end

local pcall = pcall --pcall gets destryoed when a Steam:http_access function is run
function this:parse(text)
	local f = loadstring(text)
	local ret = {}
	setfenv(f, ret)
	pcall(f)
	return ret
end

function this:update(chat)
	chat = chat or function() end
	chat("UPDATE", jhud.lang("downloading"), jhud.chat.config.spare1)
	self:dlunzip(chat)
	chat("UPDATE", jhud.lang("applying"), jhud.chat.config.spare1)
	self:xcopy(chat)
end

function this:dlunzip(chat)
	os.execute("curl.exe "..self:format(self.URLz).." -k > johnhud\\archive.zip")
	os.execute("rmdir johnhud\\update /s /q")
	os.execute("mkdir johnhud\\update")
	os.execute("cd johnhud && 7za.exe x -oupdate/ archive.zip > nul")
	os.execute("del johnhud\\archive.zip /Q")
end
function this:xcopy(chat)
	local branchthing = "johnhud\\update\\" .. self.vconf.project .."-"..self.vconf.branch
	jhud.log(branchthing)
	for i,v in pairs(self.ignore) do
		os.execute("del "..branchthing.."\\"..v)
	end
	os.execute("xcopy /e /y "..branchthing.." johnhud")
	self:createVerFile{
		version = self.newavailable
	}
end

function this:__init()
	if not Steam or not Steam.http_request then return end
	local verfile = io.open("johnhud/version")
	local vertab = self:parse(verfile:read("*all"))
	verfile:close()
	for i,v in pairs(vertab) do
		self.vconf[i] = v
	end
	Steam:http_request(self:format(self.URLn, "version"), function(success, data)
		if not success then
			jhud.dlog("error retreiving the github data")
			return
		else
			jhud.dlog("got github data")
		end
		local tab = self:parse(data)

		if tab.version ~= self.vconf.version then
			jhud.chat("JHUD", jhud.lang("newver"):format(self.vconf.version or "?", tab.version or "?"), jhud.chat.config.spare1)
			self.newavailable = tab.version
		end
	end)
	jhud.chat:addCommand("update", function(chat)
		if not self.newavailable then
			chat("UPDATE", jhud.lang("nonewver"):format(self.vconf.version), jhud.chat.config.failed)
		else
			self:update(chat)
		end
	end)
end

function this:createVerFile(data)
	local verfile = io.open("johnhud/version", "w")
	for i,v in pairs(self.vconf) do
		verfile:write(i..self.eqchar..(data[i] or v)..self.sepchar)
	end
	verfile:close()
end
