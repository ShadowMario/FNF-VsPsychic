import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

class Achievements {
	public static var achievementsStuff:Array<Dynamic> = [ //Name, Description, Hidden achievement
		["Freaky on a Friday Night",	"Play on a Friday... Night.",							 true],
		["She Calls Me Daddy Too",		"Beat Week 1 on Hard with no Misses.",					false],
		["No More Tricks",				"Beat Week 2 on Hard with no Misses.",					false],
		["Call Me The Hitman",			"Beat Week 3 on Hard with no Misses.",					false],
		["Lady Killer",					"Beat Week 4 on Hard with no Misses.",					false],
		["Missless Christmas",			"Beat Week 5 on Hard with no Misses.",					false],
		["Highscore!!",					"Beat Week 6 on Hard with no Misses.",					false],
		["You'll Pay For That...",		"Beat Week 7 on Hard with no Misses.",					true],
		["Psyche",						"Beat Psychic on Hard with no Misses.",					false],
		["What a Funkin' Disaster!",	"Complete a Song with a rating lower than 20%.",		false],
		["Perfectionist",				"Complete a Song with a rating of 100%.",				false],
		["Roadkill Enthusiast",			"Watch the Henchmen die over 100 times.",				false],
		["Oversinging Much...?",		"Hold down a note for 20 seconds.",						false],
		["Hyperactive",					"Finish a Song without going Idle.",					false],
		["Just the Two of Us",			"Finish a Song pressing only two keys.",				false],
		["Toaster Gamer",				"Have you tried to run the game on a toaster?",			false],
		["Debugger",					"Beat the \"Test\" Stage from the Chart Editor.",		 true],
		["Digital ft. Salvati",			"Beat the \"Late Drive\" Stage from the Chart Editor.",	 true]
	];

	public static var achievementsUnlocked:Array<Dynamic> = [ //Save string, is it unlocked?
		['friday_night_play', false],	//0
		['week1_nomiss', false],		//1
		['week2_nomiss', false],		//2
		['week3_nomiss', false],		//3
		['week4_nomiss', false],		//4
		['week5_nomiss', false],		//5
		['week6_nomiss', false],		//6
		['week7_nomiss', false],		//7
		['psychic_demo_nomiss', false],	//8
		['ur_bad', false],				//9
		['ur_good', false],				//10
		['roadkill_enthusiast', false],	//11
		['oversinging', false],			//12
		['hype', false],				//13
		['two_keys', false],			//14
		['toastie', false],				//15
		['debugger', false], 			//16
		['latedrive', false] 			//17
	];

	public static var henchmenDeath:Int = 0;
	public static var nextAchievement:Float = 0;

	public static function unlockAchievement(id:Int):Void {
		FlxG.log.add('Completed achievement "' + achievementsStuff[id][0] +'"');
		achievementsUnlocked[id][1] = true;
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		nextAchievement = 3.9;
	}

	public static function loadAchievements():Void {
		if(FlxG.save.data != null) {
			if(FlxG.save.data.achievementsUnlocked != null) {
				FlxG.log.add("Trying to load stuff");
				var savedStuff:Array<String> = FlxG.save.data.achievementsUnlocked;
				for (i in 0...achievementsUnlocked.length) {
					for (j in 0...savedStuff.length) {
						if(achievementsUnlocked[i][0] == savedStuff[j]) {
							achievementsUnlocked[i][1] = true;
						}
					}
				}
			}
			if(henchmenDeath == 0 && FlxG.save.data.henchmenDeath != null) {
				henchmenDeath = FlxG.save.data.henchmenDeath;
			}
		}

		// You might be asking "Why didn't you just fucking load it directly dumbass??"
		// Well, Mr. Smartass, i'm obviously going to change the "Psyche" achievement's objective so that you have to complete the entire week
		// with no misses instead of just Psychic once the full release is out. So, for not having the rest of your achievements lost on
		// the full release, we only save the achievements' tag names instead. This also makes me able to rename achievements later of course.

		// Edit: Oh yeah, just thought that this also makes me able to change the achievements orders later if i want to.
		// So yeah, if you didn't thought about that i'm smarter than you, i think

		// buffoon
	}
}

class AttachedAchievement extends FlxSprite {
	public var sprTracker:FlxSprite;
	public function new(x:Float = 0, y:Float = 0, id:Int = 0) {
		super(x, y);

		if(Achievements.achievementsUnlocked[id][1]) {
			loadGraphic(Paths.image('achievementgrid'), true, 150, 150);
			animation.add('icon', [id], 0, false, false);
			animation.play('icon');
		} else {
			loadGraphic(Paths.image('lockedachievement'));
		}
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	override function update(elapsed:Float) {
		if (sprTracker != null)
			setPosition(sprTracker.x - 130, sprTracker.y + 25);

		super.update(elapsed);
	}
}