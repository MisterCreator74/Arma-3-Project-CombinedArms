/*
	Autor: MisterCreator74
	Version: 1.6.4 - Neuer Array Typ - Beta Variante
	Beschreibung:
	Beinhaltet Stadtspeziefische Arrays. Und Funktionen sowie Sensoren um Rückmeldung über den Zustand von vordefinierten Städeten zu bekommen
	
	
	Array Inhalt: [[position, name, größe, Status, prioBlu, prioOpf],[position, name, größe, Status, prioBlu, prioOpf]]
	

	Benötigete Marker:
		"Base_Bluefor"  -> markiert Blufor Basis
		"Base_Opfor"	-> markiert Opfor Basis
		"city_Stadtname_Größe_Status_PrioBlue_PrioOpf"-> Name kann random String (mit Leerzeichen)sein, Größe kann small oder big sein, Status kann contested, Blue, Opf, empty (Standard), BlueC und OpfC sein, 
														PrioBlue und PrioOpf kann Zahl von 1-3 oder leer (Leerzeichen)	sein. Die Unterstriche sind wichtig!!!
														
		"spawn_marker_nummer"
*/


//getting all Map Markers
_mapmarkers = allMapMarkers;



//setting Variables for counting
_anzahlStaedte = 0;
_anzahlSpawnPunkte = 0;



//filling Arrays with markers
SpawnMarker = _mapmarkers select {["spawn",_x, true] call BIS_fnc_inString;};
CityArray = _mapmarkers select {["city",_x, true] call BIS_fnc_inString;};
CityMarker = [];
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
		systemChat "Project CombinedArms: No Cities found, Array Skript terminated. Place Markers according to Skript header";
	};
if (_anzahlBases < 2) exitWith
	{
		systemChat "Project CombinedArms: Not all Bases found, Array Skript terminated. Please make sure to place a Base_Bluefor & Base_Opfor marker in the editor";
	};
	
	
//Debug hints for setting up
if (show_debug_hints == true) then
	{
		hint format ["Spawnpoints: %1 \n Cities: %2" , _anzahlSpawnPunkte, _anzahlStaedte];
		sleep 5;
	};	


{
	_pos = getMarkerPos _x;
	_cityCenter = "Land_HelipadEmpty_F" createVehicle _pos;
	CityMarker append [_cityCenter];
	

}forEach CityArray;

hint format ["%1",CityMarker];


