package states;

import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.addons.ui.FlxButtonPlus;
import backend.ScriptHandler;
import flixel.FlxObject;
import flixel.FlxBasic;
import backend.GClient;
import io.colyseus.Room;
import schema.GameState;
import flixel.math.FlxRect;
import flixel.util.FlxSort;
import backend.MapLoader;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;
import objects.*;
import flixel.FlxG;
import flixel.FlxSprite;
import io.colyseus.Client;

class PlayState extends FlxState
{
	public var player:Player;

	public var players:Map<String, Player> = new Map();

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	//public var objects:Map<String, FlxSkewedSprite> = new Map<String, FlxSkewedSprite>();
	public var objects:FlxGroup;

	public static var instance:PlayState;

	var hitboxS:FlxSprite;
	public var scriptArray:Array<ScriptHandler>;

	var pauseButton:FlxButtonPlus;

	override public function create()
	{
		objects = new FlxGroup();
		GClient.connect();
		GClient.createORjoinGame();
		instance = this;
		camGame = new FlxCamera();
		camGame.bgColor.alpha = 0;
		FlxG.cameras.add(camGame, true);
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);
		player = new Player();
		player.cameras = [camGame];
		MapLoader.loadMap(Paths.getData("data/maps/test.json", false));
		add(player);
		add(objects);
		var hitbox:FlxRect = player.getHitbox();
		hitboxS = new FlxSprite(hitbox.x, hitbox.y);
		hitboxS.makeGraphic(Std.int(hitbox.width), Std.int(hitbox.height), 0x00FF00);
		add(hitboxS);
		camGame.follow(player, LOCKON, 0.6);
		camGame.zoom = 0.5;
		pauseButton = new FlxButtonPlus(1000, 10, function() {
			openSubState(new substates.PauseMenu());
		}, "=", 50, 20);
		pauseButton.cameras = [camHUD];
		add(pauseButton);
		super.create();
	}

	override public function update(elapsed:Float)
	{
		var animName = "idle";
		if (FlxG.keys.pressed.LEFT)
		{
			player.velocity.x -= 5;
			player.flipX = true;
			animName = "walk";
		}
		if (FlxG.keys.pressed.RIGHT)
		{
			player.velocity.x += 5;
			player.flipX = false;
			animName = "walk";
		}
		if (FlxG.keys.pressed.UP)
		{
			player.velocity.y -= 5;
			animName = "walk";
		}
		if (FlxG.keys.pressed.DOWN)
		{
			player.velocity.y += 5;
			animName = "walk";
		}
		player.animation.play(animName);

		GClient.sendMessage("move", {
			y: player.y,
			x: player.x,
			flipX: player.flipX,
			animation: animName
		});
		var customSort = function(Order:Int, Obj1:Dynamic, Obj2:Dynamic)
		{
			if (Obj1.y + Obj1.height - 10 < Obj2.y + Obj2.height - 10)
				return -1;
			else if (Obj1.y + Obj1.height - 10 > Obj2.y + Obj2.height - 10)
				return 1;
			else
				return 0;
		}
        sortA(customSort, FlxSort.ASCENDING);
		// hitboxS.x = player.getHitbox().x;
		// hitboxS.y = player.getHitbox().y;
		super.update(elapsed);
	}
	function sortA(func:(Int, FlxBasic, FlxBasic) -> Int, order = FlxSort.ASCENDING):Void
	{
		members.sort(func.bind(order));
	}
}
