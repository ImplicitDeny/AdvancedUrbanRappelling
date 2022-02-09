/*
The MIT License (MIT)

Copyright (c) 2016 Seth Duda

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

systemChat "GRSI modified version running";

AUR_Advanced_Urban_Rappelling_Install = {

// Prevent advanced urban rappelling from installing twice
if(!isNil "AUR_RAPPELLING_INIT") exitWith {};
AUR_RAPPELLING_INIT = true;

diag_log "Advanced Urban Rappelling Loading...";

/*
	Description:
	Finds the nearest rappel point within 1.5m of the specified player.
	
	Parameter(s):
	_this select 0: OBJECT - The rappelling unit
	_this select 1: STRING - Search type - "FAST_EXISTS_CHECK" or "POSITION". If FAST_EXISTS_CHECK, this function
		does a quicker search for rappel points and return 1 if a possible rappel point is found, otherwise 0.
		If POSITION, the function will return the rappel position and direction in an array, or empty array if
		no position is found.
		
	Returns: 
	Number or Array (see above)
*/

AUR_Rappel = {
	params ["_player","_rappelPoint","_rappelDirection","_ropeLength"];

	_player setVariable ["AUR_Is_Rappelling",true,true];

	_playerPreRappelPosition = getPosASL _player;
	
	// Start player rappelling 2m out from the rappel point
	_playerStartPosition = _rappelPoint vectorAdd (_rappelDirection vectorMultiply 2);
	_playerStartPosition set [2, getPosASL _player select 2];
	_player setPosWorld _playerStartPosition;
	
	// Create anchor for rope (at rappel point)
	_anchor = createVehicle ["Land_Can_V2_F", _player, [], 0, "CAN_COLLIDE"];
	hideObject _anchor;
	_anchor enableSimulation false;
	_anchor allowDamage false;
	[_anchor] remoteExec ["AUR_Hide_Object_Global", 2];

	// Create rappel device (attached to player)
	_rappelDevice = createVehicle ["B_static_AA_F", _player, [], 0, "CAN_COLLIDE"];
	hideObject _rappelDevice;
	_rappelDevice setPosWorld _playerStartPosition;
	_rappelDevice allowDamage false;
	[_rappelDevice] remoteExec ["AUR_Hide_Object_Global", 2];
	
	[_player,_rappelDevice,_anchor] remoteExec ["GSRI_fnc_aurplayRappellingSoundGlobal", 2];
	
	_rope2 = ropeCreate [_rappelDevice, [-0.15,0,0], _ropeLength - 1];
	_rope2 allowDamage false;
	_rope1 = ropeCreate [_rappelDevice, [0,0.15,0], _anchor, [0, 0, 0], 1];
	_rope1 allowDamage false;
	
	_anchor setPosWorld _rappelPoint;

	_player setVariable ["AUR_Rappel_Rope_Top",_rope1];
	_player setVariable ["AUR_Rappel_Rope_Bottom",_rope2];
	_player setVariable ["AUR_Rappel_Rope_Length",_ropeLength];

	[_player] spawn AUR_Enable_Rappelling_Animation;
	
	// Make player face the wall they're rappelling on
	_player setVectorDir (_rappelDirection vectorMultiply -1);
	
	_gravityAccelerationVec = [0,0,-9.8];
	_velocityVec = [0,0,0];
	_lastTime = diag_tickTime;
	_lastPosition = AGLtoASL (_rappelDevice modelToWorldVisual [0,0,0]);
	
	_decendRopeKeyDownHandler = -1;
	_ropeKeyUpHandler = -1;
	if(_player == player) then {	
		_decendRopeKeyDownHandler = (findDisplay 46) displayAddEventHandler ["KeyDown", {
			private ["_topRope","_bottomRope"];
			if(_this select 1 in (actionKeys "MoveBack")) then {
				_ropeLength = player getVariable ["AUR_Rappel_Rope_Length",100];
				_topRope = player getVariable ["AUR_Rappel_Rope_Top",nil];
				_bottomRope = player getVariable ["AUR_Rappel_Rope_Bottom",nil];
				if(ropeLength _bottomRope > 1) then {
					if(!isNil "_topRope") then {
						ropeUnwind [ _topRope, 1.5, ((ropeLength _topRope) + 0.1) min _ropeLength];
					};
					if(!isNil "_bottomRope") then {
						ropeUnwind [ _bottomRope, 1.5, ((ropeLength _bottomRope) - 0.1) max 0];
					};
				};
			};
			if(_this select 1 in (actionKeys "MoveForward")) then {
				_ropeLength = player getVariable ["AUR_Rappel_Rope_Length",100];
				_topRope = player getVariable ["AUR_Rappel_Rope_Top",nil];
				if(!isNil "_topRope") then {
					ropeUnwind [ _topRope, 0.3, ((ropeLength _topRope) - 0.1) min _ropeLength];
				};
				_bottomRope = player getVariable ["AUR_Rappel_Rope_Bottom",nil];
				if(!isNil "_bottomRope") then {
					ropeUnwind [ _bottomRope, 0.3, ((ropeLength _bottomRope) + 0.1) max 0];
				};
			};
			if(_this select 1 in (actionKeys "Turbo") && player getVariable ["AUR_JUMP_PRESSED_START",0] == 0) then {
				player setVariable ["AUR_JUMP_PRESSED_START",diag_tickTime];
			};
			
			if(_this select 1 in (actionKeys "TurnRight")) then {
				player setVariable ["AUR_RIGHT_DOWN",true];
			};
			if(_this select 1 in (actionKeys "TurnLeft")) then {
				player setVariable ["AUR_LEFT_DOWN",true];
			};
		}];
		_ropeKeyUpHandler = (findDisplay 46) displayAddEventHandler ["KeyUp", {
			if(_this select 1 in (actionKeys "Turbo")) then {
				player setVariable ["AUR_JUMP_PRESSED",true];
				player setVariable ["AUR_JUMP_PRESSED_TIME",diag_tickTime - (player getVariable ["AUR_JUMP_PRESSED_START",diag_tickTime])];
				player setVariable ["AUR_JUMP_PRESSED_START",0];	
			};
			if(_this select 1 in (actionKeys "TurnRight")) then {
				player setVariable ["AUR_RIGHT_DOWN",false];
			};
			if(_this select 1 in (actionKeys "TurnLeft")) then {
				player setVariable ["AUR_LEFT_DOWN",false];
			};
		}];
	} else {
		[_rope1,_rope2] spawn {
			params ["_rope1","_rope2"];
			sleep 1;
			_randomSpeedFactor = ((random 10) - 5) / 10;
			ropeUnwind [ _rope1, 2 + _randomSpeedFactor, (ropeLength _rope1) + (ropeLength _rope2)];
			ropeUnwind [ _rope2, 2 + _randomSpeedFactor, 0];
		};
	};
	
	_walkingOnWallForce = [0,0,0];
	
	while {true} do {
	
		_currentTime = diag_tickTime;
		_timeSinceLastUpdate = _currentTime - _lastTime;
		_lastTime = _currentTime;
		if(_timeSinceLastUpdate > 1) then {
			_timeSinceLastUpdate = 0;
		};

		_environmentWindVelocity = wind;
		_playerWindVelocity = _velocityVec vectorMultiply -1;
		_totalWindVelocity = _environmentWindVelocity vectorAdd _playerWindVelocity;
		_totalWindForce = _totalWindVelocity vectorMultiply (9.8/53);

		_accelerationVec = _gravityAccelerationVec vectorAdd _totalWindForce vectorAdd _walkingOnWallForce;
		_velocityVec = _velocityVec vectorAdd ( _accelerationVec vectorMultiply _timeSinceLastUpdate );
		_newPosition = _lastPosition vectorAdd ( _velocityVec vectorMultiply _timeSinceLastUpdate );

		if(_newPosition distance _rappelPoint > ((ropeLength _rope1) + 1)) then {
			_newPosition = (_rappelPoint) vectorAdd (( vectorNormalized ( (_rappelPoint) vectorFromTo _newPosition )) vectorMultiply ((ropeLength _rope1) + 1));
			_surfaceVector = ( vectorNormalized ( _newPosition vectorFromTo (_rappelPoint) ));
			_velocityVec = _velocityVec vectorAdd (( _surfaceVector vectorMultiply (_velocityVec vectorDotProduct _surfaceVector)) vectorMultiply -1);
		};

		_radius = 0.85;
		_intersectionTests = 10;
		for "_i" from 0 to _intersectionTests do
		{
			_axis1 = cos ((360/_intersectionTests)*_i);
			_axis2 = sin ((360/_intersectionTests)*_i);
			{
				_directionUnitVector = vectorNormalized _x;
				_intersectStartASL = _newPosition;
				_intersectEndASL = _newPosition vectorAdd ( _directionUnitVector vectorMultiply _radius );
				_surfaces = lineIntersectsSurfaces [_intersectStartASL, _intersectEndASL, _player, objNull, true, 10,"FIRE","NONE"];
				{
					_x params ["_intersectionPositionASL", "_surfaceNormal", "_intersectionObject"];
					_objectFileName = str _intersectionObject;
					if((_objectFileName find "rope") == -1 && not (_intersectionObject isKindOf "RopeSegment") && (_objectFileName find " t_") == -1 && (_objectFileName find " b_") == -1 ) then {
						if(_newPosition distance _intersectionPositionASL < 1) then {
							_newPosition = _intersectionPositionASL vectorAdd ( ( vectorNormalized ( _intersectEndASL vectorFromTo _intersectStartASL )) vectorMultiply  (_radius) );
						};
						_velocityVec = _velocityVec vectorAdd (( _surfaceNormal vectorMultiply (_velocityVec vectorDotProduct _surfaceNormal)) vectorMultiply -1);
					};
				} forEach _surfaces;
			} forEach [[_axis1, _axis2, 0], [_axis1, 0, _axis2], [0, _axis1, _axis2]];
		};
		
		
		_jumpPressed = _player getVariable ["AUR_JUMP_PRESSED",false];
		_jumpPressedTime = _player getVariable ["AUR_JUMP_PRESSED_TIME",0];
		_leftDown = _player getVariable ["AUR_LEFT_DOWN",false];
		_rightDown = _player getVariable ["AUR_RIGHT_DOWN",false];
		
		if(_jumpPressed || _leftDown || _rightDown) then {
			
			// Get the surface normal of the surface the player is hanging against
			_intersectStartASL = _newPosition;
			_intersectEndASL = _intersectStartASL vectorAdd (vectorDir _player vectorMultiply (_radius + 0.3));
			_surfaces = lineIntersectsSurfaces [_intersectStartASL, _intersectEndASL, _player, objNull, true, 10, "GEOM", "NONE"];
			_isAgainstSurface = false;
			{
				_x params ["_intersectionPositionASL", "_surfaceNormal", "_intersectionObject"];
				_objectFileName = str _intersectionObject;
				if((_objectFileName find "rope") == -1 && not (_intersectionObject isKindOf "RopeSegment") && (_objectFileName find " t_") == -1 && (_objectFileName find " b_") == -1 ) exitWith {
					_isAgainstSurface = true;
				};
			} forEach _surfaces;

			if(_isAgainstSurface) then {
				if(_jumpPressed) then {
					_jumpForce = ((( 1.5 min _jumpPressedTime )/1.5) * 4.5) max 2.5;
					_velocityVec = _velocityVec vectorAdd (vectorDir _player vectorMultiply (_jumpForce * -1));
					_player setVariable ["AUR_JUMP_PRESSED", false];
				};
				if(_rightDown) then {
					_walkingOnWallForce = (vectorNormalized ((vectorDir _player) vectorCrossProduct [0,0,1])) vectorMultiply 1;
				};
				if(_leftDown) then {
					_walkingOnWallForce = (vectorNormalized ((vectorDir _player) vectorCrossProduct [0,0,-1])) vectorMultiply 1;
				};
				if(_rightDown && _leftDown) then {
					_walkingOnWallForce = [0,0,0];
				}
			} else {
				_player setVariable ["AUR_JUMP_PRESSED", false];
			};
		
		} else {
			_walkingOnWallForce = [0,0,0];
		};
		
		_rappelDevice setPosWorld (_newPosition vectorAdd (_velocityVec vectorMultiply 0.1) );
		_rappelDevice setVectorDir (vectorDir _player); 
		
		_player setPosWorld (_newPosition vectorAdd [0,0,-0.6]);

		_player setVelocity [0,0,0];

		_lastPosition = _newPosition;
		
		//if((getPos _player) select 2 < 1 || !alive _player || vehicle _player != _player || ropeLength _rope2 <= 1 || _player getVariable ["AUR_Climb_To_Top",false] || _player getVariable ["AUR_Detach_Rope",false] ) exitWith {};
		if(!alive _player || vehicle _player != _player || _player getVariable ["AUR_Climb_To_Top",false] || _player getVariable ["AUR_Detach_Rope",false] ) exitWith {};
		
		sleep 0.01;
	};

	/*
	if(ropeLength _rope2 > 1 && alive _player && vehicle _player == _player && not (_player getVariable ["AUR_Climb_To_Top",false])) then {
		// Here was cheating code to prevent players from being dumb. Not our style. Removed.		
	};*/
	
	if(_player getVariable ["AUR_Climb_To_Top",false]) then {
		_player allowDamage false;
		_player setPosASL _playerPreRappelPosition;
	};

	ropeDestroy _rope1;
	ropeDestroy _rope2;		
	deleteVehicle _anchor;
	deleteVehicle _rappelDevice;
	
	_player setVariable ["AUR_Is_Rappelling",nil,true];
	_player setVariable ["AUR_Rappel_Rope_Top",nil];
	_player setVariable ["AUR_Rappel_Rope_Bottom",nil];
	_player setVariable ["AUR_Rappel_Rope_Length",nil];
	_player setVariable ["AUR_Climb_To_Top",nil];
	_player setVariable ["AUR_Detach_Rope",nil];
	_player setVariable ["AUR_Animation_Move",nil,true];

	if(_decendRopeKeyDownHandler != -1) then {			
		(findDisplay 46) displayRemoveEventHandler ["KeyDown", _decendRopeKeyDownHandler];
	};
	
	sleep 2;
	
	_player allowDamage true;

};

