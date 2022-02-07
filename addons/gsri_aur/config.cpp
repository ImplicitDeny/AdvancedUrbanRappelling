class CfgPatches
{
	class AUR_AdvancedUrbanRappelling
	{
		author = "duda123";
		name = "Advanced Urban Rappelling";
		url = "https://github.com/sethduda/AdvancedUrbanRappelling";
		units[] = {"AUR_AdvancedUrbanRappelling"};
		requiredVersion = 1.0;
		requiredAddons[] = {"A3_Modules_F"};
	};
};

class CfgFunctions {
	class GSRI {
		class AUR {
			file = "fr\gsri\aur\functions";
			class advancedUrbanRappellingInit {	postInit=1 };
			class aurPlaySound3D {};
			class aurPlayRappellingSound {};
			class aurPlayRappellingSoundGlobal {};
			class aurHasAddonAnimsInstalled {};
			class aurHasAddonSoundsInstalled {};
			class aurFindNearbyRappelPoint {};
			class aurGetPlayerHeightAboveGround {};
			class aurCheckRappelAction {};
			class aurCheckDetachAction {};
			class aurCheckClimbToTop {};
			class aurRappelAction {};
			class aurDetachAction {};
			class aurClimbToTopAction {};
		};
	};
};

class CfgSounds
{
	class AUR_Rappel_Loop
	{
		name = "AUR_Rappel_Loop";
		sound[] = {"fr\gsri\aur\sounds\AUR_Rappel_Loop.ogg", db+5, 1};
		titles[] = {0,""};
	};
	class AUR_Rappel_Start
	{
		name = "AUR_Rappel_Start";
		sound[] = {"fr\gsri\aur\sounds\AUR_Rappel_Start.ogg", db+10, 1};
		titles[] = {0,""};
	};
	class AUR_Rappel_End
	{
		name = "AUR_Rappel_End";
		sound[] = {"fr\gsri\aur\sounds\AUR_Rappel_End.ogg", db+10, 1};
		titles[] = {0,""};
	};
};
#include "cfgAnimations.hpp"
