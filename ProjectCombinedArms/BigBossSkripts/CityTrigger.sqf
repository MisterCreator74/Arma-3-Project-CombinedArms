
/*
	Author: MisterCreator74
	Version: 1.7.0 
	Description:
	Includes city-specific arrays. And functions and sensors to get feedback about the state of predefined cities.
	
	Needed to run:
	"Base_Blufor"   -> defines the Blufor Base
	"Base_Opfor"	-> defines the Opfor Base
	"city_CityName_Size_Status_PrioBlue_PrioOpf" -> Name can be any random string, Size can be "small" or "big", status can be contested, Blue, Opf, empty (Standard), BlueC und OpfC, prio can be number 1-3 or empty
	
	example:
	city_NewYork_big_empty_3_1
	
	available city variables are: 
	PCA_CityPosition | PCA_CityName | PCA_CitySize | PCA_CityStatus | PCA_CityBluPrio | PCA_CityOpfPrio | PCA_CityMarker	
	all variables can be globally retrieved and changed with: 
	_trigger = CityArray select *insert city index here* select 7;
	_variable = _trigger getVariable ["VariableName", "defaultValue if not assigned"];
	

		
	Dev area only:
	Array Content: [[position, name, größe, Status, prioBlu, prioOpf, MarkerName ,TriggerName],[position, name, größe, Status, prioBlu, prioOpf, MarkerName, TriggerName]]
*/

//getting all Map Markers
_mapmarkers = allMapMarkers;



//setting Variables for counting
_anzahlStaedte = 0;
_anzahlSpawnPunkte = 0;



//filling Arrays with markers
SpawnMarker = _mapmarkers select {["spawn",_x, true] call BIS_fnc_inString;};
CityArray = _mapmarkers select {["city",_x, true] call BIS_fnc_inString;};
BaseArray = _mapmarkers select {["Base",_x, true] call BIS_fnc_inString;};



//counting Arrays
_anzahlStaedte = count CityArray;
_anzahlSpawnPunkte = count SpawnMarker;
_anzahlBases = count BaseArray;



//if no cities found terminat Skript
if (_anzahlStaedte == 0) exitWith
	{
		if (show_debug_hints == true) then
			{
				hint "No Cities found, Array Skript terminated";
			};
		["Project CombinedArms: No Cities found, Array Skript terminated. Place Markers according to Skript header"] remoteExec ["systemChat", 0];
	};
if (_anzahlBases < 2) exitWith
	{
		["Project CombinedArms: Not all Bases found, Array Skript terminated. Please make sure to place a Base_Blufor & Base_Opfor marker in the editor"] remoteExec ["systemChat", 0];
	};
	
	
//Debug hints for setting up
if (show_debug_hints == true) then
	{
		hint format ["Spawnpoints: %1 \n Cities: %2" , _anzahlSpawnPunkte, _anzahlStaedte];
		sleep 5;
	};	
if (repeat_Array_hints == true) then
	{
		0 spawn
		{
			while {true} do
				{
					hint format["%1",CityArray];
					sleep 5;
				};
		};
	};
	


// generating new Array Typ with subarrays
{
	_content = CityArray select _forEachIndex;
	_markerName = _content;
	_position = getmarkerpos _content; 
	_content = _content splitString "_";
	_prioBlu = _content select 4;
	_prioBlu = parseNumber _prioBlu;
	_prioOpf = _content select 5;
	_prioOpf = parseNumber _prioOpf;
	_newArraycontent = [_position,_content select 1, _content select 2, _content select 3, _prioBlu, _prioOpf, _markerName];
	CityArray set [_forEachIndex, _newArraycontent];
}foreach CityArray;





