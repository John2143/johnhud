this.getPlayers = function(self, ...)
	return jhud.player:getPlayers(...)
end

function this:kick(noban, chat, on)
	local plys = self:getPlayers(on)
	for i,v in pairs(plys) do
		v:kick()
	end
end

function this:csay(chat, text)
	if not jhud.net:isServer() then return end
	jhud.net("jhud.admin.csay", text)
end
function this:csay2(chat, text)
	if not jhud.net:isServer() then return end
	jhud.net("jhud.admin.csay2", text)
end

function this:docsay(text)
	jhud.dlog("CSAY", text)
	managers.hud:show_hint{
		text = text,
		event = 0,
		time = 5,
	}
end
function this:docsay2(text)
	jhud.dlog("CSAY2", text)
	managers.hud:present_mid_text{ --csay expanding box
		title = "TODO ADD A WAY TO SET THIS",
		text = text,
		icon = "unused",
		time = 5,
		event = {}
	}
end

function this:__init()
	jhud.chat:addCommand("kick", function(...) self:kick(true, ...) end)
	jhud.chat:addCommand("kickb", function(...) self:kick(false, ...) end)
	jhud.chat:addCommand("csay", function(...) self:csay(...) end)
	jhud.chat:addCommand("csay2", function(...) self:csay2(...) end)

	jhud.net:hook("jhud.admin.csay", function(data)
		self:docsay(data)
	end)
	jhud.net:hook("jhud.admin.csay2", function(data)
		self:docsay2(data)
	end)
end
