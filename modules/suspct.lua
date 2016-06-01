local function pct(n)
    return math.floor(n*100)
end
function this:getSuspicion(sus, usr)
    if not sus then return 1 end
    if usr then
        for i,v in pairs(sus) do
            if v.u_suspect == usr then
                return v.status
            end
        end
    else
        local most = 0
        for k,x in pairs(sus) do
            most = math.max(most,x.status)
        end
        return most
    end
end
local lastWhisper = true
local textheight = 30
local lastSuspicion = {}
function this:__update(t, dt)
    if not (managers and managers.groupai and managers.groupai:state()) then return end
    --This relies on the fact that you can
    --never return to whisper after leaving
    if not lastWhisper then return end
    self.shd = self.shd or managers.groupai:state()._suspicion_hud_data
    if not self.shd then return end

    if not self.panel then
        local h = self.config.num*textheight
        jhud.dlog("No panels")
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
    if self.textpanels then
        if lastWhisper ~= jhud.whisper then
            lastWhisper = jhud.whisper
            for i,v in pairs(self.textpanels) do
                v:set_visible(jhud.whisper)
            end
            if not jhud.whisper then return end
        end 
        local suspicionAmount = {}
        local osu = self.config.onlyshowyou
        for i,v in pairs(self.shd) do
            local sus = self:getSuspicion(v.suspects, osu and jhud.localPlayer())
            if sus == 1 and not self.times[i] and not osu then
                self.times[i] = t
            end
            if sus ~= 1 or self.times[i] and t < self.times[i] + self.config.show100for then
                table.insert(suspicionAmount, sus)
            end
        end
        for i = 1, 5 do
            if suspicionAmount[i] then
                self.textpanels[i]:set_text(pct(suspicionAmount[i]).."%")
                self.textpanels[i]:set_color(math.lerp(
                    Color(0, .8, .8),
                    Color(.8, .2, 0),
                    suspicionAmount[i]
                ))
                self.textpanels[i]:set_visible(true)
            else
                self.textpanels[i]:set_visible(false)
            end
        end
    end
end

function this:__init()
    self.times = {}
end
