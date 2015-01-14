function this:__init()
	if not _G.UnitNetworkHandler then return end
	self.hooks = {}
	jhud.hook("UnitNetworkHandler","add_synced_team_upgrade", function(self, category, funcname, data, sender)
		if category and tostring(category) and category:sub(1,4) == "1337" then
			jhud.dlog("Network sync method called: ", funcname, data)
			if self.hooks[funcname] then
				self.hooks[funcname](data)
			end
			return true
		end
	end)
end

function this:send(name, data, nofeedback)
	if not managers.network and managers.network:session() and name and data then
		managers.network:session():send_to_peers_synched("add_synced_team_upgrade", "1337"..name, data, "ayy lmao*")
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