//generating City Sensors
{	
	//querying the individual city values (user given in marker variable name)
	_subarray = CityArray select _forEachIndex;			 //-> opens the array at the city position
	_subArrayIndex = _forEachIndex;						 //-> saves the index of the subarray in the array
	_position = CityArray select _forEachIndex select 0;
	_name = CityArray select _forEachIndex select 1;
	_groesse = CityArray select _forEachIndex select 2;
	_status = CityArray select _forEachIndex select 3;
	_prioBlu = CityArray select _forEachIndex select 4;
	_prioOpf = CityArray select _forEachIndex select 5;
	


	// Dynamic Ressources spawning
	if (use_dynamic_ressources == true) then
		{
			//spawnen der Ressourcen für kleine Städte
			if (_groesse == "small") then
				{
					_anzahl = [0,1,2,3] call BIS_fnc_selectRandom;
					for "_i" from 0 to _anzahl +1 do 
						{
							_spawnPos = [_position, 0, (RANDOM 360)] call BIS_fnc_relPos;
							_spawnPos = [_spawnPos, 1, 150, 3, 0, 20, 0] call BIS_fnc_findSafePos;
							_ressources = ["I_supplyCrate_F","CargoNet_01_barrels_F","CargoNet_01_box_F"] call BIS_fnc_selectRandom;
							_obj = _ressources createVehicle _spawnPos;
							if (_ressources == "I_supplyCrate_F") then
								{
									clearBackpackCargo _obj;
									clearWeaponCargo _obj;
									clearMagazineCargo _obj;
									clearItemCargo _obj;							
								};
						};				
				};

								
									
			//spawnen der Ressourcen für große Städte
			if (_groesse == "big") then
				{
					_anzahl = [4,5,6,7,8,9] call BIS_fnc_selectRandom;
					for "_i" from 0 to _anzahl +1 do 
						{	
							_spawnPos = [_position, 0, (RANDOM 360)] call BIS_fnc_relPos;
							_spawnPos = [_spawnPos, 1, 150, 3, 0, 20, 0] call BIS_fnc_findSafePos;
							_ressources = ["I_supplyCrate_F","CargoNet_01_barrels_F","CargoNet_01_box_F"] call BIS_fnc_selectRandom;
							_obj1 = _ressources createVehicle _spawnPos;
							if (_ressources == "I_supplyCrate_F") then
								{
									clearBackpackCargo _obj1;
									clearWeaponCargo _obj1;
									clearMagazineCargo _obj1;
									clearItemCargo _obj1;
								};
						};
				};
		};
	
	
	_nametrg = ["trg", _name, _groesse] joinstring "_";
	_alreadySpawned = "notActivated";
	_nametrgtext = _nametrg;	
	_nametrg = createTrigger ["EmptyDetector", _position];
	_subarray set [7, _nametrg];
	_nametrg setTriggerText _nametrgtext;
	_nametrg setTriggerArea [city_size,city_size,city_size, false];
	_nametrg setTriggerActivation ["Any","present", true];    //->evtl auf repaeting true setzen
	_nametrg setVariable ["alreadySpawned",_alreadySpawned , true];
	_nametrg setVariable ["_subarray",_subarray, true];
	_nametrg setVariable ["_subArrayIndex", _subArrayIndex, true];
	_nametrg setTriggerStatements ["this",tostring
											{	
												_alreadySpawned = thisTrigger getVariable "alreadySpawned";
												_subarray = thisTrigger getVariable "_subarray";
												_subArrayIndex = thistrigger getVariable "_subArrayIndex";
												_countactivated = true;
												
												if (_alreadySpawned != "true") then
													{
														[_subarray,_subArrayIndex, _countactivated, thisTrigger] spawn
															{
																params ["_subarray", "_subArrayIndex", "_countactivated","_thistrigger"];
																
																while {true} do
																	{
																		_enemycount = {alive _x && _x inArea _thistrigger} count units EAST; 
																		_friendlycount = {alive _x && _x inArea _thistrigger} count units WEST;
																		_counter = 0;
																		_status = _subarray select 3;
																		_anticapture = 0;
																		
																		while {_enemycount >0 AND _friendlycount >0} do
																			{
																				_status = _subarray select 3;
																			
																				if(_enemycount > 2* _friendlycount) then
																					{
																						_counter = _counter +1;
																						sleep 1;
																						if (_counter == capture_time) exitWith
																							{
																								_subarray set [3,"Opf"];
																								_counter = 0;
																							};
																					}
																					else 
																					{
																						if (2* _enemycount < _friendlycount) then 
																							{
																								_counter = _counter +1;
																								sleep 1;
																								if (_counter == capture_time) exitWith
																									{
																										_subarray set [3,"Blue"];
																										_counter = 0;
																									};
																							}
																							else
																							{
																								_subarray set [3,"contested"];
																							};
																							
																					};		
																				_enemycount = {alive _x && _x inArea _thistrigger} count units EAST; 
																				_friendlycount = {alive _x && _x inArea _thistrigger} count units WEST;
																			};
																			
																		while {_enemycount == 0 AND _friendlycount == 0 AND (_status == "contested" OR _status == "Blue" OR _status == "Opf")} do	
																			{	
																				_counter = 0;
																				_status = _subarray select 3;
																				_enemycount = {alive _x && _x inArea _thistrigger} count units EAST; 
																				_friendlycount = {alive _x && _x inArea _thistrigger} count units WEST;
																				_subarray set [3,"empty"];
																				
																			};
																			
																		while {_enemycount == 0 AND _friendlycount >= 1} do
																			{	
																				_status = _subarray select 3;
																				if (_status == "OpfC") then
																				{
																					_counter = -capture_time;
																			        _subarray set [3, "contested"];
																					_anticapture = 1;
																				}
																				else
																				{
																					if (_status != "BlueC" AND _status != "Blue" AND _anticapture == 0) then 
																					{
																						_subarray set [3, "Blue"];
																						_counter = 0;
																					};
																					
																				};
																				_counter = _counter +1;
																				sleep 1;
																				if (_counter == capture_time) exitWith 
																					{
																						_subarray set [3, "BlueC"];
																						_counter = 0;
																						_anticapture = 0;
																					};
																				_enemycount = {alive _x && _x inArea _thistrigger} count units EAST; 
																				_firendlycount = {alive _x && _x inArea _thistrigger} count units WEST;
																			};
																			
																		while {_enemycount >= 1 AND _friendlycount == 0} do
																			{
																				_status = _subarray select 3;
																				if (_status == "BlueC") then
																				{
																					_counter = -capture_time;
																			        _subarray set [3, "contested"];
																					_anticapture = 1;
																				}
																				else 
																				{
																					if (_status != "OpfC" AND _status != "Opf" AND _anticapture == 0) then 
																					{
																						_subarray set [3, "Opf"];
																						_counter = 0;
																					};
																					
																				};
																				_counter = _counter +1;
																				sleep 1;
																				if (_counter == capture_time) exitWith 
																					{
																						_subarray set [3, "OpfC"];
																						_counter = 0;
																						_anticapture = 0;
																					};
																				_enemycount = {alive _x && _x inArea _thistrigger} count units EAST; 
																				_firendlycount = {alive _x && _x inArea _thistrigger} count units WEST;
																			};

																	};	
															};
													};
												thisTrigger setVariable ["alreadySpawned", "true"];										  
											},"_countactivated = false;"];
											
											
	if (_prioBlu == 0) then 
	{
		_distance = getmarkerpos "Base_Blufor" distance2d _position;
		if (_distance > 10000) then 
			{
				_prioBlu = 1;
			}
			else
			{
				if (_distance > 5000) then 
					{
						_prioBlu = 2;
					}
					else 
					{
						if (_distance < 5000) then 
							{
								_prioBlu = 3;
							};
					};
			};
		_subarray set [4, _prioBlu];
	};
	
	if (_prioOpf == 0) then 
	{
		_distance = getmarkerpos "Base_Opfor" distance2d _position;
		if (_distance > 10000) then 
			{
				_prioOpf = 1;
			}
			else
			{
				if (_distance > 5000) then 
					{
						_prioOpf = 2;
					}
					else 
					{
						if (_distance < 5000) then 
							{
								_prioOpf = 3;
							};
					};
			};
		_subarray set [5, _prioOpf];
	};

}foreach CityArray;


