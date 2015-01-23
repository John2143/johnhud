--This file is for config options
--Please read jhopts.lua for all the available config options
--Overwriting an option is available however you want, however, an example is
--  provided below for overriding an option
--[[
	EXAMPLES:
	o.m.assault.color.anticipation = Color('FF0000')
	o.m._.showload = false

]]--
local o = {} --DO NOT REMOVE THIS LINE
o.language = "EN"
o.disabledModules = {
	suspct	= false,
	bind    = false,
	assault = false,
	chat    = false,
	voice   = false,
}


jhud.options = o --DO NOT REMOVE THIS LINE
