package backend;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.ByteArray;
import openfl.display3D.textures.RectangleTexture;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import openfl.utils.Assets as OpenFlAssets;
import com.akifox.asynchttp.*;

class Paths {
    static public function getPath(path:String) {
        return "assets/" + path;
    }
	public static var localTrackedAssets:Array<String> = [];
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	static public function image(key:String, ?allowGPU:Bool = true):FlxGraphic
	{
		var bitmap:BitmapData = null;
		var file:String = null;

		#if MODS_ALLOWED
		file = modsImages(key);
		if (currentTrackedAssets.exists(file))
		{
			localTrackedAssets.push(file);
			return currentTrackedAssets.get(file);
		}
		else if (FileSystem.exists(file))
			bitmap = BitmapData.fromFile(file);
		else
		#end
		{
			file = getPath('images/$key.png');
			if (currentTrackedAssets.exists(file))
			{
				localTrackedAssets.push(file);
				return currentTrackedAssets.get(file);
			}
			else if (OpenFlAssets.exists(file))
				bitmap = OpenFlAssets.getBitmapData(file);
			else
			{
				var request = new HttpRequest({
					url: "http://" + ClientPrefs.data.address + '/images/$key.png',
					async: false,
					callback: function(response:HttpResponse):Void
					{
						if (response.isOK)
						{
							//#if !cpp
							bitmap = BitmapData.fromBytes(ByteArray.fromBytes(response.contentRaw));
							//#else
							//bitmap = response.toBitmapData();
							//#end
							trace('DONE ${response.status}');
						}
						else
						{
							trace('ERROR ${response.status} ${response.error}');
						}
					}
				});
				request.send();
            }
		}

		if (bitmap != null)
		{
			var retVal = cacheBitmap(file, bitmap, allowGPU);
			if (retVal != null)
				return retVal;
		}

		trace('oh no its returning null NOOOO ($file)');
		return null;
	}

	static public function cacheBitmap(file:String, ?bitmap:BitmapData = null, ?allowGPU:Bool = true)
	{
		if (bitmap == null)
		{
			#if MODS_ALLOWED
			if (FileSystem.exists(file))
				bitmap = BitmapData.fromFile(file);
			else
			#end
			{
				if (OpenFlAssets.exists(file, IMAGE))
					bitmap = OpenFlAssets.getBitmapData(file);
			}

			if (bitmap == null)
				return null;
		}

		localTrackedAssets.push(file);
		if (allowGPU && ClientPrefs.data.cacheOnGPU)
		{
			var texture:RectangleTexture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
			texture.uploadFromBitmapData(bitmap);
			bitmap.image.data = null;
			bitmap.dispose();
			bitmap.disposeImage();
			bitmap = BitmapData.fromTexture(texture);
		}
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
		newGraphic.persist = true;
		newGraphic.destroyOnNoUse = false;
		currentTrackedAssets.set(file, newGraphic);
		return newGraphic;
	}

	inline static public function getSparrowAtlas(key:String, ?allowGPU:Bool = true):FlxAtlasFrames
	{
		var imageLoaded:FlxGraphic = image(key, allowGPU);
		#if MODS_ALLOWED
		var xmlExists:Bool = false;

		var xml:String = modsXml(key);
		if (FileSystem.exists(xml))
			xmlExists = true;

		return FlxAtlasFrames.fromSparrow(imageLoaded, (xmlExists ? File.getContent(xml) : getPath('images/$key.xml', library)));
		#else
		return FlxAtlasFrames.fromSparrow(imageLoaded, getData('images/$key.xml'));
		#end
	}

	public static function getData(path:String, checkInFiles:Bool = true):String
	{
		var file = getPath(path);
		if (OpenFlAssets.exists(file) && checkInFiles)
            return OpenFlAssets.getText(file);
        else {
            var text:String = "";
			var request = new HttpRequest({
				url: "http://" + ClientPrefs.data.address + '/$path',
				async: false,
				callback: function(response:HttpResponse):Void
				{
					if (response.isOK)
					{
						text = response.toText();
						trace('DONE ${response.status}');
					}
					else
					{
						trace('ERROR ${response.status} ${response.error}');
					}
				}
			});
			request.send();
            return text;
        }
	}
}