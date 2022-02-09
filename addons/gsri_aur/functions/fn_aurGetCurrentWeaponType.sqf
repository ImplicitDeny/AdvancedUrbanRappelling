params ["_player"];

switch (currentWeapon _player) do {
	case (handgunWeapon _player): { "HANDGUN" };
	case (primaryWeapon _player): { "PRIMARY" };
	case (secondaryWeapon _player): { "SECONDARY" };
	default { "OTHER" };
}
