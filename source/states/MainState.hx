package states;

import objects.MenuButton;
import flixel.addons.ui.FlxButtonPlus;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxState;

class MainState extends FlxState
{
	override public function create()
	{
		var myText:FlxText = new FlxText(100, 100, 0, "Among US", 96, true);
		myText.font = Paths.getPath("fonts/SusFont.ttf");
		myText.antialiasing = true;
		myText.screenCenter(X);
		add(myText);

		var playButton = new MenuButton(100, 300, "Play", clickPlay, 150, 60);
		playButton.screenCenter(X);
		add(playButton);

		var playButton = new MenuButton(0, 500, "Edit", function() {
			FlxG.switchState(new StageEditor());
		}, 300, 120);
		playButton.screenCenter(X);
		add(playButton);

		var profile = new FlxButton(-50, 100, "");
		profile.scale.set(0.5, 0.5);
		profile.loadGraphic(Paths.image("ui/AccountIcon"));
		add(profile);

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
