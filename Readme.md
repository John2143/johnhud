# An addon for payday

## Features

 - Custom chat: type %icon% to have a character in the chat ex: %ghost% for the stealth icon (Only shows for people with johnhud)
 - Assault indicator: shows state of stealth or assault, number of pagers, civillians standing, alerted or tied
 - Bindable voice commands: bind a key to say any voice line you want. This includes a __lot__ of things. You can find some of them in binds.txt
 - Suspicion percent meter: Allows you to see the individual detection amounts of people detecting you or your crew
 - Preplanning saving and loading: Save a preplan and use it the next time you have a heist
 - Extra skilltrees: Have as many skilltrees as you want (Pending rebalance)
 - Ignore: Mute annoying people and ban them from your lobbies (Currently only the first one)
 - Automatic update system: Never worry about having the latest version!
 - Change skills/perkdeck during heist planning

## Planned
 - A (local) site that will show detailed statistics about the players you are playing with: Simply open a html document in a web browser
 - Mutators (mabye)
 - Hardcore mode
 - Mabye I can make a level editor or something cool like that

## Commands
### Module: player.lua
 - /playing: prints player list and steamids
 - /reload: reloads players
 - /ignore: players | blocks chat from a player
 - /unignore: players | unblocks chat from a player


### Module: admin.lua
 - /kick: players | kicks a player
 - /kickb: players | bans a player
 - /csay: text | broadcasts text akin to casing mode warning
 - /csay2: text | broadcasts text in a box, vertical bar starts a new line
 - /restart or /r: Restart the current heist instantly WARNING: IT DEDUCTS OFFSHORE MONEY IF IT IS A PROJOB


### Module: autoupdate.lua
 - /updatedata:
  - variable:newvalue | changes version data. ex. /updatedata branch:ayy uname:lmao
  - --reset,-r | resets version data to defaults (uname=John2143658709, project=johnhud, branch=master)
  - --pure,-p | creates a new version file, with only the version (Everything else will be defaulted as listed above)
  - --next,-+ | increases version by 1 (You probably shouldnt need this unless you want to decline an update)
 - /update: updates johnhud, if there is a newer version
  - --force,-f | forces an update
   - --download,-d | downloads an update, but does not apply it
   - --xcopy-only,-c | Only copy over the current version assuming there exists a folder in update/ called {project}-{branch}

### Module: preplanning.lua
 - /l or /last: uses last plan used including flags
 - /prex:
   - plan name | executes saved plan with name
   - --vote-only,-v | executes votes from a plan only
   - --other-only,-o | executes things other than votes in a saved plan
   - --force,-f | forces plan execution
 - /prsv:
   - plan name | saves current plan under specified name
   - --self-only, -s | saves a plan with only the stuff you put down

### Module: infamy.lua
 - /skillset: Creates, deletes, or changes to a skilltree
  - --delete,-d | Delete the skill tree specified
  - --new,-n | Creates a new skill tree
  - --force,-f | Force the deleteion
  - Tree | The name of the skilltree or the ID of the skilltree(first is 1, second is 2...)
