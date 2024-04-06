package backend;

#if sys
import sys.io.File;
#end
import states.PlayState;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.addons.display.FlxBackdrop;

typedef MapData = {
    var objects:Array<ObjectData>;
    var playerPos:Array<Array<Float>>;
	var scripts:Null<Array<String>>;
}

typedef ObjectData = {
    var type:String;
    var name:String;
    var x:Float;
    var y:Float;
    var width:Null<Float>;
    var height:Null<Float>;
	var scale:Null<Array<Float>>;
    var imagePath:String;
    var angle:Null<Float>;
    var visible:Null<Bool>;
    var alpha:Null<Float>;
    var skewPos:Null<Array<Float>>;
    var animated:Bool;
    var animations:Null<Array<AnimationData>>;
    var defaultAnim:Null<String>;
	var repeated:Null<Bool>;
	var maxTiles:Null<Array<Int>>;
}

typedef AnimationData = {
    var name:String;
    var nameframe:String;
    var fpsCount:Int;
}

class MapLoader {
    static var jsonData:MapData;
    public static function loadMap(data:String) {
        jsonData = cast Json.parse(data);
        for (objectD in jsonData.objects) {
            var object:MapObject = new MapObject(objectD.x, objectD.y);
            object.cameras = [PlayState.instance.camGame];
            if (objectD.animated) {
                object.frames = Paths.getSparrowAtlas(objectD.imagePath);
                for (animationD in objectD.animations) {
                    object.animation.addByPrefix(animationD.name, animationD.nameframe, animationD.fpsCount);
                }
                object.animation.play(objectD.defaultAnim);
            }
            else
                object.loadGraphic(Paths.image(objectD.imagePath));
            if (objectD.scale != null && objectD.scale != []) {
                object.scale.set(
                    objectD.scale[0],
                    objectD.scale[1]
                );
            }
            if (objectD.angle != null) object.angle = objectD.angle;
            if (objectD.alpha != null) object.alpha = objectD.alpha;
            if (objectD.visible != null) object.visible = objectD.visible;
            if (objectD.skewPos != null) {
                object.skew.set(
                    objectD.skewPos[0],
                    objectD.skewPos[1]
                );
            }
			if (objectD.maxTiles != null && objectD.maxTiles != [1, 1] && objectD.maxTiles != []) {
				object.repeatTexture(objectD.maxTiles[0], objectD.maxTiles[1]);
            }
            object.antialiasing = true;
            object.updateHitbox();
            object.immovable = true;
            
            PlayState.instance.objects.set(objectD.name, object);
            PlayState.instance.add(object);
            trace(objectD.name + " is loaded.");
            //object.add_to_group(PlayState.instance.objects);
            //PlayState.instance.objects.add(object);
        }
        if (jsonData.scripts != null) {
			for (path in jsonData.scripts)
				PlayState.instance.scriptArray.push(new ScriptHandler(path));
        }
    }
}