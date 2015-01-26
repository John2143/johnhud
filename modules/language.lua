require("johnhud/language/"..jhud.options.language..".lua")
this._ = LOADLANGUAGE()
this.isEN = jhud.options.language == "EN"
if not this.isEN then
	require("johnhud/language/EN.lua")
	this._ENG = LOADLANGUAGE()
end
LOADLANGUAGE = nil

jhud.log(jhud.options.language.." loaded.")

setmetatable(this,{
	__call = function(_, ...)
		local forward = {...}
		for i,v in pairs(forward) do
			forward[i] = tostring(v)
		end
		return _:_key(forward)
	end,
})


function this:_key(key, default)
	local tab = default and self._ENG or self._
	for table_key, t in ipairs(key) do
		local b = tab[t]
		if not b then break end
		if type(b) == "table" then
			tab = b
		else
			return b
		end
	end
	if self.isEN or default then
		--jhud.dlog("No translation for "..table.concat(key,"->"))
		return self._._.trans_error
	else
		return self:_key(key, true)
	end
end
function this:affix(str, chars)
	if not str then return self._._.affix_error end
	chars = chars or "[]"
	local char1 = chars:sub(1,1)
	local char2 = chars:sub(2,2)
	if not char2 then char2 = char1 end
	return char1..str..char2
end
function this:new(...)
	local baseargs = {...}
	local tab = {}
	setmetatable(tab,{
		__index = self,
		__call = function(_, ...)
			local args = {}
			for i,v in pairs(baseargs) do
				table.insert(args,v)
			end
			--TODO implement table.merge to cut out the unnecessarily copied for loop
			for i,v in pairs{...} do
				table.insert(args,v)
			end
			return _:_key(args)
		end
	})
	return tab
end

L = jhud.language

