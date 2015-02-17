--This file is for config options
--Please read jhopts.lua for all the available config options
--Overwriting an option is available however you want, however, an example is
--  provided below for overriding an option
--[[
	EXAMPLES:
	o.m.assault.color.anticipation = Color('FF0000')
	o.m._.showload = false

	EXAMPLE VOICE BIND:
    b.voice[3][1] = "k"
               ^this must always be 1
            ^this is the command number from jhbinds(the number in brackets)
         ^this is what you want to bind

]]--
local o = jhud.options
local b = jhud.binds


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


jhud.options = o --DO NOT REMOVE THIS LINE
