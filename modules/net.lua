--Note on unpack
-- Unpack will always ignore element 0, so I use that to store the name
-- and return the correct value every time

function this:executeNethook(dat)
	if self.hooks[dat[0]] then
		self.hooks[dat[0]](unpack(dat))
	end
end

function this:getPeerID(refresh)
	if refresh or not self.peerid then
		self.peerid = managers.network:session():local_peer():id()
	end
	return self.peerid
end

function this:receiveHandshake(name, id, isHost, isCheating, isHardcore)
	self.netData[id] = {
		cheater = isCheating,
		hardcore = isHardcore,
		isHost = isHost,
		name = name,
	}
end

function this:sendHandshake()

end

function this:hostHasJHUD()
	return false
end

function this:__init()
	if not _G.UnitNetworkHandler then return end
	self.netData = {}
	self.hooks = {}
	jhud.hook("ChatManager", "_receive_message", function(cm, id, name, message, color, icon)
		if id == 4 then
			local dat = string.split(message, self._joinchar, -2)
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

			local methoddata = string.split(dat[-1], ",", 0)
			local method = methoddata[0]

			if method == self.TO_HOST and self:isServer() or
					method == self.TO_PEERS then

				self:executeNethook(dat)
			elseif method == self.REQUEST_HANDSHAKE_SPECIFIC and table.hasValue(methoddata, self:getPeerID()) or
					method == self.REQUEST_HANDSHAKE_ALL then
				self:sendHandshake(unpack(dat))
			elseif method == self.RETURN_HANDSHAKE and --TODO make the handshake actually secure
					(
						not methoddata[0] or
						table.hasValue(methoddata, self:getPeerID())
					) then
				self:receiveHandshake(name, unpack(dat))
			end

			return true
		end
	end)
end

this.TO_HOST = 1
this.TO_PEERS = 2
this.REQUEST_HANDSHAKE_SPECIFIC = 3
this.REQUEST_HANDSHAKE_ALL = 4
this.RETURN_HANDSHAKE = 5

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

		ses:send_to_peers_ip_verified("send_chat_message", 4, send)
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
