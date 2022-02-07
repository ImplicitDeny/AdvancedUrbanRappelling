params ["_soundSource","_className"];
private ["_config","_configMission"];
_config = getArray ( configFile / "CfgSounds" / _className / "sound" );
if(count _config > 0) exitWith {
	_soundSource say3D  _className;
};
_configMission = getArray ( missionConfigFile / "CfgSounds" / _className / "sound" );
if(count _configMission > 0) exitWith {
	_soundSource say3D  _className;
};