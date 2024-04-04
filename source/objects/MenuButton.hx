package objects;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;

class MenuButton extends FlxButton
{
	public function new(x:Float, y:Float, text:String, ?OnClick:Void->Void, width:Float, height:Float)
	{
        super(x, y, text, OnClick);
        loadGraphic(Paths.image("ui/button"));
        scale.x = width / this.width;
        scale.y = height / this.height;
        updateHitbox();
        label.font = "assets/fonts/SusFont.ttf";
        label.antialiasing = true;
        label.color = 0xFFFFFF;
        label.size = 96;
        label.scale.x = scale.x;
        label.scale.y = scale.y;
        label.updateHitbox();
        label.alignment = "center";
	}
}
