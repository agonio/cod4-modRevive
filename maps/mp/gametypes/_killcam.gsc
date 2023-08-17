#include maps\mp\gametypes\_hud_util;

/*#########################
FzBr.Dark
deividandreolasmo@hotmail.com
#########################*/
init()
{
	precacheString(&"PLATFORM_PRESS_TO_SKIP");
	precacheString(&"PLATFORM_PRESS_TO_RESPAWN");
	precacheShader("white");
   precacheShader("waypoint_target");
    
    maps\mp\gametypes\_finalkillcam::main();
    maps\mp\gametypes\_dBots::init();

	level.killcam = maps\mp\gametypes\_tweakables::getTweakableValue( "game", "allowkillcam" );
	
	if( level.killcam || level.finalkillcam)
		setArchive(true);
}

killcam(
	attackerNum, // entity number of the attacker
	killcamentity, // entity number of the attacker's killer entity aka helicopter or airstrike
	sWeapon, // killing weapon
	predelay, // time between player death and beginning of killcam
	offsetTime, // something to do with how far back in time the killer was seeing the world when he made the kill; latency related, sorta
	respawn, // will the player be allowed to respawn after the killcam?
	maxtime, // time remaining until map ends; the killcam will never last longer than this. undefined = no limit
	perks, // the perks the attacker had at the time of the kill
	attacker, // entity object of attacker
   deathtime
)
{
	// monitors killcam and hides HUD elements during killcam session
	//if ( !level.splitscreen )
	//	self thread killcam_HUD_off();
	
	self endon("disconnect");
	self endon("spawned");
	level endon("game_ended");
    
	if(attackerNum < 0)
   {
       self endKillcam();
       return;
   }
   
   if(level.showingFinalKillcam)
   {
       self SetClientDvar("ui_ShowMenuOnly", "none");
       self thread CreateFKMenu();
   }
   
	// length from killcam start to killcam end
	if (getdvar("scr_killcam_time") == "") {
		if (sWeapon == "artillery_mp")
			camtime = 1.3;
		else if ( !respawn ) // if we're not going to respawn, we can take more time to watch what happened
			camtime = 5.0;
		else if (sWeapon == "frag_grenade_mp")
			camtime = 4.5; // show long enough to see grenade thrown
		else
			camtime = 2.5;
	}
	else
		camtime = getdvarfloat("scr_killcam_time");
	
	if (isdefined(maxtime)) {
		if (camtime > maxtime)
			camtime = maxtime;
		if (camtime < .05)
			camtime = .05;
	}
   
	if(level.showingfinalkillcam)
        predelay = level.killcamstart - deathtime;
   
	// time after player death that killcam continues for
	if (getdvar("scr_killcam_posttime") == "")
		postdelay = 2;
	else {
		postdelay = getdvarfloat("scr_killcam_posttime");
		if (postdelay < 0.05)
			postdelay = 0.05;
	}
   
   if(level.showingfinalkillcam)
       postdelay = 1.5;
	
	/* timeline:
	
	|        camtime       |      postdelay      |
	|                      |   predelay    |
	
	^ killcam start        ^ player death        ^ killcam end
	                                       ^ player starts watching killcam
	
	*/
	
	killcamlength = camtime + postdelay;
	level.killcamlength = killcamlength;
   
	
	// don't let the killcam last past the end of the round.
	if (isdefined(maxtime) && killcamlength > maxtime)
	{
		// first trim postdelay down to a minimum of 1 second.
		// if that doesn't make it short enough, trim camtime down to a minimum of 1 second.
		// if that's still not short enough, cancel the killcam.
		if (maxtime < 2)
			return;

		if (maxtime - camtime >= 1) {
			// reduce postdelay so killcam ends at end of match
			postdelay = maxtime - camtime;
		}
		else {
			// distribute remaining time over postdelay and camtime
			postdelay = 1;
			camtime = maxtime - 1;
		}
		
		// recalc killcamlength
		killcamlength = camtime + postdelay;
	}

	killcamoffset = camtime + predelay;
	 visionSetNaked( getdvar("mapname") );
	self notify ( "begin_killcam", getTime() );
   	
	self.sessionstate = "spectator";
	self.spectatorclient = attackerNum;
	self.killcamentity = killcamentity;
	self.archivetime = killcamoffset;
	self.killcamlength = killcamlength;
	self.psoffsettime = offsetTime;

	// ignore spectate permissions
	self allowSpectateTeam("allies", true);
	self allowSpectateTeam("axis", true);
	self allowSpectateTeam("freelook", true);
	self allowSpectateTeam("none", true);
   
	if ( isDefined( attacker ) && level.showingFinalKillcam ) // attacker may have disconnected
	{
        
	}
	self thread endedKillcamCleanup();
	// wait till the next server frame to allow code a chance to update archivetime if it needs trimming
	wait 0.05;

	if ( self.archivetime <= predelay && !level.showingfinalkillcam) // if we're not looking back in time far enough to even see the death, cancel
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		
		return;
	}
	
	self.killcam = true;
   
   if(!level.showingFinalKillcam)
   {
       if ( !isdefined( self.kc_skiptext ) )
       {
          self.kc_skiptext = newClientHudElem(self);
          self.kc_skiptext.archived = false;
          self.kc_skiptext.x = 0;
          self.kc_skiptext.alignX = "center";
          self.kc_skiptext.alignY = "middle";
          self.kc_skiptext.horzAlign = "center_safearea";
          self.kc_skiptext.vertAlign = "top";
          self.kc_skiptext.sort = 1; // force to draw after the bars
          self.kc_skiptext.font = "objective";
          self.kc_skiptext.foreground = true;
          
          if ( level.splitscreen )
          {
             self.kc_skiptext.y = 34;
             self.kc_skiptext.fontscale = 1.6;
          }
          else
          {
             self.kc_skiptext.y = 60;
             self.kc_skiptext.fontscale = 2;
          }
       }
       if ( respawn )
          self.kc_skiptext setText(&"PLATFORM_PRESS_TO_RESPAWN");
       else
          self.kc_skiptext setText(&"PLATFORM_PRESS_TO_SKIP");
          
       self.kc_skiptext.alpha = 1;
   }
   else
   {
       if ( !isdefined( self.kc_nametext ) )
       {
          self.kc_nametext = newClientHudElem(self);
          self.kc_nametext.archived = false;
          self.kc_nametext.x = 0;
          self.kc_nametext.y = -85;
          self.kc_nametext.alignX = "center";
          self.kc_nametext.alignY = "bottom";
          self.kc_nametext.horzAlign = "center_safearea";
          self.kc_nametext.vertAlign = "bottom";
          self.kc_nametext.sort = 1; // force to draw after the bars
          self.kc_nametext.font = "default";
          self.kc_nametext.fontscale = 1.4;
          self.kc_nametext.foreground = true;
       }
       
       self.kc_nametext setText( attacker.name );
       self.kc_nametext.alpha = 1;
   }
   
	if ( !level.splitscreen )
	{
		if ( !isdefined( self.kc_tsdaimer ) )
		{
			self.kc_timer = createFontString( "objective", 2.0 );
			if ( level.console )
				self.kc_timer setPoint( "TOP", undefined, 0, 80 );
			else
				self.kc_timer setPoint( "TOP", undefined, 0, 80 );
			self.kc_timer.archived = false;
			self.kc_timer.foreground = true;
         self.kc_timer.sort = 1;
			/*
			self.kc_timer.x = 0;
			self.kc_timer.y = -32;
			self.kc_timer.alignX = "center";
			self.kc_timer.alignY = "middle";
			self.kc_timer.horzAlign = "center_safearea";
			self.kc_timer.vertAlign = "bottom";
			self.kc_timer.fontScale = 2.0;
			self.kc_timer.sort = 1;
			*/
		}
		
		self.kc_timer.alpha = 1;
		self.kc_timer setTenthsTimer(camtime);
		
		self showPerk( 0, perks[0], -10 );
		self showPerk( 1, perks[1], -10 );
		self showPerk( 2, perks[2], -10 );
	}

	self thread spawnedKillcamCleanup();
	self thread endedKillcamCleanup();
   
   if(!level.showingFinalKillcam)
        self thread waitSkipKillcamButton();
   
	self thread waitKillcamTime();
   
	self waittill("end_killcam");

	self endKillcam();

	self.sessionstate = "dead";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
}

