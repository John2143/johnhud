jhud = jhud or {}
if not managers then return end
if jhud.hook then
	jhud.hook:restoreAll()
end
jhud.debug = true
jhud.log = function(...)
	for i,v in ipairs{...} do
		io.write(tostring(v).."\t")
	end
	io.write("\n")
end
jhud.log("JohnHUD started.")
table.hasValue = function(table, val)
	for i,v in ipairs(table) do
		if v == val then
			return true
		end
	end
	return false
end
string.split = function(text, reg, ind)
	ind = ind or 1
	reg = reg or ","
	local dat = {}
	for w in text:gmatch("[^"..reg.."]+") do
		dat[ind] = w
		ind = ind + 1
	end
	return dat
end
string.gloop = function(text, reg, ind)
	local ret, ind = {}, ind or 0
	for w in text:gmatch(reg or "%w+") do
		ret[ind] = w
		ind = ind + 1
	end
	return ret
end
jhud.digest = function(num)
	return Application:digest_value(num, true)
end
jhud.undigest = function(num)
	return Application:digest_value(num)
end
do
	local split = ",\n"
	local splitnoval = "\n"
	local val = "="
	local tstart = "{"
	local tend = "}"
	local ttv = {
		number = function(a)
			return tostring(a)
		end,
		string = function(a)
			return '"'..a..'"'
		end,
		boolean = function(a)
			return a and "true" or "false"
		end
	}
	local tti = {
		string = function(a)
			return a
		end
	}

	local function safe(value, index)
		local typ = type(value)
		local def = ttv[typ]
		if index then
			if tti[typ] then
				return tti[typ](value)
			else
				return L:affix(def(value))
			end
		else
			return def(value) or "nil"
		end
	end
	local function write(h, tab)
		for i,v in pairs(tab) do
			if type(v) == "table" then
				h:write(safe(i, true)..val..tstart..splitnoval)
				write(h, v)
				h:write(tend..split)
			else
				h:write(safe(i, true)..val..safe(v, false)..split)
			end
		end
	end
	jhud.save = function(path, tab)
		local handle = io.open("johnhud/data/"..path, "w")
		if not handle then return false end
		write(handle, tab)
		handle:close()
		return true
	end
	jhud.load = function(path)
		local handle = io.open("johnhud/data/"..path, "r")
		if not handle then return {}, true end
		local func = loadstring(table.concat{"RETURN = {",handle:read("*all"), "}"})
		handle:close()
		local ret = {}
		setfenv(func, ret)
		local suc, err = pcall(func)
		if not suc then
			jhud.log("LOADERR", err)
			return {}, true
		else
			return ret.RETURN
		end
	end
end
do
	--bit opterations
	-- b1 + b2 = bitwise or
	-- b1 * b2 = bitwise and
	-- b1 % b2 = bitwise xor

	local NUMS = {}
	local maxbit = 64
	for i = 1, maxbit do
		NUMS[i] = 2^(i - 1)
	end
	local _bit = {}
	local bitfunc = {}
	local bit = function(a)
		local bitrep
		if type(a) == "number" then
			bitrep = {}
			for i = maxbit, 1, -1 do
				local num = NUMS[i]
				local res = a - num
				if res >= 0 then
					a = res
					bitrep[i] = true
				else
					bitrep[i] = false
				end
			end
		else
			bitrep = a
		end
		setmetatable(bitrep, _bit)
		return bitrep
	end
	bitfunc.bor = function(a, b)
		local new = {}
		for i,v in pairs(a) do
			if b[i] or v then
				new[i] = true
			else
				new[i] = false
			end
		end
		return bit(new)
	end
	bitfunc.band = function(a, b)
		local new = {}
		for i,v in pairs(a) do
			if b[i] and v then
				new[i] = true
			else
				new[i] = false
			end
		end
		return bit(new)
	end
	bitfunc.bxor = function(a, b)
		local new = {}
		for i,v in pairs(a) do
			if (b[i] and not v) or (not b[i] and v) then
				new[i] = true
			else
				new[i] = false
			end
		end
		return bit(new)
	end
	bitfunc.base10 = function(bit)
		local num = 0
		for i,v in pairs(bit) do
			if v then num = num + NUMS[i] end
		end
		return num
	end
	_bit.__add = bitfunc.bor
	_bit.__mul = bitfunc.band
	_bit.__mod = bitfunc.bxor
	_bit.__index = {
		rep = bitfunc.base10
	}

	jhud.bit = bit
	jhud.bitm = {}
	setmetatable(jhud.bitm, {__index = function(__, want)
		if bitfunc[want] then
			return function(...)
				local args = {...}
				_(args)
				for i,v in pairs(args) do
					args[i] = bit(tonumber(v))
				end
				return bitfunc.base10(bitfunc[want](unpack(args)))
			end
		end
	end})

end

jhud.createPanel = function()
	if not RenderSettings then return end
	jhud.resolution = RenderSettings.resolution
	return Overlay:gui():create_scaled_screen_workspace(jhud.resolution.x, jhud.resolution.y, 0, 0, jhud.resolution.x, jhud.resolution.y):panel{name = "workspace_panel"}
end
jhud.keyboard = Input:keyboard()
jhud.log2 = function(...)
	jhud.log(string.format(...))
end
jhud.dlog = function(...)
	if not jhud.debug then return end
	jhud.log("DEBUG: ",...)
end

function jhud.localPlayer()
	return managers and managers.player and managers.player:player_unit()
end

function jhud.addModule(tab)
	for i,v in ipairs(tab) do
		table.insert(jhud.options.modules, v)
	end
end
function jhud.addCheatModule(tab)
	for i,v in ipairs(tab) do
		table.insert(jhud.options.cheaterModules, v)
	end
end

dofile 'johnhud/jhopts.lua'--REP
dofile 'johnhud/jhbinds.lua'--REP
dofile 'johnhud/cfg.lua'--REP

jhud.cheating = jhud.options.cheat
if jhud.cheating then
	jhud.addModule(jhud.options.cheaterModules)
end
--S
for i,v in ipairs(jhud.options.modules) do
	if v and not jhud.options.disabledModules[v] then
		jhud[v] = {config = jhud.options.m[v]}
		this = jhud[v]
		dofile(string.format('johnhud/modules/%s.lua', v))
	end
end
--E
this = nil
for i,v in pairs(jhud.options.modules) do
	if jhud[v].__init then
		local suc, err = pcall(jhud[v].__init, jhud[v])
		if err then jhud.log(err) end
	end
end
jhud.lang = L:new("_")
if jhud.chat and jhud.options.m._.showload then
	jhud.chat(jhud.lang("start"))
	if jhud.cheating then
		jhud.chat(jhud.lang("cheater"))
	end
end
jhud.hook("AchievementManager", "award_steam", function()
	if jhud.cheating then return true end
end)
jhud.hook("GameStateMachine", "update", function(GSMOBJ, t, dt)
	jhud.whisper = managers.groupai and managers.groupai:state().whisper_mode and managers.groupai:state():whisper_mode()
	for i,v in pairs(jhud) do
		if type(v) == "table" then
			if v.__update then
				local suc, err = pcall(v.__update, v, t, dt)
				if not suc then jhud.log(err) end
			end
			if v.__igupdate and managers.groupai then
				local suc, err = pcall(v.__igupdate, v, t, dt)
				if not suc then jhud.log(err) end
			end
		end
	end
end)
