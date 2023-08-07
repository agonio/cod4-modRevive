#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gameobjects;

setup()
{
    // rm after debug ***
    setDvar("scr_game_matchstarttime", 1);
    
    setDvar("scr_game_playerwaittime", 1);
    // ***

	thread watchRevives();
	thread watchRounds();
	thread watchPrematch();
}

watchPrematch() {
	level endon("game_ended");
	for(;;) {
		level waittill("prematch_over");
		printAliveCount();
	}
}

watchRounds() {
	level endon("game_ended");
	for(;;) {
		level waittill("round_switch");
		wait 2; // delay print, as players don't seem to be setup already
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
    //self endon("spawned_player")
	wait ( 0.05 );

	printAliveCount();

	// wait for body's final position
	wait(1.5);

	visuals[0] = spawn( "script_model", self.body.origin );
	trigger = spawn( "trigger_radius", self.body.origin, 0, 32 , 32 );

	team = self.pers["team"];
	if ( isDefined( team ) && (team == "allies" || team == "axis") )
	{
		resBox = createUseObject( team, trigger, visuals, (0,0,32) );
		resBox allowUse( "friendly" );
		resBox setUseTime( 0 );
		resBox set2DIcon( "friendly", "compass_waypoint_defend" );
		resBox set3DIcon( "friendly", "compass_waypoint_defend" );
		resBox setVisibleTeam( "friendly" );

		self thread monitorBody(trigger, resBox);
	}
}

monitorBody(trigger, resBox) {
	self endon("disconnect");
	self endon("revived");
	level endon( "game_ended" );

	for (;;)
	{
		wait (0.05);
		trigger waittill("trigger", player);
		if ( player.pers["team"] == self.pers["team"] && !player.checkingBody ) {
			player.checkingBody = true;
			player thread checkIfReviving( self, trigger, resBox );		
		}
	}	
}

checkIfReviving( deadPlayer, trigger, resBox )
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );

	barData = spawnStruct();
	barData.useText = "reviving "+ deadPlayer.name;
	barData.inUse = false;
	barData.useRate = 1;
	barData.curProgress = 0;
	barData.useTime = 3000;

	text = createFontString( "objective", 1.5 );
	text setPoint("CENTER", undefined, level.primaryProgressBarTextX, level.primaryProgressBarTextY);
	text setText("hold 'USE' to revive "+ deadPlayer.name);
	
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
			revivePlayer(deadPlayer, resBox);
			break;
		}
	}
	text destroy();

	// Body is not there or the player is not touching the trigger anymore	
	self.checkingBody = false;	
}

revivePlayer( deadPlayer, resBox )
{
    deadPlayer maps\mp\gametypes\_globallogic::spawnPlayer();
    deadPlayer.health = 10;
    deadPlayer spawn(deadPlayer.body.origin, deadPlayer.angles);
    deadPlayer maps\mp\gametypes\_class::giveLoadout( deadPlayer.team, deadPlayer.class );
    resBox disableObject();
	
	level notify("player_revived");
	deadPlayer notify("revived");
    
	resBox.visuals[0] delete();
    resBox.trigger delete();
    wait 0.05;
    deadPlayer.health = getMaxHealth();
	deadPlayer playLocalSound( "tacotruck" );
}


printAliveCount() 
{
	printTeam("^2"+level.aliveCount["axis"]+ " ^7vs ^1" + level.aliveCount["allies"], "axis");
	printTeam("^2"+level.aliveCount["allies"]+ " ^7vs ^1" + level.aliveCount["axis"], "allies");
}

printMsg(pl, msg)
{
	pl IprintLnBold(msg);
}

printAllPlayers(msg)
{
    players = getEntArray("player", "classname");
	
	for(i = 0; i < players.size; i++)
	{
	    // Send a message to all players
		thread printMsg(players[i], msg);
	}
}

printTeam(msg, team)
{
	players = getEntArray("player", "classname");
	
	for(i = 0; i < players.size; i++)
	{
		if (players[i].pers["team"] == team) 
		{
			// Send a message to all team players
			thread printMsg(players[i], msg);
		}
	}
}

getMaxHealth()
{
    if ( level.hardcoreMode )
		return 30;
	else if ( level.oldschool )
		return 200;
	else
		return 100;
}