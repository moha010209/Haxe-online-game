package objects;

import openfl.display.BitmapData;
import openfl.geom.Point;
import flixel.addons.effects.FlxSkewedSprite;

class MapObject extends FlxSkewedSprite {
    public var type:String = "normal";
    private var originalBitmap:BitmapData;
    public var repeatTiles:Array<Int> = [1, 1];

    public function repeatTexture(x:Int = 1, y:Int = 1):Void {
		if (originalBitmap == null)
			originalBitmap = pixels;
        
        if (originalBitmap == null) {
            trace("Error: originalBitmap is not initialized.");
            return;
        }


        var repeatedWidth:Int = originalBitmap.width * x;

        var repeatedHeight:Int = originalBitmap.height * y;

        var repeatedBitmapData:BitmapData = new BitmapData(repeatedWidth, repeatedHeight, true, 0x00000000);

        for (row in 0...y) {
            for (col in 0...x)
            {
				repeatedBitmapData.merge(originalBitmap, originalBitmap.rect, new Point(col * originalBitmap.width, row * originalBitmap.height), 255, 255, 255, 255);
            }
        }

        makeGraphic(repeatedWidth, repeatedHeight, 0x00000000);
        pixels = repeatedBitmapData;
        updateHitbox();

        repeatTiles = [x, y];
    }
}