sleep 1;

[format["Project CombinedArms: City system initialized with %1 recognized cities" , _anzahlStaedte]] remoteExec ["systemChat", 0];



0 spawn 
{	
	sleep 5;
	["Project CombinedArms: City priority system launched"] remoteExec ["systemChat", 0];

	
	while {true} do
		{
			{
				_subarray = CityArray select _forEachIndex;			 //-> opens the array at the city position
				_subArrayIndex = _forEachIndex;						 //-> saves the index of the subarray in the array
				_position = CityArray select _forEachIndex select 0;
				_name = CityArray select _forEachIndex select 1;
				_groesse = CityArray select _forEachIndex select 2;
				_status = CityArray select _forEachIndex select 3;
				_prioBlu = CityArray select _forEachIndex select 4;
				_prioOpf = CityArray select _forEachIndex select 5;
				
				// Blufor Prio Anpassung
				if (_status == "Blue" OR _status == "BlueC") then				
					{

						if (_prioBlu > 10 AND _status != "contested") then
							{
								_prioBlu = _prioBlu - 20;
								
							}
							else 
							{
							if ( _prioBlu > 0 AND _status != "empty" AND _status != "contested") then
								{
									_prioBlu = _prioBlu - 10;
								};
							};
					};
					
				if (_status == "Opf" OR _status == "OpfC") then
					{						
						if (_prioBlu < 0 AND _status != "contested") then
							{
								_prioBlu = _prioBlu + 20;
							}
							else 
							{
								if (_prioBlu < 10 AND _status != "empty" AND _status != "contested") then
									{
										_prioBlu = _prioBlu + 10;
									};
							};
				
					};
				_subarray set [4, _prioBlu];
				
				// Opfor Prio Anpassung
				if (_status == "Opf" OR _status == "OpfC") then				
					{

						if (_prioOpf > 10 AND _status != "contested") then
							{
								_prioOpf = _prioOpf - 20;
								
							}
							else 
							{
							if ( _prioOpf > 0 AND _status != "empty" AND _status != "contested") then
								{
									_prioOpf = _prioOpf - 10;
								};
							};
					};
					
				if (_status == "Blue" OR _status == "BlueC") then
					{						
						if (_prioOpf < 0 AND _status != "contested") then
							{
								_prioOpf = _prioOpf + 20;
							}
							else 
							{
								if (_prioOpf < 10 AND _status != "empty" AND _status != "contested") then
									{
										_prioOpf = _prioOpf + 10;
									};
							};
				
					};
				_subarray set [5, _prioOpf];
				
				
				
				
				
			}foreach CityArray;
			sleep 5;
		};
};					




// setVariable workaround -> Variables beeing set to triggers instead of markers
0 spawn 
{
	sleep startup_delay;

	while {true} do
	{
		
		{

			_position = _x select 0;
			_name = _x select 1;
			_groesse = _x select 2;
			_status = _x select 3;
			_prioBlu =  _x select 4;
			_prioOpf = _x select 5;
			_marker = _x select 6;
			_trigger = _x select 7;
			
			_trigger setVariable ["PCA_CityPosition", _position, true];
			_trigger setVariable ["PCA_CityName", _name, true];
			_trigger setVariable ["PCA_CitySize", _groesse, true];
			_trigger setVariable ["PCA_CityStatus", _status, true];
			_trigger setVariable ["PCA_CityOpfPrio", _prioOpf, true];
			_trigger setVariable ["PCA_CityBluPrio", _prioBlu, true];
			_trigger setVariable ["PCA_CityMarker", _marker, true];
			
		}forEach CityArray ;
		sleep 5;
	};	
};


