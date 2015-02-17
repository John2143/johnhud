jhud = jhud or {}
jhud.debug = true
jhud.log = function(...)
	for i,v in pairs{...} do
		io.write(tostring(v).."\t")
	end
	io.write("\n")
end
jhud.log("JohnHUD started.")

jhud.createPanel = function()
	if not RenderSettings then return end
	jhud.resolution = RenderSettings.resolution
	return Overlay:gui():create_scaled_screen_workspace(jhud.resolution.x, jhud.resolution.y, 0, 0, jhud.resolution.x, jhud.resolution.y):panel({ name = "workspace_panel"})
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
