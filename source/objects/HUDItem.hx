package objects;

import flixel.FlxSprite;

class HUDItem extends FlxSprite {
    public function new(x:Float, y:Float, type:String) {
        super(x,y);
        loadGraphic(type);
    }
}