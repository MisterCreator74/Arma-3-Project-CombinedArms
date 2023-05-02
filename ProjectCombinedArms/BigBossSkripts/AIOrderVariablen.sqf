/*
	Autor: MisterCreator74
	Version: 1.0
	Beschreibung:
	group Variables: groupType | PCA_groupStatus | PCA_groupTarget | PCA_groupConnected | PCA_groupTypeChange | PCA_enableAutoOrders
	Stati: In Caps -> Wegpunkte (z.B.: MOVE, GETIN) alles klein -> andere
	
	available taskTypes: infantry_movement | infantry_transport | infantry_capture | air_support
	

	
*/
sleep 2;



PCA_fnc_findGroup = {
params ["_variable", "_search", "_status"];

private _foundIndex = bluGroups findIf {
    _xName = _x getVariable _variable;
    _xStatus = _x getVariable ["PCA_groupStatus", "idle"];
    _xName  == _search && (_status == "" || _xStatus  == _status)
};

if (_foundIndex != -1) exitWith {bluGroups select _foundIndex;};
grpNull; // Not found
};



PCA_fnc_cancelOrderReturn = {
params ["_taskID", "_grp"];
[_taskID,"Canceled", true] call BIS_fnc_taskSetState;
_grp setVariable ["PCA_groupStatus","idle", true];
deleteWaypoint [_grp,1]; 
};



PCA_fnc_cancelOrder = {
params ["_taskID", "_grp"];
_actionID = leader _grp addAction ["PCA: Cancel Order", tostring{_grp = _this select 3 select 0; _taskID = _this select 3 select 1; [_taskID, _grp] remoteExec ["PCA_fnc_cancelOrderReturn", 0];  _actionID = _this select 2; leader _grp removeAction _actionID;}, [_grp, _taskID], 97, false];
leader _grp setVariable ["PCA_cancelActionID", _actionID, 0];
};


NOTasks = 0;
PCA_fnc_taskcreate = {
	params ["_taskType", "_taskPos", "_taskName", "_taskDescription", "_waypointType", "_grp", "_succeedCondition","_executingStatus", "_finishedStatus", "_assignedVehicle", "_actionID"];
	
	// task creation
	_taskID = str NOTasks;
	[_grp, _taskID, [_taskdescription, _taskname], _taskpos, "ASSIGNED", 99, true, "", true] call BIS_fnc_taskCreate;
	NOTasks = NOTasks +1;
	
	// cancel order for squadleader
	[_taskID, _grp] remoteExec ["PCA_fnc_cancelOrder", leader _grp];
	
	
	// create group waypoints
	_wp = _grp addwaypoint [_taskpos, 15];
	_wp setWaypointType _waypointType;

	// setting group status
	_grp setVariable ["PCA_groupStatus",_executingStatus];

	// task completion
	[_taskID, _taskType, _taskPos, _taskName, _taskDescription, _waypointType, _grp, _succeedCondition,_executingStatus, _finishedStatus, _assignedVehicle, _actionID] spawn 
	{ 
		params ["_taskID","_taskType", "_taskPos", "_taskName", "_taskDescription", "_waypointType", "_grp", "_succeedCondition","_executingStatus", "_finishedStatus", "_assignedVehicle", "_actionID"];

		while {true} do
		{
			_unitcount = {alive _x && _x inArea [_taskpos,30,30, 0,false, -1]} count units _grp;
			if (call _succeedCondition) then 
			{
				if (_taskType == "infantry_movement") then 
					{
						
					};
					
				if (_taskType == "infantry_transport") then 
					{
						if (_waypointType == "GETOUT") then 
							{
								_grp leaveVehicle _vehicle;
							};
							
						
						_grp setVariable ["PCA_groupStatus",_statusfinished];
					};
				[_taskID,"Succeeded", true] call BIS_fnc_taskSetState;
				_actionID = leader _grp getVariable ["PCA_cancelActionID", ""];
				leader _grp removeAction _actionID;
				_grp setVariable ["PCA_groupStatus","idle", true];
				deleteWaypoint [_grp,1];
				break;
			};

			sleep 10;
		};
	};

};

