package backend;

import flixel.util.FlxSave;

// Add a variable here and it will get automatically saved
@:structInit class SaveVariables
{
	public var address:String = "localhost:2567";
	public var cacheOnGPU:Bool = false;
}

class ClientPrefs
{
	public static var data:SaveVariables = {};
	public static var defaultData:SaveVariables = {};

	public static function saveSettings()
	{
		for (key in Reflect.fields(data))
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));
		FlxG.save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs()
	{
		for (key in Reflect.fields(data))
			if (Reflect.hasField(FlxG.save.data, key))
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));
	}
}