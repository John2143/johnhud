jhud.rlib("big")
jhud.wmod("chat")
jhud.rmod("net")
jhud.rlib("file")

local _player = {}

function _player:name()
	return self.peer._name
end

function _player:character()
	return self.peer._character
end

function _player:setInfamy(rank)
	self.peer:set_rank(rank)
	return self
end

function _player:cID()
	return self.peer._user_id
end

function _player:steamID()
	if not self._steamID then
		local uid = jhud.bignum(self:cID(), 10) - _player.steamid0
		local last, server = uid:div(2)
		self._steamID = ("STEAM_0:%s:%s"):format(server, last:print())
	end
	return self._steamID
end

function _player:infamy(rank)
	if rank then
		if self.iscl then
			jhud.infamy:setInfamy(rank)
		end
		self.peer:set_rank(rank)
		return self
	else
		if self.iscl then
			return jhud.infamy:getInfamy()
		else
			return self.peer:rank()
		end
	end
end

function _player:infamystr()
	return managers.experience:rank_string(self:infamy())
end

function _player:color()
	return tweak_data.chat_colors[self.id]
end

function _player:kick()
	if not jhud.net:isServer() then return end
	managers.network:session():remove_peer(
		self.peer,
		self.id,
		"Kicked by host"
	)
	return nil
end

function _player:hasJHUD(does)
	if does == nil then
		return self.jhud
	else
		self.jhud = does
		return self
	end
end

function _player:isCheating(is)
	if is == nil then
		return self.jhudCheater
	else
		self.jhudCheater = is
		if is and managers.hud then
			managers.hud:mark_cheater(self.id)
		end
		return self
	end
end

function _player:toString()
	return "Player<"..self.id.." "..self:name()..">"
end

setmetatable(this,  {__call = function(_, id)
	local tab = {
		peer = managers.network:session():peers()[id] or
				managers.network:session():local_peer(),

		id = id,
	}
	setmetatable(tab, {
		__index = _player,
		__tostring = _player.toString,
	})

	if table.hasValue(_.ignored, tab:cID()) then
		tab.ignore = true
	end
	return tab
end})

function this:loadPlys()
	self.plys = {}
	self.ignored = jhud.load("ignored")
	for i,v in pairs(managers.network:session():peers()) do
		self.plys[i] = self(i)
	end
	local localid = jhud.net:getPeerID()
	local localplayer = self(localid)
	localplayer.iscl = true
	self.plys[localid] = localplayer
end

function this:active()
	if self.isactive then return true end
	self.isactive = true
	self.isactive = self:activate()
	jhud.dlog("Activated player", self.isactive)
	return self.isactive
end
this.__init = this.active

function this:activate()
	if not (managers.network and managers.network:session()) then return false end
	_player.steamid0 = jhud.bignum("76561197960265728", 10) -- this is the community id of STEAM_0:0:0
	self:loadPlys()
	if jhud.chat then
		jhud.chat:addCommand("playing", function(chat)
			chat(chat.lang("cmdplaying"), self:isSolo() and chat.lang("solo") or "", chat.config.spare1)
			for i,v in pairs(self.plys) do
				chat(i, v:name()..", "..v:steamID(), chat.config.spare2)
			end
		end)
		jhud.chat:addCommand("reload", function(chat)
			self:loadPlys()
		end)
		jhud.chat:addCommand("ignore", function(chat, arg)
			local plys = self:getPlayers(arg)
			if not plys[1] then return chat.NO_PLAYER end
			chat("IGN", chat:nice{chat.lang("ignoring"), plys}, chat.config.spare3)
			for i,v in pairs(plys) do
				if not table.hasValue(self.ignored, v:cID()) then
					table.insert(self.ignored, v:cID())
					v.ignore = true
				end
			end
			jhud.save("ignored", self.ignored)
		end)
		jhud.chat:addCommand("unignore", function(chat, arg)
			local plys = self:getPlayers(arg)
			if not plys[1] then return chat.NO_PLAYER end
			for i,v in pairs(plys) do
				if v.ignore then
					for k,x in pairs(self.ignored) do
						if x == v:cID() then
							table.remove(self.ignored, k)
						end
					end
					v.ignore = false
					chat("IGN", chat.lang("unignore"):format(v:name()), chat.config.spare1)
				end
			end
			jhud.save("ignored", self.ignored)
		end)
	end
	return true
end
function this:__addpeer(i)
	self.plys[i] = self(i)
end
function this:__removepeer(i)
	self.plys[i] = nil
end
function this:isSolo()
	if not self:active() then return false end
	for i,v in pairs(self.plys) do
		if v.id ~= jhud.net:getPeerID() then
			return false
		end
	end
	return true
end

function this:localPlayer()
	if not self:active() then return false end
	return self.plys[jhud.net:getPeerID()]
end

function this:playerByPeerID(id)
	if not self:active() then return false end
	return self.plys[id]
end

local function compareFloat(a, b)
	if b < a + .01 and b > a - .01 then
		return true
	end
	return false
end
function this:playerByColor(color)
	if not self:active() then return false end
	for i,v in pairs(self.plys) do
		local pcolor = v:color()
		if
			color == pcolor or
			compareFloat(pcolor.r, color.r) and
			compareFloat(pcolor.b, color.b) and
			compareFloat(pcolor.g, color.g) and
			compareFloat(pcolor.a, color.a)
		then
			return v
		end
	end
end

local function newbase()
	local baseTable = {}
	setmetatable(baseTable, {
		types = "plys"
	})
	return baseTable
end

function this:getPlayers(text)
	if not self:active() then return {} end
	local plys = newbase()
	local isRemove
	local function doInsert(ply)
		if isRemove then
			for i,v in ipairs(plys) do
				if v == ply then
					table.remove(plys, i)
				end
			end
		else
			table.insert(plys, ply)
		end
	end

	for i,name in pairs(text:split()) do
		isRemove = false
		if name:sub(1,1) == "-" then
			isRemove = true
			name = name:sub(2)
		end
		if name == "*" then
			plys = newbase()
			for i,v in pairs(self.plys) do
				doInsert(v)
			end
		elseif name == "^" then
			doInsert(self:localPlayer())
		else
			for k,v in pairs(self.plys) do
				if v:name():lower():find(name) then
					doInsert(v)
				end
			end
		end
	end
	return plys
end
