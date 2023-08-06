# cod4-modRevive
cod4 mod for sd with revive mechanic. based on modwarfare.

## Setup

- checkout repo into `<cod-dir>/Mods` (result should be `Mods/modrevive/<files>`)
- [ModTools](https://wiki.zeroy.com/index.php?title=Call_of_Duty_4:_needed#ModTools) with corresponding [readme](https://www.cod4central.com/content/cod4-mod-tools-readme.txt)
- [VSCode extension](https://marketplace.visualstudio.com/items?itemName=se2dev.cod-sense) (or similar)

## Build

If everything is setup correctly you simply need to run `makeMod.bat`.
These files should be generated/updated:
- mod.ff
- z_modrevive.iwd

⚠ If the client is still running, only .tmpX files will be generated.

## Run / Test

To run the game with the mod, create a shortcut to the mp bin with following parameters: 

`"<path_to_iw3mp.exe>" +set developer 1 +set fs_game mods/ModRevive`

In the game launch a server with the `sd` gamemode.

## Useful links

- [GSC language Tutorial](https://www.moddb.com/tutorials/scripting-1-basics)
- [Modding Wiki](https://wiki.zeroy.com/index.php?title=Call_of_Duty_4:_Modding)
  - [Modding Tutorial](https://wiki.zeroy.com/index.php?title=Call_of_Duty_4:_Modding_Tutorial#Scripting)
- [Example-Mod @github](https://github.com/dan2k3k4/bp-cod4/blob/master/maps/mp/gametypes/_globallogic.gsc)
- [COD4 Default GSC files @github](https://github.com/volkv/CoD4-Default-GSC-Scripts/blob/master/maps/mp/gametypes/_gameobjects.gsc)