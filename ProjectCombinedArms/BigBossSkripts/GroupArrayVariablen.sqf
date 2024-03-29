/*
	Author: MisterCreator74
	Version: 1.5
	
	Description:
	Main functions of this script: 
	1. give every squad a squadtyp
	2. give the squadleader the ability to change the squadtype (search for: Change GroupType)
	3. enable/disable auto orders for every squad form the leader (search for: auto orders)
	4. return an array with all the Blufor groups (bluGroups) and one with all the Opfor groups (opfGroups)
	
	grouptype can be retrieved with: groupname getVariable ["PCA_groupType", "Standartwert"];
	
*/


PCA_fnc_showGuiMessage = {
  params ["_message", "_callbackfn", "_callbackargs"];
  _Guiresult = [_message, "Project CombinedArms", "Yes", "No", [] call BIS_fnc_displayMission, false, false] call BIS_fnc_guiMessage;
  [_GuiResult, _callbackargs] remoteExec [_callbackfn, remoteExecutedOwner];
};


PCA_fnc_messageResult = {
  params ["_GuiResult", "_args"];
  _args params ["_grp", "_grouptype", "_NewGrouptype"];
  if (_GuiResult) then 
            {
                _grp setVariable ["PCA_groupType",_NewGrouptype];
                _grp setVariable ["PCA_groupTypeChange", "locked"];
				[format ["Project CombinedArms: %1 changed GroupType from '%2' to '%3' and will now recive %4 orders.", _grp, _grouptype, _NewGrouptype, _NewGrouptype]] remoteExec ["systemChat", 0];
            }
            else 
            {
                _grp setVariable ["PCA_groupTypeChange", "locked"];
            };      
};



PCA_fnc_getGroupType = 
{
	private ["_grp","_vehlist","_cars","_apcs","_tanks","_helis","_planes","_boats","_veh","_type"];
	params ["_grp"];

	//_grp = _this;
	
	_vehlist = [];
	_cars = 0;
	_apcs = 0;
	_tanks = 0;
	_helis = 0;
	_planes = 0;
	_uavs = 0;
	_boats = 0;
	_artys = 0;
	_mortars = 0;
	_support_reammo = 0;
	_support_repair = 0;
	_support_refuel = 0;
	_support_medic = 0;
	_support = 0;
	_transport = 0;
	_NOSeats = 0;
	{
		if (!canstand vehicle _x && alive vehicle _x && !(vehicle _x in _vehlist)) then {
			_veh = vehicle _x;
			_NOSeats = count fullCrew [_veh,"", true];
			_vehlist = _vehlist + [_veh];

			//--- Vehicle is Car
			if (_veh iskindof "car" || _veh iskindof "wheeled_apc" && _NOSeats >= 7 ) then {_transport = _transport + 1};
			if (_veh iskindof "car" || _veh iskindof "wheeled_apc") then {_cars = _cars + 1};


			//--- Vehicle is Tank
			if (_veh iskindof "tank") then {
				if (getnumber(configfile >> "cfgvehicles" >> typeof _veh >> "artilleryScanner") > 0) then
				{
					//--- Self-propelled artillery
					_artys = _artys + 1;
				} else {

					//--- Armored tank
					_tanks = _tanks + 1;
				};
			};

			//--- Vehicle is APC
			if (_veh iskindof "tracked_apc") then {_apcs = _apcs + 1};

			//--- Vehicle is Helicopter
			if (_veh iskindof "helicopter" && _NOSeats >= 7 ) then {_transport = _transport + 1};
			if (_veh iskindof "helicopter") then {_helis = _helis + 1};

			//--- Vehicle is Plane
			if (_veh iskindof "plane") then {
				if (_veh iskindof "uav") then {

					//--- UAV
					_uavs = _uavs + 1
				} else {

					//--- Plane
					_planes = _planes + 1
				};
			};

			//--- Vehicle is Artillery
			if (_veh iskindof "staticcanon") then {_artys = _artys + 1};

			//--- Vehicle is Mortar
			if (_veh iskindof "staticmortar") then {_mortars = _mortars + 1};

			//--- Vehicle is Boat
			if (_veh iskindof "boat") then {_boats = _boats + 1};

			//--- Vehicle is support
			_canHeal = getnumber (configfile >> "cfgvehicles" >> typeof _veh >> "attendant") > 0;
			_canReammo = getnumber (configfile >> "cfgvehicles" >> typeof _veh >> "transportAmmo") > 0;
			_canRefuel = getnumber (configfile >> "cfgvehicles" >> typeof _veh >> "transportFuel") > 0;
			_canRepair = getnumber (configfile >> "cfgvehicles" >> typeof _veh >> "transportRepair") > 0;
			if (_canHeal) then {_support_medic = _support_medic + 1};
			if (_canReammo) then {_support_reammo = _support_reammo + 1};
			if (_canRefuel) then {_support_refuel = _support_refuel + 1};
			if (_canRepair) then {_support_repair = _support_repair + 1};
		};
	} foreach units _grp;

	_type = "infantry";
	if (_cars >= 1) then {_type = "motor_inf"};
	if (_cars >= 1 && _transport >= 1) then {_type = "transport"};
	if (_apcs >= 1) then {_type = "mech_inf"};
	if (_tanks >= 1) then {_type = "tank"};
	if (_helis >= 1) then {_type = "CAS"};
	if (_helis >= 1 && _transport >= 1) then {_type = "Air_Transport"};
	if (_planes >= 1) then {_type = "plane"};
	if (_uavs >= 1) then {_type = "uav"};
	if (_artys >= 1) then {_type = "art"};
	if (_mortars >= 1) then {_type = "mortar"};
	if (_support_repair >= 1) then {_type = "maint"};
	if (_support_medic >= 1) then {_type = "med"};
	if ((_support_medic + _support_reammo + _support_refuel + _support_repair) > 1) then {_type = "support"};
	if (_type == "Any") then {_type = "infantry"};
	//if (_boats >= 1) then {_type = "boat"};
	_type
};


