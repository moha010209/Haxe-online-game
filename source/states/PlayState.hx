package states;

import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.addons.ui.FlxButtonPlus;
import flixel.util.FlxSort;
import backend.Paths;
import backend.MapLoader;
import backend.GClient;
import objects.Player;
import backend.ScriptHandler;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxCamera;
import flixel.input.keyboard.FlxKey;
import flixel.FlxSprite;

class PlayState extends FlxState {
    public var player:Player;
    public var players:Map<String, Player> = new Map();
    public var camGame:FlxCamera;
    public var camHUD:FlxCamera;
    public var hudObjects:Map<String, FlxSkewedSprite> = new Map<String, FlxSkewedSprite>();
	public var objects:Map<String, MapObject> = new Map<String, MapObject>();
    public static var instance:PlayState;
    public var pauseButton:FlxButtonPlus;
    public var scriptArray:Array<ScriptHandler> = [];

    override public function create():Void {
        GClient.connect();
        GClient.createORjoinGame();
        instance = this;
        initializeCameras();
        player = new Player();
        player.cameras = [camGame];
		player.maxVelocity.set(2000, 2000);
        MapLoader.loadMap(Paths.getData("data/maps/test.json", false));
        add(player);
        camGame.follow(player, LOCKON, 0.6);
        camGame.zoom = 0.5;
        initializePauseButton();
        super.create();
    }

    override public function update(elapsed:Float):Void {
        handlePlayerMovement();
        //sortObjects();
        super.update(elapsed);
        for (object in members) {
            if (Std.isOfType(object, FlxSprite) && object.alive) {
                //collide(player, object);
            }
        }
    }

    private function initializeCameras():Void {
        camGame = new FlxCamera();
        camGame.bgColor.alpha = 0;
        FlxG.cameras.add(camGame, true);
        camHUD = new FlxCamera();
        camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD, false);
    }

    private function initializePauseButton():Void {
        pauseButton = new FlxButtonPlus(1000, 10, function() {
            openSubState(new substates.PauseMenu());
        }, "=", 50, 20);
        pauseButton.cameras = [camHUD];
        add(pauseButton);
    }

    private function handlePlayerMovement():Void {
        player.velocity.set(0, 0);

        if (FlxG.keys.pressed.LEFT) {
            player.velocity.x -= 200;
            player.flipX = true;
        }
		if (FlxG.keys.pressed.RIGHT) {
            player.velocity.x += 200;
            player.flipX = false;
        }

        if (FlxG.keys.pressed.UP) {
            player.velocity.y -= 200;
        }
		if (FlxG.keys.pressed.DOWN) {
            player.velocity.y += 200;
        }

        player.animation.play(player.velocity.x != 0 || player.velocity.y != 0 ? "walk" : "idle");
        GClient.sendMessage("move", {
            y: player.y,
            x: player.x,
            flipX: player.flipX,
            animation: player.animation.name
        });
    }

    private function sortObjects():Void {
		members.sort(customSort);
    }

    private function customSort(obj1:Dynamic, obj2:Dynamic):Int {
        if (obj1.y < obj2.y) return -1;
        else if (obj1.y > obj2.y) return 1;
        else return 0;
    }

    public static function collide(objectOrGroup1:Dynamic, objectOrGroup2:Dynamic):Bool {
        if (FlxG.pixelPerfectOverlap(objectOrGroup1, objectOrGroup2)) {
            FlxObject.separate(objectOrGroup1, objectOrGroup2);
            return true;
        }
        return false;
    }
}