publicVariable "PCA_fnc_taskcreate";
publicVariable "PCA_fnc_cancelOrder";
publicVariable "PCA_fnc_cancelOrderReturn";
publicVariable "PCA_fnc_findGroup";

/*
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
																			_grp setVariable ["PCA_groupStatus","idle"];
																			_transportGroup = _grp getVariable "groupConnected";
																			_grp setVariable ["PCA_groupConnected", ""];
																			_transportGroup setVariable ["PCA_groupConnected", ""];																			
																			}, [_grp, _taskID], 99, false];

		_grp setVariable ["PCA_groupStatus",_status];


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
				_grp setVariable ["PCA_groupStatus",_statusfinished];
				deleteWaypoint [_grp,1];
				hint "task succeeded";
				leader _grp removeAction _actionID;
				if (_statusfinished != "mounted") then
				{
					_transportGroup = _grp getVariable ["PCA_groupConnected", grpNull];
					_grp setVariable ["PCA_groupConnected", ""];
					if (isNull _transportGroup) then
					{
					
					}
					else
					{
						_transportGroup setVariable ["PCA_groupConnected", ""];
					};
				};
				break;
			};


			sleep 10;
		};
	};

};

publicVariable "fnc_taskcreate";
*/

//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




0 spawn 
{
	sleep startup_delay;
	["Project CombinedArms: AI Order System activated"] remoteExec ["systemChat", 0];
	while {true} do 
	{
		hint "cycle";
		sleep 0.5;
		hint "";
		{
			_groupType = _x getVariable ["PCA_groupType", ""];
			_groupStatus = _x getVariable ["PCA_groupStatus", "idle"];
			_autoOrders = _x getVariable ["PCA_enableAutoOrders", "true"];
			_groupTarget = _x getVariable ["PCA_groupTarget", ""];
			
			
			// Target aquiering
			if (_groupTarget == "") then 
				{
				
				};
			_target = sortedArrayBlu select 0;
			_targetpos = _target select 0;
			_trigger = _target select 7;
			
			
			

			
			
			// Order Selection
			if (_autoOrders == "true") then
				{
				
					// infantry orders
					if (_groupType == "infantry") then 
						{
						
							// if goup is at idle
							if (_groupStatus == "idle") then 
								{
									_x setVariable ["PCA_groupTarget", _target];
									//_connectedGroups = _trigger getVariable ["PCA_connectedGroups", 0];
									//_trigger setVariable ["PCA_connectedGroups", _connectedGroups +1];
									_distance = leader _x distance2d _targetpos;
									_savePos = [_targetpos, 200, 500, 20, 0, 20, 0, [],_targetpos] call BIS_fnc_findSafePos;
									
									if (_distance > 2000) then 
										{
											//_transportGroup = ["groupType","transport","idle"] call PCA_fnc_findGroup;
											["You´re now supposed to get advanced tasks but they are not implemented yet :("] remoteExec ["hint", leader _x];
										}
										else
										{
											if (_distance < 500) then 
												{
													_target = _x getVariable "groupTarget";
													_targetpos = _target select 0;

													["infantry_movement", _targetpos, "Attack", "attack the objective", "SAD", _x, {_grp getVariable "groupTarget" select 3 == "BlueC"}, "attacking", "idle", "", ""] call PCA_fnc_taskcreate;
													
												}
												else 
												{
													["infantry_movement", _savepos, "Move", "move to the objective", "MOVE", _x, {_unitcount == count units _grp}, "moving", "idle", "", ""] call PCA_fnc_taskcreate;
												};
										};
								};
						};
					
					// transport orders
					if (_groupType == "transport") then
						{

								
						};
					
					//	cas orders				
					if (_groupType == "CAS") then
						{
							// when fuel active task is canceled and RTB task is given, completes when vehicle is refueld
							if (fuel vehicle leader _x < 0.2 AND _groupStatus != "RTB") then 
								{
									_currentTask = currentTask leader _x;
									hint str _currentTask;
									leader _x removeSimpleTask _currentTask;								
									["air_support", getMarkerpos "Base_Blufor", "RTB: refuel, rearm", "return to base, refuel and rearm", "MOVE", _x, {fuel vehicle leader _grp > 0.9}, "RTB", "idle", "", ""] call PCA_fnc_taskcreate;
								};
								
							if (_groupStatus == "idle") then
								{
									["air_support", getMarkerpos "Base_Blufor", "Wait for orders", "make sure your Vehicle is ready for takeoff, refuel, rearm and wait for orders", "HOLD", _x, {_grp getVariable ["groupReady", "idle"] == "ready"}, "ready", "ready", "", ""] call PCA_fnc_taskcreate;
								};
								
							if (_groupStatus == "ready") then
								{
									["You´re now supposed to get advanced tasks but they are not implemented yet :("] remoteExec ["hint", leader _x];
								};						
						};
						
					// tank orders
					if (_groupType == "tank") then
						{
							if (fuel vehicle leader _x < 0.2 AND _groupStatus != "RTB") then 
								{
									_currentTask = currentTask leader _x;
									hint str _currentTask;
									leader _x removeSimpleTask _currentTask;								
									["air_support", getMarkerpos "Base_Blufor", "RTB: refuel, rearm", "return to base, refuel and rearm", "MOVE", _x, {fuel vehicle leader _grp > 0.9}, "RTB", "ready", "", ""] call PCA_fnc_taskcreate;
								};						
						};
			
				};
		sleep 1;		
		}forEach bluGroups;	
		sleep 30;
	};
};

