jhud.wmod("chat")

function this:getPagersUsed()
	return managers.groupai and (managers.groupai:state():get_nr_successful_alarm_pager_bluffs()) or -1
end

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
				if self.pagersActive > 0 then
					max(self.config.danger.pager)
					if self.pagersActive > 4 then
						max(self.config.danger.nopagers)
					end
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

--TODO make these not temporary
local dramaH = 200
local dramaX = 45
local dramaW = 20
local buffer = 5
local dramaY = 0
local markbuffer = 2
local markH = 4
local animtime = 1/3
local const = dramaH/100


local function nonlerpfunc(pct)
	return pct^(2/5)
end
local function reversenlerpfunc(pct)
	return 1-nonlerpfunc(1-pct)
end
local function nlirp(a, d, p, reverse) --a = start, d = delta, p = pct
	return a + d*(reverse and reversenlerpfunc or nonlerpfunc)(p)
end

function this:setDramaSlider(value)
	if not self.dramapanel then return end
	self.dramapanel:set_h(-const*value + 1)
end

function this:createAnim(func, destroy, animtime, startx, endx, reverse)
	local start
	--local startx = start_ -- -dramaW
	--local endx = end_ --dramaX
	local delta = endx - startx

	return function(t, dt) --Should probaby do this by using dt
		start = start or t
		local pct = math.min((t - start)/animtime, 1)
		func(nlirp(startx, delta, pct, reverse))
		if pct == 1 then
			if destroy then destroy(self) end
			return true
		end
	end
end
function this:heistStateTransition()
	jhud.dlog("Transition method called with status"..self.heistStatus)
	local new = self.dramaData[self.heistStatus]
	self:marksOut(function(self)
		jhud.log("destroy called")
		self.dramamarks = nil
		if new then
			self:createMarks(new)
			self:marksIn()
		end
	end)
end

function this:addAnim(anim)
	table.insert(self.anims, anim)
end

function this:dramaIn(tied)
	self:addAnim(self:createAnim(function(x)
		self.dramafluff:set_x(x)
		self.dramapanel:set_x(x + buffer)
	end, tied, animtime, -dramaW, dramaX, false))
end

function this:marksIn(tied)
	if not self.dramamarks then return end
	self:addAnim(self:createAnim(function(x)
		for i,v in pairs(self.dramamarks) do
			v:set_x(x)
		end
	end, tied, animtime, -dramaW, dramaX + markbuffer, false))
end

function this:dramaOut(tied)
	self:addAnim(self:createAnim(function(x)
		self.dramafluff:set_x(x)
		self.dramapanel:set_x(x + buffer)
	end, tied, animtime, dramaX, -dramaW, false))
end

function this:marksOut(tied)
	if not self.dramamarks then
		if tied then tied(self) end
		return
	end
	self:addAnim(self:createAnim(function(x)
		for i,v in pairs(self.dramamarks) do
			v:set_x(x)
		end
	end, tied, animtime, dramaX + markbuffer, -dramaW, false))
end

function this:createMarks(marks)
	for i,v in pairs(self.dramamarks or {}) do
		v:hide() --TODO find if theres a panel:destroy()
	end
	self.dramamarks = {}
	for i,v in ipairs(marks) do
		local mark= jhud.createPanel()
		mark:set_x(-300)
		mark:set_y(dramaY - buffer - const*v.amt + markH/2)
		mark:set_w(dramaW - 2*markbuffer)
		mark:set_h(-(markH + const*(v.len or 0)))
		mark:rect{
			name = "fbg",
			color = v.color:with_alpha(.5),
			layer = -600,
			halign = "scale",
			valign = "scale"
		}
		table.insert(self.dramamarks, mark)
	end
end

