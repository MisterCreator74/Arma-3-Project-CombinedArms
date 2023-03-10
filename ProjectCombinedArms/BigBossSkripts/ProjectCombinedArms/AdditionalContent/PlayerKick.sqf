

addMissionEventHandler ["EntityKilled", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	
	
	
	if (isPlayer _unit && (side player == side _killer)) then 
		{
			_id = getPlayerID _killer;
			hint "Friendly Fire detected";
			"Eigenbeschuss ist verboten" remoteExec ["hintC", _killer];
			serverPassword serverCommand format ["#kick %1",_id];
		};

}];
