package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null, ?highQualityOnly:Bool = false)
	{
		if (library != null)
			return getLibraryPath(file, library);

		var lvlName:String = currentLevel;
		if(highQualityOnly) lvlName = currentLevel + '_high';

		if (lvlName != null)
		{
			var levelPath = getLibraryPathForce(file, lvlName);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String, ?highQualityOnly:Bool = false)
	{
		return getPath(file, type, library, highQualityOnly);
	}

	inline static public function txt(key:String, ?library:String, ?highQualityOnly:Bool = false)
	{
		return getPath('data/$key.txt', TEXT, library, highQualityOnly);
	}

	inline static public function xml(key:String, ?library:String, ?highQualityOnly:Bool = false)
	{
		return getPath('data/$key.xml', TEXT, library, highQualityOnly);
	}

	inline static public function json(key:String, ?library:String, ?highQualityOnly:Bool = false)
	{
		return getPath('data/$key.json', TEXT, library, highQualityOnly);
	}

	static public function sound(key:String, ?library:String, ?highQualityOnly:Bool = false)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library, highQualityOnly);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String, ?highQualityOnly:Bool = false)
	{
		return sound(key + FlxG.random.int(min, max), library, highQualityOnly);
	}

	inline static public function music(key:String, ?library:String, ?highQualityOnly:Bool = false)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library, highQualityOnly);
	}

	inline static public function voices(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String, ?highQualityOnly:Bool = false)
	{
		return getPath('images/$key.png', IMAGE, library, highQualityOnly);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, ?highQualityOnly:Bool = false)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library, highQualityOnly), file('images/$key.xml', library, highQualityOnly));
	}

	inline static public function getPackerAtlas(key:String, ?library:String, ?highQualityOnly:Bool = false)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library, highQualityOnly), file('images/$key.txt', library, highQualityOnly));
	}
}
