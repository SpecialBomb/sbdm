# NOTE

If you are serving sbdm on a server, I strongly reccomend the following settings for the intended experience:

***ABSOLUTLEY RECCOMENDED*** Set ticrate to 72 frames per second, or in inverse notation for some servers, 0.0138888889. I would automatically do this in the mod, but every engine parses the ticrate variable differently

If the engine you are using supports it, turn on jumping up steps (ex. sv_jumpstep)

These settings are for mainly for movement, and will not affect anything else but the walljump.

The server I reccomend using is darkplaces as these settings are on by default, but other servers will work. Just make sure the settings above are met as closely as possible, and the mod will work as intended.

# sbdm

sbdm, or SpecialBomb's Death Match, is a mod that is aimed at making all of the weapons useful in their own way.
For example, if you had the Nailgun, and got the Super Nailgun, why would you want to use the Nailgun anymore?
This mod tries to fix that.
It also adds more ways to move, and adds different ways of playing.

#Weapon Changes

+The Axe now does 80 damage, making it a viable melee weapon.

+The Nailgun now throws nails, and they stick to the map. If they are touched by a player, they get damaged by it (9 per nail). The nails last a minute until they disappear, and can be destroyed using explosives.

+The Nailgun only allows 30 spikes in the game at a time. There is a nifty number that pops up at the center of your screen telling you how many you have in the level. This number pops up when spikes are created or destroyed.

+If you are adept with the Nailgun, there are two aliases that you would find useful to bind, spikes and dspikes. spikes reports how many spike you currently have. dspikes deletes all of your spikes if you want to replace them, but you won't get your ammo back.

+The Shotgun is now infinitly accurate, and does more damage (40). This is useful in long range encounters with enemies.

+The Double-Barreled Shotgun has a much larger square spread rather than a rectangular one, and does more damage (100). It also has kickback, which can be used for stopping in midair, or boosting jumps.

+The Super Nailgun no longer shoots nails, but rather acts like the Doom Chaingun (does 18 damage)

+The lightning gun is now like a railgun. It does 80 damage per bolt, and uses 10 cells per shot. It takes 1.5 seconds inbetween shots.

+All weapons have no recoil when you shoot them.

#Gameplay Changes

+The Quad and Ring now drop on death. (needs improving)

+There is no longer any automatic weapon switching, besides on low ammo.

+Instagib axes can be enabled with "deathmatch 3". Disables item pickups, and spawns player with only an axe. The axe will do 1000 damage.

+Instagib mode with the railgun can be enabled with "dethamatch 4". Disables item pickups, and you have infinite ammo.

+Practice mode can be enabled with "deathmatch 5". It gives you a non-damaging super shotgun and infinite ammo to practice walljump and super shotgun jump combos. It is impossible to take damage in this mode.

+Random spawns. (needs improving)

+Grenades aren't random.

+Rocket impact damage is always 120.

+Players won't keep weapons, ammo, health, and armor when changing levels.

+If someone were to suicide with a recent attacker, the recent attacker will get the frag.

+The invisibility ring doesn't make your weapons invisible.

+Walljumping! (see below)

#Other Changes

+You can look at a player to see their name.

+Map voting. Maps dm1 to dm6 are voteable, and uses a yes greater than no system (non voters are not counted).

+You can vote for gamemodes deathmatch, instagib, and insta axes (see aliases below).

+Drowning doesn't damage armor. (might not be working)

Other things will be added at some point.

#Walljumping

To do walljumps, bind a key (perferrably mouse2) to "impulse 30." You can also bind "walljump" if you want to use the alias. Using the bound key while your back is facing towards a wall, you will jump in the direction you are looking in. This can be useful for finding combos in maps that let you get around quicker than usual. Practice a bit to get used to it, because nothing will happen if you jump at the wrong angle. You can only walljump 3 times until you have to touch the ground again.

#Important Aliases

walljump - causes you to walljump. (impulse 30)

spikes - tells you how many spikes you have in the level. (impulse 21)

dspikes - deletes all of your spikes. (impulse 22)

yes - votes yes. (impulse 13)

no - votes no. (impulse 14)

dm1 - Starts a vote to change map to dm1 (impulse 15)

dm2 - Starts a vote to change map to dm2 (impulse 16)

dm3 - Starts a vote to change map to dm3 (impulse 17)

dm4 - Starts a vote to change map to dm4 (impulse 18)

dm5 - Starts a vote to change map to dm5 (impulse 19)

dm6 - Starts a vote to change map to dm6 (impulse 20)

vote_deathmatch - Starts a vote for changing the mode to deathmatch and restarting the server (impulse 23)

vote_instaaxes - Starts a vote for changing the mode to insta axes and restarting the server (impulse 24)

vote_instagib - Starts a vote for changing the mode to instagib and restarting the server (impulse 25)

vote_practice - starts a vote for changing the mode to practice and restarting the server (impulse 26)
