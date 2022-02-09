params ["_player","_rappelDevice","_rappelAncor"];
if(!hasInterface) exitWith {};
if(player distance _player < 15) then {
	[_player, "AUR_Rappel_Start"] call GSRI_fnc_aurPlaySound3D;
	[_rappelDevice, "AUR_Rappel_Loop"] call GSRI_fnc_aurPlaySound3D;
};
_this spawn {
	params ["_player","_rappelDevice","_rappelAncor"];
	private ["_lastDistanceFromAnchor","_distanceFromAnchor"];
	_lastDistanceFromAnchor = _rappelDevice distance _rappelAncor;
	while {_player getVariable ["AUR_Is_Rappelling",false]} do {
		_distanceFromAnchor = _rappelDevice distance _rappelAncor;
		if(_distanceFromAnchor > _lastDistanceFromAnchor + 0.1 && player distance _player < 15) then {
			[_player, "AUR_Rappel_Loop"] call GSRI_fnc_aurPlaySound3D;
			sleep 0.2;
			[_rappelDevice, "AUR_Rappel_Loop"] call GSRI_fnc_aurPlaySound3D;
		};
		sleep 0.9;
		_lastDistanceFromAnchor = _distanceFromAnchor;
	};
};
_this spawn {
	params ["_player"];
	while {_player getVariable ["AUR_Is_Rappelling",false]} do {
		sleep 0.1;
	};
	if(player distance _player < 15) then {
		[_player, "AUR_Rappel_End"] call GSRI_fnc_aurPlaySound3D;
	};
};