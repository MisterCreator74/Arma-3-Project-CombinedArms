/*
	Autor: MisterCreator74
	Version: 1.0
	Beschreibung:
	_content: city_Stadtname_Größe_Status_PrioBlue_PrioOpf -> Prio wird anfangs abgefragt und dann dynamisch berechnet
	
*/



0 spawn 
{
	while {true} do
		{
		_arrayBlu = CityArray;
		_arrayOpf = CityArray;
		
		sortedArrayBlu = [
			_arrayBlu,
			[],
				{
					_x params ["_pos","_name","_size","_prioBlu","_prioOpf"];

					_prioBlu; //must return string, number, or array
				},
				"DESCEND"
		] call BIS_fnc_sortBy;
		
		sortedArrayOpf = [
			_arrayOpf,
			[],
				{
					_x params ["_pos","_name","_size","_prioBlu","_prioOpf"];

					_prioOpf; //must return string, number, or array
				},
				"DESCEND"
		] call BIS_fnc_sortBy;

		sleep 30;
			
		};
};


/*
newCityArray = [];

0 spawn 
{
	while {true} do
		{
			{
				_content = CityMarker select _forEachIndex;
				_content = _content splitString "_";
				newCityArray set [_forEachIndex, _content];
				hint format ["%1",newCityArray];
				sleep 5;
				_status = newCityArray select 0 select 3;
				_subarray = newCityArray select 0;
				_status = "testing purposes";
				_subarray set [3, _status];
				sleep 5;
				hint "New main Array:";
				sleep 1;
				hint format ["%1", newCityArray];
				sleep 5;
			}foreach CityMarker;
			
			
		};
};


*/