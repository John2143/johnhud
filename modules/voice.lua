function this:voiceline(line)
	if line and managers.player:player_unit() then
		managers.player:player_unit():sound():say(line,true,true)
		return true
	end
	return false
end
function this:bainline(line, net)
	if line then
		managers.dialog:queue_dialog(line, {})
	end
	if net and jhud.net and jhud.net:isServer() then
		managers.network:session():send_to_peers_synched("bain_comment", line)
	end
end

this.internalnames = {
	hoxton = 5,
	clover = 7,
	houston = 2,
	wick = 6,
}
function this:__init()
	local _self = self
	for i,v in pairs(jhud.binds.voice) do
		if v[1] then
			jhud.bind(v[1], function()
				_self:voiceline(v[2])
			end)
		end
	end
	for i,v in pairs(jhud.binds.bainlines) do
		if v[1] then
			jhud.bind(v[1], function()
				_self:bainline(v[2], v[3])
			end)
		end
	end
end
