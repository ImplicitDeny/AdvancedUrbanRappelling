/*
The MIT License (MIT)

Copyright (c) 2016 Seth Duda

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

systemChat "GRSI-modified AUR running";

// Prevent advanced urban rappelling from installing twice
if(!isNil "AUR_RAPPELLING_INIT") exitWith {};
AUR_RAPPELLING_INIT = true;

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

systemChat "GSRI-modified AUR loaded";
