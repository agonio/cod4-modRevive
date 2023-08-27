#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\util;
#include maps\mp\gametypes\_gameobjects;

setup()
{
	level.usedReviveObjIds = [];
	for (i=0; i<16; i++) {
		// reserve the first 6 (sd)
		level.usedReviveObjIds[i] = i<6;
	}
	precacheShader("revive_icon");

	thread watchRevives();
	thread watchPrematch();
}

getNextFreeObjId()
{
	for(i=0; i<level.usedReviveObjIds.size; i++) {
		if (level.usedReviveObjIds[i] == false) {
			level.usedReviveObjIds[i] = true; //mark as used and hope that the loop is not running in parallel...
			return i;
		}
	}
	return -1; // all used, no marker on minimap available
}

markObjIdUnused(id)
{
	level.usedReviveObjIds[id] = false;
	objective_delete(id);
}

watchPrematch() {
	level endon("game_ended");
	for(;;) {
		level waittill("prematch_over");
		printAliveCount();
	}
}

watchRevives() {
	level endon("game_ended");
	for(;;) {
		level waittill("player_revived");
		printAliveCount();
	}
}

checkRevive(attacker, sMeansOfDeath)
{
	wait ( 0.05 );

	printAliveCount();

	// wait for body's final position
	wait(1.5);

	trigger = spawn( "trigger_radius", self.body.origin, 0, 45 , 45 );

	team = self.pers["team"];
	if ( isDefined( team ) && (team == "allies" || team == "axis") )
	{
		resObjective = maps\mp\gametypes\_objpoints::createTeamObjpoint( "revive_"+ self.name, self.body.origin + (0,0,32), team, "revive_icon" );
		resObjective setWayPoint(true, "revive_icon");

		objId = getNextFreeObjId(); // starts with 6, max is 15; so we have 10 objIds free
		if (objId != -1 && objId < 16 ) {
			objective_add(objId, "active", self.body.origin);
			objective_icon(objId, "revive_icon");
			objective_team(objId, team);
			resObjective.id = objId;
		}

		self thread monitorBody(trigger, resObjective);
	}
}

monitorBody(trigger, resObjective) {
	self endon("disconnect");
	self endon("revived");
	level endon( "game_ended" );

	for (;;)
	{
		wait (0.05);
		trigger waittill("trigger", player);
		if ( player.pers["team"] == self.pers["team"] && !player.checkingBody ) {
			player.checkingBody = true;

			if (isdefined(self.droppedDeathItem)) {
				self.droppedDeathItem triggerOff();
			}
			player thread checkIfReviving( self, trigger, resObjective );
		}
	}
}

checkIfReviving( deadPlayer, trigger, resObjective )
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	barData = spawnStruct();
	barData.useText = "reviving ^2"+ deadPlayer.name;
	barData.inUse = false;
	barData.useRate = 1;
	barData.curProgress = 0;

	baseTime = maps\mp\gametypes\_tweakables::getTweakableValue("player", "revivetime"); // default 3000 ms
	increase = maps\mp\gametypes\_tweakables::getTweakableValue("player", "revivetimeincrease"); // default 1000 ms
	barData.useTime = baseTime + deadPlayer.reviveCount * increase;

	text = createFontString( "objective", 1.5 );
	text setPoint("CENTER", undefined, level.primaryProgressBarTextX, level.primaryProgressBarTextY);
	text setText("hold 'USE' to revive ^2"+ deadPlayer.name);

	// Stay here as long as the body exists and the player is touching it
	while ( isDefined( self ) && isDefined( deadPlayer.body ) && self isTouching( trigger ) ) {
		wait (0.05);
		text.alpha = 1;
		barData.curProgress = 0;
		// track use button pressed
		while (self isTouching( trigger ) && self useButtonPressed() && barData.curProgress < barData.useTime) {
			text.alpha = 0;
			barData.inUse = true;
			self thread personalUseBar(barData);
			self disableWeapons();
			wait (0.05);
			barData.curProgress += 50;
		}
		barData.inUse = false;
		self enableWeapons();

		if (barData.curProgress >= barData.useTime) {
			wait (0.05);
			revivePlayer(deadPlayer);
			trigger delete();
			if (isdefined(resObjective.id) && resObjective.id != -1) {
				markObjIdUnused(resObjective.id);
			}
			maps\mp\gametypes\_objpoints::deleteObjPoint(resObjective);
			break;
		}
	}
	text destroy();

	// Body is not there or the player is not touching the trigger anymore
	self.checkingBody = false;
	if (isdefined(deadPlayer.droppedDeathItem)) {
		deadPlayer.droppedDeathItem triggerOn();
	}
}

revivePlayer( deadPlayer )
{
	deadPlayer maps\mp\gametypes\_globallogic::spawnPlayer();
	deadPlayer.reviveCount++;
	deadPlayer.health = 10;
	deadPlayer spawn(deadPlayer.body.origin, deadPlayer.angles);
	deadPlayer maps\mp\gametypes\_class::giveLoadout( deadPlayer.team, deadPlayer.class );

	level notify("player_revived");
	deadPlayer notify("revived");

	deadPlayer.body delete();
	wait 0.05;
	deadPlayer.health = getMaxHealth();
	deadPlayer playLocalSound( "tacotruck" );
}


printAliveCount()
{
	printTeam("^2"+level.aliveCount["axis"]+ " ^7vs ^1" + level.aliveCount["allies"], "axis");
	printTeam("^2"+level.aliveCount["allies"]+ " ^7vs ^1" + level.aliveCount["axis"], "allies");
}


getMaxHealth()
{
	if ( level.hardcoreMode )
		return 30;
	else if ( level.oldschool )
		return 200;
	else {
		healthTweak = maps\mp\gametypes\_tweakables::getTweakableValue("player", "maxhealth");
		return healthTweak;
	}
}