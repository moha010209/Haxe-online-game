package states;

import backend.MapLoader;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

#if sys
import sys.io.File;
#end

using StringTools;

class StageEditor extends FlxState {
    public static var instance:StageEditor;
    var jsonData:MapData;
    var spriteNamer:FlxInputText;
    var pathNamer:FlxInputText;
    var typeSetter:FlxInputText;
    var setterbutton:FlxButton;
    var spriteAdder:FlxButton;
    var spriteCoord:FlxText;
    var skewCoord:FlxText;
    var selNum:FlxText;
    var curSprite:Int = 0;
    var sprites:Array<MapObject> = [];
    var camGame:FlxCamera;
    var camEditor:FlxCamera;
    var guide:FlxText;
    var saveButton:FlxButton;
    var objectcam:FlxObject;

    public override function create() {
        instance = this;
        jsonData = {
            objects: [],
            playerPos: [[0, 0]],
            scripts: []
        };

        camGame = new FlxCamera();
        camGame.zoom = 0.5;
        FlxG.cameras.add(camGame, true);
        camGame.bgColor.alpha = 0;

        camEditor = new FlxCamera();
        camEditor.bgColor.alpha = 0;
        FlxG.cameras.add(camEditor, false);

        spriteNamer = createInputText(100, 10, 150);
        pathNamer = createInputText(600, 10, 150);
        typeSetter = createInputText(600, 30, 150);

        setterbutton = createButton(300, 5, "set", setValues);
        spriteAdder = createButton(400, 5, "add", addObject);

        spriteCoord = createText(0, 60, "coords : 0, 0, 90");
        skewCoord = createText(0, 120, "skew coords : 0, 0");
        selNum = createText(0, 40, "selected Sprite ID: 0");
        guide = createText(975, 10, "arrows: move selected sprite\nCTRL + arrows: move camera\nU-I: change sprite angle\nZQSD: move skew point\nP: change the selected sprite\nN: change selected sprite alpha\nL-M: change selected sprite scale x\nT-Y: change selected sprite scale y");

        saveButton = createButton(1180, 680, "save map" #if sys , saveProgress #end);

        objectcam = new FlxObject(1280 / 2, 720 / 2);
        objectcam.cameras = [camGame];
        add(objectcam);

		camGame.follow(objectcam);

        addObject();
        super.create();
    }

    function createInputText(x:Int, y:Int, width:Int):FlxInputText {
        var inputText = new FlxInputText(x, y, width);
        inputText.cameras = [camEditor];
        add(inputText);
        return inputText;
    }

    function createButton(x:Int, y:Int, label:String, ?callback:Void->Void):FlxButton {
        var button = new FlxButton(x, y, label, callback);
        button.cameras = [camEditor];
        add(button);
        return button;
    }

    function createText(x:Int, y:Int, text:String):FlxText {
        var textObj = new FlxText(x, y, 0, text, 12);
        textObj.cameras = [camEditor];
        add(textObj);
        return textObj;
    }

    function setValues() {
        var currentObject = jsonData.objects[curSprite];
        
        currentObject.name = spriteNamer.text;
        currentObject.imagePath = pathNamer.text;
        var currentSprite = sprites[curSprite];
        currentSprite.loadGraphic(Paths.image(pathNamer.text));
        currentObject.x = currentSprite.x;
        currentObject.y = currentSprite.y;
        currentObject.angle = currentSprite.angle;
        currentObject.alpha = currentSprite.alpha;
        currentObject.scale = [currentSprite.scale.x, currentSprite.scale.y];
        currentObject.skewPos = [currentSprite.skew.x, currentSprite.skew.y];
        var input:String = typeSetter.text;
		var result:Array<String> = input.split(", ");
        currentObject.type = result[0];
		if (result.length > 2) currentSprite.repeatTexture(Std.parseInt(result[1]), Std.parseInt(result[2]));
		currentObject.maxTiles = [currentSprite.repeatTiles[0], currentSprite.repeatTiles[1]];
    }

    function addObject() {
        var sprite:MapObject = new MapObject();
        sprite.cameras = [camGame];
        sprite.antialiasing = true;
        add(sprite);
        sprites.push(sprite);

        jsonData.objects.push({
            type: "wall",
            name: "",
            x: 0,
            y: 0,
            width: null,
            height: null,
            scale: [],
            imagePath: "",
            angle: 90,
            visible: true,
            alpha: 1,
            skewPos: null,
            animated: false,
            animations: null,
            defaultAnim: null,
            repeated: false,
            maxTiles: [1, 1]
        });
    }

    override function update(elapsed:Float) {
		var blockInput:Bool = false;
		if (spriteNamer.hasFocus || pathNamer.hasFocus || typeSetter.hasFocus)
			blockInput = true;
		if (!blockInput)
		{
			var nbr = 1;
			if (FlxG.keys.pressed.SHIFT)
				nbr = 10;

			if (!FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.pressed.RIGHT)
					sprites[curSprite].x += nbr;
				if (FlxG.keys.pressed.LEFT)
					sprites[curSprite].x -= nbr;
				if (FlxG.keys.pressed.DOWN)
					sprites[curSprite].y += nbr;
				if (FlxG.keys.pressed.UP)
					sprites[curSprite].y -= nbr;
			}
			else
			{
				if (FlxG.keys.pressed.RIGHT)
					objectcam.x -= nbr;
				if (FlxG.keys.pressed.LEFT)
					objectcam.x += nbr;
				if (FlxG.keys.pressed.DOWN)
					objectcam.y -= nbr;
				if (FlxG.keys.pressed.UP)
					objectcam.y += nbr;
			}

			if (FlxG.keys.pressed.U)
				sprites[curSprite].angle -= nbr;
			if (FlxG.keys.pressed.I)
				sprites[curSprite].angle += nbr;

			if (FlxG.keys.justPressed.P)
				changecurSel(1);

			if (FlxG.keys.pressed.D)
				sprites[curSprite].skew.x += nbr;
			if (FlxG.keys.pressed.Q)
				sprites[curSprite].skew.x -= nbr;
			if (FlxG.keys.pressed.S)
				sprites[curSprite].skew.y += nbr;
			if (FlxG.keys.pressed.Z)
				sprites[curSprite].skew.y -= nbr;

			if (FlxG.keys.pressed.L)
				if (sprites[curSprite].scale.x <= 0)
					sprites[curSprite].scale.x -= nbr * 0.01;
			if (FlxG.keys.pressed.M)
				sprites[curSprite].scale.x += nbr * 0.01;

			if (FlxG.keys.pressed.T)
				if (sprites[curSprite].scale.y <= 0)
					sprites[curSprite].scale.y -= nbr * 0.01;
			if (FlxG.keys.pressed.Y)
				sprites[curSprite].scale.y += nbr * 0.01;

			if (FlxG.keys.justPressed.ALT)
			{
				var spriteCur = sprites[curSprite];
				sprites.remove(spriteCur);
				remove(spriteCur);
				jsonData.objects.remove(jsonData.objects[curSprite]);
			}

			var alpha:Float = sprites[curSprite].alpha;
			if (FlxG.keys.pressed.N)
				alpha += 0.01;
			if (sprites[curSprite].alpha > 1)
				alpha = 0;
			sprites[curSprite].alpha = alpha;
			sprites[curSprite].updateHitbox();
		}

		spriteCoord.text = "coords: " + Std.string(sprites[curSprite].x) + ", " + Std.string(sprites[curSprite].y) + ", "
			+ Std.string(sprites[curSprite].angle) + "\nalpha: " + Std.string(sprites[curSprite].alpha) + "\nscale: "
			+ Std.string(sprites[curSprite].scale.x)
			+ " , "
			+ Std.string(sprites[curSprite].scale.y)
			+ "\nTiles: [ "
			+ Std.string(sprites[curSprite].repeatTiles[0] + " , " + Std.string(sprites[curSprite].repeatTiles[1]) + " ]");
        skewCoord.text = "skew coords: " + Std.string(sprites[curSprite].skew.x) + ", " + Std.string(sprites[curSprite].skew.y);
        selNum.text = "selected Sprite ID: " + Std.string(curSprite);

        super.update(elapsed);
    }

    function changecurSel(dir:Int) {
        curSprite += dir;
        if (curSprite > sprites.length - 1)
            curSprite = 0;
        spriteNamer.text = jsonData.objects[curSprite].name;
        pathNamer.text = jsonData.objects[curSprite].imagePath;
		typeSetter.text = jsonData.objects[curSprite].type + ", " + sprites[curSprite].repeatTiles[0] + ", " + sprites[curSprite].repeatTiles[1];
    }

    #if sys
    function saveProgress() {
        File.saveContent("saves/save.json", haxe.Json.stringify(jsonData, "\t").trim());
    }
    #end
}