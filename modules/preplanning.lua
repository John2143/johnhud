function this:getCurrentPlan(plan)
	local id = jhud.net:getPeerID()
	local vote = managers.preplanning._players_votes[id]
	local default = managers.preplanning:current_location_data().default_plans

	local defaultplan = {default[plan], 1}

	return vote and vote[plan] or defaultplan
end

function this:getPlanCost(plan)
	if type(plan) == "table" then
		plan = plan[1]
	end
	return
		managers.money:get_preplanning_type_cost(plan), --$
		managers.preplanning:get_type_budget_cost(plan) --favors
end

function this:getFavors(used) --this(true) = amount of favors used, this(false) = amount of favors available in the heist
	local budget = {managers.preplanning:get_current_budget()}
	return used and budget[2] - budget[1] or budget[2]
end

function this:addPlanCost(tab, plan)
	local money, favors = self:getPlanCost(plan)
	tab.cost = tab.cost + money
	tab.favors = tab.favors + favors
end

function this:parsePlan(selfonly)
	local heist = self:currentHeist()
	local preplan = {votes = {cost = 0, favors = 0}, other = {cost = 0, favors = 0}}

	for i,v in pairs(managers.preplanning:get_current_majority_votes() or {}) do
		local plan
		if selfonly then
			plan = self:getCurrentPlan(i)
		else
			plan = v
		end
		self:addPlanCost(preplan.votes, plan[1])
		local vote = {
			name = plan[1],
			value = plan[2]
		}
		vote.script = managers.preplanning._mission_elements_by_type
				[vote.name]
				[vote.value]
				._id

		table.insert(preplan.votes,vote)
	end

	local localid = jhud.net:getPeerID()
	for i,v in pairs(managers.preplanning._reserved_mission_elements) do
		if not selfonly or v.peer_id == localid then
			table.insert(preplan.other, {
				name = v.pack[1],
				value = v.pack[2],
				script = i,
			})
			self:addPlanCost(preplan.other, v.pack[1])
		end
	end
	return preplan
end

function this:enactPlan(plan, dovotes, doother)
	if not plan then return true end
	local favorscost = 0
	if doother then favorscost = favorscost + plan.other.favors end
	if dovotes then favorscost = favorscost + plan.votes.favors end

	if self:getFavors() < favorscost then return "verytoocostly" end
	if self:getFavors(true) < favorscost then return "toocostly" end

	if doother then
		for i,v in ipairs(plan.other) do
			managers.preplanning:reserve_mission_element(v.name, v.script)
		end
	end
	if dovotes then
		for i,v in ipairs(plan.votes) do
			managers.preplanning:vote_on_plan(v.name, v.script)
		end
	end
	return false
end

function this:currentHeist()
	return "bb"
end

function this:savePlan(name, plan)
	local heist = self:currentHeist()
	self.savedPlans[heist] = self.savedPlans[heist] or {}
	self.savedPlans[heist][name] = plan
end

function this:loadPlans()
	self.savedPlans = {}
end

function this:chatPlan(chat, name, v, concise, pre)
	local cashcost, favorcost =
		v.votes.cost + v.other.cost,
		v.votes.favors + v.other.favors
	if not concise then
		chat((pre or "").."PLAN", name, chat.config.spare1)
		chat("  "..self.lang("cost"):format(managers.money._cash_sign or "?"), cashcost, chat.config.spare2, true)
		chat("  "..self.lang("cost"):format(self.lang("favors")), favorcost, chat.config.spare2, true)
		chat("  "..self.lang("num"):format(self.lang("other")), #v.other, chat.config.spare2, true)
	else
		chat((pre or "").."PLAN", name.." <"..cashcost..", "..favorcost.."> "..(#v.other), chat.config.spare1)
	end
end

function this:__init()
	if not (managers.preplanning and jhud.chat) then return end
	self.lang = L:new("preplanning")
	self:loadPlans()
	jhud.chat:addCommand("prsv", function(chat, ...)
		local name, selfonly
		for i,v in pairs{...} do
			if v == "-s" or v == "--self-only" then
				selfonly = true
			else
				name = v
			end
		end
		if not name then return chat.MISSING_ARGUMENTS end
		local plan = self:parsePlan(selfonly)
		self:savePlan(name, plan)
		self:chatPlan(chat, name, plan, false)
	end)
	jhud.chat:addCommand("prex", function(chat, ...)
		local name, printOnly
		local dovotes, doother = true, true
		for i,v in pairs{...} do
			if v == "-v" or v == "--vote-only" then
				doother = false
			elseif v == "-o" or v == "--other-only" then
				dovotes = false
			elseif v == "-p" or v == "--print" then
				printOnly = true
			else
				name = v
			end
		end
		if name then
			local plan = (self.savedPlans[self:currentHeist()] or {})[name]
			if not plan then chat("PLAN", self.lang("notfound"), chat.config.failed) return end
			if printOnly then
				self:chatPlan(chat, name, plan, false, "P")
			else
				self:enactPlan(plan, dovotes, doother)
				self:chatPlan(chat, name, plan, true, "DO")
			end
		else
			for i,v in pairs(self.savedPlans[self:currentHeist()] or {}) do
				self:chatPlan(chat, i, v, true)
			end
		end
	end)
end
