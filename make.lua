os.execute("echo disabled until some other time")
do return end

jhud = jhud or {}
Color = Color or function() end
dofile 'cfg.lua'
dofile 'jhopts.lua'
setmetatable(jhud.options,{
	__index = jhud.defOptions
})
local function readFile(f)
	local fil = io.open(f, "r")
	local s = fil:read("*all")
	fil:close()
	return s
end
local fl = readFile("main.lua")

local fstart = "\ndo --MODULE MN\njhud.MN = {config = jhud.options.m.MN}\nlocal this = jhud.MN"
local fend = "\nend\n"
local mods = {}
for i,v in pairs(jhud.options.modules) do
	if v and not jhud.options.disabledModules[v] then
		table.insert(mods, (string.gsub(fstart, "MN", v)))
		table.insert(mods, readFile("modules/"..v..".lua"))
		table.insert(mods, fend)
	end
end
fl = string.gsub(fl, "%-%-S[%s%S]*%-%-E", table.concat(mods, "\n"))
fl = string.gsub(fl, "dofile[%s%(]?[\"']johnhud/(.-)[\"'][%s%)]*%-%-REP", function(filename)
	return table.concat({
		"do --DOFILE REP "..filename,
		readFile(filename),
		"end",
	}, "\n")
end)
local outfile = os.tmpname():sub(2)
print(outfile)
do
	local ftemp = io.open(outfile, "w")
	ftemp:write(fl)
	ftemp:close()
end

os.execute("luac "..outfile)
os.execute "mv luac.out jhud.luac"
os.execute("del "..outfile)
