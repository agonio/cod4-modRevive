#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_globallogic;
#include common_scripts\utility;

main()
{
    if(getDvar("scr_game_finalkillcam") == "")
        setDvar("scr_game_finalkillcam", 1);
    
    level.showingfinalkillcam = false;
    level.killcam_style = 0;
    level.Winner = undefined;
    level.InEndGame = false;
    
    level.finalkillcam = getDvarInt("scr_game_finalkillcam" );
    
    thread FKonPlayerConnect();
}

FKonPlayerConnect()
{
    for(;;)
    {
        level waittill("connecting", player);
        
        player thread onBeginKillcam();
    }
}

onBeginKillcam()
{
    for(;;)
    {
        self waittill("begin_FK");
        
        level.killcamstart = GetTime()/1000;
    
        self notify ( "reset_outcome" );
        
        if(level.teambased)
        {
            self maps\mp\gametypes\_killcam::killcam(
            level.FK[level.winner]["attackerNum"],
            level.FK[level.winner]["killcamentity"],
            level.FK[level.winner]["sWeapon"],
            0,
            0,
            0,
            undefined,
            level.FK[level.winner]["perks"],
            level.FK[level.winner]["attacker"],
            level.FK[level.winner]["deathTime"]);
        }
        else
        {
            self maps\mp\gametypes\_killcam::killcam(
            level.winner.FK["attackerNum"],
            level.winner.FK["killcamentity"],
            level.winner.FK["sWeapon"],
            0,
            0,
            0,
            undefined,
            level.winner.FK["perks"],
            level.winner.FK["attacker"],
            level.winner.FK["deathTime"]);
        }
    }
}
        
onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
    if(attacker != self)
    {
        team = attacker.team;
        level.FK[team]["attackerNum"] = attacker getEntityNumber();
        
        //if(isDefined(eInflictor))
            //level.FK[team]["killcamentity"] = eInflictor getEntityNumber();
       // else
            level.FK[team]["killcamentity"] = -1;
        
        level.FK[team]["sWeapon"] = sWeapon;
        level.FK[team]["PreDelay"] = psOffsetTime;
        level.FK[team]["attacker"] = attacker;
        level.FK[team]["perks"] = attacker maps\mp\gametypes\_globallogic::GetPerks();
        level.FK[team]["deathTime"] = GetTime()/1000;     
        
        attacker.FK["attackerNum"] = attacker getEntityNumber();
        
        //if(isDefined(eInflictor))
            //level.FK[team]["killcamentity"] = eInflictor getEntityNumber();
       // else
            attacker.FK["killcamentity"] = -1;
        
        attacker.FK["sWeapon"] = sWeapon;
        attacker.FK["PreDelay"] = psOffsetTime;
        attacker.FK["attacker"] = attacker;
        attacker.FK["perks"] = attacker maps\mp\gametypes\_globallogic::GetPerks();
        attacker.FK["deathTime"] = GetTime()/1000;
        level.victim = self;
    }
}

