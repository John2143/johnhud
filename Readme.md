# An addon for payday

## Features

 - Custom chat: type %icon% to have a character in the chat ex: %ghost% for the stealth icon (Only shows for people with johnhud)
 - Assault indicator: shows state of stealth or assault
 - Bindable voice commands: bind a key to say any voice line you want
 - Suspicion percent meter: Allows you to see the individual detection amounts of people detecting you or your crew

## Commands:
### Module: player.lua
 /playing: prints player list
 /reload: reloads players
 /ignore: players | blocks chat from a player
 /unignore: players | unblocks chat from a player
### Module: admin.lua
 /kick: arguments: players | kicks a player
 /kickb: players | bans a player
 /csay: text | broadcasts text akin to casing mode warning
 /csay2: text | broadcasts text in a box, vertical bar starts a new line
### Module: autoupdate.lua
 /updatedata: variable:newvalue | changes version data
--reset,-r | resets version data to defaults (uname=John2143658709, project=johnhud, branch=master) 
--pure,-p | creates a new version file, with only the version 
--next,-+ | increases version by 1 
 /update: updates johnhud, if there is a newer version 
--force,-f | forces an update
--download,-d | downloads an update, but does not apply it
### Module: preplanning.lua
 /l: uses last plan used
 /prex: plan name | executes saved plan with name 
 - --vote-only,-v | executes votes from a plan only 
 - --other-only,-o | executes things other than votes in a saved plan 
 - --force,-f | forces plan execution
 /prsv: plan name | saves current plan under specified name 
 - --self-only, -s | saves a plan with only the stuff you put down
