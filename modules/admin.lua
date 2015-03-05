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
function this:restart(chat, ...)
	if not jhud.net:isServer() then return chat.NOT_HOST end
	if not managers.hud then return chat.NEED_HEIST end --Use hud to check if you are in game, could also use equipment selections

	if managers.job:is_current_job_professional() then
		local g = managers.job._global.current_job
		g.current_stage = 1
		local diff = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
		local offcost = managers.money:get_cost_of_premium_contract(g.job_id, diff or 2)
		managers.money:deduct_from_offshore(offcost)
		jhud.dlog(offcost, "paid for restart")
	end
	managers.game_play_central:restart_the_game()
end

function this:__init()
	jhud.chat:addCommand("kick", function(...) return self:kick(false, ...) end)
	jhud.chat:addCommand("kickb", function(...) return self:kick(true, ...) end)
	jhud.chat:addCommand("csay", function(...) return self:csay(...) end)
	jhud.chat:addCommand("csay2", function(...) return self:csay2(...) end)
	jhud.chat:addCommand("restart", function(...) return self:restart(...) end)
	jhud.chat:alias("r", "restart")

	jhud.net:hook("jhud.admin.csay", function(data)
		self:docsay(data)
	end)
	jhud.net:hook("jhud.admin.csay2", function(...)
		self:docsay2(...)
	end)
end
