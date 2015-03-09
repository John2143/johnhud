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
