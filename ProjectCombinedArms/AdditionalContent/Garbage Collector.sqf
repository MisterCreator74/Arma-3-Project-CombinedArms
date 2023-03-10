/*
	Autor: MisterCreator74
	Version: 2.8
	Beschreibung:
	Ein Script um tote Einheiten zu löschen. Dabei werden tote und zerstörte Fahrzeuge gelöscht solange sich kein Spieler im Umkreis von 800m (standard) aufhält. 
	Dies schont die Ressourcen des Servers und wirkt sich positiv auf die FPS aus.
	
*/

Garbage_Collector_delete_Radius = 1600;


//Detektieren ob eine Entität gestorben ist
addMissionEventHandler ["EntityKilled", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];		
	
	// Wenn die Entität keinen Variablennamen hat
	if (vehicleVarName _unit =="") then
	{
		//wird der Unitname abgerufen
		_unitname = str _unit;
		
		//anhand der Leerzeichen getrennt und mithilfe von Unterstrichen wieder zusammengesetzt
		_unitnamearry = _unitname splitString " ";
		_unitname = _nametrg joinstring"_";
		
		//und als Variablenname festgelegt
		_unit setVehicleVarName _unitname;
		(_unit call BIS_fnc_objectVar);

	};
	
	//erzeugen des Triggers zur Spielerabfrage
	_nametrg = str _unit;
	_trgText = str _unit;
	_nametrg = createTrigger ["EmptyDetector",getpos _unit];
	_nametrg setTriggerArea [Garbage_Collector_delete_Radius,Garbage_Collector_delete_Radius,Garbage_Collector_delete_Radius,false];
	_nametrg setTriggerText _trgText;
	_nametrg setTriggerInterval 30;
	_nametrg setTriggerActivation ["ANYPLAYER", "NOT PRESENT", true];
	_nametrg setTriggerStatements ["this", 
						"
							_nameThisTrigger = triggerText thisTrigger;
							_obj = call compile _nameThisTrigger;
							deleteVehicle _obj;
							
							if (show_debug_hints == true)
								{
									hint 'Garbage Collector: Entität gelöscht';
								};
						"
						,""];

}];

//deleteVehicle _x;