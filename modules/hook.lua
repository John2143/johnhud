--TODO add hooks to a table, if table doesnt exist then insert function wrapper that calls every function in the table, if the table does exist then just insert the function
--This may or may not be slower, however it would add the ability to add a jhud.hook:call function
setmetatable(this,{
	__call = function(_, iclass, ifunc, callback)
		jhud.dlog("Hooking "..iclass..":"..ifunc)
		if not(_G[iclass] and _G[iclass][ifunc]) then
			jhud.dlog("Global variable not avaiable")
			return false
		end
		local oldfunc = _G[iclass][ifunc]
		_G[iclass][ifunc] = function(...)
			local success, res = pcall(callback, ...)
			if success then
				if not res then
					oldfunc(...)
				elseif type(res) == "table" then
					local tab = {...}
					for i,v in ipairs(res) do
						tab[i] = v
					end
					oldfunc(unpack(tab[i]))
				end
			else
				jhud.log("ERROR: ", res)
				oldfunc(...)
			end
		end
		return true
	end
})
