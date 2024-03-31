package states;

import flixel.util.FlxSort;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxInputText;
import backend.MapLoader;
import flixel.addons.ui.FlxUIDropDownMenu;
#if sys
import sys.io.File;
#end
import flixel.FlxObject;

using StringTools;

class StageEditor extends FlxState {
    public static var instance:StageEditor;
    var jsonData:MapData;
    var spriteNamer:FlxInputText;
	var animNamer:FlxInputText;
	var preanimNamer:FlxInputText;
	var pathNamer:FlxInputText;
    var setterbutton:FlxButton;
    var spriteAdder:FlxButton;
    var spriteCoord:FlxText;
	var skewCoord:FlxText;
    var selNum:FlxText;
    var curSprite:Int = 0;
    var sprites:Array<FlxSkewedSprite> = [];
    var camGame:FlxCamera;
    var camEditor:FlxCamera;
    var guide:FlxText;
    var saveButton:FlxButton;
    var animationNamer:FlxInputText;
    var animationPrefix:FlxInputText;
    var defaultAnim:FlxInputText;
	var AnimList:FlxUIDropDownMenu;
    var addAnimationButton:FlxButton;
    var objectcam:FlxObject;
    public override function create() {
        instance = this;
        jsonData = {
            objects: [],
            playerPos: [[0, 0]]
        };
        camGame = new FlxCamera();
        camGame.zoom = 0.5;
		FlxG.cameras.add(camGame, true);
		camGame.bgColor.alpha = 0;
        camEditor = new FlxCamera();
		camEditor.bgColor.alpha = 0;

		FlxG.cameras.add(camEditor, false);
        spriteNamer = new FlxInputText(100, 10, 150);
        spriteNamer.cameras = [camEditor];
        add(spriteNamer);

		pathNamer = new FlxInputText(600, 10, 150);
		pathNamer.cameras = [camEditor];
		add(pathNamer);

        setterbutton = new FlxButton(300, 5, "set", setValues);
		setterbutton.cameras = [camEditor];
        add(setterbutton);

        spriteAdder = new FlxButton(400, 5, "add", addSprite);
		spriteAdder.cameras = [camEditor];
        add(spriteAdder);

        spriteCoord = new FlxText(0, 60, 0, "coords : 0, 0, 90", 12);
		spriteCoord.cameras = [camEditor];
        add(spriteCoord);

		skewCoord = new FlxText(0, 100, 0, "skew coords : 0, 0", 12);
		skewCoord.cameras = [camEditor];
		add(skewCoord);

		selNum = new FlxText(0, 40, 0, Std.string(curSprite), 12);
		selNum.cameras = [camEditor];
        add(selNum);

		guide = new FlxText(1000, 10, 0,
            "arrows: move selected sprite
            \nCTRL + arrows: move camera
            \nU-I: change sprite angle
            \nZQSD: move skew point
            \nP: change the selected sprite
            \nN: change selected sprite alpha", 12);
		guide.cameras = [camEditor];
		add(guide);

		saveButton = new FlxButton(1180, 680, "save map" #if sys , saveProgress #end);
		saveButton.cameras = [camEditor];
		add(saveButton);

        objectcam = new FlxObject(1280 / 2, 720 / 2);
        objectcam.cameras = [camGame];
        add(objectcam);

		camGame.follow(objectcam);

        addSprite();
        super.create();
    }
    function setValues() {
        jsonData.objects[curSprite].name = spriteNamer.text;
		jsonData.objects[curSprite].imagePath = pathNamer.text;
        jsonData.objects[curSprite].x = sprites[curSprite].x;
		jsonData.objects[curSprite].y = sprites[curSprite].y;
		jsonData.objects[curSprite].angle = sprites[curSprite].angle;
        jsonData.objects[curSprite].alpha = sprites[curSprite].alpha;
		jsonData.objects[curSprite].skewPos = [sprites[curSprite].skew.x, sprites[curSprite].skew.y];
		sprites[curSprite].loadGraphic("assets/images/" + pathNamer.text + ".png");
    }
    function addSprite() {
        var sprite:FlxSkewedSprite = new FlxSkewedSprite();
        sprite.cameras = [camGame];
		sprite.antialiasing = true;
        add(sprite);
        jsonData.objects.push({
			type: "normal",
			name: "",
			x: 0,
			y: 0,
			width: null,
			height: null,
			imagePath: "",
			angle: 90,
			visible: true,
			alpha: 1,
			skewPos: null,
			animated: false,
			animations: null,
			defaultAnim: null
        });
        sprites.push(sprite);
    }
    override function update(elapsed:Float) {
        var blockInput:Bool = false;
		if (spriteNamer.hasFocus || pathNamer.hasFocus) blockInput = true;
        if (!blockInput) {
            var nbr = 1;
            if (FlxG.keys.pressed.SHIFT) nbr = 10;

            if (!FlxG.keys.pressed.CONTROL) {
                if (FlxG.keys.pressed.RIGHT)
                    sprites[curSprite].x += nbr;
                if (FlxG.keys.pressed.LEFT)
                    sprites[curSprite].x -= nbr;
                if (FlxG.keys.pressed.DOWN)
                    sprites[curSprite].y += nbr;
                if (FlxG.keys.pressed.UP)
                    sprites[curSprite].y -= nbr;
            } else {
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

			var alpha:Float = sprites[curSprite].alpha;
			if (FlxG.keys.pressed.N)
				alpha += 0.01;
			if (sprites[curSprite].alpha > 1)
				alpha = 0;
			sprites[curSprite].alpha = alpha;
			sprites[curSprite].updateHitbox();
        }
		spriteCoord.text = "coords: " + Std.string(sprites[curSprite].x) + ", " + Std.string(sprites[curSprite].y) + ", "
			+ Std.string(sprites[curSprite].angle) + "\nalpha: " + Std.string(sprites[curSprite].alpha);
		skewCoord.text = "skew coords: " + Std.string(sprites[curSprite].skew.x) + ", " + Std.string(sprites[curSprite].skew.y);
		selNum.text = "selected Sprite ID: " + Std.string(curSprite);
        //this.sort(FlxSort.byY, FlxSort.ASCENDING);
        super.update(elapsed);
    }
    function changecurSel(dir:Int) {
        curSprite += dir;
        if (curSprite > sprites.length-1)
            curSprite = 0;
		spriteNamer.text = jsonData.objects[curSprite].name;
		pathNamer.text = jsonData.objects[curSprite].imagePath;
    }
    #if sys
    function saveProgress() {
		File.saveContent("saves/save.json", haxe.Json.stringify(jsonData, "\t").trim());
    }
    #end
}