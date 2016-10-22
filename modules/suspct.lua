jhud.wmod("net")
jhud.rmod("assault") -- only for jhud.whisper
jhud.rlib("file") --only if net

local function pct(n)
    return math.floor(n*100)
end

function this:createCriminalTable()
    local tab = {}
    for x, k in pairs(managers.criminals._characters) do
        if k.peer_id and k.peer_id > 0 then
            tab[k.peer_id] = {[-1] = 0}
        end
    end
    return tab
end

function this:normalSHD()
    local pcts = self:createCriminalTable()
    for i,v in pairs(self.shd) do
        for ii,vv in pairs(v.suspects or {}) do
            for x, k in pairs(managers.criminals._characters) do
                if(vv.u_suspect == k.unit) then
                    table.insert(pcts[k.peer_id], vv.status)
                end
            end
        end
    end
    return pcts
end

function this:doPanel(panel, suspicion, alwaysVisible)
    if suspicion or alwaysVisible then
        suspicion = suspicion or 0
        panel:set_text(pct(suspicion).."%")
        panel:set_color(math.lerp(
            Color(0, .8, .8),
            Color(.8, .2, 0),
            suspicion
        ))
        panel:set_visible(true)
    else
        panel:set_visible(false)
    end
end

function this:whisperDo(t, dt)
    if jhud.net:isServer() then
        self.shd = self.shd or managers.groupai:state()._suspicion_hud_data
        self:networkAmounts(self:normalSHD(), self.diffT, t)
    end

    local suspicionAmount = self.amounts[jhud.net:getPeerID()] or {}
    for i = 1, self.config.num do
        local v = suspicionAmount[i]
        self:doPanel(self.textpanels[i], v)
    end

    if self.config.showDetection then
        for i = 1, 4 do
            if self.amounts[i] and self.HUDPanels[i] then
                local max = 0
                for x, k in ipairs(self.amounts[i]) do
                    if k > max then max = k end
                end
                self:doPanel(self.HUDPanels[i].c, max, true)
            end
        end
    end
end

function this:associateUnitsWithIDs()
    local update = false
    if self.units then
        for i,v in ipairs(managers.criminals._characters) do
            if v.peer_id and v.peer_id > 0 then
                if not(v.unit and v.unit.character_damage) then
                    --TODO figure out the real reason for the crash
                    update = false
                    break
                elseif self.units[v.peer_id] ~= v.unit:character_damage() then
                    update = true
                end
            end
        end
    else update = true end

    if not update then return end

    jhud.log("refreshing units")
    self.units = {}
    for i = 1, 4 do
        for k,v in ipairs(managers.criminals._characters) do
            if v.peer_id == i then
                jhud.log(k, v)
                self.units[i] = v.unit:character_damage()
                jhud.pt(v)
            end
        end
    end
    jhud.pt(self.units)

    --jhud.pt(self.units, 2)
    --Associate the units with HUD IDs too
    self:createHUDPanels()
end

function this:networkAmounts(newAmounts, rateLimit, t)
    local oldAmounts = self.amounts
    self.amounts = newAmounts
    local update = false
    for i,v in ipairs(oldAmounts) do
        for x,k in pairs(v) do
            if not self.amounts[i] or self.amounts[i][x] ~= k then
                update = true
            end
        end
    end
    if jhud.net and update and rateLimit and (self.lastUpdateT + rateLimit) < t then
        jhud.net("jhud.suspct.amounts", jhud.serialize(self.amounts), true)
        self.lastUpdateT = t
    end
end

local function fmt(num)
    return ("%.0f"):format(num)
end

local function floatEqual(a, b)
    return math.abs(a - b) < .001
end

function this:loudDo(t, dt)
    if self.config.showHP then
		local amounts = {}
		for i,v in pairs(self.units) do
			amounts[i] = {}
			amounts[i].hp       = v:get_real_health() * 10
			amounts[i].armor    = v:get_real_armor()  * 10
			amounts[i].maxArmor = v:_max_armor()      * 10
			amounts[i].maxHP    = v:_max_health()     * 10
		end
		-- jhud.pt(amounts, 100)	

        for i,v in ipairs(self.HUDPanels) do
            local amt = amounts[i]
            if amt then --should always be true
                local hasArmor = --Actually show armor
                    amt.armor > 0 and
                    not floatEqual(amt.armor, amt.maxArmor)
                v.c:set_color(hasArmor and
                    math.lerp(Color("666666"), Color("ffffff"), amt.armor / amt.maxArmor) or
                    math.lerp(Color("aa3333"), Color("00dd33"), amt.hp / amt.maxHP)
                )
                v.c:set_text(floatEqual(amt.hp, 0) and "" or hasArmor and fmt(amt.armor) or fmt(amt.hp))
            end
        end
    end
