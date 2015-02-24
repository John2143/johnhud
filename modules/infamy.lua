function this:setInfamy(rank)
	if managers and managers.experience then
--its up to you whether or not you use this: you wont receive a CHEATER tag, you won't
-- get banned by ovk, but I'm not going to implment it anywhere as a base feature in johnhud.
--PS you wont receive the actual infamy points or achievements.
--This does permanantly save to your playerfile, so its up to you to keep track.
--Current max infamy: 5
--Current hard coded max: 7
		managers.experience._global.rank = jhud.digest(rank)
	end
end
function this:getInfamy()
	return jhud.undigest(managers.experience._global.rank)
end

function this:__init()
	do return end ----------------------
	jhud.hook("HUDManager", "update_name_label_by_peer", function(self, peer)
		for _, data in pairs(self._hud.name_labels) do
			if data.peer_id == peer:id() then
				local name = data.character_name
				if peer:level() then
					local ply = jhud.player:getPlayerByPeerID(peer:id())
					local experience = (peer:rank() > 0 and managers.experience:rank_string(peer:rank()) .. "-" or "") ..
							peer:level() ..
							((peer:id() == jhud.net:getPeerID() or ply and ply:hasJHUD()) and "j" or "")
					name = name .. " " .. L:affix(experience)
				end
				data.text:set_text(utf8.to_upper(name))
				self:align_teammate_name_label(data.panel, data.interact)
			else
			end
		end
		return true
	end)
end
