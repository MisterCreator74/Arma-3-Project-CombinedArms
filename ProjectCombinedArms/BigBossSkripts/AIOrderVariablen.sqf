/*
	Autor: MisterCreator74
	Version: 1.1
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
				if (_taskType == "infantry_capture") then 
					{
						_grp setVariable ["PCA_groupTarget", ""];
					};
					
				if (_taskType == "infantry_transport") then 
					{
						if (_waypointType == "GETOUT") then 
							{
								_grp leaveVehicle _vehicle;
							};
							
						

					};
				_grp setVariable ["PCA_groupStatus",_statusfinished];
				[_taskID,"Succeeded", true] call BIS_fnc_taskSetState;
				_actionID = leader _grp getVariable ["PCA_cancelActionID", ""];
				leader _grp removeAction _actionID;
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
									//_x setVariable ["PCA_groupTarget", _target];
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

													["infantry_capture", _targetpos, "Attack", "attack the objective", "SAD", _x, {_grp getVariable "groupTarget" select 3 == "BlueC"}, "attacking", "idle", "", ""] call PCA_fnc_taskcreate;
													
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




