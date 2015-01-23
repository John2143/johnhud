jhud.defOptions = {
	modules = { --This is the list of modules that get loaded. comment out any of them to disable them
				--words in parenthesis are required modules
		"language",		--[REQUIRED]
		"hook",			--[REQUIRED]
		"net",			--[REQUIRED]
		"suspct",		-- Shows suspicion percentages
		"bind",			-- Allows you to bind keys
		"assault",		-- Gives heist status at the top of the screen
		"chat",			-- disabling this will remove johnhud from printing to your chat
		"voice",		-- (bind) Allows you to bind keys for voicelines
	},
	language = "EN",
	m = {
		_ = {
			showload = true, --Prints '%skull%: JohnHUD Loaded to verify that all modules loaded corretly
		},
		assault = {
			color = {
				anticipation = Color('7519FF'),	
				fade = Color('00FFCC'), 				
				build = Color('00CC66'),				
				sustain = Color('CCFF33'),			
				none = Color('CCFF33'),		
				control = Color('99CC00'),
				compromised = Color('A6A610'),
				stealth = Color('005CE6'),
				caution = Color('FF9900'),
				danger = Color('CC0000'),
			},
			stealthind = {
				y = 0, --more = down
				x = 0, --more = right
				text_size = 7, --more = larger
			},
			calling = {
				y = 0, --more = down
				x = 0, --more = right
				text_size = 15, --more = larger
				color = Color(1, .1, .1)
			},
			danger = {
				--Change the text of the indicator when an event is happening
				--Values
				-- 0: Stealth
				-- 1: Caution
				-- 2: Danger
				pager = 1, --A pager needs to be asnwered
				uncool = 2, --A civ or cop is alerted
				questioning = 0, --Someone is being detected
			},
			showpagers = true, --Show the #pagers in the indicator
			uppercase = true, --Make the indicator uppercase
		},
		suspct = { --Stealth percent indicator
			show100for = 4, --How long to keep the 100% on your hud
			num = 5, --Max number of counters at once
		}
	}
}
