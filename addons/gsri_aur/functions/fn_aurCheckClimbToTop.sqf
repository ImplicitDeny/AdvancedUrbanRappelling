params ["_player"];
private ["_topRope"];
if!(_player getVariable ["AUR_Is_Rappelling",false]) exitWith {false;};
_topRope = player getVariable ["AUR_Rappel_Rope_Top",nil];
if(isNil "_topRope") exitWith {false;};
if(ropeLength _topRope > 1) exitWith {false;};
true;