--Note on unpack
-- Unpack will always ignore element 0, so I use that to store the name
-- and return the correct value every time
function this:__init()
	if not _G.UnitNetworkHandler then return end
	self.hooks = {}
	jhud.hook("ChatManager", "_receive_message", function(cm, id, name, message, color, icon)
		if id == 4 then
			local dat = {}
			local ind = -2
			for w in message:gmatch("[^" .. self._joinchar .. "]+") do
				dat[ind] = w
				ind = ind + 1
			end
			_(dat)
			if dat[-2] ~= "jhud" then return end
			--Example string: jhud|1|fname|fdata1|fdata2
			--Parses to:
			--dat
			--	-2	jhud	--always
			--	-1	1		--network method
			--	0	fname	--funcname
			--	1	fdata1	--data...
			--	2	fdata2
			--unpack(dat)
			--	(fdata1, fdata2)
			jhud.dlog("Network sync method called: ", dat[0], unpack(dat))
			if self.hooks[dat[0]] then
				self.hooks[dat[0]](unpack(dat))
			end
			return true
		end
	end)
end

this.TO_HOST = 1
this.TO_PEERS = 2
this._joinchar = "|"

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
			"jhud"..self._joinchar..
			to..self._joinchar..
			name..self._joinchar..
			table.concat(data,self._joinchar)

		if to == self.TO_PEERS then
			ses:send_to_peers_ip_verified("send_chat_message", 4, send)
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
