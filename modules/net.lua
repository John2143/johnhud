jhud.wmod("player")
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

function this:receiveHandshake(hstype, peer, ...)
	local data = {...}
	if jhud.player then
		local ply = jhud.player:getPlayerByPeerID(peer)
		if not ply then return end
		ply:hasJHUD(true)
		if hstype == 1 then
			ply:isCheating(data[1] == 1)
		end
	end
end

function this:sendHandshake(hstype)
	local data = {}
	if hstype == 1 then
		data[1] = jhud.cheater and 1 or 0
	end
	self:_sendPure(self.RETURN_HANDSHAKE, hstype, self:getPeerID(), unpack(data))
end

function this:hostHasJHUD()
	return false
end

this.TO_HOST = 1
this.TO_PEERS = 2
this.REQUEST_HANDSHAKE_SPECIFIC = 3
this.REQUEST_HANDSHAKE_ALL = 4
this.RETURN_HANDSHAKE = 5

function this:__init()
	if not _G.UnitNetworkHandler then return end
	self.hooks = {}
	jhud.hook("ChatManager", "_receive_message", function(cm, id, name, message, color, icon)
		if id == 4 then
			local dat = string.split(message, self._joinchar, -2)
			if dat[-2] ~= "jhud" then return end
			--Example string: jhud|1|fname|fdata1|fdata2
			--Parses to:
			--dat
			--	-2	jhud	--always --with goonmod this will be some junk value like GGSM/1/2/3 or something
			--	-1	1		--network method
			--	0	fname	--funcname
			--	1	fdata1	--data...
			--	2	fdata2
			--unpack(dat)
			--	(fdata1, fdata2)
			jhud.dlog("Network sync method called: ", dat[0], unpack(dat))
			--more hacky unpacky
			--table.hasValue uses the ipairs method so it will ignore element 0
			--example netmethod
			--Ambigious
			--  ...|3|... --net method 3, no specific peer
			--Specific
			--  ...|5,4,1|... -- only preform net method 5 if you are peer 4 or peer 1

			local methoddata = string.split(dat[-1], ",", 0)
			for i,v in pairs(methoddata) do
				methoddata[i] = tonumber(v)
			end
			local method = methoddata[0]


			if method == self.TO_HOST and self:isServer() or
					method == self.TO_PEERS then

				self:executeNethook(dat)
			elseif method == self.REQUEST_HANDSHAKE_SPECIFIC and table.hasValue(methoddata, self:getPeerID()) or
					method == self.REQUEST_HANDSHAKE_ALL then
				self:sendHandshake(dat[0], unpack(dat))
			elseif method == self.RETURN_HANDSHAKE and --TODO make the handshake actually secure
					(
						not methoddata[1] or --only receive it if it ambigious
						table.hasValue(methoddata, self:getPeerID()) --or specific to the local player
					) then
				self:receiveHandshake(name, dat[0], unpack(dat))
			end

			return true
		end
	end)
	jhud.hook("BaseNetworkSession", "add_peer", function(bns, name, rpc, in_lobby, loading, synched, i, ...)------
		jhud.callModuleMethod("__addpeer", i)
		jhud.callModuleMethod("__postaddpeer", i)
	end)
	jhud.hook("BaseNetworkSession", "remove_peer", function(bns, peer, i, reason)------
		jhud.callModuleMethod("__removepeer", i)
		jhud.callModuleMethod("__postremovepeer", i)
	end)
end


this._joinchar = "|"
function this:_sendPure(to, ...)
	if not(managers.network or managers.network:session()) then return false end
	local send =
		"jhud"..self._joinchar..
		to..self._joinchar..
		table.concat({...},self._joinchar)
	managers.network:session():send_to_peers_ip_verified("send_chat_message", 4, send) --4 isnt shown to chat
	return true
end
function this:_basicSend(name, data, to, localcall)
	if type(data) ~= "table" then
		data = {data}
	end
	if localcall then
		if self.hooks[name] then
			self.hooks[name](unpack(data))
		end
	end
	if self:_sendPure(to, name, unpack(data)) then
		return true
	else
		jhud.dlog("could not send (mabye not in a game) [no game session]")
		return false
	end
end
function this:send(name, data, nofeedback)
	return self:_basicSend(name, data, self.TO_PEERS, not nofeedback)
end
function this:sendHost(name, data)
	return self:_basicSend(name, data, self.TO_HOST, false)
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
