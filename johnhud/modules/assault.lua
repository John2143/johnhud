jhud.wmod("chat")


local cautda = {[0] = "stealth", "caution", "danger", "compromised"}

function this:getHeistStatus()
	if not jhud.net:isServer() then return end
	if managers.groupai and managers.groupai:state() then
		local assault = managers.groupai:state()._task_data.assault
		if assault.phase then
			jhud.assault.assaultWaveOccurred = true
			return assault.phase
		else
			if jhud.whisper then
				local state = 0
				local function max(x)
					state = math.max(state, x)
				end
				if self.uncool > 0 then max(self.config.danger.uncool) end
				if self.uncoolstanding > 0 then max(self.config.danger.uncoolstanding) end
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
local lastUncool
local lastUncoolStanding
local doUpdate = true
function this:updateTag(t, dt)
	self.heistStatus = self:getHeistStatus() or self.heistStatus
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
				-- core/fonts/nice_editor_font core/fonts/system_font core/fonts/diesel fonts/font_univers_530_bold fonts/font_fortress_22
				font = "fonts/font_univers_530_bold",
				font_size = 28 + self.config.stealthind.text_size,
			}
		end
		if jhud.net:isServer() then
			if lastUncoolStanding ~= self.uncoolstanding then
				lastUncoolStanding = self.uncoolstanding
				jhud.net:send("jhud.assault.standing", self.uncoolstanding)
			end
			if (self.heistStatus ~= lastStatus) then
				lastStatus = self.heistStatus
				jhud.net:send("jhud.assault.heistStatus", self.heistStatus)
			end
			self.textpanel:set_visible(true)
		end
		if doUpdate then self:updateTagText() end
		doUpdate = false
		self.textpanel:set_visible(true)
	end
end
function this:updateTagText()
	if not self.textpanel then return end
	if not (jhud.whisper and
				(self.config.showduring.stealth) or
				(self.config.showduring.assault)
			)
	then
		self.textpanel:set_visible(true)
		return
	end
	local text = self.config.showghost and jhud.whisper and
			(jhud.chat and
				jhud.chat.icons.Ghost or
				"S "
			) or
			("")
	text = text..self.lang(self.heistStatus)
	if self.config.uppercase then
		text = L:affix(text:upper())
	end
	self.textpanel:set_text(text)
	self.textpanel:set_color(self.config.color[self.heistStatus] or Color(1,1,1))
end
function this:updateDangerData(t, dt)
	end



function this:__igupdate(t, dt)
	if not managers then return end
	self:updateDangerData(t, dt)
	self:updateTag(t, dt)
end

function this:__cleanup(carry)
	carry.assaultData = {}
	local c = carry.assaultData
	c.textpanel = self.textpanel
	c.textpanel:text("")
end
function this:__init(carry)
	self.uncool = 0
	--Number of pagers used
	--This number includes the number of pagers that will need to be used
	--ie: pagercop dies during ecm, this number get added to anyway
	local old = carry.assaultData or {}
	self.heistStatus = "none"
	self.lang = L:new("assault")
	jhud.net:hook("jhud.assault.heistStatus", function(data)
		self.heistStatus = data --This does not need to be reset on host
		self:updateTagTextNext()
	end)
end
function this:__addpeer(id)
	if not jhud.net:isServer() then return end
	jhud.net:send("jhud.assault.heistStatus", self.heistStatus)
end
function this:updateTagTextNext()
	doUpdate = true
end
