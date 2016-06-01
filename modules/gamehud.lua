function this:__init()
    if not managers.hud then return end
    self.data = {}
end

function this:__igupdate()
do return end
    local units = {}
    for i,v in ipairs(managers.criminals._characters) do
        if v.peer_id then
            units[i] = v.unit
        end
    end
    for i,v in pairs(managers.hud._teammate_panels) do
        if units[i] then
            self:show(i)
            local p = v._panel:children()[1] --player panel
            local h, a --health and armor
            local dat = self.data[i]

            if not dat then
                h = p:text{
                    name = "hp"..i,
                    text = "hp",
                    font = tweak_data.menu.pd2_medium_font,
                    font_size = 20
                }
                a = p:text{
                    name = "ar"..i,
                    text = "ar",
                    font = tweak_data.menu.pd2_medium_font,
                    font_size = 20
                }
                h:set_top(5)
                a:set_top(5)

                a:set_left(50)

                h:set_color(self.config.hpcolor or Color('ffaaaa'))
                a:set_color(self.config.arcolor or Color('aaaaff'))

                jhud.log("CREATEDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"..i)

                self.data[i] = {h = h, a = a}
                dat = self.data[i]
            else
                a = dat.a
                h = dat.h
            end
            local dam = units[i]:character_damage()
            if not dam then return end---------------------------------------------------------
            if dam:arrested() and not self.data[i].hidden then
                self:hide(i)
            else
                if p then
                    if dat.lastArmor ~= dam._armor then
                        a:set_text(("%.1f"):format(dam:get_real_armor()))
                    end
                    if dat.lastHP ~= dam._health then
                        h:set_text(("%.1f"):format(dam:get_real_health()))
                    end
                    --TODO bleedout
                else
                    self:hide(i)
                end
            end
        else
            self:hide(i)
        end
    end
end
function this:hide(i)
    if self.data[i] then
        if not self.data[i].hidden then
            self.data[i].a:hide()
            self.data[i].h:hide()
            self.data[i].hidden = true
        end
    end
end
function this:show(i)
    if self.data[i] then
        if self.data[i].hiddden then
            self.data[i].a:set_visible(true)
            self.data[i].h:set_visible(true)
            self.data[i].hidden = false
        end
    end
end
