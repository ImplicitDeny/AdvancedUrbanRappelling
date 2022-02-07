params ["_player"];
if(_player getVariable ["AUR_Is_Rappelling",false]) exitWith {false;};
if(vehicle _player != _player) exitWith {false;};
if(([_player] call GSRI_fnc_aurGetPlayerHeightAboveGround) < 4) exitWith {false};
if!([_player,"FAST_EXISTS_CHECK"] call GSRI_fnc_aurFindNearbyRappelPoint) exitWith {false;};
if(count ([_player,"POSITION"] call GSRI_fnc_aurFindNearbyRappelPoint) == 0) exitWith {false;};
true;