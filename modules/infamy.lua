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
