package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import lime.utils.Assets;
import haxe.Json;
import openfl.net.FileReference;

using StringTools;

class PreferencesSubstate extends MusicBeatSubstate
{
	private static var curSelected:Int = 1;
	var options:Array<String> = [
		'GRAPHICS',
		'Low Quality',
		'Anti-Aliasing',
		#if !html5
		'Double Framerate', //Apparently 120FPS isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		#end
		'',
		'GAMEPLAY',
		'Downscroll',
		'Note Splashes',
		'Flashing Lights',
		'Camera Zooms'
		#if !mobile
		,'FPS Counter'
		#end
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxArray:Array<CheckboxThingie> = [];

	private var characterLayer:FlxTypedGroup<Character>;
	private var showCharacter:Character = null;
	private var descText:FlxText;

	var nextAccept:Int = 5;

	public function new()
	{
		super();
		characterLayer = new FlxTypedGroup<Character>();
		add(characterLayer);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var isCentered:Bool = unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, options[i], false, false);
			optionText.isMenuItem = true;
			if(isCentered) {
				optionText.screenCenter(X);
				optionText.forceX = optionText.x;
			} else {
				optionText.x += 250;
				optionText.forceX = 250;
			}
			optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(!isCentered) {
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, false);
				checkbox.sprTracker = optionText;
				checkboxArray.push(checkbox);
				add(checkbox);
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		changeSelection();
		reloadCheckboxes();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			close();
		}

		if(controls.ACCEPT && nextAccept <= 0) {
			switch(options[curSelected]) {
				case 'Double Framerate':
					ClientPrefs.doubleFps = !ClientPrefs.doubleFps;
					if(ClientPrefs.doubleFps) {
						FlxG.updateFramerate = 120;
						FlxG.drawFramerate = 120;
					} else {
						FlxG.drawFramerate = 60;
						FlxG.updateFramerate = 60;
					}
					nextAccept = 5;

				case 'FPS Counter':
					ClientPrefs.showFPS = !ClientPrefs.showFPS;
					if(Main.fpsVar != null)
						if(ClientPrefs.showFPS)
							Main.fpsVar.x = 10;
						else
							Main.fpsVar.x = -100;

				case 'Low Quality':
					ClientPrefs.lowQuality = !ClientPrefs.lowQuality;

				case 'Anti-Aliasing':
					ClientPrefs.globalAntialiasing = !ClientPrefs.globalAntialiasing;
					showCharacter.antialiasing = ClientPrefs.globalAntialiasing;
					for (item in grpOptions) {
						item.antialiasing = ClientPrefs.globalAntialiasing;
					}
					for (i in 0...checkboxArray.length) {
						var spr:CheckboxThingie = checkboxArray[i];
						if(spr != null) {
							spr.antialiasing = ClientPrefs.globalAntialiasing;
						}
					}
					OptionsState.menuBG.antialiasing = ClientPrefs.globalAntialiasing;

				case 'Note Splashes':
					ClientPrefs.noteSplashes = !ClientPrefs.noteSplashes;

				case 'Flashing Lights':
					ClientPrefs.flashing = !ClientPrefs.flashing;

				case 'Violence':
					ClientPrefs.violence = !ClientPrefs.violence;

				case 'Swearing':
					ClientPrefs.cursing = !ClientPrefs.cursing;

				case 'Downscroll':
					ClientPrefs.downScroll = !ClientPrefs.downScroll;

				case 'Camera Zooms':
					ClientPrefs.camZooms = !ClientPrefs.camZooms;
			}
			FlxG.sound.play(Paths.sound('scrollMenu'));
			reloadCheckboxes();
		}

		if(showCharacter != null && showCharacter.animation.curAnim.finished) {
			showCharacter.dance();
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}
	
	function changeSelection(change:Int = 0)
	{
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = options.length - 1;
			if (curSelected >= options.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		switch(options[curSelected]) {
			case 'Double Framerate':
				descText.text = "If checked, the framerate will be increased to 120.";
			case 'FPS Counter':
				descText.text = "If unchecked, hides FPS Counter.";
			case 'Low Quality':
				descText.text = "If checked, disables some background details,\ndecreases loading times and improves performance.";
			case 'Anti-Aliasing':
				descText.text = "If unchecked, disables anti-aliasing, increases performance\nat the cost of the graphics not looking as smooth.";
			case 'Downscroll':
				descText.text = "If checked, notes go Down instead of Up, simple enough.";
			case 'Swearing':
				descText.text = "If unchecked, your mom won't be angry at you.";
			case 'Violence':
				descText.text = "If unchecked, you won't get disgusted as frequently.";
			case 'Note Splashes':
				descText.text = "If unchecked, hitting \"Sick!\" notes won't show particles.";
			case 'Flashing Lights':
				descText.text = "Uncheck this if you're sensitive to flashing lights!";
			case 'Camera Zooms':
				descText.text = "If unchecked, the camera won't zoom in on a beat hit.";
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}

				for (j in 0...checkboxArray.length) {
					var tracker:FlxSprite = checkboxArray[j].sprTracker;
					if(tracker == item) {
						checkboxArray[j].alpha = item.alpha;
						break;
					}
				}
			}
		}

		if(options[curSelected] == 'Anti-Aliasing') {
			if(showCharacter == null) {
				showCharacter = new Character(840, 170, 'bf', true);
				showCharacter.setGraphicSize(Std.int(showCharacter.width * 0.8));
				showCharacter.updateHitbox();
				showCharacter.dance();
				characterLayer.add(showCharacter);
			}
		} else if(showCharacter != null) {
			characterLayer.clear();
			showCharacter = null;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadCheckboxes() {
		for (i in 0...grpOptions.length) {
			for (j in 0...checkboxArray.length) {
				var checkbox:CheckboxThingie = checkboxArray[j];
				if(checkbox != null && checkbox.sprTracker == grpOptions.members[i]) {
					var daValue:Bool = false;
					switch(options[i]) {
						case 'Double Framerate':
							daValue = ClientPrefs.doubleFps;
						case 'FPS Counter':
							daValue = ClientPrefs.showFPS;
						case 'Low Quality':
							daValue = ClientPrefs.lowQuality;
						case 'Anti-Aliasing':
							daValue = ClientPrefs.globalAntialiasing;
						case 'Note Splashes':
							daValue = ClientPrefs.noteSplashes;
						case 'Flashing Lights':
							daValue = ClientPrefs.flashing;
						case 'Downscroll':
							daValue = ClientPrefs.downScroll;
						case 'Swearing':
							daValue = ClientPrefs.cursing;
						case 'Violence':
							daValue = ClientPrefs.violence;
						case 'Camera Zooms':
							daValue = ClientPrefs.camZooms;
					}
					checkbox.set_daValue(daValue);
					break;
				}
			}
		}
	}

	private function unselectableCheck(num:Int):Bool {
		return options[num] == 'GRAPHICS' || options[num] == 'GAMEPLAY' || options[num] == '';
	}
}