publicVariable "PCA_fnc_showGuiMessage";
publicVariable "PCA_fnc_messageResult";
publicVariable "PCA_fnc_getGroupType";


PCA_fnc_groupTypeChange = 
{
	params ["_grp"];
	//_grp = _this;
	_toChange = _grp getVariable ["PCA_groupTypeChange", "empty"];
	_grouptype = _grp getVariable ["PCA_groupType", "empty"];
	
	if (count units _grp < 1) exitWith
	{
		_grp setVariable ["PCA_groupTypeChange", "empty"];
		_grp setVariable ["PCA_groupType", "empty"];
	};

	{
		if ( isPlayer _x && _x == leader group _x && _toChange == "empty") then  // if (leader group _x isPlayer && _toChange == "empty") then -> noch zu testen der Rest geht
		{	
			[_x, ["PCA: Change GroupType", { params ["_target"]; group _target setVariable ["PCA_GroupTypeChange", "change", true]; }, nil, 99, false]] remoteExec ["addAction", _x];
			[_x, ["PCA: enable/disable auto orders", { params ["_target"]; _autoOrders =  group _target getVariable ["PCA_enableAutoOrders", "true"]; if (_autoOrders == "true") then {group _target setVariable ["PCA_enableAutoOrders", "false", true]; ["PCA auto orders disabled"] remoteExec ["hint", _target];} else {group _target setVariable ["PCA_enableAutoOrders", "true", true]; ["PCA auto orders enabled"] remoteExec ["hint", _target];}; }, nil, 98, false]] remoteExec ["addAction", _x];
		};
	} forEach Units _grp;


	
	if (_grouptype == "empty") then
	{
		_grouptype = _grp call PCA_fnc_getGroupType;
		_grp setVariable ["PCA_groupTypeChange", "change"];
		_grp setVariable ["PCA_groupType",_grouptype];

	};
	
	if (_grouptype != "empty" && _toChange == "change") then
	{
		
		_NewGrouptype = _grp call  PCA_fnc_getGroupType;
		[_grp, _grouptype, _NewGrouptype] spawn 
		{
			params ["_grp", "_grouptype", "_NewGrouptype"];
			[format ["Are you sure you want to change your GroupType from '%1' to '%2'?",_grouptype, _NewGrouptype], "PCA_fnc_messageResult", [_grp, _grouptype, _NewGrouptype]] remoteExec ["PCA_fnc_showGuiMessage", leader _grp];
		};

	};
	
	if (_grouptype != "empty" && _toChange == "empty") then
	{
		_grp setVariable ["PCA_groupTypeChange", "locked"];
	};
	
	
};


//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

0 spawn 
{
	while {true} do
	{ 
		bluGroups = allGroups select {side _x == WEST};
		opfGroups = allGroups select {side _x == EAST};
		{
			[_x] remoteExec ["PCA_fnc_groupTypeChange", 0];
			

		}foreach allGroups;
		sleep 5;
	};
};