local lastStatus
local lastCasing = false
local lastCalling
local callingText = L("assault","calling")
local lastUncool
local lastUncoolStanding
local doUpdate = true
local lastWhisper = true
local lastDrama, lastDiff

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

			dramaY = (jhud.resolution.y)/2 + 25
			self.dramafluff = jhud.createPanel()
			self.dramafluff:set_x(-300)
			self.dramafluff:set_y(dramaY)
			self.dramafluff:set_w(dramaW)
			self.dramafluff:set_h(-dramaH - 2*buffer)
			self.dramafluff:rect{
				name = "fbg",
				color = Color("dfdfdf"):with_alpha(.2),
				layer = -1000,
				halign = "scale",
				valign = "scale"
			}

			self.dramapanel = jhud.createPanel()
			self.dramapanel:set_x(-300)
			self.dramapanel:set_y(dramaY - buffer)
			self.dramapanel:set_w(dramaW - 2*buffer)
			self.dramapanel:rect{
				name = "bg",
				color = Color("ffffff"):with_alpha(.5),
				layer = -800,
				halign = "scale",
				valign = "scale"
			}
			self:setDramaSlider(100)
		end
		if jhud.net:isServer() then
			if lastUncoolStanding ~= self.uncoolstanding then
				lastUncoolStanding = self.uncoolstanding
				jhud.net:send("jhud.assault.standing", self.uncoolstanding)
			end
			if lastUncool ~= self.uncool then
				lastUncool = self.uncool
				jhud.dlog("number of uncool people changed to "..self.uncool)
				jhud.net:send("jhud.assault.uncool", self.uncool)
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
			if lastDrama ~= self.drama then
				lastDrama = self.drama
				jhud.net:send("jhud.assault.drama", self.drama)
			end
			if lastDiff ~= self.diff then
				lastDiff = self.diff
				jhud.net:send("jhud.assault.diff", self.diff)
			end
			if lastWhisper ~= jhud.whisper then
				lastWhisper = jhud.whisper
				jhud.net:send("jhud.assault.whisperState", jhud.whisper and 1 or 0)
			end
		end
		if doUpdate then self:updateTagText() end
		doUpdate = false
	else
		lastStatus = nil
		self.panel = nil
		self.textpanel = nil
		self.callpanel = nil
		self.calltext = nil
		lastUncool = nil
		lastUncoolStanding = nil
		lastCalling = nil
	end
end
function this:updateTagText()
	if not self.textpanel then return end
	if not (jhud.whisper and
				(self.config.showduring.stealth) or
				(self.config.showduring.assault)
			)
	then
		self.textpanel:set_visible(false)
		return
	end
	local text = self.config.showghost and jhud.whisper and
			(jhud.chat and
				jhud.chat.icons.Ghost or
				"S "
			) or
			("")
	text = text..self.lang(self.heistStatus)
	if jhud.whisper then
		if self.config.showpagers and self.pagersNR > 0 then
			jhud.dlog(self.pagersNR, "pagers used.")
			text = text.." "..(self.config.showpagersleft and
					4 - self.pagersNR or
					self.pagersNR
				)..(jhud.chat and jhud.chat.icons.Skull or "p")
		end

		local uc = self.config.uncoolsitting and self.config.showuncoolstanding and
			self.uncool - self.uncoolstanding or
			self.uncool
		jhud.dlog(self.uncool, uc, self.uncoolstanding)
		if self.config.showuncool and uc > 0 then
			text = text.." "..uc.."!"
		end
		if self.config.showuncoolstanding and self.uncoolstanding > 0 then
			text = text.." "..self.uncoolstanding.."^"
		end
	else
		if self.config.showdrama and self.drama ~= nil then
			text = text.." "..self.drama.."%"
		end
		if self.config.showdiff and self.diff ~= nil then
			text = text.." "..self.diff..(jhud.chat and jhud.chat.icons.Skull or "D")
		end
	end
	if self.config.uppercase then
		text = L:affix(text:upper())
	end
	self.textpanel:set_text(text)
	self.textpanel:set_color(self.config.color[self.heistStatus] or Color(1,1,1))
end
local lastSucessfulPagerNR = 0
function this:updateDangerData(t, dt)
	if not self.pagersActive then return end
	self.pagersUsed = self:getPagersUsed()
	if self.pagersUsed ~= lastSucessfulPagerNR then
		lastSucessfulPagerNR = self.pagersUsed
		self.pagersActive = self.pagersActive - 1
	end
	self.uncool = 0
	self.uncoolstanding = 0
	self.caution = 0
	self.calling = 0
	if managers.groupai and managers.groupai:state() and managers.groupai:state()._suspicion_hud_data then

		local isECM= false
		for i,v in pairs(managers.groupai:state()._ecm_jammers) do isECM = true break end

		for i,v in pairs(managers.groupai:state()._suspicion_hud_data) do
			if v.alerted then
				self.uncool = self.uncool + 1
				if v.icon_pos and v.u_observer then
					if v.icon_pos.z > (90 + v.u_observer:position().z) then --observer position is their feet
						self.uncoolstanding = self.uncoolstanding + 1
					end
				end
			else
				self.caution = self.caution + 1
			end
			if not isECM and v.status == "calling" then
				self.calling = self.calling + 1
			end
		end
	end
