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
	}
} end