AUR_Enable_Rappelling_Animation_Global = {
	params ["_player"];
	[_player,true] remoteExec ["AUR_Enable_Rappelling_Animation", 0];
};

AUR_Enable_Rappelling_Animation = {
	params ["_player",["_globalExec",false]];
	
	if(local _player && _globalExec) exitWith {};
	
	if(local _player && !_globalExec) then {
		[_player] remoteExec ["AUR_Enable_Rappelling_Animation_Global", 2];
	};

	if(_player != player) then {
		_player enableSimulation false;
	};
	
	if(call GSRI_fnc_aurHasAddonAnimsInstalled) then {		
		if([_player] call GSRI_fnc_aurGetCurrentWeaponType == "HANDGUN") then {
			if(local _player) then {
				_player switchMove "AUR_01_Idle_Pistol";
				_player setVariable ["AUR_Animation_Move","AUR_01_Idle_Pistol_No_Actions",true];
			} else {
				_player setVariable ["AUR_Animation_Move","AUR_01_Idle_Pistol_No_Actions"];			
			};
		} else {
			if(local _player) then {
				_player switchMove "AUR_01_Idle";
				_player setVariable ["AUR_Animation_Move","AUR_01_Idle_No_Actions",true];
			} else {
				_player setVariable ["AUR_Animation_Move","AUR_01_Idle_No_Actions"];
			};
		};
		if!(local _player) then {
			// Temp work around to avoid seeing other player as standing
			_player switchMove "AUR_01_Idle_No_Actions";
			sleep 1;
			_player switchMove "AUR_01_Idle_No_Actions";
			sleep 1;
			_player switchMove "AUR_01_Idle_No_Actions";
			sleep 1;
			_player switchMove "AUR_01_Idle_No_Actions";
		};
	} else {
		if(local _player) then {
			_player switchMove "HubSittingChairC_idle1";
			_player setVariable ["AUR_Animation_Move","HubSittingChairC_idle1",true];
		} else {
			_player setVariable ["AUR_Animation_Move","HubSittingChairC_idle1"];		
		};
	};

	_animationEventHandler = -1;
	if(local _player) then {
		_animationEventHandler = _player addEventHandler ["AnimChanged",{
			params ["_player","_animation"];
			if(call GSRI_fnc_aurHasAddonAnimsInstalled) then {
				if((toLower _animation) find "aur_" < 0) then {
					if([_player] call GSRI_fnc_aurGetCurrentWeaponType == "HANDGUN") then {
						_player switchMove "AUR_01_Aim_Pistol";
						_player setVariable ["AUR_Animation_Move","AUR_01_Aim_Pistol_No_Actions",true];
					} else {
						_player switchMove "AUR_01_Aim";
						_player setVariable ["AUR_Animation_Move","AUR_01_Aim_No_Actions",true];
					};
				} else {
					if(toLower _animation == "aur_01_aim") then {
						_player setVariable ["AUR_Animation_Move","AUR_01_Aim_No_Actions",true];
					};
					if(toLower _animation == "aur_01_idle") then {
						_player setVariable ["AUR_Animation_Move","AUR_01_Idle_No_Actions",true];
					};
					if(toLower _animation == "aur_01_aim_pistol") then {
						_player setVariable ["AUR_Animation_Move","AUR_01_Aim_Pistol_No_Actions",true];
					};
					if(toLower _animation == "aur_01_idle_pistol") then {
						_player setVariable ["AUR_Animation_Move","AUR_01_Idle_Pistol_No_Actions",true];
					};
				};
			} else {
				_player switchMove "HubSittingChairC_idle1";
				_player setVariable ["AUR_Animation_Move","HubSittingChairC_idle1",true];
			};
		}];
	};
	
	if(!local _player) then {
		[_player] spawn {
			params ["_player"];
			private ["_currentState"];
			while {_player getVariable ["AUR_Is_Rappelling",false]} do {
				_currentState = toLower animationState _player;
				_newState = toLower (_player getVariable ["AUR_Animation_Move",""]);
				if!(call GSRI_fnc_aurHasAddonAnimsInstalled) then {
					_newState = "HubSittingChairC_idle1";
				};
				if(_currentState != _newState) then {
					_player switchMove _newState;
					_player switchGesture "";
					sleep 1;
					_player switchMove _newState;
					_player switchGesture "";
				};
				sleep 0.1;
			};			
		};
	};
	
	waitUntil {!(_player getVariable ["AUR_Is_Rappelling",false])};
	
	if(_animationEventHandler != -1) then {
		_player removeEventHandler ["AnimChanged", _animationEventHandler];
	};
	
	_player switchMove "";	
	_player enableSimulation true;
	
};

