#include common_scripts\utility;
#include maps\mp\_utility;

removeGl(weapon) {
	for( i = 0 ; i < weapon.size - 2 ; i ++ ) {
		if(weapon[i] == "_" && weapon[i+1] == "g" && weapon[i+2] == "l") {
			return getSubStr(weapon, 0, i) + "_mp";
		}
	}
	return weapon;
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

// gets custom class struct
getCustomClassStruct(class) {
	// gets custom class data from stat bytes, if necessary
	self maps\mp\gametypes\_class::cac_getdata();

	// obtains the custom class number
	class_num = int( class[class.size-1] )-1;

	return self.custom_class[class_num];
}

getPrimaryWeapon(class) {
	if( isSubstr( class, "CLASS_CUSTOM" ) )
	{
		classStruct = self getCustomClassStruct(class);

		return classStruct["primary"];
	} else {
		return level.classWeapons["allies"][class][0];
	}
}

getSecondaryWeapon(class) {
	if( isSubstr( class, "CLASS_CUSTOM" ) )
	{
		classStruct = self getCustomClassStruct(class);

		return classStruct["secondary"];
	} else {
		return level.classSidearm["allies"][class];
	}
}

//rpg, c4, claymore
getInventoryWeapon(class) {
	if( isSubstr( class, "CLASS_CUSTOM" ) )
	{
		classStruct = self getCustomClassStruct(class);

		return classStruct["inventory"];
	} else {
		return level.classItem["allies"][class]["type"];
	}
}

getGrenadeWeapon(class) {
	if( isSubstr( class, "CLASS_CUSTOM" ) )
	{
		classStruct = self getCustomClassStruct(class);

		return classStruct["grenades"];
	} else {
		return level.classGrenades[class]["primary"]["type"];
	}
}

getSpecialNadeWeapon(class) {
	if( isSubstr( class, "CLASS_CUSTOM" ) )
	{
		classStruct = self getCustomClassStruct(class);

		return classStruct["specialgrenades"];
	} else {
		return level.classGrenades[class]["secondary"]["type"];
	}
}