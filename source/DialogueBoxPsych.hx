package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSubState;
import flixel.FlxCamera;

using StringTools;

class DialogueBoxPsych extends MusicBeatSubstate
{
	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	public static var finishThing:Void->Void;
	var bgFade:FlxSprite = null;
	var bgWhite:FlxSprite = null;
	var box:FlxSprite;
	var textToType:String = '';

	var arrayCharacters:Array<FlxSprite> = [];
	var arrayStartX:Array<Float> = [];

	var cam:FlxCamera;
	var currentText:Int = 1;
	var offsetPos:Float = 600;
	public function new(?dialogueList:Array<String>, black:FlxSprite, white:FlxSprite, cam:FlxCamera)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'psychic':
				FlxG.sound.playMusic(Paths.music('psy-dialogue'), 0);
				FlxG.sound.music.fadeIn(2, 0, 1);
		}
		this.cam = cam;
		this.dialogueList = dialogueList;
		var splitName:Array<String> = dialogueList[0].split(":");

		for (i in 0...2) {
			var x:Float = 50;
			var char:FlxSprite = new FlxSprite(50, 180);
			char.x -= offsetPos;
			switch(splitName[i]) {
				case 'bf':
					char.frames = Paths.getSparrowAtlas('dialogue/BF_Dialogue');
					char.animation.addByPrefix('talkIdle', 'BFTalk', 24, true);
					char.animation.addByPrefix('talk', 'bftalkloop', 24, true);
					char.animation.play('talkIdle', true);

				case 'psychic':
					char.frames = Paths.getSparrowAtlas('dialogue/Psy_Dialogue'); //oppa gangnam style xddddd kill me
					char.animation.addByPrefix('talkIdle', 'PSYtalk', 24, true);
					char.animation.addByPrefix('talk', 'PSY loop', 24, true);
					char.animation.addByPrefix('angryIdle', 'PSY angry', 24, true);
					char.animation.addByPrefix('angry', 'PSY ANGRY loop', 24, true);
					char.animation.addByPrefix('unamusedIdle', 'PSY unamused', 24, true);
					char.animation.addByPrefix('unamused', 'PSY UNAMUSED loop', 24, true);
					char.animation.play('talkIdle', true);
					char.y -= 140;
			}
			char.setGraphicSize(Std.int(char.width * 0.7));
			char.updateHitbox();
			if(i > 0) {
				x = FlxG.width - char.width - 100;
				char.x = x + offsetPos;
			}
			char.antialiasing = ClientPrefs.globalAntialiasing;
			char.scrollFactor.set();
			char.cameras = [cam];
			//char.visible = false;
			add(char);
			arrayCharacters.push(char);
			arrayStartX.push(x);
		}

		box = new FlxSprite(70, 370);
		box.frames = Paths.getSparrowAtlas('speech_bubble');
		box.scrollFactor.set();
		box.antialiasing = ClientPrefs.globalAntialiasing;
		box.animation.addByPrefix('normal', 'speech bubble normal', 24);
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('angry', 'AHH speech bubble', 24);
		box.animation.addByPrefix('angryOpen', 'speech bubble loud open', 24, false);
		box.visible = false;
		box.cameras = [cam];
		box.setGraphicSize(Std.int(box.width * 0.9));
		box.updateHitbox();
		add(box);

		bgFade = black;
		bgWhite = white;
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	var textX = 90;
	var textY = 430;
	var scrollSpeed = 4500;
	var daText:Alphabet = null;
	override function update(elapsed:Float)
	{
		if(!dialogueOpened) {
			bgWhite.visible = false;
			bgFade.alpha -= 0.5 * elapsed;
			if(bgFade.alpha <= 0) {
				remove(bgFade);
				bgWhite.visible = true;
				bgWhite.alpha = 0;
				bgFade = bgWhite;
				for (i in 0...arrayCharacters.length) {
					var char:FlxSprite = arrayCharacters[i];
					if(char != null) {
						char.visible = true;
						char.alpha = 0;
					}
				}

				dialogueOpened = true;
				startNextDialog();
			}
		} else if(!dialogueEnded) {
			bgFade.alpha += 0.5 * elapsed;
			if(bgFade.alpha > 0.5) bgFade.alpha = 0.5;

			if(FlxG.keys.justPressed.ANY) {
				if(!daText.finishedText) {
					if(daText != null) {
						daText.killTheTimer();
						remove(daText);
					}
					daText = new Alphabet(0, 0, textToType, false, true, 0.0, 0.7);
					daText.x = textX;
					daText.y = textY;
					daText.cameras = [cam];
					add(daText);
				} else if(currentText >= dialogueList.length) {
					dialogueEnded = true;
					switch(box.animation.curAnim.name) {
						case 'normalOpen' | 'normal':
							box.animation.play('normalOpen', true);
						case 'angryOpen' | 'angry':
							box.animation.play('angryOpen', true);
					}
					box.animation.curAnim.curFrame = box.animation.curAnim.frames.length - 1;
					box.animation.curAnim.reverse();
					remove(daText);
					daText = null;
					updateBoxOffsets();
				} else {
					startNextDialog();
				}
				FlxG.sound.play(Paths.sound('dialogueClose'));
			} else if(daText.finishedText) {
				var char:FlxSprite = arrayCharacters[lastCharacter];
				if(char != null && !char.animation.curAnim.name.endsWith('Idle') && char.animation.curAnim.curFrame >= char.animation.curAnim.frames.length - 1) {
					char.animation.play(char.animation.curAnim.name + 'Idle');
				}
			}

			if(box.animation.curAnim.finished) {
				switch(box.animation.curAnim.name) {
					case 'normalOpen':
						box.animation.play('normal', true);
					case 'angryOpen':
						box.animation.play('angry', true);
				}
				updateBoxOffsets();
			}

			if(lastCharacter != -1 && arrayCharacters.length > 0) {
				for (i in 0...arrayCharacters.length) {
					var char = arrayCharacters[i];
					if(char != null) {
						if(i != lastCharacter) {
							if(i == 1) {
								if(char.x < arrayStartX[i] + offsetPos) {
									char.x += scrollSpeed * elapsed;
									if(char.x > arrayStartX[i] + offsetPos) char.x = arrayStartX[i] + offsetPos;
								}
							} else if(char.x > arrayStartX[i] - offsetPos) {
								char.x -= scrollSpeed * elapsed;
								if(char.x < arrayStartX[i] - offsetPos) char.x = arrayStartX[i] - offsetPos;
							}
							char.alpha -= 3 * elapsed;
							if(char.alpha < 0) char.alpha = 0;
						} else {
							if(i == 1) {
								if(char.x > arrayStartX[i]) {
									char.x -= scrollSpeed * elapsed;
									if(char.x < arrayStartX[i]) char.x = arrayStartX[i];
								}
							} else if(char.x < arrayStartX[i]) {
								char.x += scrollSpeed * elapsed;
								if(char.x > arrayStartX[i]) char.x = arrayStartX[i];
							}
							char.alpha += 3 * elapsed;
							if(char.alpha > 1) char.alpha = 1;
						}
					}
				}
			}
		} else {
			if(box != null && box.animation.curAnim.curFrame <= 0) {
				remove(box);
				box = null;
			}

			if(bgFade != null) {
				bgFade.alpha -= 0.5 * elapsed;
				if(bgFade.alpha <= 0) {
					remove(bgFade);
					bgFade = null;
				}
			}

			for (i in 0...arrayCharacters.length) {
				var leChar:FlxSprite = arrayCharacters[i];
				if(leChar != null) {
					leChar.x += scrollSpeed * (i == 1 ? 1 : -1) * elapsed;
					leChar.alpha -= 1 * elapsed;
				}
			}

			if(box == null && bgFade == null) {
				for (i in 0...arrayCharacters.length) {
					var leChar:FlxSprite = arrayCharacters[0];
					if(leChar != null) {
						arrayCharacters.remove(leChar);
						remove(leChar);
					}
				}
				finishThing();
				close();
			}
		}
		super.update(elapsed);
	}

	var lastCharacter:Int = -1;
	var lastBoxType:Int = -1;
	function startNextDialog():Void
	{
		var splitName:Array<String> = dialogueList[currentText].split(":");
		var character:Int = Std.parseInt(splitName[1]);
		var speed:Float = Std.parseFloat(splitName[3]);
		var boxType:Int = Std.parseInt(splitName[4]);
		textToType = splitName[5];
		//FlxG.log.add(textToType);
		box.visible = true;
		if(character != lastCharacter) {
			if(boxType > 0) {
				box.animation.play('angryOpen', true);
			} else {
				box.animation.play('normalOpen', true);
			}
			updateBoxOffsets();
			box.flipX = (character < 1);
		} else if(boxType != lastBoxType) {
			if(boxType > 0) {
				box.animation.play('angry', true);
			} else {
				box.animation.play('normal', true);
			}
			updateBoxOffsets();
		}
		lastCharacter = character;
		lastBoxType = boxType;

		if(daText != null) {
			daText.killTheTimer();
			remove(daText);
		}
		daText = new Alphabet(textX, textY, textToType, false, true, speed, 0.7);
		daText.cameras = [cam];
		add(daText);

		var char:FlxSprite = arrayCharacters[character];
		if(char != null) {
			char.animation.play(splitName[2], true);
			var rate:Float = 24 - (((speed - 0.05) / 5) * 480);
			if(rate < 12) rate = 12;
			else if(rate > 48) rate = 48;
			char.animation.curAnim.frameRate = rate;
		}
		currentText++;
	}

	function updateBoxOffsets() {
		box.centerOffsets();
		box.updateHitbox();
		if(box.animation.curAnim.name.startsWith('angry')) {
			box.offset.set(50, 70);
		} else {
			box.offset.set(10, 0);
		}
		
		if(!box.flipX) box.offset.y += 10;
	}
}
