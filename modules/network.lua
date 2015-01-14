function this:__init()
	if not _G.UnitNetworkHandler then return end
	self.hooks = {}
	local oldfunc = UnitNetworkHandler.add_synced_team_upgrade
	function UnitNetworkHandler:add_synced_team_upgrade(category, funcname, data, sender)
		if tostring(category) == "1337" then
			jhud.log("ayy", funcname, data, sender)
			-- for i,v in pairs(self.hooks) do
				-- if i == funcname then
					-- pcall(funcname, data)
					-- break
				-- end
			-- end
		else 
			oldfunc(self, category, funcname, data, sender)
		end
	end
end

function this:send(name, data, nofeedback)
	if not managers.network and managers.network:session()then
		managers.network:session():send_to_peers_synched("add_synced_team_upgrade", "1337", name, data)
	end
	if not nofeedback and self.hooks[name] then self.hooks[name](data) end
	return true
end

function this:hook(name, func)
	if not self.hooks then return end
	self.hooks[name] = func
end

setmetatable(this, {
	__call = function(_, name, data, no)
		_:send(name, data, no)
	end
})

function this:isServer()
	if not Network then return false end
	return Network:is_server() or self.isSP()
end

function this:isClient()
	if not Network then return false end
	return Network:is_client()
end

function this:isSP()
	return Global.game_settings.single_player or false
end

net = this