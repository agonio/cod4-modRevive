# cod4-modRevive
is a mod for `search&destroy` adding a revive mechanic. It has the following features:

- nearby players can revive team-mates after they've been killed
- display the current amount of players per team alive, when..
  - a new round started,
  - a player was killed,
  - a player was revived.
- manage the available perks via DVARs - `perk_forbid_specialty_<perkname> 1`
- integrated the [Final Killcam](https://www.moddb.com/mods/final-killcam) mod created by [FzBr.d4rk](https://www.moddb.com/members/fzbrd4rk) ©

## Usage
Download the latest version of the mod from the [releases-page](https://github.com/agonio/cod4-modRevive/releases) and extract the content to `<cod-dir>/Mods/ModRevive`. The mod should then appear in your game as 'ModRevive'.

### Customization
There are several DVARs to customize the ModRevive experience:

- `perk_forbid_specialty_<perkname>`: allows to control which perks are allowed on the server; default: 0 (allowed)
- `scr_player_revivetime`: basic revive time; default: 3000 (ms)
- `scr_player_revivetimeincrease`: additional time per prior successful revive; default: 1000 (ms)
- `scr_game_roundstarttime`: time in seconds to wait before each round; default: 5 (s)


## Development

### Setup

- checkout repo into `<cod-dir>/Mods` (result should be `Mods/modrevive/<files>`)
- [ModTools](https://wiki.zeroy.com/index.php?title=Call_of_Duty_4:_needed#ModTools) with corresponding [readme](https://www.cod4central.com/content/cod4-mod-tools-readme.txt)
- [VSCode extension](https://marketplace.visualstudio.com/items?itemName=se2dev.cod-sense) (or similar)

### Build

If everything is setup correctly you simply need to run `makeMod.bat`.
These files should be generated/updated:
- mod.ff
- z_modrevive.iwd

⚠ If the client is still running, only .tmpX files will be generated.

### Run / Test

- Use the artifacts from the 'Build' and launch the game directly with the mod, e.g. create a shortcut to the mp bin with following parameters: 

```
"<path_to_iw3mp.exe>" +set developer 1 +set fs_game mods/ModRevive +set scr_game_matchstarttime 1 +set scr_game_playerwaittime 1 +set scr_game_roundstarttime 1
```
\* The three DVARs are not required but recommended for faster testing, as these define the time to wait before the match/round starts.

- In the game launch a server with the `sd` gamemode.

- For local testing the Final Killcam mod offers the possibility to add Bots. Open console and type `/add_bots X` (X = amount)

### Useful links

- [GSC language Tutorial](https://www.moddb.com/tutorials/scripting-1-basics)
- [Modding Wiki](https://wiki.zeroy.com/index.php?title=Call_of_Duty_4:_Modding)
  - [Modding Tutorial](https://wiki.zeroy.com/index.php?title=Call_of_Duty_4:_Modding_Tutorial#Scripting)
- [Example-Mod @github](https://github.com/dan2k3k4/bp-cod4/blob/master/maps/mp/gametypes/_globallogic.gsc)
- [COD4 Default GSC files @github](https://github.com/volkv/CoD4-Default-GSC-Scripts/blob/master/maps/mp/gametypes/_gameobjects.gsc)
