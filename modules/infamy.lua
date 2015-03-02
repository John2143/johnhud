jhud.rlib("file")
function this:setInfamy(rank)
	if managers and managers.experience then
--its up to you whether or not you use this: you wont receive a CHEATER tag, you won't
-- get banned by ovk, but I'm not going to implment it anywhere as a base feature in johnhud.
--PS you wont receive the actual infamy points or achievements.
--This does permanantly save to your playerfile, so its up to you to keep track.
--Current max infamy: 5
--Current hard coded max: 7
--Hype train hype: 25
		managers.experience._global.rank = jhud.digest(rank)
	end
end
function this:getInfamy()
	return jhud.undigest(managers.experience._global.rank)
end

function this:emptyTree()
	local st = {}
	for i,v in pairs(self.st.skills) do
		st[i] = {
			total = v.total,
			unlocked = 0,
		}
	end
	return st
end

function this:emptySSTree()
	local ss = {}
	local zero = jhud.digest(0)
	for i = 1, 5 do
		ss[i] = {points_spent = zero, unlocked = false}
	end
	return ss
end
function this:emptySwitch()
	return {
		points = jhud.digest(120),
		skills = self:emptyTree(),
		unlocked = true,
		specialization = jhud.digest(6), --idk what this is
		trees = self:emptySSTree(),
	}
end
function this:newSkillTree(name)
	local skilldata = self:emptySwitch()
	name = name or "Unnamed"
	skilldata.name = name
	self:saveTree(name, skilldata, true)
	self:initSkillTree(name, skilldata)

	table.insert(self.skilltrees, name)
	self:saveTrees()
end
function this:removeSkillTree(name)
	table.delete(self.skilltrees, name)
	self:saveTrees()

	self:doInitSkilltrees()
end
function this:saveSkillTree()
	local ss = self.st.selected_skill_switch
	local jhudtree = ss - self.lastRealTree
	if jhudtree < 1 then return end --overkill implemented tree
	local treename = self.skilltrees[jhudtree]

	self:saveTree(treename, ss)
end
function this:initSkillTree(name, data)
	local skilldata = data or self:loadTree(name)

	self.st.skill_switches[self.nextskilltree] = skilldata
	--managers.skilltree:set_skill_switch_name(self.nextskilltree, name:upper())
	self.nextskilltree = self.nextskilltree + 1
end
function this:doInitSkilltrees()
	local sw = self.st.skill_switches
	for i,v in pairs(sw) do
		if i > self.lastRealTree then
			sw[i] = nil
		end
	end
	for i,v in ipairs(self.skilltrees) do
		self:initSkillTree(v)
	end
end
function this:renameSkillTree(id, new)
	local ss = id - self.lastRealTree
	local old = self.skilltrees[ss]
	self.skilltrees[ss] = new

	self:saveTrees()
	self:saveTree(new, id)
end
local path = "skilltree_"
function this:loadTree(name)
	return jhud.load(path..name)
end
function this:saveTree(name, id, notID)
	if notID then
		jhud.save(path..name, id)
	else
		jhud.save(path..name, self.st.skill_switches[id])
	end
end
function this:saveTrees() --recycling helps :)
	jhud.save("skilltrees", self.skilltrees)
end
function this:numTrees()
	return #self.skilltrees
end
function this:createSkilltreeButton()
	local stg = managers.menu_component._skilltree_gui
	local lastpanel = stg._skill_tree_panel:child("switch_skills_button")
	local pan = stg._panel:text{
		name = "jhud_newskilltree",
		text = L("skilltree", "New skill tree"),
		font_size = lastpanel:font_size(),
	}
	pan:set_top(lastpanel:top())
	pan:set_left(lastpanel:left())
end
function this:__init(carry)
	if not managers.skilltree then return end
	self.st = managers.skilltree._global
	self.lastRealTree = 5
	self.nextskilltree = self.lastRealTree + 1 --the next skilltree
	self.skilltrees = jhud.load('skilltrees')
	self:doInitSkilltrees()
	jhud.hook("SkillTreeGui", "_stop_rename_skill_switch", function(stg)
		local id = self.st.selected_skill_switch
		if id > self.lastRealTree then
			self:renameSkillTree(id, stg._renaming_skill_switch)
		end
	end)
	jhud.hook("SkillTreeManager", "save", function(stm, data)
		for i,v in pairs(self.st.skill_switches) do
			if i > self.lastRealTree then
				self:saveTree(self.skilltrees[i - self.lastRealTree], i)
			end
		end
	end)
	--[[ Will implement later
	if managers.menu_component then
		self:createSkilltreeButton()
	else
		jhud.hook("SkillTreeGui", "_setup", function()
			self:createSkilltreeButton()
		end, jhud.hook.POSTHOOK)
	end
	]]
end