waitKillcamTime()
{
	self endon("disconnect");
	self endon("end_killcam");

	wait(self.killcamlength - 0.05);
   
	self notify("end_killcam");

}

waitSkipKillcamButton()
{
	self endon("disconnect");
	self endon("end_killcam");

	while(self useButtonPressed())
		wait .05;

	while(!(self useButtonPressed()))
		wait .05;

	self notify("end_killcam");
}

endKillcam()
{
	if(isDefined(self.kc_skiptext))
		self.kc_skiptext.alpha = 0;
	if(isDefined(self.kc_timer))
		self.kc_timer.alpha = 0;
   if(isDefined(self.kc_nametext))
       self.kc_nametext.alpha = 0;
   
   if(isDefined(self.top_fk_shader))
       self.top_fk_shader.alpha = 0;
   if(isDefined(self.bottom_fk_shader))
       self.bottom_fk_shader.alpha = 0;
   if(isDefined (self.fk_title))
       self.fk_title.alpha = 0;
	
	if ( !level.splitscreen )
	{
		self hidePerk( 0 );
		self hidePerk( 1 );
		self hidePerk( 2 );
	}
	self.killcam = undefined;
	
	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
   
   level notify("end_killcam");
   setDvar("timescale", 1);
   level.showingFinalKillcam = false;
   
   if ( !level.splitscreen )
	{
		self hidePerk( 0 );
		self hidePerk( 1 );
		self hidePerk( 2 );
	}
   self SetClientDvar("ui_ShowMenuOnly", "");
}

