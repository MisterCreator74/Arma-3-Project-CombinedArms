/*
	Autor: MisterCreator74
	Version: 1.0
	Beschreibung:
	sets for every City the variables same as the array attributs

	
*/

0 spawn 
{
	sleep startup_delay;
	_cityMarkers = allMapMarkers select {["city",_x, true] call BIS_fnc_inString;};
	while {true} do
	{
		
		{
			
			_content = _x splitString "_";
			_name = _content select 1;
			_array = [];
			{
				_iffound = _x find _name;
				if (_iffound == 1) then 
				{
					_array = _x;
					break;
				};
			}forEach CityArray;
			_pos = _array select 0;
			_name = _array select 1;
			_groesse = _array select 2;
			_status = _array select 3;
			_prioBlu = _array select 4;
			_prioOpf = _array select 5;
			

			_marker = call compile _x;

			_marker setVariable ["cityPostion",_pos];
			_marker setVariable ["citySize",_groesse];
			_marker setVariable ["cityStatus",_status];
			_marker setVariable ["cityPrioBlu",_prioBlu];
			_marker setVariable ["cityPrioOpf",_prioOpf];
		
		}forEach _cityMarkers;
	};	
};