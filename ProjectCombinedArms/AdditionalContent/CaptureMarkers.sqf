/*
	Autor: MisterCreator74
	Version: 1.0
	Beschreibung:
	sets for every City the variables same as the array attributs

	

*/
sleep startup_delay;
while {true} do
{
	{
		_trigger = _x select 7;

		_marker = [_x select 6, _trigger] call BIS_fnc_markerToTrigger;
		_marker setMarkerAlpha 0.5;
		_status = _trigger getVariable ["PCA_CityStatus","empty"];
		//hint str _status;
		
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