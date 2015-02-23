LOADLANGUAGE = function() return {
	assault = {
		anticipation = "Starting",		--Assault wave coming soon
		fade = "Fade", 					--No more Spawns
		build = "Build",				--Spawns until # of enemies reaches a certin level
		sustain = "Sustain",			--Continues spawns to sustain that #
		none = "Not in a heist",		--
		control = "Control",			--Between waves
		compromised = "Compromised",	--Assult phase has not begun, but stealth has failed (alarms, civs calling, pagers, gunshots, etc). Exactly the same as the Control phase, but this is the first.
		stealth = "Stealth",			--Stealth
		caution = "Caution",			--You are being detected
		danger = "Danger",				--Somebody is alerted
		calling = "Somebody is calling the police!",
	},
	_ = {
		start = "JohnHUD started",
		trans_error = "Translation Error",
		affix_error = "Affixation Error",
		cheater = "Acheivements are disabled because you are cheating",
		newver = "There is a new version of johnhud available. Type '/update' when in a game to update.",
		nonewver = "There is no new version available",
		downloading = "Downloading...",
		applying = "Applying...",
	},
	chat = {
		unknown = "Unknown command '%s'",
		cmdplaying = "Current players",
		noplayer = "This command requires a player argument",
		solo = "Currently in a solo heist",
		requiresheist = "You must be in a heist to use this",
		internalerror = "Internal command error (This shouldnt happen!)",
		needhost = "You must be the host to use this",
	}
} end
