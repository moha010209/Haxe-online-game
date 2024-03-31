package states;

import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxState;

class MainState extends FlxState
{
	override public function create()
	{
		var myText:FlxText = new FlxText(100, 100, 0, "Among US", 96, true);
		myText.font = "assets/fonts/SusFont.ttf";
		myText.antialiasing = true;
		myText.screenCenter(X);
		add(myText);
		var playButton = new FlxButton(0, 300, "Play", clickPlay);
		playButton.screenCenter(X);
		add(playButton);
		var playButton = new FlxButton(0, 500, "Edit", function() {
			FlxG.switchState(new StageEditor());
		});
		playButton.screenCenter(X);
		add(playButton);
		super.create();
	}

	function clickPlay() {
		FlxG.switchState(new PlayState());
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
