/*
	Autor: MisterCreator74
	Version: 1.0
	Beschreibung:
	group Variables: groupType | groupStatus | groupTarget | groupConnected | groupTypeChange
	Stati: In Caps -> Wegpunkte (z.B.: MOVE, GETIN) alles klein -> andere
	
	[group, taskposition, Taskdescription, Taskname, condition, Status/Waypointtype, Status when finished, vehicle] call taskcreate;
	

	
*/
sleep 2;



fnc_findGroup = {
params ["_variable", "_search", "_status"];

private _foundIndex = bluGroups findIf {
    _xName = _x getVariable _variable;
    _xStatus = _x getVariable ["groupStatus", "idle"];
    _xName  == _search && (_status == "" || _xStatus  == _status)
};

if (_foundIndex != -1) exitWith {bluGroups select _foundIndex;};
grpNull; // Not found
};


NOTasks = 0;
fnc_taskcreate = {
	params ["_grp","_taskpos","_taskdescription","_taskname", "_condition", "_status", "_statusfinished","_vehicle"];
	_taskID = str NOTasks;
	[_grp, _taskID, [_taskdescription, _taskname], _taskpos, "ASSIGNED", 99, true, "", true] call BIS_fnc_taskCreate;
	NOTasks = NOTasks +1;
	_wp = _grp addwaypoint [_taskpos, 15];
	_wp setWaypointType _status;
	_actionID = leader _grp addAction ["PCA: Cancel Order", tostring {
																			_actionID = _this select 2;
																			_grp = _this select 3 select 0;
																			_taskID = _this select 3 select 1;
																			[_taskID,"Canceled", true] call BIS_fnc_taskSetState; 
																			deleteWaypoint [_grp,1];
																			leader _grp removeAction _actionID;
																			_grp setVariable ["groupStatus","idle"];
																			_transportGroup = _grp getVariable "groupConnected";
																			_grp setVariable ["groupConnected", ""];
																			_transportGroup setVariable ["groupConnected", ""];																			
																			}, [_grp, _taskID], 99, false];

		_grp setVariable ["groupStatus",_status];


	[_grp,_taskpos,_taskdescription,_taskname, _condition, _status, _statusfinished, _vehicle, _taskID, _actionID] spawn 
	{ 
		params ["_grp","_taskpos","_taskdescription","_taskname", "_condition", "_status", "_statusfinished","_vehicle", "_taskID", "_actionID"];

		while {true} do
		{
			
			_unitcount = {alive _x && _x inArea [_taskpos,30,30, 0,false, -1]} count units _grp;
			if (call _condition) then 
			{
				if (_status == "GETOUT") then 
				{
					_grp leaveVehicle _vehicle;
				};
				[_taskID,"Succeeded", true] call BIS_fnc_taskSetState;
				_grp setVariable ["groupStatus",_statusfinished];
				deleteWaypoint [_grp,1];
				hint "task succeeded";
				leader _grp removeAction _actionID;
				if (_statusfinished != "mounted") then
				{
					_transportGroup = _grp getVariable ["groupConnected", grpNull];
					_grp setVariable ["groupConnected", ""];
					if (isNull _transportGroup) then
					{
					
					}
					else
					{
						_transportGroup setVariable ["groupConnected", ""];
					};
				};
				break;
			};


			sleep 10;
		};
	};

};




//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



