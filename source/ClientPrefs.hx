package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import Controls;

class ClientPrefs {
	public static var downScroll:Bool = false;
	public static var showFPS:Bool = true;
	public static var flashing:Bool = true;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var doubleFps:Bool = false;
	public static var cursing:Bool = true;
	public static var violence:Bool = true;
	public static var camZooms:Bool = true;
	public static var arrowColors:Array<Int> = [0, 0, 0, 0];

	public static var defaultKeys:Array<FlxKey> = [
		A, LEFT,			//Note Left
		S, DOWN,			//Note Down
		W, UP,				//Note Up
		D, RIGHT,			//Note Right

		A, LEFT,			//UI Left
		S, DOWN,			//UI Down
		W, UP,				//UI Up
		D, RIGHT,			//UI Right

		R, NONE,			//Reset
		SPACE, ENTER,		//Accept
		BACKSPACE, ESCAPE,	//Back
		ENTER, ESCAPE		//Pause
	];
	public static var lastControls:Array<FlxKey> = defaultKeys.copy();

	public static function saveSettings() {
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.doubleFps = doubleFps;
		FlxG.save.data.cursing = cursing;
		FlxG.save.data.violence = violence;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.arrowColors = arrowColors;

		var achieves:Array<String> = [];
		for (i in 0...Achievements.achievementsUnlocked.length) {
			if(Achievements.achievementsUnlocked[i][1]) {
				achieves.push(Achievements.achievementsUnlocked[i][0]);
			}
		}
		FlxG.save.data.achievementsUnlocked = achieves;
		FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls', 'ninjamuffin99'); //Placing this in a separate save so that it can be deleted without removing your Score and stuff
		save.data.customControls = lastControls;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		if(FlxG.save.data.downScroll != null) {
			downScroll = FlxG.save.data.downScroll;
		}
		if(FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			if(Main.fpsVar != null) {
				if(showFPS) {
					Main.fpsVar.x = 10;
				} else {
					Main.fpsVar.x = -100;
				}
			}
		}
		if(FlxG.save.data.flashing != null) {
			flashing = FlxG.save.data.flashing;
		}
		if(FlxG.save.data.globalAntialiasing != null) {
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		}
		if(FlxG.save.data.noteSplashes != null) {
			noteSplashes = FlxG.save.data.noteSplashes;
		}
		if(FlxG.save.data.lowQuality != null) {
			lowQuality = FlxG.save.data.lowQuality;
		}
		if(FlxG.save.data.doubleFps != null) {
			doubleFps = FlxG.save.data.doubleFps;
			if(doubleFps) {
				FlxG.updateFramerate = 120;
				FlxG.drawFramerate = 120;
			} else {
				FlxG.drawFramerate = 60;
				FlxG.updateFramerate = 60;
			}
		}
		/*if(FlxG.save.data.cursing != null) {
			cursing = FlxG.save.data.cursing;
		}
		if(FlxG.save.data.violence != null) {
			violence = FlxG.save.data.violence;
		}*/
		if(FlxG.save.data.camZooms != null) {
			camZooms = FlxG.save.data.camZooms;
		}
		if(FlxG.save.data.arrowColors != null) {
			arrowColors = FlxG.save.data.arrowColors;
		}

		var save:FlxSave = new FlxSave();
		save.bind('controls', 'ninjamuffin99');
		if(save != null && save.data.customControls != null) {
			removeControls(lastControls);
			lastControls = save.data.customControls;
			loadControls(lastControls);
		}
	}

	public static function removeControls(controlArray:Array<FlxKey>) {
		PlayerSettings.player1.controls.unbindKeys(Control.NOTE_LEFT, [controlArray[0], controlArray[1]]);
		PlayerSettings.player1.controls.unbindKeys(Control.NOTE_DOWN, [controlArray[2], controlArray[3]]);
		PlayerSettings.player1.controls.unbindKeys(Control.NOTE_UP, [controlArray[4], controlArray[5]]);
		PlayerSettings.player1.controls.unbindKeys(Control.NOTE_RIGHT, [controlArray[6], controlArray[7]]);

		PlayerSettings.player1.controls.unbindKeys(Control.UI_LEFT, [controlArray[8], controlArray[9]]);
		PlayerSettings.player1.controls.unbindKeys(Control.UI_DOWN, [controlArray[10], controlArray[11]]);
		PlayerSettings.player1.controls.unbindKeys(Control.UI_UP, [controlArray[12], controlArray[13]]);
		PlayerSettings.player1.controls.unbindKeys(Control.UI_RIGHT, [controlArray[14], controlArray[15]]);

		PlayerSettings.player1.controls.unbindKeys(Control.RESET, [controlArray[16], controlArray[17]]);
		PlayerSettings.player1.controls.unbindKeys(Control.ACCEPT, [controlArray[18], controlArray[19]]);
		PlayerSettings.player1.controls.unbindKeys(Control.BACK, [controlArray[20], controlArray[21]]);
		PlayerSettings.player1.controls.unbindKeys(Control.PAUSE, [controlArray[22], controlArray[23]]);
	}

	public static function loadControls(controlArray:Array<FlxKey>) {
		PlayerSettings.player1.controls.bindKeys(Control.NOTE_LEFT, [controlArray[0], controlArray[1]]);
		PlayerSettings.player1.controls.bindKeys(Control.NOTE_DOWN, [controlArray[2], controlArray[3]]);
		PlayerSettings.player1.controls.bindKeys(Control.NOTE_UP, [controlArray[4], controlArray[5]]);
		PlayerSettings.player1.controls.bindKeys(Control.NOTE_RIGHT, [controlArray[6], controlArray[7]]);

		PlayerSettings.player1.controls.bindKeys(Control.UI_LEFT, [controlArray[8], controlArray[9]]);
		PlayerSettings.player1.controls.bindKeys(Control.UI_DOWN, [controlArray[10], controlArray[11]]);
		PlayerSettings.player1.controls.bindKeys(Control.UI_UP, [controlArray[12], controlArray[13]]);
		PlayerSettings.player1.controls.bindKeys(Control.UI_RIGHT, [controlArray[14], controlArray[15]]);

		PlayerSettings.player1.controls.bindKeys(Control.RESET, [controlArray[16], controlArray[17]]);
		PlayerSettings.player1.controls.bindKeys(Control.ACCEPT, [controlArray[18], controlArray[19]]);
		PlayerSettings.player1.controls.bindKeys(Control.BACK, [controlArray[20], controlArray[21]]);
		PlayerSettings.player1.controls.bindKeys(Control.PAUSE, [controlArray[22], controlArray[23]]);
	}
}