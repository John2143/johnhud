jhud = jhud or {}
(jhud.log or io.write)("JohnHUD started.")

jhud.createPanel = function()
	if not RenderSettings then return end
	jhud.resolution = RenderSettings.resolution
	return Overlay:gui():create_scaled_screen_workspace(jhud.resolution.x, jhud.resolution.y, 0, 0, jhud.resolution.x, jhud.resolution.y):panel({ name = "workspace_panel"})
end
jhud.keyboard = Input:keyboard()

jhud.log = function(...)
	for i,v in pairs{...} do
		io.write(tostring(v).."\t")
	end
	io.write("\n")
end
jhud.dlog = function(...)
	if not jhud.debug then return end
	jhud.log("DEBUG: ",...)
end

dofile 'johnhud/jhopts.lua'
dofile 'johnhud/jhbinds.lua'

for i,v in pairs(jhud.options.modules) do
	if v then 
		-- if jhud[v] then io.write(string.format("=============MODULE %s RELOADED==============\n", v)) end
		jhud[v] = {config = jhud.options.m[v]}
		this = jhud[v]
		dofile(string.format('johnhud/modules/%s.lua', v))
	end
end
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
end

if GameStateMachine then 
	local oldgs = GameStateMachine.update
	function GameStateMachine:update(t, dt)
		oldgs(self, t, dt)
		for i,v in pairs(jhud) do
			if type(v) == "table" and v.__update then 
				-- io.write("update", i)
				local aaas, err = pcall(v.__update, v, t, dt) 
				if err then jhud.log(err) end
			end
		end
	end
end