function this:setInfamy(rank)
	if managers and managers.experience then
--its up to you whether or not you use this: you wont receive a CHEATER tag, you won't
-- get banned by ovk, but I'm not going to implment it anywhere as a base feature in johnhud.
--PS you wont receive the actual infamy points or achievements.
--This does permanantly save to your playerfile, so its up to you to keep track.
--Current max infamy: 5
--Current hard coded max: 7
		managers.experience._global.rank = Application:digest_value(rank, true)
	end
end

function this:__init()
	jhud.hook("HUDManager", "update_name_label_by_peer", function(self, peer)
		for _, data in pairs(self._hud.name_labels) do
			if data.peer_id == peer:id() then
				local name = data.character_name
				if peer:level() then
					local experience = (peer:rank() > 0 and managers.experience:rank_string(peer:rank()) .. "-" or "") .. peer:level() .. (jhud.player.plys[peer].isJHUD and "j" or "")
					name = name .. " (" .. experience .. ")"
				end
				data.text:set_text(utf8.to_upper(name))
				self:align_teammate_name_label(data.panel, data.interact)
			else
			end
		end
		return true
	end)
end
