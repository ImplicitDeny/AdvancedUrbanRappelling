params ["_player"];	
if([_player] call GSRI_fnc_aurCheckRappelAction) then {
	_rappelPoint = [_player,"POSITION"] call GSRI_fnc_aurFindNearbyRappelPoint;
	if(count _rappelPoint > 0) then {
		_player setVariable ["AUR_Rappelling_Last_Started_Time",diag_tickTime];
		_player setVariable ["AUR_Rappelling_Last_Rappel_Point",_rappelPoint];
		_ropeLength = _player getVariable ["GSRI_AUR_ropeLength", 30];
		[_player, _rappelPoint select 0, _rappelPoint select 1,_ropeLength] call GSRI_fnc_aurRappel;
	} else {
		"Couldn't attach rope. Move closer to edge!" remoteExec ["hint", _player];
	};
} else {
	"Couldn't attach rope. Move closer to edge!" remoteExec ["hint", _player];
};