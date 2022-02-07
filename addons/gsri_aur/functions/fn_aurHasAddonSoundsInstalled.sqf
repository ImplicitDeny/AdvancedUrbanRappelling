private ["_config","_configMission"];
_config = getArray ( configFile / "CfgSounds" / "AUR_Rappel_Start" / "sound" );
_configMission = getArray ( missionConfigFile / "CfgSounds" / "AUR_Rappel_Start" / "sound" );
(count _config > 0 || count _configMission > 0);