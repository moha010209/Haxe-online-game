package backend;

#if sys
import sys.io.File;
#end
import states.PlayState;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.effects.FlxSkewedSprite;

typedef MapData = {
    var objects:Array<ObjectData>;
    var playerPos:Array<Array<Float>>;
}

typedef ObjectData = {
    var type:String;
    var name:String;
    var x:Float;
    var y:Float;
    var width:Null<Float>;
    var height:Null<Float>;
    var imagePath:String;
    var angle:Null<Float>;
    var visible:Null<Bool>;
    var alpha:Null<Float>;
    var skewPos:Null<Array<Float>>;
    var animated:Bool;
    var animations:Null<Array<AnimationData>>;
    var defaultAnim:Null<String>;
}

typedef AnimationData = {
    var name:String;
    var nameframe:String;
    var fpsCount:Int;
}

class MapLoader {
    static var jsonData:MapData;
    public static function loadMap(data:String) {
		jsonData = Json.parse(data);
        for (objectD in jsonData.objects) {
            var object:FlxSkewedSprite = new FlxSkewedSprite(objectD.x, objectD.y);
            if (objectD.animated) {
				object.frames = FlxAtlasFrames.fromSparrow("assets/images/" + objectD.imagePath + ".png", "assets/images/" + objectD.imagePath + ".xml");
                for (animationD in objectD.animations) {
                    object.animation.addByPrefix(animationD.name, animationD.nameframe, animationD.fpsCount);
                }
                object.animation.play(objectD.defaultAnim);
			}
			else
				object.loadGraphic("assets/images/" + objectD.imagePath + ".png");
            if (objectD.width != null && objectD.height != null) {
                object.scale.set(
                    object.width / objectD.width,
                    object.height / objectD.height
                );
            }
            if (objectD.angle != null) object.angle = objectD.angle;
            if (objectD.alpha != null) object.alpha = objectD.alpha;
            if (objectD.visible != null) object.visible = objectD.visible;
            if (objectD.skewPos!= null) {
                object.skew.set(
                    objectD.skewPos[0],
                    objectD.skewPos[1]
                );
            }
            object.antialiasing = true;
            PlayState.instance.objects.set(objectD.name, object);
			PlayState.instance.add(object);
        }
        PlayState.instance.player.x = jsonData.playerPos[0][0];
		PlayState.instance.player.y = jsonData.playerPos[0][1];
    }
}