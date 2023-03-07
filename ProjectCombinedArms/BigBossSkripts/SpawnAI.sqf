/*
	Autor: MisterCreator74
	Version: 1.0
	Beschreibung:
	Spawnt Truppen, Fahrzeuge, und alle AI Einheiten. Beinhaltet auch Parkplätze. Die Arrays z.b.: _bluVehSpawn zeigen in Subbarray auch an ob ein Platz belegt ist [["Blu_Veh_Spawn_1","Occupied"],["Blu_Veh_Spawn_2", "Unoccupied"]]
	
	

	Benötigete Marker:
		"Base_Blufor"  -> markiert Blufor Basis
		"Base_Opfor"	-> markiert Opfor Basis
		
		Es können beliebig Viele Parkplatzmarker festgelegt werden.
		
*/

sleep startup_delay;

// Variablen definieren
// Referenzen auf die Spawn-Punkte (Base_Blufor und Base_Opfor)
_base_blufor = "Base_Blufor";
_base_opfor = "Base_Opfor";



for "_i" from 0 to max_AI_Troops / AI_TroopSize do 
{
	_savePos = [getMarkerPos "Base_Blufor", 0, 100, 20, 0, 20, 0, [],getMarkerPos "Base_Blufor"] call BIS_fnc_findSafePos;
	[_savePos, WEST , AI_TroopSize,[], [], [], [], [], 0, true, 1] call BIS_fnc_spawnGroup;
};

for "_i" from 0 to max_AI_Troops / AI_TroopSize do 
{
_savePos = [getMarkerPos "Base_Opfor", 0, 100, 20, 0, 20, 0, [],getMarkerPos "Base_Opfor"] call BIS_fnc_findSafePos;
[_savePos, EAST , AI_TroopSize,[], [], [], [], [], 0, true, 1] call BIS_fnc_spawnGroup;
};


0 spawn 
{
	while {true} do 
		{
			_NOWPlayers = count (units blufor select { isPlayer _x });
			_WUnits = count units West - _NOWPlayers;
			_NOEPlayers = count (units EAST select { isPlayer _x });
			_EUnits = count units EAST - _NOEPlayers;
			
			if (show_debug_hints == true) then
			{
				hint format ["West Units: %1 \n East Units: %2", _WUnits, _EUnits];
			};
			
			
			if (_WUnits < (max_AI_Troops * 0.8)) then
				{
					//hint "threshold activated";
					_savePos = [getMarkerPos "Base_Blufor", 0, 100, 20, 0, 20, 0, [],getMarkerPos "Base_Blufor"] call BIS_fnc_findSafePos;
					[_savePos, WEST , AI_TroopSize,[], [], [], [], [], 0, true, 1] call BIS_fnc_spawnGroup;
				};
			if (_EUnits < (max_AI_Troops * 0.8)) then
				{
					//hint "threshold E activated";
					_savePos = [getMarkerPos "Base_Opfor", 0, 100, 20, 0, 20, 0, [],getMarkerPos "Base_Opfor"] call BIS_fnc_findSafePos;
					[_savePos, East , AI_TroopSize,[], [], [], [], [], 0, true, 1] call BIS_fnc_spawnGroup;
				};	

					
			

			sleep 5;
		};
};



// Blufor Transport spawning
_mapmarkers = allMapMarkers;
_blumarkers = _mapmarkers select {["blu",_x, true] call BIS_fnc_inString;};
bluVehSpawn = _mapmarkers select {["spawn",_x, true] call BIS_fnc_inString;};
bluVehSpawn = _mapmarkers select {["Veh",_x, true] call BIS_fnc_inString;};
_NOBVS = count bluVehSpawn;
for "_i" from 0 to _NOBVS -1 do 
	{
		_marker = bluVehSpawn select _i;
		_spawnPos = getMarkerpos _marker;
		bluVehSpawn set [_i, [bluVehSpawn select _i, "1"]];
		_subarray = bluVehSpawn select _i;
		_Vehtrg = [bluVehSpawn select _i,"Trg"] joinstring "_";
		_Vehtrgtext = _Vehtrg;
		_Vehtrg = createTrigger ["EmptyDetector", _spawnPos];
		_Vehtrg setTriggerText _Vehtrgtext;
		_Vehtrg setTriggerArea [10,10,10, false];
		_Vehtrg setTriggerActivation ["Any","present", true];
		_Vehtrg setVariable ["_subarray",_subarray, true];
		_Vehtrg setTriggerStatements ["this", tostring {
													_subarray = thisTrigger getVariable "_subarray";
													_subarray set [1, "1"];
													
													}, tostring {
													_subarray = thisTrigger getVariable "_subarray";
													_subarray set [1, "0"];}];
		
		_truck = BluTransportTruck createVehicle _spawnPos;
		createVehicleCrew _truck;
		sleep 1;
	};

// Opfor Transport spawning	
_mapmarkers = allMapMarkers;
_Opfmarkers = _mapmarkers select {["Opf",_x, true] call BIS_fnc_inString;};
_OpfVehSpawn = _mapmarkers select {["spawn",_x, true] call BIS_fnc_inString;};
_OpfVehSpawn = _mapmarkers select {["Veh",_x, true] call BIS_fnc_inString;};
_NOOVS = count _OpfVehSpawn;
for "_i" from 0 to _NOOVS -1 do 
	{
		_marker = _OpfVehSpawn select _i;
		_spawnPos = getMarkerpos _marker;
		_truck = OpfTransportTruck createVehicle _spawnPos;
		createVehicleCrew _truck;
		sleep 1;
	};

[bluVehSpawn] spawn 
{	
	params ["_BluVehSpawn"];
	while {true} do
	{

		bluVehSpawn = [
			bluVehSpawn,
			[],
				{
					_x params ["_name","_status"];

					_status; //must return string, number, or array
				},
				"ASCEND"
				
		] call BIS_fnc_sortBy;
		//hint format ["%1",_BluVehSpawn];
		sleep 1;
	};
};



		
