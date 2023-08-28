#include common_scripts\utility;
#include maps\mp\_utility;

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

getPrimaryWeapon(class) {
	// ============= custom class selected ==============
	if( isSubstr( class, "CLASS_CUSTOM" ) )
	{
		// gets custom class data from stat bytes, if necessary
		self maps\mp\gametypes\_class::cac_getdata();

		// obtains the custom class number
		class_num = int( class[class.size-1] )-1;

		return self.custom_class[class_num]["primary"];

	// ============= default class selected ==============
	} else	{
		return level.classWeapons["allies"][class][0];
	}
}

getSecondaryWeapon(class) {
	// ============= custom class selected ==============
	if( isSubstr( class, "CLASS_CUSTOM" ) )
	{
		// gets custom class data from stat bytes, if necessary
		self maps\mp\gametypes\_class::cac_getdata();

		// obtains the custom class number
		class_num = int( class[class.size-1] )-1;

		return self.custom_class[class_num]["secondary"];

	// ============= default class selected ==============
	} else	{
		return level.classSidearm["allies"][class];
	}
}