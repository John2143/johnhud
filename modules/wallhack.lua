function this:mark_enemies(doit)
	if doit then
		self.units = {}
		setmetatable(self.units, {__mode = "v"})

		local units = World:find_units_quick("all", 3, 16, 21, managers.slot:get_mask("enemies"))
		for i,v in ipairs(units) do
			table.insert(self.units, v)
		end
	end
	for i,v in pairs(self.units) do
		if v then
			self:applyContour(v, doit)
		end
	end
end

function this:applyContour(unit, add)
	local name = unit:base()._tweak_table
	local func = add and "add" or "remove"
	local cont = unit:contour()
	cont[func](cont, self.contours[name] and "jhudwh_"..name or "jhudwh__def")
end
this.contours = {
	_def = {
		color = Vector3(1,1,1),
	},
	taser = {
		color = Vector3(0, .4, .7)
	},
	shield = {
		color = Vector3(1, .5, 0)
	},
	tank = {
		color = Vector3(1, 1, 0)
	},
	sniper = {
		color = Vector3(1, .3, .3)
	},
	security = {
		color = Vector3(1, 0, .2)
	},
}

this._markingToggle = false
function this:__init()
	if not rawget(_G, "ContourExt") then return end
	for i,v in pairs(self.contours) do
		if not v.color then v.color = Vector3(1,1,1) end
		if not v.material_swap_required then v.material_swap_required = true end
		if not v.priority then v.priority = 1 end
		ContourExt._types["jhudwh_"..i] = v
	end
	jhud.bind(jhud.binds.cheats.wallhack, function()
		self._markingToggle = not self._markingToggle
		self:mark_enemies(self._markingToggle)
		jhud.log("WH: "..(self._markingToggle and "on" or "off"))
	end)
end
jhud.cheating = true