0 spawn 
{
	sleep startup_delay;
	systemChat "Project CombinedArms: AI Order System activated";
	while {true} do 
	{
		hint "cycle";
		sleep 0.5;
		{
			_groupType = _x getVariable ["groupType", ""];
			_groupStatus = _x getVariable ["groupStatus", "idle"];
			
			// Target aquiering 
			_target = sortedArrayBlu select 0;
			_targetpos = _target select 0;
			
			
			// Order Selection
			if (_groupType == "infantry" && _groupStatus == "idle") then			
			{
				_x setVariable ["groupTarget", _target];
				_distance = leader _x distance2d _targetpos;
				_savePos = [_targetpos, 200, 500, 20, 0, 20, 0, [],_targetpos] call BIS_fnc_findSafePos;
				
				// Aquiering Transport
				if (_distance > 2000) then 
				{
						
					_transportGroup = ["groupType","transport","idle"] call fnc_findGroup; 										// Finding an transport group

					if (isNull _transportGroup) then							 												// If no transportgroup was found
					{
						hint "no transport found";
						[_x ,_savePos, "Move to the Objective", "MOVE", "this", "MOVE", "idle"] call fnc_taskcreate;
					}
					else 
					{
						_vehicle = vehicle leader _transportGroup;																// Finding Transport vehicle
						_pos = getpos _vehicle;																					// Finding Vehicle Pos
						_x setVariable ["groupConnected", _transportGroup];
						_transportGroup setVariable ["groupConnected", _x];
						_transportGroup setVariable ["groupStatus", "transporting"];
						
						if (getpos leader _transportGroup distance2d getPos leader _x > 1000) then 									// If transport is far away
						{
							[_transportGroup ,getPos leader _x, "Move to the Group", "MOVE", {_unitcount == count units _grp}, "MOVE", "idle", ""] call fnc_taskcreate;
							[_x ,_pos, "get in that vehicle", "GETIN", {

																					_numTotal = count (units _grp);
																					_numInVeh = { _x in _vehicle } count (units _grp);																				 
																					_numTotal == _numInVeh
																					 }, "GETIN NEAREST", "mounted", _vehicle] call fnc_taskcreate;
						}
						else 
						{

							
							[_x ,_pos, "get in that vehicle", "GETIN", {

																					_numTotal = count (units _grp);
																					_numInVeh = { _x in _vehicle } count (units _grp);																				 
																					_numTotal == _numInVeh
																					 }, "GETIN NEAREST", "mounted", _vehicle] call fnc_taskcreate;	//creating getin Order
						};
					};
					
				}
				else
				{
					if (_distance < 500) then 
					{
						_target = _x getVariable "groupTarget";
						_targetpos = _target select 0;
						[_x ,_targetpos, "Attack the Objective", "Attack", {_grp getVariable "groupTarget" select 3 == "BlueC"}, "SAD", "idle", ""] call fnc_taskcreate;				// creating Attack Order -> TODO condtion
					}
					else 
					{
						[_x ,_savePos, "Move to the Objective", "MOVE", {_unitcount == count units _grp}, "MOVE", "idle", ""] call fnc_taskcreate;				// creating Move Order
					};
				
				};
				
			};
			








			
			if (_groupType == "infantry" && _groupStatus == "mounted") then
			{

				_transportGroup = _x getVariable "groupConnected";
				_savePos = [_targetpos, 200, 500, 20, 0, 20, 0, [],_targetpos] call BIS_fnc_findSafePos;
				_vehicle = vehicle leader _transportGroup;
				[_transportGroup ,_savePos, "Transport the Group", "Transport", {_unitcount == count units _grp}, "MOVE", "idle", _vehicle] call fnc_taskcreate;
				[_x ,_savePos, "Get out at Target", "Get out at Target", {_unitcount == count units _grp}, "GETOUT", "idle", _vehicle] call fnc_taskcreate;
			};
			
			
			
			
			
			
			
			
			
			if (_groupType == "transport" && _groupStatus == "idle") then 
			{
				_pos = getPos vehicle leader _x;
				_parkpos = bluVehSpawn select 0 select 0;
				//_parkpos = _parkpos select 0;
				_parkpos = getMarkerpos _parkpos;
				_distance = _pos distance2d _parkpos;			
				if (_distance > 100) then 
				{
					[_x,_parkpos, "Move back to Base", "Transport", {_unitcount == count units _grp}, "MOVE", "idle", ""] call fnc_taskcreate;
				};
			};
			
			

		}forEach bluGroups;	
		sleep 30;
	};
};




