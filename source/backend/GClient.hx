package backend;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Http;
import haxe.io.Bytes;
import io.colyseus.Client;
import io.colyseus.Room;
import io.colyseus.events.EventHandler;
import lime.app.Application;
import objects.Player;
import openfl.utils.ByteArray;
import schema.GameState;
import states.PlayState;

class GClient
{
	public static var client:Client;
	public static var room:Null<Room<GameState>>;

	public static function connect()
	{
		client = new Client("ws://" + ClientPrefs.data.address);
	}

	public static function createORjoinGame()
	{
		client.joinOrCreate("game", [], GameState, function(err, roomD)
		{
			if (err != null)
			{
				trace("Couldn't connect!", " JOIN ERROR: " + err.code + " - " + err.message);
				client = null;
				return;
			}

			room = roomD;

			roomD.state.players.onAdd(function(entity, key)
			{
				if (room.sessionId != key)
				{
					var playerP = new Player();
					PlayState.instance.players.set(key, playerP);
					playerP.x = entity.x;
					playerP.y = entity.y;
					playerP.flipX = entity.flipX;
					PlayState.instance.players.get(key).animation.play(entity.animation);
					PlayState.instance.add(playerP);

					entity.onChange((changes) ->
					{
						PlayState.instance.players.get(key).x = entity.x;
						PlayState.instance.players.get(key).y = entity.y;
						PlayState.instance.players.get(key).flipX = entity.flipX;
						PlayState.instance.players.get(key).animation.play(entity.animation);
					});
				}
				else
				{
					PlayState.instance.players.set(key, PlayState.instance.player);
				}
			});

			roomD.state.objects.onAdd(function(entity, key)
			{
				var object:FlxSkewedSprite = new FlxSkewedSprite(entity.x, entity.y);
				if (entity.animated)
				{
					object.frames = Paths.getSparrowAtlas(entity.imagePath);
					for (animationD in entity.animations)
					{
						object.animation.addByPrefix(animationD.name, animationD.frameName, animationD.frameRate);
					}
					object.animation.play(entity.animation);
				}
				else
					object.loadGraphic(Paths.image(entity.imagePath));
				if (entity.width != null && entity.height != null && entity.width != 0 && entity.height != 0)
				{
					object.scale.set(object.width / entity.width, object.height / entity.height);
				}
				if (entity.angle != null)
					object.angle = entity.angle;
				if (entity.alpha != null)
					object.alpha = entity.alpha;
				if (entity.skewPos != null)
				{
					object.skew.set(entity.skewPos[0], entity.skewPos[1]);
				}
				object.antialiasing = true;
				PlayState.instance.objects.set(key, object);
				PlayState.instance.add(object);
			});

			roomD.state.objects.onRemove(function(entity, key)
			{
				trace("entity removed at " + key + " => " + entity);
				PlayState.instance.remove(PlayState.instance.objects.get(key));
			});

			roomD.onMessage("loadScript", function(data)
			{
				PlayState.instance.scriptArray.push(new ScriptHandler(data));
			});

			roomD.state.players.onRemove(function(entity, key)
			{
				trace("entity removed at " + key + " => " + entity);
				PlayState.instance.remove(PlayState.instance.players.get(key));
			});

			trace("joined successfully");
		});
	}

	public static function sendMessage(type:String, data:Dynamic)
	{
		if (room != null)
			room.send(type, data);
	}
}
