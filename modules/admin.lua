jhud.rmod("chat")
jhud.rmod("player")
this.getPlayers = function(self, ...)
	return jhud.player:getPlayers(...)
end

function this:kick(ban, chat, on)
	if not jhud.net:isServer() then return chat.NOT_HOST end
	local plys = self:getPlayers(on)
	if not plys[1] then return chat.NO_PLAYER end
	chat("KICK", chat:nice{ban and "Kicking(ban) " or "Kicking ", plys}, chat.config.spare1)

	for i,v in pairs(plys) do
		if v.id == jhud.net:getPeerID() then
			chat("KICK", chat.lang("kickself"), chat.config.failed)
		else
			v:kick()
		end
	end
end

function this:csay(chat, ...)
	if not jhud.net:isServer() then return chat.NOT_HOST end
	if not managers.hud then return chat.NEED_HEIST end
	jhud.net("jhud.admin.csay", table.concat({...}, " "))
end
function this:csay2(chat, ...)
	if not jhud.net:isServer() then return chat.NOT_HOST end
	if not managers.hud then return chat.NEED_HEIST end
	jhud.net("jhud.admin.csay2", table.concat({...}, " "):split(jhud.net._joinchar))
end

function this:docsay(text)
	jhud.dlog("CSAY", text)
	managers.hud:show_hint{
		text = text,
		event = 0,
		time = 5,
	}
end
function this:docsay2(top, bottom)
	jhud.dlog("CSAY2", top, bottom)
	managers.hud:present_mid_text{ --csay expanding box
		title = top,
		text = bottom or "",
		icon = "unused",
		time = 5,
		event = {}
	}
end

function this:__init()
	jhud.chat:addCommand("kick", function(...) return self:kick(false, ...) end)
	jhud.chat:addCommand("kickb", function(...) return self:kick(true, ...) end)
	jhud.chat:addCommand("csay", function(...) return self:csay(...) end)
	jhud.chat:addCommand("csay2", function(...) return self:csay2(...) end)

	jhud.net:hook("jhud.admin.csay", function(data)
		self:docsay(data)
	end)
	jhud.net:hook("jhud.admin.csay2", function(...)
		self:docsay2(...)
	end)
end
