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
	if self.func[iclass][ifunc] then
		jhud.dlog("Restored ", iclass, ifunc)
		_G[iclass][ifunc] = self.func[iclass][ifunc]
		self.fhooks[iclass][ifunc] = nil
	end
end
function this:restoreAll()
	for i,v in pairs(self.fhooks or {}) do
		for k,x in pairs(v) do
			self:restore(i, k)
		end
	end
end

this.PREHOOK = 1
this.POSTHOOK = 2
this.OVERRIDE = 3

function this:addFunctionHook(iclass, ifunc, callback, hooktype)
	hooktype = hooktype or self.PREHOOK
	jhud.dlog("Hooking "..iclass..":"..ifunc.." @ "..hooktype)

	if not(rawget(_G, iclass) and _G[iclass][ifunc]) then
		jhud.dlog(">> Global variable not avaiable")
		return false
	end
	self.fhooks[iclass] = self.fhooks[iclass] or {}
	self.phooks[iclass] = self.phooks[iclass] or {}
	self.func[iclass] = self.func[iclass] or {}

	if hooktype == self.OVERRIDE then
		if not self.func[iclass][ifunc] then
			self.func[iclass][ifunc] = _G[iclass][ifunc]
		end
		_G[iclass][ifunc] = callback
	else
		if not self.func[iclass][ifunc] then
			self.fhooks[iclass][ifunc] = {}
			self.phooks[iclass][ifunc] = {}
			self.func[iclass][ifunc] = _G[iclass][ifunc]
			_G[iclass][ifunc] = function(...) --TODO make this into a function that doesnt need to be rewritten for every function
				local cancelFunc = false;
				local forward = {...}
				for i, callback in pairs(self.fhooks[iclass][ifunc]) do
					local success, res = pcall(callback, unpack(forward))
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
				if not cancelFunc then
					local retvals = {self.func[iclass][ifunc](unpack(forward))}
					for i, callback in pairs(self.phooks[iclass][ifunc]) do
						local success, res = pcall(callback, forward, retvals)
						if success then
							if res then
								if type(res) == "table" then
									for i,v in pairs(res) do
										retvals[i] = v
									end
								end
							end
						else
							jhud.log("PERROR:", res)
						end
					end
					return unpack(retvals)
				end
			end
		end
		if hooktype == self.PREHOOK then
			table.insert(self.fhooks[iclass][ifunc], callback)
		elseif hooktype == self.POSTHOOK then
			table.insert(self.phooks[iclass][ifunc], callback)
		end
	end
	return true
end
function this:__cleanup(carry)
	self:restoreAll()
end
function this:__init(carry)
	self.fhooks = {}
	self.phooks = {}
	self.lhooks = {}
	self.func = {}
end

setmetatable(this,{
	__call = this.addFunctionHook
})
