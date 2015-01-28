--Note on unpack
-- Unpack will always ignore element 0, so I use that to store the name
-- and return the correct value every time
function this:__init()
	if not _G.UnitNetworkHandler then return end
	self.hooks = {}
	local _self = self
	jhud.hook("UnitNetworkHandler","sync_grenades", function(self, gtype)
		if gtype and tostring(gtype) and gtype ~= "frag" then
			local dat = {}
			local ind = 0
			for w in gtype:gmatch("[^~]-") do
				dat[ind] = w
				ind = ind + 1
			end
			jhud.dlog("Network sync method called: ",dat[0], unpack(dat))
			if _self.hooks[dat[0]] then
				_self.hooks[dat[0]](unpack(dat))
			end
			return true
		end
	end)
end
function this:send(name, data, nofeedback)
	if managers.network and managers.network:session() and name then
		local mgs = managers.network:session()
		if type(data) ~= "table" then
			data = {data}
		end
		data[0] = name
		local datacompr = table.concat(data, "~")
		local send = data[0] -- name
		if datacompr ~= "" then
			send = send .. "~" .. datacompr
		end
		mgs:send_to_peers_synched("sync_grenades", send)
	else
		jhud.dlog("could not send")
	end
	if not nofeedback and self.hooks[name] then self.hooks[name](unpack(data)) end
	return true
end

function this:hook(name, func)
	if not self.hooks then return end
	self.hooks[name] = func
end

setmetatable(this, {
	__call = function(_, ...)
		_:send(...)
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
