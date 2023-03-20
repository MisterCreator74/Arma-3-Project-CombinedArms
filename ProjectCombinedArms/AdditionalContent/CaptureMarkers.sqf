/*
	Author: MisterCreator74
	Version: 1.2
	Description:
	visualizes the city status on the map with colored circles

*/

// waiting for initialisation
sleep startup_delay;

while {true} do
{
	{
		// get the trigger and assigning the corresponding marker to the triggersize
		_trigger = _x select 7;
		_marker = [_x select 6, _trigger] call BIS_fnc_markerToTrigger;
		_marker setMarkerAlpha 0.5;
		
		// retrieving the global city status for each city
		_status = _trigger getVariable ["PCA_CityStatus","empty"];

		// deciding which color the marker should get
		if (_status == "empty") then
		{
			_marker setMarkerColor "ColorBlack";
		}
		else
		{
			if (_status == "BlueC") then 
			{
			 _marker setMarkerColor "ColorBlue";
			}
			else 
			{
				
				if (_status == "OpfC") then 
				{
					_marker setMarkerColor "ColorRed";
				}
				else 
				{
					_marker setMarkerColor "ColorGreen";
				};
			};
		};

	}forEach CityArray;
	sleep 10;
};