CreateFKMenu()
{
    self.top_fk_shader = newClientHudElem(self);
    self.top_fk_shader.elemType = "shader";
    self.top_fk_shader.archived = false;
    self.top_fk_shader.horzAlign = "fullscreen";
    self.top_fk_shader.vertAlign = "fullscreen";
    self.top_fk_shader.sort = 0;
    self.top_fk_shader.foreground = true;
    self.top_fk_shader.color	= (.15, .15, .15);
    self.top_fk_shader setShader("white",640,112);
    self.top_fk_shader.alpha = 0.5;
    
    self.bottom_fk_shader = newClientHudElem(self);
    self.bottom_fk_shader.elemType = "shader";
    self.bottom_fk_shader.y = 368;
    self.bottom_fk_shader.archived = false;
    self.bottom_fk_shader.horzAlign = "fullscreen";
    self.bottom_fk_shader.vertAlign = "fullscreen";
    self.bottom_fk_shader.sort = 0; 
    self.bottom_fk_shader.foreground = true;
    self.bottom_fk_shader.color	= (.15, .15, .15);
    self.bottom_fk_shader setShader("white",640,112);
    self.bottom_fk_shader.alpha = 0.5;
    
    self.fk_title = newClientHudElem(self);
    self.fk_title.archived = false;
    self.fk_title.y = 45;
    self.fk_title.alignX = "center";
    self.fk_title.alignY = "middle";
    self.fk_title.horzAlign = "center";
    self.fk_title.vertAlign = "top";
    self.fk_title.sort = 1; // force to draw after the bars
    self.fk_title.font = "objective";
    self.fk_title.fontscale = 3.5;
    self.fk_title.foreground = true;
    self.fk_title.shadown = 1;
    self.fk_title.shadown = 1;

    if( !level.killcam_style )
        self.fk_title setText("GAME WINNING KILL");
    else
        self.fk_title setText("ROUND WINNING KILL");
    self.fk_title.alpha = 1;
}

spawnedKillcamCleanup()
{
	self endon("end_killcam");
	self endon("disconnect");

	self waittill("spawned");
	self endKillcam();
}

spectatorKillcamCleanup( attacker )
{
	self endon("end_killcam");
	self endon("disconnect");
	attacker endon ( "disconnect" );

	attacker waittill ( "begin_killcam", attackerKcStartTime );
	waitTime = max( 0, (attackerKcStartTime - self.deathTime) - 50 );
	wait (waitTime);
	self endKillcam();
}

endedKillcamCleanup()
{
	self endon("end_killcam");
	self endon("disconnect");
	level waittill("game_ended");
	self endKillcam();
}
