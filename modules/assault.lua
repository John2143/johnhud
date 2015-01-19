function this:getPagersUsed()
	return managers.groupai and (managers.groupai:state():get_nr_successful_alarm_pager_bluffs()) or -1
end

local cautda = {[0] = "stealth", "caution", "danger"}

function this:getHeistStatus() 
	if not jhud.net:isServer() then return end
	if managers.groupai and managers.groupai:state() then
		local assault = managers.groupai:state()._task_data.assault
		if assault.phase then
			jhud.assault.assaultWaveOccurred = true
			return assault.phase
		else
			if self.whisper then
				local state = 0
				local function max(x)
					state = math.max(state, x)
				end
				if self.pagersActive > 0 then max(self.config.danger.pager) end
				if self.uncool > 0 then max(self.config.danger.uncool) end
				if self.caution > 0 then max(self.config.danger.questioning) end
				return cautda[state]
			elseif jhud.assault.assaultWaveOccurred then
				return "control"
			else
				return "compromised"
			end
		end
	else
		jhud.assault.assaultWaveOccurred = false
		return "none"
	end
end

local lastStatus
local lastCasing = false
local lastCalling
local callingText = L("assault","calling")
function this:updateTag(t, dt)
	self.heistStatus = self:getHeistStatus() or self.heistStatus
	local isCasing = managers.hud and managers.hud._hud_assault_corner._casing
	if self.heistStatus ~= "none" then
		if not self.panel then 
			self.panel = jhud.createPanel()
			self.panel:set_x((jhud.resolution.x - 400)/2 + self.config.stealthind.x)
			self.panel:set_y(80  + self.config.stealthind.y)
			self.panel:set_w(400)
			self.panel:set_h(100)
			self.textpanel = self.panel:text{
				name = "assaultind",
				align = "center",
				font = tweak_data.hud_present.text_font,
				font_size = tweak_data.hud_present.text_size  + self.config.stealthind.text_size,
			}
			self.callpanel = jhud.createPanel()
			self.callpanel:set_x((jhud.resolution.x - 400)/2 + self.config.calling.x)
			self.callpanel:set_y((jhud.resolution.y - 400)/2 + self.config.calling.y)
			self.callpanel:set_w(400)
			self.callpanel:set_h(400)
			self.calltext = self.callpanel:text{
				name = "calling",
				align = "center",
				color = self.config.calling.color,
				font = tweak_data.hud_present.text_font,
				font_size = tweak_data.hud_present.text_size  + self.config.calling.text_size,
			}
		end
		if (self.heistStatus ~= lastStatus) then
			lastStatus = self.heistStatus
			jhud.net:send("jhud.assault.heistStatus", self.heistStatus)
		end
		if lastCasing ~= isCasing then
			lastCasing = isCasing
			self.textpanel:set_visible(not isCasing)
		end
		if lastCalling ~= self.calling then
			lastCalling = self.calling
			jhud.net:send("jhud.assault.calling", self.calling)
		end
	else
		lastStatus = nil
		self.panel = nil
		self.textpanel = nil
		self.callpanel = nil
		self.calltext = nil
	end
end
function this:updateTagText()
	if not self.textpanel then return end
	local text = L("assault", self.heistStatus)
	if self.whisper then
		if self.config.showpagers and self.pagersNR > 0 then 
			text = text.." "..self.pagersNR..(jhud.chat and jhud.chat.icons.Skull or "p") 
		end
		local detection = 0
	end
	if self.config.uppercase then
		text = L:affix(text:upper())
	end
	self.textpanel:set_text(text)
	self.textpanel:set_color(self.config.color[self.heistStatus] or Color(1,1,1))
end
local lastSucessfulPagerNR = 0
function this:updateDangerData(t, dt)
	if not (jhud.net:isServer() and self.pagersActive) then return end
	self.pagersUsed = self:getPagersUsed()
	if self.pagersUsed ~= lastSucessfulPagerNR then
		lastSucessfulPagerNR = self.pagersUsed
		self.pagersActive = self.pagersActive - 1
	end
	self.uncool = 0
	self.caution = 0
	self.calling = 0
	if managers.groupai and managers.groupai:state() and managers.groupai:state()._suspicion_hud_data then
		for i,v in pairs(managers.groupai:state()._suspicion_hud_data) do
			if v.alerted then
				self.uncool = self.uncool + 1
			else
				self.caution = self.caution + 1
			end
			if v.status == "calling" then
				local f = false
				for i,v in pairs(managers.groupai:state()._ecm_jammers) do f = true end
				if f then self.calling = self.calling + 1 end
				--for some reason #managers.groupai:state()._ecm_jammers == 0
			end
		end
	end
end


function this:__update(t, dt)
	if not managers then return end
	self.whisper = managers.groupai and managers.groupai:state().whisper_mode and managers.groupai:state():whisper_mode()
	self:updateDangerData(t, dt)
	self:updateTag(t, dt)
end

function this:__init()
	-- jhud.debug = true
	--Number of pagers used
	--This number includes the number of pagers that will need to be used
	--ie: pagercop dies during ecm, this number get added to anyway
	self.pagersNR = 0
	if jhud.net:isServer() then
		self.pagersActive = 0 --Number of pagers that are being answered or need to be answered
		self.deadCopsWithPagers = {}
		local _self = self
		if _G.CopBrain then
			jhud.hook("CopBrain", "begin_alarm_pager", function(self, reset)
				local has = false
				for i,v in pairs(_self.deadCopsWithPagers) do
					if v == self then
						has = true
						break
					end
				end
				if not has then
					table.insert(_self.deadCopsWithPagers, self)
					jhud.dlog("pagercop died and will pager")
					_self.pagersActive = _self.pagersActive + 1
					jhud.net:send("jhud.assault.pagersNR", _self.pagersNR + 1)
				end
			end)
		end
	end
	jhud.net:hook("jhud.assault.heistStatus", function(data)
		self.heistStatus = data
		self:updateTagText()
	end)
	jhud.net:hook("jhud.assault.pagersNR", function(data)
		self.pagersNR = data
		self:updateTagText()
	end)
	jhud.net:hook("jhud.assault.calling", function(data)
		self.calltext:set_visible(data > 0)
		self.calltext:set_text(callingText)
	end)
end