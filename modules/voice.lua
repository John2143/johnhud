function this:voiceline(line)
	if line and managers.player:player_unit() then
		managers.player:player_unit():sound():say(line,true,true)
		return true
	end
	return false
end

function this:__init()
	local _self = self
	for i,v in pairs(jhud.binds.voice) do
		if v[1] then
			jhud.bind(v[1], function()
				_self:voiceline(v[2])
			end)
		end
	end
end