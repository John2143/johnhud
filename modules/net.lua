--Note on unpack
-- Unpack will always ignore element 0, so I use that to store the name
-- and return the correct value every time
this.UNHhook = "sync_warn_about_civilian_free"
function this:__init()
	if not _G.UnitNetworkHandler then return end
	self.hooks = {}
	local _self = self
	jhud.hook("UnitNetworkHandler", self.UNHhook, function(self, gtype)
		_(self, gtype)
		if type(gtype) == "string" then
			local calldata = gtype:match("^".._self._startchar.."(.+)")
			if calldata then
				local dat = {}
				local ind = -1
				for w in calldata:gmatch("[^~]*") do
					dat[ind] = w
					ind = ind + 1
				end
				--Example string: $!1~fname~fdata1~fdata2
				--Parses to:
				--dat
				--	-1	1		--network method
				--	0	fname	--funcname
				--	1	fdata1	--data...
				--	2	fdata2
				--unpack(dat)
				--	(fdata1, fdata2)
				jhud.dlog("Network sync method called: ", dat[0], unpack(dat))
				if _self.hooks[dat[0]] then
					_self.hooks[dat[0]](unpack(dat))
				end
				return true
			end
		end
	end)
end

this.TO_HOST = 1
this.TO_PEERS = 2
this._joinchar = "~"
this._startchar = "$!"

function this:_doSend(name, data, to, localcall)
	if type(data) ~= "table" then
		data = {data}
	end
	if localcall then
		if self.hooks[name] then
			self.hooks[name](unpack(data))
		end
	end
	if managers.network and managers.network:session() and name then
		local ses = managers.network:session()
		local send =
			self._startchar..
			to..self._joinchar..
			name..self._joinchar..
			table.concat(data,self._joinchar)

		if to == self.TO_PEERS then
			ses:send_to_peers_synched(self.UNHhook, send)
		elseif to == self.TO_HOST then
			--TODO
		end
		return true
	else
		jhud.dlog("could not send (mabye not in a game)")
		return false
	end
end
function this:send(name, data, nofeedback)
	return self:_doSend(name, data, self.TO_PEERS, not nofeedback)
end
function this:sendHost(name, data)
	return self:_doSend(name, data, self.TO_HOST, false)
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
	return Network:is_server() or self:isSP()
end

function this:isClient()
	if not Network then return false end
	return Network:is_client()
end

function this:isSP()
	return Global.game_settings.single_player or false
end
