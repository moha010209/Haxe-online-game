package objects;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.graphics.FlxGraphic;
#if sys
import sys.io.File;
#end
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

class Player extends FlxSkewedSprite
{
	public var rgbShader:RGBShaderReference;
	public static var MAX_SPEED_X:Float = 200;
	public static var MAX_SPEED_Y:Float = 200;
	public function new()
	{
		super();
		//loadGraphic("assets/images/player.png", true);
		frames = Paths.getSparrowAtlas("player");
		animation.addByPrefix("idle", "idle", 24);
		animation.addByPrefix("walk", "Walk", 24);
		animation.play("idle");
		x = 0;
		y = 0;
		var newRGB:RGBPalette = new RGBPalette();
		rgbShader = new RGBShaderReference(this, newRGB);
		rgbShader.r = 0xc51111;
		rgbShader.g = 0x96cadd;
		rgbShader.b = 0x7a0838;
	}
}
