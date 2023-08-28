setup() {
    
	level.serverDvars = [];

    // perks
	setServerDvarDefault( "perk_forbid_specialty_parabolic", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_gpsjammer", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_holdbreath", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_quieter", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_longersprint", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_detectexplosive", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_explosivedamage", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_pistoldeath", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_grenadepulldeath", 1, 0, 1 );	// default 1 forbid
	setServerDvarDefault( "perk_forbid_specialty_bulletdamage", 1, 0, 1 );		// default 1 forbid
	setServerDvarDefault( "perk_forbid_specialty_bulletpenetration", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_bulletaccuracy", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_twoprimaries", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_rof", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_fastreload", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_extraammo", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_armorvest", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_fraggrenade", 1, 0, 1 ); 		// default 1 forbid
	setServerDvarDefault( "perk_forbid_specialty_specialgrenade", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_weapon_c4", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_weapon_claymore", 0, 0, 1 );
	setServerDvarDefault( "perk_forbid_specialty_weapon_rpg", 0, 0, 1 );
}

// default shall always be enabled
perkIndexIfAllowed(name, referenceArr) {
    if (isdefined(getDvar( "perk_forbid_"+name )) && getDvarFloat("perk_forbid_"+name) == 1) {
        return 190; // undefined perk index
    }
    return referenceArr[name];
}

// set a dvar to a default value or, if it already has a value, assure that it's in the valid range
setDvarDefault( dvarName, setVal, minVal, maxVal )
{
	// no value set
	if ( getDvar( dvarName ) != "" )
	{
		if ( isString( setVal ) )
			setVal = getDvar( dvarName );
		else
			setVal = getDvarFloat( dvarName );
	}
		
	if ( isDefined( minVal ) && !isString( setVal ) )
		setVal = max( setVal, minVal );

	if ( isDefined( maxVal ) && !isString( setVal ) )
		setVal = min( setVal, maxVal );

	setDvar( dvarName, setVal );
	return setVal;
}


// set a dvar to a default value or, if it already has a value, assure that it's in the valid range
// server dvars should always be updated to client when they change
setServerDvarDefault( dvarName, setVal, minVal, maxVal )
{
	setVal = setDvarDefault( dvarName, setVal, minVal, maxVal );

	level.serverDvars[dvarName] = setVal;
}