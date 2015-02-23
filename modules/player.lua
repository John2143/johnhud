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

function _player:infamy(rank)
	if rank then
		self.peer:set_rank(rank)
		return self
	else
		return self.peer:rank()
	end
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

setmetatable(this,  {__call = function(_, id)
	local tab = {
		peer = managers.network:session():peers()[id] or
				managers.network:session():local_peer(),

		id = id,
	}
	setmetatable(tab, {__index = _player})
	return tab
end})

function this:__init()
	self.plys = {}
	if not (managers.network and managers.network:session()) then return end
	for i,v in pairs(managers.network:session():peers()) do
		self.plys[i] = self(i)
	end
	local id = jhud.net:getPeerID()
	self.plys[id] = self(id)
	self.plys[id].iscl = true

	if jhud.chat then
		jhud.chat:addCommand("playing", function(chat)
			chat(chat.lang("cmdplaying"), self:isSolo() and chat.lang("solo") or "", chat.config.spare1)
			for i,v in pairs(self.plys) do
				chat(i, v:name(), chat.config.spare2)
			end
		end)
	end
end

function this:isSolo()
	for i,v in pairs(self.plys) do
		if v.id ~= jhud.net:getPeerID() then
			return false
		end
	end
	return true
end

function this:localPlayer()
	return self.plys[jhud.net:getPeerID()]
end

function this:playerByPeerID(id)
	return self.plys[id]
end

local function compareFloat(a, b)
	if b < a + .01 and b > a - .01 then
		return true
	end
	return false
end

function this:playerByColor(color)
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

function this:getPlayers(text)
	local plys = {}
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

		for k,v in pairs(self.plys) do
			if v:name():lower():find(name) then
				doInsert(v)
			end
		end
	end
	return plys
end
