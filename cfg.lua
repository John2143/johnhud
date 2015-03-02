--This file is for config options
--Please read jhopts.lua for all the available config options
--Overwriting an option is available however you want, however, an example is
--  provided below for overriding an option
--[[
	EXAMPLES:
	o.m.assault.color.anticipation = Color('FF0000')
	o.m._.showload = false
]]--
local o = jhud.options


o.language = "EN"
o.disabledModules = {
	suspct	= false,
	chat    = false,
	voice   = false,
}

o.cheat = false --Enable cheater modules
if o.cheat then
	b.cheats.wallhack = "num 1"
end

jhud.addModule{ --Add module names here in a comma seperated list

}
jhud.addCheatModule{

}


--Binds can be found in binds.txt
local chains, dallas, wolf, hoxton, clover, houston, wick, dragan =	"b", "a", "c", "d", "n", "l", "m", ""

jhud.binds = {
	voice = {
		n = "f36x_any",
		l = "s07x_sin",
	},
	bainlines = {
		k = "ban_q01"..wolf,
	},
}