endGameFK( winner, endReasonText  )
{
    if(level.InEndGame)
        return;
    
    level.InEndGame = true;
    
    if ( isdefined( winner ) && level.gametype == "sd" )
		[[level._setTeamScore]]( winner, [[level._getTeamScore]]( winner ) + 1 );

	// return if already ending via host quit or victory
	if ( game["state"] == "postgame" || level.gameEnded )
		return;

	visionSetNaked( "mpOutro", 2.0 );
	
	game["state"] = "postgame";
	level.gameEndTime = getTime();
	level.gameEnded = true;
	level.inGracePeriod = false;
	level notify ( "game_ended" );
	
	setGameEndTime( 0 ); // stop/hide the timers
	
	if ( level.rankedMatch )
	{
		setXenonRanks();
		
		if ( hostIdledOut() )
		{
			level.hostForcedEnd = true;
			logString( "host idled out" );
			endLobby();
		}
	}
	
	updatePlacement();
	updateMatchBonusScores( winner );
	updateWinLossStats( winner );
	
	setdvar( "g_deadChat", 1 );
	
	// freeze players
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		player freezePlayerForRoundEnd();
		player thread roundEndDoF( 4.0 );
		
		player freeGameplayHudElems();
		
		player setClientDvars( "cg_everyoneHearsEveryone", 1 );

		if( level.rankedMatch )
		{
			if ( isDefined( player.setPromotion ) )
				player setClientDvar( "ui_lobbypopup", "promotion" );
			else
				player setClientDvar( "ui_lobbypopup", "summary" );
		}
	}

    // end round
    if ( (level.roundLimit > 1 || (!level.roundLimit && level.scoreLimit != 1)) && !level.forcedEnd )
    {
		if ( level.displayRoundEndText )
		{
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];
				
				if ( level.teamBased )
					player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, true, endReasonText );
				else
					player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
		
				player setClientDvars( "ui_hud_hardcore", 1,
									   "cg_drawSpectatorMessages", 0,
									   "g_compassShowEnemies", 0 );
			}

			if ( level.teamBased && !(hitRoundLimit() || hitScoreLimit()) )
				thread announceRoundWinner( winner, level.roundEndDelay / 4 );
			
			if ( hitRoundLimit() || hitScoreLimit() )
				roundEndWait( level.roundEndDelay / 2, false );
			else
				roundEndWait( level.roundEndDelay, true );
		}

      //Final Killcam
      if(level.players.size > 0 && level.gametype == "sd")
      {
        if( !maps\mp\gametypes\_globallogic::hitScoreLimit() )
            level.killcam_style = 1;
        else
            level.killcam_style = 0;
        
        FinalKillcamTeam( winner );
        
        if(level.showingFinalKillcam)
            level waittill("end_killcam");
        
        
         level.showingFinalKillcam = false;
      }

		game["roundsplayed"]++;
		roundSwitching = false;
		if ( !hitRoundLimit() && !hitScoreLimit() )
			roundSwitching = checkRoundSwitch();

		if ( roundSwitching && level.teamBased )
		{
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];
				
				if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
				{
					player [[level.spawnIntermission]]();
					player closeMenu();
					player closeInGameMenu();
					continue;
				}
				
				switchType = level.halftimeType;
				if ( switchType == "halftime" )
				{
					if ( level.roundLimit )
					{
						if ( (game["roundsplayed"] * 2) == level.roundLimit )
							switchType = "halftime";
						else
							switchType = "intermission";
					}
					else if ( level.scoreLimit )
					{
						if ( game["roundsplayed"] == (level.scoreLimit - 1) )
							switchType = "halftime";
						else
							switchType = "intermission";
					}
					else
					{
						switchType = "intermission";
					}
				}
				switch( switchType )
				{
					case "halftime":
						player leaderDialogOnPlayer( "halftime" );
						break;
					case "overtime":
						player leaderDialogOnPlayer( "overtime" );
						break;
					default:
						player leaderDialogOnPlayer( "side_switch" );
						break;
				}
				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, level.halftimeSubCaption );
				player setClientDvar( "ui_hud_hardcore", 1 );
			}
			
			roundEndWait( level.halftimeRoundEndDelay, false );
		}
		else if ( !hitRoundLimit() && !hitScoreLimit() && !level.displayRoundEndText && level.teamBased )
		{
			players = level.players;
			for ( index = 0; index < players.size; index++ )
			{
				player = players[index];

				if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
				{
					player [[level.spawnIntermission]]();
					player closeMenu();
					player closeInGameMenu();
					continue;
				}
				
				switchType = level.halftimeType;
				if ( switchType == "halftime" )
				{
					if ( level.roundLimit )
					{
						if ( (game["roundsplayed"] * 2) == level.roundLimit )
							switchType = "halftime";
						else
							switchType = "roundend";
					}
					else if ( level.scoreLimit )
					{
						if ( game["roundsplayed"] == (level.scoreLimit - 1) )
							switchType = "halftime";
						else
							switchTime = "roundend";
					}
				}
				switch( switchType )
				{
					case "halftime":
						player leaderDialogOnPlayer( "halftime" );
						break;
					case "overtime":
						player leaderDialogOnPlayer( "overtime" );
						break;
				}
				player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( switchType, true, endReasonText );
				player setClientDvar( "ui_hud_hardcore", 1 );
			}			

			roundEndWait( level.halftimeRoundEndDelay, !(hitRoundLimit() || hitScoreLimit()) );
		}

        if ( !hitRoundLimit() && !hitScoreLimit() )
        {
        	level notify ( "restarting" );
            game["state"] = "playing";
            map_restart( true );
            return;
        }
        
		if ( hitRoundLimit() )
			endReasonText = game["strings"]["round_limit_reached"];
		else if ( hitScoreLimit() )
			endReasonText = game["strings"]["score_limit_reached"];
		else
			endReasonText = game["strings"]["time_limit_reached"];
	}
	
	thread maps\mp\gametypes\_missions::roundEnd( winner );
	
	// catching gametype, since DM forceEnd sends winner as player entity, instead of string
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];

		if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
		{
			player [[level.spawnIntermission]]();
			player closeMenu();
			player closeInGameMenu();
			continue;
		}
		
		if ( level.teamBased )
		{
			player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, false, endReasonText );
		}
		else
		{
			player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
			
			if ( isDefined( winner ) && player == winner )
				player playLocalSound( game["music"]["victory_" + player.pers["team"] ] );
			else if ( !level.splitScreen )
				player playLocalSound( game["music"]["defeat"] );
		}
		
		player setClientDvars( "ui_hud_hardcore", 1,
							   "cg_drawSpectatorMessages", 0,
							   "g_compassShowEnemies", 0 );
	}
	
	if ( level.teamBased )
	{
		thread announceGameWinner( winner, level.postRoundTime / 2 );
		
		if ( level.splitscreen )
		{
			if ( winner == "allies" )
				playSoundOnPlayers( game["music"]["victory_allies"], "allies" );
			else if ( winner == "axis" )
				playSoundOnPlayers( game["music"]["victory_axis"], "axis" );
			else
				playSoundOnPlayers( game["music"]["defeat"] );
		}
		else
		{
			if ( winner == "allies" )
			{
				playSoundOnPlayers( game["music"]["victory_allies"], "allies" );
				playSoundOnPlayers( game["music"]["defeat"], "axis" );
			}
			else if ( winner == "axis" )
			{
				playSoundOnPlayers( game["music"]["victory_axis"], "axis" );
				playSoundOnPlayers( game["music"]["defeat"], "allies" );
			}
			else
			{
				playSoundOnPlayers( game["music"]["defeat"] );
			}
		}
	}
	
	roundEndWait( level.postRoundTime, true );
   
    //Final Killcam
    if(level.players.size > 0 && level.gametype != "sd")
    {
        level.killcam_style = 0;
        
        FinalKillcamTeam( winner );
        
        if(level.showingFinalKillcam)
            level waittill("end_killcam");
        
        
        level.showingFinalKillcam = false;
    }
	
	level.intermission = true;
	
	//regain players array since some might've disconnected during the wait above
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		player closeMenu();
		player closeInGameMenu();
		player notify ( "reset_outcome" );
		player thread spawnIntermission();
		player setClientDvar( "ui_hud_hardcore", 0 );
		player setclientdvar( "g_scriptMainMenu", game["menu_eog_main"] );
	}
	
	logString( "game ended" );
	wait getDvarFloat( "scr_show_unlock_wait" );
	
	if( level.console )
	{
		exitLevel( false );
		return;
	}
	
	// popup for game summary
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		//iPrintLnBold( "opening eog summary!" );
		//player.sessionstate = "dead";
		player openMenu( game["menu_eog_unlock"] );
	}
	
	thread timeLimitClock_Intermission( getDvarFloat( "scr_intermission_time" ) );
	wait getDvarFloat( "scr_intermission_time" );
	
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		//iPrintLnBold( "closing eog summary!" );
		player closeMenu();
		player closeInGameMenu();
	}
	
	exitLevel( false );
}

FinalKillcamTeam( winner )
{
    level.winner = winner;

    if(!level.finalkillcam)
        return;
    
    level.showingFinalKillcam = true;
    
    for( i = 0; i < level.players.size; i++)
    {
        level.players[i] notify("begin_FK");
    }
}