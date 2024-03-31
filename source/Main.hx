package;

import states.MainState;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		FlxG.autoPause = false;
		addChild(new FlxGame(0, 0, MainState));
	}
}
