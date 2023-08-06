#include common_scripts\utility;
#include maps\mp\_utility;

init()
{
	level.deadPlayers["axis"] = [];
	level.deadPlayers["allies"] = [];

    // rm after debug ***
    setDvar("scr_game_matchstarttime", 1);
    
    setDvar("scr_game_playerwaittime", 1);
    // ***

	thread watchRevives();
	thread watchRounds();
}

onPrecacheGameType()
{
	precacheModel( "prop_suitcase_bomb" );
	precacheModel( "revive_tool_chest" );
}

watchRounds() {
	for(;;) {
		level waittill("round_switch");
		wait 2; // delay print, as players don't seem to be setup already
		printAliveCount();
	}
}

watchRevives() {
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

	visuals[0] = spawn( "script_model", self.origin );
	if ( !isDefined( visuals[0] ) )
	{
		self IprintLnBold("No script_model found in map.");
		return;
	}

	trigger = spawn( "trigger_radius", self.origin, 0, 32 , 32 );
	if ( !isDefined( trigger ) )
	{
		self IprintLnBold("No trigger found in map.");
		return;
	}

	deadPlayer = spawnStruct();
	deadPlayer.location = self.origin;
	deadPlayer.angles = self.angles;
    deadPlayer.player = self;

	team = self.pers["team"];
	if ( isDefined( team ) && (team == "allies" || team == "axis") )
	{
		resBox = maps\mp\gametypes\_gameobjects::createUseObject( team, trigger, visuals, (0,0,32) );
		resBox maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
		resBox maps\mp\gametypes\_gameobjects::setUseTime( 3 );
		resBox maps\mp\gametypes\_gameobjects::setUseText( "reviving "+ self.name );
		//resBox maps\mp\gametypes\_gameobjects::setUseHintText( "hold to revive "+ self.name );
		resBox maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defend" );
		resBox maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "compass_waypoint_defend" );
		resBox maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
		resBox.useWeapon = "briefcase_bomb_mp";
        resBox.deadPlayer = deadPlayer;

        resBox.onUse = ::revivePlayer;

		level.deadPlayers[team][self.name] = deadPlayer;
	}
}

revivePlayer( medicPlayer )
{
    self.deadPlayer.player maps\mp\gametypes\_globallogic::spawnPlayer();
    self.deadPlayer.player.health = 10;
    self.deadPlayer.player spawn(self.deadPlayer.location, self.deadPlayer.angles);
    self.deadPlayer.player maps\mp\gametypes\_class::giveLoadout( self.deadPlayer.player.team, self.deadPlayer.player.class );
    self maps\mp\gametypes\_gameobjects::disableObject();
	level notify("player_revived");
    
	self.visuals[0] delete();
    // self.trigger delete(); // we need to clean the trigger somehow. For each trigger a new thread-loop runs in _gameobject.gsc
    wait 0.05;
    self.deadPlayer.player.health = getMaxHealth();
	self.deadPlayer.player playLocalSound( "tacotruck" );
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