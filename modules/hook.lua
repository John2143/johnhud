setmetatable(this,{
	__call = function(_, iclass, ifunc, callback)
		return _:addFunctionHook(iclass, ifunc, callback)
	end
})

function this:addLocalHook(fname, lname, func)
	self.lhooks[fname] = self.lhooks[fname] or {}
	self.lhooks[fname][lname] = func
	return true
end
function this:removeLocalHook(fname, lname)
	if not self.lhooks[fname] then return end
	self.lhooks[fname][lname] = nil
end
function this:callSpecific(fname, lname, ...)
	if not (self.lhooks[fname] and self.lhooks[fname][lname]) then return end
	return self.lhooks[fname][lname](...)
end
function this:call(fname, ...)
	if not self.lhooks[fname] then return end
	local ret = {}
	for i,v in pairs(self.lhooks[fname]) do
		ret[i] = v(...)
	end
	return ret
end
function this:restore(iclass, ifunc)
	_G[iclass][ifunc] = self.func[iclass][ifunc]
	self.fhooks[iclass][ifunc] = nil
end
function this:addFunctionHook(iclass, ifunc, callback)
	jhud.dlog("Hooking "..iclass..":"..ifunc)
	if not(rawget(_G, iclass) and _G[iclass][ifunc]) then
		jhud.dlog(">> Global variable not avaiable")
		return false
	end
	self.fhooks[iclass] = self.fhooks[iclass] or {}
	self.func[iclass] = self.func[iclass] or {}
	if not self.fhooks[iclass][ifunc] then
		self.fhooks[iclass][ifunc] = {}
		self.func[iclass][ifunc] = _G[iclass][ifunc]
		_G[iclass][ifunc] = function(...) --TODO make this into a function that doesnt need to be rewritten for every function
			local cancelFunc = false;
			local forward = {...}
			for i, callback in pairs(self.fhooks[iclass][ifunc]) do
				local success, res = pcall(callback, ...) --should mabye use forward here
				if success then
					if res then
						if type(res) == "table" then
							for i,v in pairs(res) do
								forward[i] = v
							end
						elseif res == true then
							cancelFunc = true
						end
					end
				else
					jhud.log("ERROR: ", res)
				end
			end
			if not cancelFunc then self.func[iclass][ifunc](unpack(forward)) end
		end
	end
	table.insert(self.fhooks[iclass][ifunc], callback)
	return true
end
function this:__init()
	self.fhooks = {}
	self.lhooks = {}
	self.func = {}
end
