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

class NotesSubstate extends MusicBeatSubstate
{
	private static var curSelected:Int = 0;
	private var grpNumbers:FlxTypedGroup<FlxText>;
	private var grpNotes:FlxTypedGroup<FlxSprite>;
	private var shaderArray:Array<ColorSwap> = [];
	var curValue:Float = 0;
	var holdTime:Float = 0;

	public function new() {
		super();

		grpNotes = new FlxTypedGroup<FlxSprite>();
		add(grpNotes);
		grpNumbers = new FlxTypedGroup<FlxText>();
		add(grpNumbers);

		for (i in 0...ClientPrefs.arrowColors.length) {
			var optionText:FlxText = new FlxText(450, (165 * i) + 60, 400, Std.string(ClientPrefs.arrowColors[i]), 64);
			optionText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			optionText.scrollFactor.set();
			optionText.borderSize = 3;
			grpNumbers.add(optionText);

			var note:FlxSprite = new FlxSprite(optionText.x - 70, optionText.y - 40);
			note.frames = Paths.getSparrowAtlas('NOTE_assets');
			switch(i) {
				case 0:
					note.animation.addByPrefix('idle', 'purple0');
				case 1:
					note.animation.addByPrefix('idle', 'blue0');
				case 2:
					note.animation.addByPrefix('idle', 'green0');
				case 3:
					note.animation.addByPrefix('idle', 'red0');
			}
			note.animation.play('idle');
			note.antialiasing = ClientPrefs.globalAntialiasing;
			grpNotes.add(note);

			var newShader:ColorSwap = new ColorSwap();
			note.shader = newShader.shader;
			newShader.update(ClientPrefs.arrowColors[i]);
			shaderArray.push(newShader);
		}
		changeSelection();
	}

	override function update(elapsed:Float) {
		if (controls.UI_UP_P) {
			changeSelection(-1);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		if(holdTime < 0.5) {
			if(controls.UI_LEFT) {
				holdTime += elapsed;
				if(controls.UI_LEFT_P) {
					FlxG.sound.play(Paths.sound('scrollMenu'));
					updateValue(-1);
				}
			} else if(controls.UI_RIGHT) {
				holdTime += elapsed;
				if(controls.UI_RIGHT_P) {
					FlxG.sound.play(Paths.sound('scrollMenu'));
					updateValue(1);
				}
			} else if(controls.UI_LEFT_R || controls.UI_RIGHT_R) {
				holdTime = 0;
			}
		} else {
			if(controls.UI_LEFT) {
				updateValue(elapsed * -60);
			} else if(controls.UI_RIGHT) {
				updateValue(elapsed * 60);
			} else if(controls.UI_LEFT_R) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				holdTime = 0;
			} else if(controls.UI_RIGHT_R) {
				FlxG.sound.play(Paths.sound('scrollMenu'));
				holdTime = 0;
			}
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			var item2 = grpNotes.members[i];
			if (curSelected == i) {
				item.x = FlxMath.lerp(item.x, 550, lerpVal);
				item2.x = item.x - 70;
			} else {
				item.x = FlxMath.lerp(item.x, 450, lerpVal);
				item2.x = item.x - 70;
			}
		}

		if (controls.BACK) {
			close();
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = ClientPrefs.arrowColors.length-1;
		if (curSelected >= ClientPrefs.arrowColors.length)
			curSelected = 0;

		curValue = ClientPrefs.arrowColors[curSelected];
		updateValue();

		for (i in 0...grpNumbers.length) {
			var item = grpNumbers.members[i];
			var item2 = grpNotes.members[i];
			item.alpha = 0.6;
			item2.alpha = 0.6;
			shaderArray[i].shader.awesomeOutline.value = [false];
			if (curSelected == i) {
				item.alpha = 1;
				item2.alpha = 1;
				shaderArray[i].shader.awesomeOutline.value = [true];
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function updateValue(change:Float = 0) {
		curValue += change;
		var roundedValue:Int = Math.round(curValue);
		if(roundedValue < -180) {
			curValue = 180;
		} else if(roundedValue > 180) {
			curValue = -180;
		}
		roundedValue = Math.round(curValue);

		ClientPrefs.arrowColors[curSelected] = roundedValue;
		shaderArray[curSelected].update(roundedValue);
		grpNumbers.members[curSelected].text = Std.string(roundedValue);
	}
}
