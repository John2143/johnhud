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
		managers.money:get_preplanning_type_cost(plan),
		managers.preplanning:get_type_budget_cost(plan)
end

function this:getFavors(used)
	local budget = {managers.preplanning:get_current_budget()}
	return used and budget[2] - budget[1] or budget[2]
end

function this:parsePlan(selfonly)
	local preplan = {votes = {cost = 0, favors = 0}, other = {cost = 0, favors = 0}}

	local function addCost(tab, plan)
		local money, favors = self:getPlanCost(plan)
		tab.cost = tab.cost + money
		tab.favors = tab.favors + favors
	end


	for i,v in pairs(managers.preplanning:get_current_majority_votes() or {}) do
		local plan
		if selfonly then
			plan = self:getCurrentPlan(i)
		else
			plan = v
		end
		addCost(preplan.votes, plan[1])
		table.insert(preplan.votes, {name = plan[1], value = plan[2]})
	end

	local localid = jhud.net:getPeerID()
	for i,v in pairs(managers.preplanning._reserved_mission_elements) do
		if not selfonly or v.peer_id == localid then
			table.insert(preplan.other, {
				name = v.pack[1],
				value = v.pack[2],
				script = i,
			})
			addCost(preplan.other, v.pack[1])
		end
	end
	return preplan
end

function this:enactPlan(plan, voteonly, otheronly)
	if self:getFavors() < (plan.other.favors + plan.vote.favors) then return "verytoocostly" end
	if self:getFavors(true) < (plan.other.favors + plan.vote.favors) then return "toocostly" end
	for i,v in ipairs(plan.other) do
		managers.preplanning:reserve_mission_element(v.name, v.script)
	end
	for i,v in ipairs(plan.votes) do
		managers.preplanning:vote_on_plan(v.name, 104306) --TODO
	end
end

function this:__init()
	if not (managers.preplanning and jhud.chat) then return end
	self.savedPlans = self.savedPlans or {}
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
		self.savedPlans[name] = plan
	end)
	jhud.chat:addCommand("prex", function(chat, ...)
		local name, voteonly, otheronly
		for i,v in pairs{...} do
			if v == "-v" or v == "--vote-only" then
				voteonly = true
			elseif v == "-o" or v == "--other-only" then
				otheronly = true
			else
				name = v
			end
		end
		if name then
			self:enactPlan(self.savedPlans[name], voteonly, otheronly)
		else
			for i,v in pairs(self.savedPlans) do
				chat(i)
			end
		end
	end)
end
