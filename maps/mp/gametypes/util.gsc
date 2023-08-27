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