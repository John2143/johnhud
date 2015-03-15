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
 - Better summary screen
 - Commend and report functions (from pd2stats.com api)

## Planned
 - A (local) site that will show detailed statistics about the players you are playing with: Simply open a html document in a web browser
 - Mutators (mabye)
 - Hardcore mode
 - Mabye I can make a level editor or something cool like that

## Commands
### Syntax
##### General command syntax is "/name arg1 arg2 arg3..." or "!name arg1 arg2 arg3..."  
Every command that requires a player argument is required to have the ability to
accept as many as you give it, however, some commands may not have the ability
to use every player. There are a few ways to specify a player or players.

 - `*` All players in the game
 - `!` All players in the game excluding you. Identical to `*,-^`
 - `^` You (local player)
 - `name` The name of a player or players

The `-` character when prefixing anything equals the opposite of that group.
Multiple arguments may be comma seperated and will execute sequentially.

Examples:

 - `/kick !,-bob` Kick everyone in the lobby unless they have the word 'bob' in
 their name
 - `/ignore bar,-foobar` Ignore anyone with the word 'bar' in their name unless
 they have the word 'foobar' in thier name

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

### Module: pd2stats.lua
 - /commend <name> <reason>: Comment a player or players. Valid reasons:
  - teacher, t | They are a good teacher
  - friendly, f, kind, k | They were nice to play with
  - leader, l | They are a good leader
 - /report <name> <reason>:  Report a player for bad conduct. Valid reasons:
  - cheater, c | They have used some kind of cheat such as impossible skill builds
  or infinite ammo.
  - greifing, g | This is any type of purposful misconduct that is meant to hinder
  the ability to successfully complete the heist. Some examples would be team
  damage, shooting a loud gun during stealth, not being in the escape, or throwing
  bags to unreachable positions
  - abuse, a | Abusing host privelages(probably). Some examples would be using a
  mutator, kicking as the game ends, or greifing(without fear of being kicked).