end
function this:updateAssault(t, dt)
	local gai = managers.groupai:state()
	self.drama = gai._drama_data and math.floor(gai._drama_data.amount*100)
	self.diff = gai._difficulty_value and math.floor(gai._difficulty_value*10)
end


function this:__igupdate(t, dt)
	if not managers then return end
	if jhud.net:isServer() then
		if jhud.whisper then
			self:updateDangerData(t, dt)
		else
			self:updateAssault(t, dt)
		end
	end
	self:updateTag(t, dt)
	for i,v in ipairs(self.anims or {}) do
		if v(t, dt) then
			table.remove(self.anims, i)
		end
	end
end

function this:__cleanup(carry)
	carry.assaultData = {}
	local c = carry.assaultData
	c.textpanel = self.textpanel
	c.callpanel = self.callpanel
	c.pagersNR = self.pagersNR or 0
	c.deadCopsWithPagers = self.deadCopsWithPagers
	c.pagersActive = self.pagersActive
	c.textpanel:text("")
	c.callpanel:text("")
end
function this:__init(carry)
	local controlData = {
		{amt = 0, len = 10, color = self.config.color.build},
	}
	self.dramaData = {
		fade = {
			{amt = 0, len = 25, color = self.config.color.control},
		},
		control = controlData, --lasts 15 seconds
		compromised = controlData,
		sustain = nil,
		anticipation = { --lasts 30 seconds, 40 seconds on dw, 60 if hostage
			{amt = 95, len = 5, color = self.config.color.build}
		},
		build = {--lasts 35 seconds
			{amt = 95, len = 5, color = self.config.color.sustain}
		},
	}
	self.anims = {}
	self.uncool = 0
	--Number of pagers used
	--This number includes the number of pagers that will need to be used
	--ie: pagercop dies during ecm, this number get added to anyway
	local old = carry.assaultData or {}
	self.pagersNR = old.pagersNR or 0
	self.uncoolstanding = 0
	self.heistStatus = "none"
	self.lang = L:new("assault")
	if jhud.net:isServer() then
		self.pagersActive = old.pagersActive or 0--Number of pagers that are being answered or need to be answered
		self.deadCopsWithPagers = old.deadCopsWithPagers or {}
		jhud.hook("CopBrain", "begin_alarm_pager", function(cb, reset)
			if not table.hasValue(self.deadCopsWithPagers, cb) then
				table.insert(self.deadCopsWithPagers, cb)
				jhud.dlog("pagercop died and will pager")
				self.pagersActive = self.pagersActive + 1
				jhud.net:send("jhud.assault.pagersNR", self.pagersNR + 1)
				if jhud.chat and self.config.chatPGUsed then
					jhud.chat:chatAll("PAGER", self.lang("pagers"):format(self.pagersNR), jhud.chat.config.spare1, false)
				end
			end
		end)
	end
	jhud.net:hook("jhud.assault.heistStatus", function(data)
		self.heistStatus = data --This does not need to be reset on host
		self:heistStateTransition()
		self:updateTagTextNext()
	end)
	jhud.net:hook("jhud.assault.pagersNR", function(data)
		self.pagersNR = tonumber(data)
		self:updateTagTextNext()
	end)
	jhud.net:hook("jhud.assault.calling", function(data)
		if not self.calltext then return end
		self.calltext:set_visible(tonumber(data) > 0 and self.config.showcalling)
		self.calltext:set_text(callingText)
	end)
	jhud.net:hook("jhud.assault.standing", function(data)
		self.uncoolstanding = tonumber(data)
		self:updateTagTextNext()
	end)
	jhud.net:hook("jhud.assault.uncool", function(data)
		self.uncool = tonumber(data)
		self:updateTagTextNext()
	end)
	jhud.net:hook("jhud.assault.drama", function(data)
		self.drama = tonumber(data)
		self:setDramaSlider(self.drama)
		self:updateTagTextNext()
	end)
	jhud.net:hook("jhud.assault.whisperState", function(data)
		jhud.whisper = tonumber(data) == 1
		if not jhud.whisper then
			self:dramaIn()
		else
		end
		self:updateTagTextNext()
	end)
	jhud.net:hook("jhud.assault.diff", function(data)
		self.diff = tonumber(data)
		self:updateTagTextNext()
	end)
end
function this:__addpeer(id)
	if not jhud.net:isServer() then return end
	jhud.net:send("jhud.assault.heistStatus", self.heistStatus)
	jhud.net:send("jhud.assault.pagersNR", self.pagersNR)
end
function this:updateTagTextNext()
	doUpdate = true
end
