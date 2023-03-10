/*
	Autor: MisterCreator74
	Version: 1.0
	Beschreibung:
	sets for every City the variables same as the array attributs

	
*/

sleep startup_delay;
while {true} do
{
	_cityMarkers = allMapMarkers select {["city",_x, true] call BIS_fnc_inString;};
	{
		_status = _x getVariable ["cityStatus","empty"];
		if (_status == "empty") then 
		{
			_marker = createMarker [_x, getMarkerpos _x];
			_marker setMarkerColor "ColorBlack";
			_marker setMarkerAlpha 0.5;
			_marker = [_marker, _x] call BIS_FNC_markerToTrigger;
		};
		
		if (_status == "BlueC") then 
		{
			
			_x setMarkerColor "ColorBlue";
			_x setMarkerAlpha 0.5;
			//_marker = [_marker, _x] call BIS_FNC_markerToTrigger;
		};
		if (_status == "OpfC") then 
		{
			
			_x setMarkerColor "ColorRed";
			_x setMarkerAlpha 0.5;
			//_marker = [_marker, _x] call BIS_FNC_markerToTrigger;
		};
	}forEach _cityMarkers;
	
	sleep 10;
};