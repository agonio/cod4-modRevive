#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\util;

setup()
{
	level.lockPrint = false;

	thread watchPrematch();
}

watchPrematch() {
	level endon("game_ended");
	for(;;) {
		level waittill("prematch_over");
		printAliveCount();
	}
}

onPlayerKilled(attacker, sMeansOfDeath) {
	wait ( 0.05 );
	printAliveCount();
}

printAliveCount()
{
	if(!isdefined(level.lockPrint) || !level.lockPrint) {
		level.lockPrint = true;
		printTeam("^2"+level.aliveCount["axis"]+ " ^7vs ^1" + level.aliveCount["allies"], "axis");
		printTeam("^2"+level.aliveCount["allies"]+ " ^7vs ^1" + level.aliveCount["axis"], "allies");

		wait ( 0.05 );
		level.lockPrint = false;
	}
}