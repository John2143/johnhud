function this:__init()
	self:hookBonuses()
end
function this:hookBonuses()
	jhud.hook("HUDStageEndScreen", "stage_init", function(forward, ret)
		self:doHook(unpack(forward))
	end, jhud.hook.POSTHOOK)
end
function this:doHook(hses, t, dt)
	local data = hses._data
	--START COPY--
	local heat_xp = hses._bonuses.heat_xp or 0
	local heat = managers.job:last_known_heat() or managers.job:has_active_job() and managers.job:get_job_heat(managers.job:current_job_id()) or 0
	local heat_color = managers.job:get_heat_color(heat)
	local bonuses_list = {
		"bonus_days",
		"bonus_low_level",
		"bonus_risk",
		"bonus_failed",
		"in_custody",
		"bonus_num_players",
		"bonus_skill",
		"bonus_infamy",
		"bonus_gage_assignment",
		"bonus_extra",
		"bonus_ghost",
		"heat_xp"
	}
	local bonuses_params = {}
	bonuses_params.bonus_days = {
		color = tweak_data.screen_colors.text,
		title = managers.localization:to_upper_text("menu_es_day_bonus")
	}
	bonuses_params.bonus_low_level = {
		color = tweak_data.screen_colors.important_1,
		title = managers.localization:to_upper_text("menu_es_alive_low_level_bonus")
	}
	bonuses_params.bonus_risk = {
		color = tweak_data.screen_colors.risk,
		title = managers.localization:to_upper_text("menu_es_risk_bonus")
	}
	bonuses_params.bonus_failed = {
		color = tweak_data.screen_colors.important_1,
		title = managers.localization:to_upper_text("menu_es_alive_failed_bonus")
	}
	bonuses_params.in_custody = {
		color = tweak_data.screen_colors.important_1,
		title = managers.localization:to_upper_text("menu_es_in_custody_reduction")
	}
	bonuses_params.bonus_num_players = {
		color = tweak_data.screen_colors.risk,
		title = managers.localization:to_upper_text("menu_es_alive_players_bonus")
	}
	bonuses_params.bonus_skill = {
		color = tweak_data.screen_colors.button_stage_2,
		title = managers.localization:to_upper_text("menu_es_skill_bonus")
	}
	bonuses_params.bonus_infamy = {
		color = tweak_data.lootdrop.global_values.infamy.color,
		title = managers.localization:to_upper_text("menu_es_infamy_bonus")
	}
	bonuses_params.bonus_gage_assignment = {
		color = tweak_data.screen_colors.button_stage_2,
		title = managers.localization:to_upper_text("menu_es_gage_assignment_bonus")
	}
	bonuses_params.bonus_extra = {
		color = tweak_data.screen_colors.button_stage_2,
		title = managers.localization:to_upper_text("menu_es_extra_bonus")
	}
	bonuses_params.bonus_ghost = {
		color = tweak_data.screen_colors.ghost_color,
		title = managers.localization:to_upper_text("menu_es_ghost_bonus").." "..(jhud.undigest(managers.job._global.saved_ghost_bonus) or "0").."%"
	}
	bonuses_params.heat_xp = {
		color = heat_color,
		title = managers.localization:to_upper_text(heat >= 0 and "menu_es_heat_bonus" or "menu_es_heat_reduction")
	}
	--END COPY--
	for i, func_name in ipairs(bonuses_list) do
		local bonus = data.bonuses[func_name] or 0
		if bonus ~= 0 then
			local bonus_params = {}
			bonus_params.color = bonuses_params[func_name] and bonuses_params[func_name].color or Color.purple
			bonus_params.title = bonuses_params[func_name] and bonuses_params[func_name].title or "ERR: " .. func_name
			bonus_params.bonus = managers.money:add_decimal_marks_to_string(bonus) or bonus
			if self.config.chat then
				self:chatBonus(bonus_params)
			end
			if self.config.draw then
				self:drawBonus(bonus_params)
			end
		end
	end
end
function this:chatBonus(params)
	jhud.chat(params.title, params.bonus, params.color, "icon_buy")
end
function this:drawBonus(param)
	if not self.y then
		--TODO
	end
end
