this.vconf = {}

this.vconf.uname = "John2143658709"
this.vconf.project = "johnhud"
this.vconf.branch = "dev"

this.ignore = {
	"cfg.lua",
	"version",
}

this.URLz = "https://github.com/%s/%s/archive/%s.zip"
this.URLn = "https://raw.githubusercontent.com/%s/%s/%s/%s"
this.sepchar = "\n"
this.eqchar = "="


function this:format(url, file)
	return string.format(self.URLn, self.vconf.uname, self.vconf.project, self.vconf.branch, file)
end

function this:parse(text)
	local f = loadstring(text)
	local ret = {}
	setfenv(f, ret)
	f()
	return ret
end

function this:update()
	Steam:http_reqest(self:format(self.URLz), function(success, data)
		if not success then return false end
		
		_(data)
		do return end
		os.execute("del johnhud\\update\\* /Q")
		os.execute("cd johnhud && 7za.exe x -oupdate/ archive.zip")
		for i,v in pairs(self.ignore) do
			os.execute("del johnhud\\update\\"..v)
		end
		os.execute("copy /Y johnhud\\update\\* johnhud\\*")
		os.execute("copy /Y johnhud\\update\\modules\\* johnhud\\modules\\*")
		os.execute("copy /Y johnhud\\update\\language\\* johnhud\\language\\*")
		os.execute("del johnhud\\archive.zip /Q")
	end)
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
			jhud.chat("JHUD", jhud.lang("newver"):format(self.vconf.version, tab.version), jhud.chat.config.spare1)
			self.newavailable = true
		end
	end)
	jhud.chat:addCommand("update", function(chat)
		if not self.newavailable then
			chat("UPDATE", jhud.lang("nonewver"):format(self.vconf.version), jhud.chat.config.failed)
		else
			chat("UPDATE", jhud.lang("downloading"), jhud.chat.config.spare1)
			self:update()
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
