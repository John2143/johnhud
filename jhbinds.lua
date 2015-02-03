local chains = "b"
local dallas = "a"
local wolf = "c"
local hoxton = "d"
jhud.binds = {
	voice = {
		{"", "f30x_any"}, 		--BULLDOZER
		{"", "f31x_any"}, 		--Sheild
		{"", "f32x_any"}, 		--taser
		{"", "f33x_any"}, 		--cloaker
		{"", "f34x_any"}, 		--sniper [W, D, Cl]
		{"", "g23"}, 			--Open fire
		{"", "g60"},			--Oh no
		{"", "g68"},			--We're overrun
		{"", "g07"}, 			--get out
		{"", "g26"},			--cableties
		{"", "g02"},			--upstairs
		{"", "g01"}, 			--downstairs
		{"", "g16"},			--defend
		{"", "g80x_plu"},		--medbag
		{"", "g69"}, 			--we gotta move to a more strategic position
		{"", "t02x_sin"}, 		--halfway there
		{"", "t01x_sin"}, 		--minutes
		{"", "g28"}, 			--almost there
		{"", "f36x_any"}, 		--GET THE FUCK UP
		{"", "t03x_sin"}, 		--seconds
		{"", "l01x_sin"}, 		--handsup
		{"", "l02x_sin"}, 		--get on knees
		{"", "l03x_sin"}, 		--cuff yourself
		{"m", "g40x_any"}, 		--cuff yourself
	},
	bainlines = {
		{"", "ban_q01"..chains, true},		--[character] pickle
		{"", "ban_r01", true},				--Extraction team (2)
		{"", "ban_r02", true},				--Extraction team (1)
		{"", "ban_r03", true},				--Freed civ (1)
		{"", "ban_r04", true},				--Freed civ (2)
		{"", "ban_h40"..wolf, true},		--[character] Last alive: no hostage
		{"", "ban_h42"..wolf, true},		--[character] Last alive: pending hostage
		{"", "ban_q02"..wolf, true},		--[character] is outta custody
		{"", "ban_h02"..wolf, true},		--marked hostage free him and [character] will be released
		{"", "ban_h31x", true},				--Assault wave will bring down the whole crew
		{"", "gen_ban_b01a", true},			--Police scanner
		{"", "gen_ban_b01b", true},			--Police assault 30 sec
		{"", "gen_ban_b02a", true},			--20 seconds left
		{"", "gen_ban_b02b", true},			--10 seconds left
		{"", "gen_ban_b02c", true},			--now
		{"", "gen_ban_b03x", true},			--30 seconds until next assault
		{"", "gen_ban_b04x", true},			--20 sec "
		{"", "gen_ban_b05x", true},			--10 sec "
		{"", "gen_ban_b10", true},			--praise 1
		{"", "gen_ban_b11", true},			--praise 2
		{"", "gen_ban_b12", true},			--praise 3
		{"h", "ban_h01x", true},			--Need hostages
		{"n", "Play_ban_h22x", true},		--Need hostages (detailed)
		{"u", "Play_ban_i20"..wolf, true},	--Last one alive [character]
		{"j", "Play_ban_h11"..wolf, true},	--[character] in custody
		{"m", "Play_ban_h50x", true},		--Hostage trade cancelled
	}
}
