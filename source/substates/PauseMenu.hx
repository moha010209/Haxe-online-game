package substates;

import states.PlayState;
import flixel.FlxCamera;
import states.MainState;
import flixel.ui.FlxButton;
import flixel.FlxSubState;

class PauseMenu extends FlxSubState {
    public var backButton:FlxButton;
	public var leaveButton:FlxButton;
    override public function create() {
        super.create();
        backButton = new FlxButton(100, 200, "back to game", function() {
            close();
        });
        leaveButton = new FlxButton(200, 200, "leave game", function() {
            GClient.leave();
            FlxG.switchState(new MainState());
        });
        backButton.cameras = [this.camera];
		leaveButton.cameras = [this.camera];
        add(backButton);
        add(leaveButton);
    }
    override public function update(elapsed:Float) {
        super.update(elapsed);
		if (FlxG.keys.pressed.ESCAPE)
		{
			close();
		}
    }
}