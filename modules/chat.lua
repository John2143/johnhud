setmetatable(jhud.chat, {
	__call = function(_,name,message,color,icon)
		if not message then
			message = name
			name = jhud.chat.icons.Skull
		end
		if icon == true or icon == false or icon == "none" or icon == "no_icon" then
			icon = false
		else
			icon = icon or "icon_repair"
		end
		managers.chat:_receive_message(1, tostring(name), tostring(message), color or Color("ffffff"), icon)
	end
})

function this:doChatAll(text)
	managers.network:session():send_to_peers_ip_verified( 'send_chat_message', 1, text)
end

function this:chatAll(name, text, color, icon, toself)
	self:doChatAll(text)
	if not toself then self(name or "JohnHUD", text, color, icon) end
end

local Icon = {
	A=57344, B=57345,	X=57346, Y=57347, Back=57348, Start=57349,
	Skull = 57364, Ghost = 57363, Dot = 1031, Chapter = 1015, Div = 1014, BigDot = 1012,
	Times = 215, Divided = 247, LC=139, RC=155, DRC = 1035, Deg = 1024, PM= 1030, No = 1033
}
jhud.chat.icons = {}
for k,v in pairs(Icon) do
	jhud.chat.icons[k] = utf8.char(v)
end

function this:sterileEmotes(text)
	-- print("text is "..text)
	for i,v in pairs(jhud.chat.icons) do
		text = string.gsub(text, string.format("%%%%%s%%%%", i:lower()), v) --lua for best regex of 2015
	end
	return text
end

this.NO_PLAYER = 1
this.NEED_HEIST = 2
this.NOT_HOST = 3
this.MISSING_ARGUMENTS = 4

function this:chatFail(lang)
	self("CMD", self.lang(lang), self.config.failed)
end

function this:__init()
	self.lang = L:new("chat")
	jhud.hook("ChatManager", "send_message", function(cm, channel, name, text)
		if text:sub(1,1) == "/" or text:sub(1,1) == "!" then
			local cmd = text:sub(2):gloop("%S+", 0)
			local success, ret = --If the command is not found the use a generic method that prints unknown command
				pcall(
					(
						self.commands[cmd[0]] or
						function()
							self("CMD", string.format(self.lang("unknown"), cmd[0] or ""), self.config.unknown)
						end
					),
					self,
					unpack(cmd)
				)

			if not success then
				self:chatFail("internalerror")
				jhud.log("CMDERR", cmd[0], ret, "ARGS", unpack(cmd))
			elseif ret == self.NO_PLAYER then
				self:chatFail("noplayer")
			elseif ret == self.NEED_HEIST then
				self:chatFail("requiresheist")
			elseif ret == self.NOT_HOST then
				self:chatFail("needhost")
			elseif ret == self.MISSING_ARGUMENTS then
				self:chatFail("missingarguments")
			end
			return true
		end
	end)
	self.commands = {}
	self:addCommand("help", self.showHelp)
	self:addCommand("test", function(chat, ...) chat("IN->" or {}, table.concat({...}, ",")) end)
	if self.config.showemotes then
		jhud.hook("ChatGui", "receive_message", self.chatEmotes)
		jhud.hook("HUDChat", "receive_message", self.chatEmotes)
	end
	if self.config.showinfamy then
		jhud.hook("ChatGui", "receive_message", self.chatInfamy)
		jhud.hook("HUDChat", "receive_message", self.chatInfamy)
	end
end

this.chatEmotes = function(cg, name, message, ...)
	return{
		[2] = jhud.chat:sterileEmotes(name),
		[3] = jhud.chat:sterileEmotes(message)
	}
end

this.chatInfamy = function(cg, name, message, color, icon)
	local ply = jhud.player:playerByColor(color)
	if not ply then return end
	if ply:name() ~= name then return end
	return{
		[2] = ply:infamystr().." "..name
	}
end

function this:showHelp(sub)
	local cmds = {}
	for i,v in pairs(self.commands) do
		table.insert(cmds, i)
	end
	self("CMD", table.concat(cmds, ", "), jhud.chat.config.spare1)
end

function this:nice(args)
	local str = {}
	for argnum,arg in ipairs(args) do
		local type = type(arg)
		if type == "table" then
			local mt = getmetatable(arg)
			if mt.types == "plys" then
				local plys = {}
				for i,v in pairs(arg) do
					table.insert(plys, v:name())
				end
				table.insert(str, "<"..table.concat(plys, ",")..">")
			end
		else
			table.insert(str, tostring(arg))
		end
	end
	return table.concat(str)..(not args.noperiod and "." or "")
end

function this:addCommand(name, func)
	self.commands[name] = func
end
