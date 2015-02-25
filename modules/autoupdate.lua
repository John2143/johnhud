this.vconf = {}

this.vconfdef = {
	uname = "John2143658709",
	project = "johnhud",
	branch = jhud.debug and "dev" or "master",
}

function this:default()
	for i,v in pairs(self.vconfdef) do
		self.vconf[i] = v
	end
end

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

function this:update(chat, args)
	chat = chat or function() end
	if not args.xcopyonly then
		chat("UPDATE", jhud.lang("downloading"), jhud.chat.config.spare1)
		self:dlunzip(chat)
	end
	if not args.dlonly then
		chat("UPDATE", jhud.lang("applying"), jhud.chat.config.spare1)
		self:xcopy(chat)
	end
	self.vconf.version = args.version
	self:createVerFile()
end

function this:dlunzip(chat)
	os.execute("cd johnhud && curl.exe "..self:format(self.URLz).." -k > archive.zip")
	os.execute("rmdir /Q /S johnhud\\update")
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
end

function this:__init()
	if not Steam or not Steam.http_request then return end
	self:default()
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
			jhud.dlog("DATA", data)
		end
		local tab = self:parse(data)

		if tab.version and tab.version ~= self.vconf.version then
			jhud.chat("JHUD", jhud.lang("newver"):format(self.vconf.version or "?", tab.version or "?"), jhud.chat.config.spare1)
			self.newavailable = tab.version
		end
	end)
	jhud.chat:addCommand("update", function(chat, ...)
		local flags = {
			force = false,
			dlonly = false,
			xcopyonly = false,
			version = self.newavailable or self.vconf.version
		}
		for i,v in pairs{...} do
			if v == "-f" or v == "--force" then
				flags.force = true
			elseif v == "-d" or v == "--download-only" then
				flags.dlonly = true
			elseif v == "-c" or v == "--copy-only" then
				flags.xcopyonly = true
			end
		end
		if not self.newavailable and not flags.force then
			chat("UPDATE", jhud.lang("nonewver"):format(self.vconf.version), jhud.chat.config.failed)
		else
			self:update(chat, flags)
		end
	end)
	jhud.chat:addCommand("updatedata", function(chat, ...)
		local pure = false
		for i,v in pairs{...} do
			if v == "-r" or v == "--reset" then
				self:default()
				chat("UPDATE", chat.lang("resetdata"), chat.config.spare2)
			elseif v == "-+" or v == "--next" then
				self.vconf.version = math.floor(self.vconf.version + 1)
				chat("UPDATE", chat.lang("valuechange"):format("version", self.vconf.version), chat.config.spare2)
			elseif v == "-p" or v == "--pure" then
				pure = true
			else
				local sp = v:split(":")
				self.vconf[sp[1]] = sp[2] or self.vconfdef[sp[1]]
				chat("UPDATE", chat.lang("valuechange"):format(sp[1], self.vconf[sp[1]]), chat.config.spare1)
			end
		end
		chat("UPDATE", chat.lang(pure and "writepure" or "writeunpure"), chat.config.spare2)
		self:createVerFile(pure)
	end)
	jhud.chat:addCommand("version", function(chat, ...)
		chat("Version", tostring(self.vconf.version), chat.config.spare1)
		chat("Branch", tostring(self.vconf.branch), chat.config.spare1)
		chat("Auhtor", tostring(self.vconf.uname), chat.config.spare1)
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
