function this:__init()
    self:hookBonuses()
end
function this:hookBonuses()
    jhud.hook("HUDStageEndScreen", "stage_init", function(forward, ret)
        self.y = nil
        self:doHook(unpack(forward))
    end, jhud.hook.POSTHOOK)
    jhud.hook("HUDStageEndScreen", "stage_spin_levels", function()
        self:hideBonus()
    end)
end
function this:doHook(hses, t, dt)
    local data = hses._data
    local panel = hses._lp_forepanel
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
        title = managers.localization:to_upper_text("menu_es_ghost_bonus").." "..(math.floor(100*(jhud.undigest(managers.job._global.active_ghost_bonus) or "0"))).."%"
    }
    bonuses_params.heat_xp = {
        color = heat_color,
        title = managers.localization:to_upper_text(heat >= 0 and "menu_es_heat_bonus" or "menu_es_heat_reduction")
    }
    --END COPY--
    local total = 0
    for i, func_name in ipairs(bonuses_list) do
        local bonus = data.bonuses[func_name] or 0
        if bonus ~= 0 then
            self:parse({
                color = bonuses_params[func_name] and bonuses_params[func_name].color or Color.purple,
                title = bonuses_params[func_name] and bonuses_params[func_name].title or "ERR: " .. func_name,
                bonus = bonus
            }, panel)
            total = total + bonus
        end
    end
    self:parse({
        color = Color("ffffff"),
        title = "TOTAL BONUS",
        bonus = total,
    }, panel)
    --static gained xp does not calculate until after everything is displayed
    --self:parse({
        --color = Color("ffffff"),
        --title = "TOTAL GAINED",
        --bonus = hses._static_gained_xp or 0,
    --}, panel)
end
function this:parse(bonus_params, panel)
    if self.config.chat then
        self:chatBonus(bonus_params)
    end
    if self.config.draw then
        self:drawBonus(bonus_params, panel)
    end
end
function this:chatBonus(params)
    jhud.chat(params.title, params.bonus, params.color, "icon_buy")
end
function this:drawBonus(param, panel)
    local strbonus = managers.money:add_decimal_marks_to_string(tostring(param.bonus)) or param.bonus
    if not self.y then
        local sumpanel = panel:child("sum_text")
        self.y = sumpanel:bottom() - sumpanel:h()*6
        self.delta = sumpanel:h()
        self.lrspace = sumpanel:h() --this is a horizontal offset
        self.x = sumpanel:right()
    end
    local title = panel:text{
        name = "jhud_bonus_title_"..param.title,
        text = param.title,
        font = tweak_data.menu.pd2_small_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        align = "right",
        alpha = 1,
        color = param.color
    }
    local bonus = panel:text{
        name = "jhud_bonus_bonus_"..param.bonus,
        text = strbonus,
        font = tweak_data.menu.pd2_small_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        align = "left",
        alpha = 1,
        color = param.color
    }
    self.y = self.y + self.delta

    title:set_right(self.x - self.lrspace)
    title:set_top(self.y)
    title:set_visible(true)

    bonus:set_left(self.x)
    bonus:set_top(self.y)
    bonus:set_visible(true)

    if not self.bonusPanels then
        self.bonusPanels = self.bonusPanels or {}
        setmetatable(self.bonusPanels, {__mode = "v"}) --see self:hideBonus
    end
    table.insert(self.bonusPanels, title)
    table.insert(self.bonusPanels, bonus)
end
function this:hideBonus()
    --I dont know how do deal with the garbage collection of these panels
    --so i'm relying on the parent panel to do it, and these will get deallocated
    --beacuse bonusPanels has __mode v
    for i,v in pairs(self.bonusPanels or {}) do
        if v.set_visible then
            v:set_visible(false)
        end
    end
    self.bonusPanels = {}
end