end

local lastWhisper
local textheight = 30
local lastSuspicion = {}

function this:__igupdate(t, dt)
    if not (managers and managers.groupai and managers.groupai:state()) then return end
    --This relies on the fact that you can
    --never return to whisper after leaving

    if not self.panel then
        self:createPanels()
    end
    local whisp = jhud.whisper
    if lastWhisper ~= whisp then
        lastWhisper = whisp
        for i,v in pairs(self.textpanels) do
            v:set_visible(whisp)
        end
        local showPanels =
            whisp and self.config.showDetection or
            not whisp and self.config.showHP

        for i,v in pairs(self.HUDPanels) do
            v.c:set_visible(showPanels)
        end
        self.amounts = {}
    end

    self:associateUnitsWithIDs()
    if whisp then
        self:whisperDo(t, dt)
    else
        self:loudDo(t, dt)
    end
end

function this:destroyHUDPanel(peer)
    if self.HUDPanels[peer] then
        jhud.log("Destroying panel", peer, self.HUDPanels[peer].p)
        jhud.pt(self.HUDPanels[peer])
        self.HUDPanels[peer].p:set_visible(false)
        self.HUDPanels[peer].c:set_visible(false)

        self.HUDPanels[peer] = nil
    end
end

function this:createHUDPanel(peer)
    self:destroyHUDPanel(peer)

    local panelID
    if jhud.net:getPeerID() == peer then
        panelID = 4
    else
        local d = managers.criminals:character_data_by_peer_id(peer)
        if not d then return end
        panelID = d.panel_id
    end

    if not panelID then return end

    jhud.log("Creating panel for peer ", peer, "id", panelID)

    local panel = managers.hud._teammate_panels[panelID]._panel
    local plpanel = panel:child("player")
    local rhpanel = plpanel:child("radial_health_panel")
    local namepanel = panel:child("name")

    local p = {p = plpanel:panel{name = "suspctparent" .. peer}}
    self.HUDPanels[peer] = p
    local width = 100
    p.p:set_x(rhpanel:w() / 2 + rhpanel:x() - width / 2)
    p.p:set_y(rhpanel:h() / 2 + rhpanel:y() - namepanel:h() / 2)
    p.p:set_w(width)
    p.p:set_h(namepanel:h())
    p.c = p.p:text{
        name = "textsuspct" .. peer,
        align = "center",
        font = tweak_data.hud_present.text_font,
        font_size = namepanel:font_size()
    }
    --p.c:set_text("23")
end

function this:createHUDPanels()
    for i = 1, 4 do
        self:createHUDPanel(i)
    end
end

function this:createPanels()
    self:createHUDPanels()
    local h = self.config.num*textheight
    self.panel = jhud.createPanel()
    self.panel:set_x((jhud.resolution.x - 100)/2)
    self.panel:set_y((jhud.resolution.y - h)/2)
    self.panel:set_w(100)
    self.panel:set_h(h)
    self.textpanels = {}
    for i = 1, self.config.num do
        self.textpanels[i] = self.panel:text{
            name = "detind"..i,
            align = "center",
            font = tweak_data.hud_present.text_font,
            font_size = tweak_data.hud_present.text_size
        }
        self.textpanels[i]:set_y((i-1)*textheight)
    end
end

function this:__cleanup(carry)
    jhud.log("Cleanup called")
    for i = 1, 4 do
        self:destroyHUDPanel(i)
    end
    carry.panel = self.panel
    carry.textpanels = self.textpanels
end

this.TICKRATE = 10

function this:__init(carry)
    self.panel = carry.panel
    self.textpanels = carry.textpanels
    self.HUDPanels = {}
    self.amounts = {}
    self.lastUpdateT = 0
    self.diffT = 1 / self.TICKRATE
    if jhud.net and not jhud.net:isServer() then
        jhud.net:hook("jhud.suspct.amounts", function(data)
            self.amounts = jhud.deserialize(data)
        end)
    end
end
