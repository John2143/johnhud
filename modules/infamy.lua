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
	for i,v in pairs(managers.skilltree._global.skills) do
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
	jhud.save("skilltreedata/"..name, skilldata)
	self:initSkillTree(name, skilldata)

	table.insert(self.skilltrees, name)
	jhud.save("skilltrees", self.skilltrees)
end
function this:removeSkillTree(name)
	local sw = managers.skilltree._global.skill_switches
	for i,v in pairs(sw) do
		if i > self.lastRealTree then
			sw[i] = nil
		end
	end
	table.delete(self.skilltrees, name)
	jhud.save("skilltrees", self.skilltrees)

	self:doInitSkilltrees()
end
function this:initSkillTree(name, data)
	local skilldata = data or jhud.load("skilltreedata/"..name)

	managers.skilltree._global.skill_switches[self.nextskilltree] = skilldata
	self.nextskilltree = self.nextskilltree + 1
end
function this:doInitSkilltrees()
	for i,v in ipairs(self.skilltrees) do
		self:initSkillTree(i)
	end
end
function this:__init()
	self.lastRealTree = #managers.skilltree._global.skill_switches
	self.nextskilltree = self.lastRealTree + 1 --the next skilltree

	self.skilltrees = jhud.load('skilltrees')
	self:doInitSkilltrees()
end
