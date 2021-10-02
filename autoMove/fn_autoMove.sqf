// File: fn_autoRun.sqf
// Author: Gen. Henry Arnold
// Description: Toggles automoving on or off.
// Spawn this function from a keyDown / keyUp handler using a custom user action.

// Exit checks
// Add reasons why auto moveing should not start
if !(isNull objectParent player) exitWith {};

// Key handler stop
// Lets stop the running using a key down EH on display 46. This can be toggled with the activation key or stopped immediatly on any keyboard press or movement key press.

// Animation duration
private _getAnimDuration = {
    private _animSpeed = getNumber (configfile >> "CfgMovesMaleSdr" >> "States" >> _this >> "speed");
    private _duration = if !(_animSpeed isEqualTo 0) then {abs (1 / _animSpeed)} else {0};

    _duration * 0.9;
};

// Loop auto moving
while {GEN_autoMove} do {

	// Exit checks
	// Add reasons why auto moveing should stop
	if !(isNull objectParent player) exitWith {GEN_autoMove = false;};
	if !(alive player) exitWith {GEN_autoMove = false;};

	// Init player variables
	private _terrainSlope = [getPos player, getDir player] call BIS_fnc_terrainGradAngle;
	private _staminaTime = getStamina player;
	private _damage = damage player;
	private _damageLegs = player getHit "legs";
	private _uniform = uniform player;
	private _animation = "";
	private _diveSuits = ["U_O_Wetsuit", "U_I_Wetsuit", "U_B_Wetsuit", "U_B_survival_uniform"];
	private _curWep = currentWeapon player;
	private _primary = primaryWeapon player;
	private _secondary = secondaryWeapon player;
	private _handgun = handgunWeapon player;

	// Check for terrain, stamina, damage
	switch (true) do {

		// Swim Fast
		case (_staminaTime > 1.5 && surfaceIsWater position player && (((getPosASL player) select 2) < -1.15) && _damage < 0.5 && _damageLegs < 0.5): {
			_animation = switch (true) do {

				// Dive suit
				case (_curWep isEqualTo "" && _uniform in _diveSuits): {"AbdvPercMsprSnonWnonDf"};
				case (_curWep isEqualTo _primary && _uniform in _diveSuits): {"AbdvPercMsprSnonWrflDf"};
				// No dive suit
				case (_curWep isEqualTo ""): {"AbswPercMsprSnonWnonDf"};
				default {"AbswPercMsprSnonWnonDf"};
			};

			// Simulate stamina use
			player setStamina (_staminaTime - 0.0001);
		};

		// Swim Normal
		case (surfaceIsWater position player && (((getPosASL player) select 2) < -1.15) && _damage < 0.5 && _damageLegs < 0.5): {
			_animation = switch (true) do {

				// Dive suit
				case (_curWep isEqualTo "" && _uniform in _diveSuits): {"AbdvPercMrunSnonWnonDf"};
				case (_curWep isEqualTo _primary && _uniform in _diveSuits): {"AbdvPercMrunSnonWrflDf"};

				// No dive suit
				case (_curWep isEqualTo ""): {"AbswPercMrunSnonWnonDf"};
				default {"AbswPercMrunSnonWnonDf"};
			};
		};

		// Swim Hurt
		case (surfaceIsWater position player && (((getPosASL player) select 2) < -1.6)): {
			_animation = switch (true) do {

				// Dive suit
				case (_curWep isEqualTo "" && _uniform in _diveSuits): {"AdvePercMwlkSnonWnonDf"};
				case (_curWep isEqualTo _primary && _uniform in _diveSuits): {"AbdvPercMwlkSnonWrflDf"};

				// No dive suit
				case (_curWep isEqualTo ""): {"AbswPercMwlkSnonWnonDf"};
				default {"AbswPercMwlkSnonWnonDf"};
			};
		};

		// Run
		case (_staminaTime > 1.5 && _terrainSlope < 20 && _damage < 0.5 && _damageLegs < 0.5 && !(surfaceIsWater position player)): {
			_animation = switch (true) do {
				case (_curWep isEqualTo ""): {"AmovPercMevaSnonWnonDf"};
				case (_curWep isEqualTo _primary): {"AmovPercMevaSlowWrflDf"};
				case (_curWep isEqualTo _secondary): {"AmovPercMevaSlowWlnrDf"};
				case (_curWep isEqualTo _handgun): {"AmovPercMevaSlowWpstDf"};
				default {"AmovPercMevaSnonWnonDf"};
			};

			// Simulate stamina use
			player setStamina (_staminaTime - 0.0001);
		};

		// Limp
		case (_damage >= 0.5 || _damageLegs >= 0.5): {
			_animation = switch (true) do {
				case (_curWep isEqualTo ""): {"AmovPercMlmpSnonWnonDf"};
				case (_curWep isEqualTo _primary): {"AmovPercMlmpSlowWrflDf"};
				case (_curWep isEqualTo _secondary): {"AmovPercMlmpSlowWlnrDf"};
				case (_curWep isEqualTo _handgun): {"AmovPercMlmpSrasWpstDf"};
				default {"AmovPercMlmpSnonWnonDf"};
			};
		};

		// Cliff walk
		case (_terrainSlope >= 30): {
			_animation = switch (true) do {
				case (_curWep isEqualTo ""): {"AmovPercMwlkSnonWnonDf"};
				case (_curWep isEqualTo _primary): {"AmovPercMwlkSlowWrflDf_ver2"};
				case (_curWep isEqualTo _secondary): {"AmovPercMwlkSrasWlnrDf"};
				case (_curWep isEqualTo _handgun): {"AmovPercMwlkSlowWpstDf"};
				default {"AmovPercMrunSnonWnonDf"};
			};
		};

		// Walk
		default {
			_animation = switch (true) do {
				case (_curWep isEqualTo ""): {"AmovPercMrunSnonWnonDf"};
				case (_curWep isEqualTo _primary): {"AmovPercMrunSlowWrflDf"};
				case (_curWep isEqualTo _secondary): {"AmovPercMrunSrasWlnrDf"};
				case (_curWep isEqualTo _handgun): {"AmovPercMrunSlowWpstDf"};
				default {"AmovPercMrunSnonWnonDf"};
			};
		};
	};

	// Animate
	player playMove _animation;

	// Debug
	//systemChat format ["%1", time];

	// Sleep for ratelimit
	uiSleep (_animation call _getAnimDuration);
};