AUR_Hide_Object_Global = {
	params ["_obj"];
	if( _obj isKindOf "Land_Can_V2_F" || _obj isKindOf "B_static_AA_F" ) then {
		hideObjectGlobal _obj;
	};
};

AUR_Add_Player_Actions = {
	params ["_player"];
	
	_player addAction ["Rappel Self", { 
		[player, vehicle player] call GSRI_fnc_aurRappelAction;
	}, nil, 0, false, true, "", "[player] call GSRI_fnc_aurCheckRappelAction"];

	_player addAction ["Climb To Top", { 
		[player] call GSRI_fnc_aurClimbToTopAction;
	}, nil, 0, false, true, "", "[player] call GSRI_fnc_aurCheckClimbToTop"];
	
	_player addAction ["Detach Rappel Device", { 
		[player] call GSRI_fnc_aurDetachAction;
	}, nil, 0, false, true, "", "[player] call GSRI_fnc_aurCheckDetachAction"];
	
	_player addEventHandler ["Respawn", {
		player setVariable ["AUR_Actions_Loaded",false];
	}];
	
};

if(!isDedicated) then {
	[] spawn {
		while {true} do {
			if(!isNull player && isPlayer player) then {
				if!(player getVariable ["AUR_Actions_Loaded",false] ) then {
					[player] call AUR_Add_Player_Actions;
					player setVariable ["AUR_Actions_Loaded",true];
				};
			};
			sleep 5;
		};
	};
};

diag_log "Advanced Urban Rappelling Loaded";

};


[] call AUR_Advanced_Urban_Rappelling_Install;
