function this:__init()
	if not jhud.player then return end
end
function this:__postaddpeer(id)
	local ply = jhud.player:playerByPeerID(id)
	if not ply then return end
	Steam:http_request(("api.pd2stats.com/player_stats/v1/?id=%s&type=lua"):format(ply:cID()), function(success, data)
		if not success then jhud.log("Failed to access pd2stats.com") return end
		local datafunc = loadstring("return "..data)
		if not datafunc then return end
		local succ, pdata = pcall(datafunc)
		if not succ then return end
		ply.pd2skillsdata = {
			commend = pdata.commend_leader,
			teacher = pdata.commend_teacher,
			kind = pdata.commend_kind,
		}
	end)
end
