package states;

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
	public var objects:Map<String, FlxSkewedSprite> = new Map<String, FlxSkewedSprite>();

	public static var instance:PlayState;

	var hitboxS:FlxSprite;
	public var scriptArray:Array<ScriptHandler>;

	override public function create()
	{
		GClient.connect();
		GClient.createORjoinGame();
		instance = this;
		camGame = new FlxCamera();
		FlxG.cameras.add(camGame, true);
		player = new Player();
		//MapLoader.loadMap(GClient.getDataFromweb("https://" + ClientPrefs.data.address + "/data/maps/test.json", true));
		add(player);
		var hitbox:FlxRect = player.getHitbox();
		hitboxS = new FlxSprite(hitbox.x, hitbox.y);
		hitboxS.makeGraphic(Std.int(hitbox.width), Std.int(hitbox.height), 0x00FF00);
		add(hitboxS);
		camGame.follow(player, LOCKON, 0.6);
		camGame.zoom = 0.5;
		super.create();
	}

	override public function update(elapsed:Float)
	{
		var animName = "idle";
		if (FlxG.keys.pressed.LEFT)
		{
			player.x -= 5;
			player.flipX = true;
			animName = "walk";
		}
		if (FlxG.keys.pressed.RIGHT)
		{
			player.x += 5;
			player.flipX = false;
			animName = "walk";
		}
		if (FlxG.keys.pressed.UP)
		{
			player.y -= 5;
			animName = "walk";
		}
		if (FlxG.keys.pressed.DOWN)
		{
			player.y += 5;
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
			if (Obj1.y + Obj1.height < Obj2.y + Obj2.height)
				return -1;
			else if (Obj1.y + Obj1.height > Obj2.y + Obj2.height)
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
