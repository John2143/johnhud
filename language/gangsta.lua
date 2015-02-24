LOADLANGUAGE = function() return {
	assault = {
		anticipation = "the police scanner's buzzing like crazy",		--Assault wave coming soon
		fade = "run like hell", 					--No more Spawns
		build = "we can rebuild him",				--Spawns until # of enemies reaches a certin level
		sustain = "nutrition",			--Continues spawns to sustain that #
		none = "you shouldn't be seeing this",		--
		control = "throw those bags",			--Between waves
		compromised = "we lost boys",	--Assult phase has not begun, but stealth has failed (alarms, civs calling, pagers, gunshots, etc). Exactly the same as the Control phase, but this is the first.
		stealth = "spooky",			--Stealth
		caution = "oh no",			--You are being detected
		danger = "shit son",				--Somebody is alerted
		calling = "nigga call the cops on yo ass",
	},
	_ = {
		start = "john perfection started",
		trans_error = "lost in translation",
		affix_error = "-ayyy",
		cheater = "shit why don't you use pirate perfection",
		newver = "gimme dat update bro (%s -> %s). do '/update' & get me the hot new code",
		nonewver = "nigga i aint tell you to update (version %s)",
		downloading = "git fetch",
		applying = "git pull",
	},
	chat = {
		unknown = "look it up in the dictionary '%s'"
		cmdplaying = "homies",
		noplayer = "tell me the men",
		solo = "playin with himself man",
		requiresheist = "go steal some shit",
		internalerror = "ey wat u doin",
		needhost = "gotta be the gang leader",
		kickself = "momentum doesn't work that way",
		valuechange = "family values '%s' -> '%s'",
		resetdata = "git reset --hard",
		writeunpure = "an unpure version file, fresh off the oven (full data)",
		writepure = "a pure version file, fresh off the oven (version only)",
	}
} end
