init()
{
	level.deadPlayers["axis"] = [];
	level.deadPlayers["allies"] = [];

    // rm after debug ***
    setDvar("scr_game_matchstarttime", 0);
    
    setDvar("scr_game_playerwaittime", 0);
    // ***
}

onPrecacheGameType()
{
	precacheModel( "prop_suitcase_bomb" );
	precacheModel( "revive_tool_chest" );
}

checkRevive(attacker, sMeansOfDeath)
{
    players = getEntArray("player", "classname");
	
	for(i = 0; i < players.size; i++)
	{
	    // Send a message to all players notifying about the kill
		thread printInfo(players[i], self.name, attacker.name, sMeansOfDeath );
	}
	self IprintLnBold("position: " + self.origin);

	visuals[0] = getEnt( "sd_bomb", "targetname" );
	if ( !isDefined( visuals[0] ) )
	{
		self IprintLnBold("No sd_bomb script_model found in map.");
		return;
	}
	visuals[0] setModel( "prop_suitcase_bomb" );

	bombZones = getEntArray( "bombzone", "targetname" );
	trigger = bombZones[0];
	if ( !isDefined( trigger ) )
	{
		self IprintLnBold("No bombzone trigger found in map.");
		return;
	}

	deadPlayer = spawnStruct();
	deadPlayer.location = self.origin;
	deadPlayer.player = self;

	team = self.pers["team"];
	if ( isDefined( team ) && (team == "allies" || team == "axis") )
	{
		trigger.origin = self.origin;
		visuals[0].origin = self.origin;
		resBox = maps\mp\gametypes\_gameobjects::createUseObject( team, trigger, visuals, (0,0,32) );
		resBox maps\mp\gametypes\_gameobjects::allowUse( "friendly" );
		resBox maps\mp\gametypes\_gameobjects::setUseTime( 3 );
		resBox maps\mp\gametypes\_gameobjects::setUseText( "reviving "+ self.name );
		resBox maps\mp\gametypes\_gameobjects::setUseHintText( "hold to revive "+ self.name );
		resBox maps\mp\gametypes\_gameobjects::set2DIcon( "friendly", "compass_waypoint_defend" );
		resBox maps\mp\gametypes\_gameobjects::set3DIcon( "friendly", "waypoint" );
		resBox maps\mp\gametypes\_gameobjects::setVisibleTeam( "friendly" );
		resBox.useWeapon = "briefcase_bomb_mp";

		deadPlayer.resBox = resBox;
		level.deadPlayers[team][self.name] = deadPlayer;
		self IprintLnBold("deadPlayers: " + level.deadPlayers[team].size);
	}
}

printInfo(pl, name1, name2, cause)
{
	pl IprintLnBold("Player " + name1 + " was killed by " + name2 + " using " + cause + ".\n He is ready to be revived. ;)");
}