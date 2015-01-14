jhud.options = {
	modules = { --This is the list of modules that get loaded. comment out any of them to disable them
				--words in parenthesis are required modules
		"language",		--[REQUIRED] DO NOT REMOVE THIS LIBRARY
		"bind",		--[RECCOMENDED] Allows you to bind keys
		"assault",		--Gives heist status at the top of the screen
		"chat",			--disabling this will remove johnhud from printing to your chat
		"voice",		--(bind) Allows you to bind keys for voicelines
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
				pager = 1,
				uncool = 2,
				questioning = 0,
			},
			showpagers = true,
			uppercase = true,
		},
		chat = {
		
		},
		voice = {
		
		}
	}
}