/*
0 spawn 
{
	sleep startup_delay;
	["Project CombinedArms: AI Order System activated"] remoteExec ["systemChat", 0];
	while {true} do 
	{
		hint "cycle";
		sleep 0.5;
		{
			_groupType = _x getVariable ["PCA_groupType", ""];
			_groupStatus = _x getVariable ["PCA_groupStatus", "idle"];
			_autoOrders = _x getVariable ["PCA_enableAutoOrders", "true"];
			
			// Target aquiering 
			_target = sortedArrayBlu select 0;
			_targetpos = _target select 0;
			
			
			// Order Selection
			
			if (_autoOrders == "true") then
			{
				if (_groupType == "infantry" && _groupStatus == "idle") then			
				{
					_x setVariable ["PCA_groupTarget", _target];
					_distance = leader _x distance2d _targetpos;
					_savePos = [_targetpos, 200, 500, 20, 0, 20, 0, [],_targetpos] call BIS_fnc_findSafePos;
					
					// Aquiering Transport
					if (_distance > 2000) then 
					{
							
						_transportGroup = ["groupType","transport","idle"] call fnc_findGroup; 										// Finding an transport group

						if (isNull _transportGroup) then							 												// If no transportgroup was found
						{
							hint "no transport found";
							//[_x ,_savePos, "Move to the Objective", "MOVE", "this", "MOVE", "idle"] call fnc_taskcreate;
							[_x ,_savePos, "Move to the Objective", "MOVE", "this", "MOVE", "idle"] remoteExec ["fnc_taskcreate", 0];
						}
						else 
						{
							_vehicle = vehicle leader _transportGroup;																// Finding Transport vehicle
							_pos = getpos _vehicle;																					// Finding Vehicle Pos
							_x setVariable ["PCA_groupConnected", _transportGroup];
							_transportGroup setVariable ["PCA_groupConnected", _x];
							_transportGroup setVariable ["PCA_groupStatus", "transporting"];
							
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
			
			
			};
		}forEach bluGroups;	
		sleep 30;
	};
};




