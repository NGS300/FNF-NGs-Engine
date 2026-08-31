package backend;

import openfl.utils.Assets;
#if (android || ios)
import lime.net.HTTPRequest;
#end

class CoolUtil {
	public static function exists(path:String, ?type:openfl.utils.AssetType = TEXT):Bool {
        #if MODS_ALLOWED
        if (FileSystem.exists(path)) return true;
        #end
        return Assets.exists(path, type);
    }

    public static function getContent(path:String):String {
        #if MODS_ALLOWED
        if (FileSystem.exists(path)) return File.getContent(path);
        #end
        if (Assets.exists(path, TEXT)) return Assets.getText(path);
        return null;
    }

    public static function getJson(path:String):Dynamic {
        var raw:String = getContent(path);
        return raw != null ? haxe.Json.parse(raw) : null;
    }

	inline public static function coolTextFile(path:String):Array<String> {
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		if (FileSystem.exists(path)) daList = File.getContent(path);
		#else
		if (Assets.exists(path)) daList = Assets.getText(path);
		#end
		return daList != null ? listFromString(daList) : [];
	}

	inline public static function listFromString(string:String):Array<String> {
		var daList:Array<String> = [];
		daList = string.trim().split("\n");
		for (i in 0...daList.length) daList[i] = daList[i].trim();
		return daList;
	}

	inline public static function capitalize(text:String)
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	public static function compareValues(latest:String, current:String):Bool {
		var a = latest.split(".");
		var b = current.split(".");
		var maxLen = Std.int(Math.max(a.length, b.length));

		for (i in 0...maxLen) {
			var va = (i < a.length) ? Std.parseInt(a[i]) : 0;
			var vb = (i < b.length) ? Std.parseInt(b[i]) : 0;

			if (va > vb) return true;
			if (va < vb) return false;
		}
		return false;
	}

	public static function setTextBorderFromString(text:FlxText, border:String) {
		switch (border.toLowerCase().trim()) {
			case "shadow": text.borderStyle = SHADOW;
			case "outline": text.borderStyle = OUTLINE;
			case "outline_fast", "outlinefast": text.borderStyle = OUTLINE_FAST;
			default: text.borderStyle = NONE;
		}
	}

	public static function floorDecimal(value:Float, decimals:Int):Float {
		if (decimals < 1) return Math.floor(value);
		return Math.floor(value * Math.pow(10, decimals)) / Math.pow(10, decimals);
	}

	inline public static function quantize(f:Float, snap:Float){
		var m:Float = Math.fround(f * snap);
		return (m / snap);
	}

	inline public static function numberArray(max:Int, ?min = 0):Array<Int> {
		var dumbArray:Array<Int> = [];
		for (i in min...max) dumbArray.push(i);
		return dumbArray;
	}

	inline public static function colorFromString(color:String):FlxColor {
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join("").trim();
		if (color.startsWith("0x")) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if (colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	inline public static function dominantColor(sprite:flixel.FlxSprite):Int {
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth) {
			for (row in 0...sprite.frameHeight) {
				var colorOfThisPixel:FlxColor = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel.alphaFloat > 0.05) {
					colorOfThisPixel = FlxColor.fromRGB(colorOfThisPixel.red, colorOfThisPixel.green, colorOfThisPixel.blue, 255);
					var count:Int = countByColor.exists(colorOfThisPixel) ? countByColor[colorOfThisPixel] : 0;
					countByColor[colorOfThisPixel] = count + 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0; //after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for (key => count in countByColor) {
			if (count >= maxCount) {
				maxCount = count;
				maxKey = key;
			}
		}
		countByColor = [];
		return maxKey;
	}

	public static var engine = states.TitleState.engineData;
	public static function checkForUpdates(callback:String->Void, url:String) {
		var version:String = engine.version.trim();
		if (ClientPrefs.data.checkForUpdates) {
			trace("checking for updates...");

			var http = new haxe.Http(url);
			http.onData = function(data:String) {
				var regex = ~/engineData\s*=\s*\{[\s\S]*?version:\s*"([^"]+)"/;
				if (regex.match(data)) {
					var latest:String = regex.matched(1).trim();
					trace('version online: $latest, your version: $version');
					callback(latest);
					return;
				}

				trace("could not find engineData.version");
				callback(version);
			};

			http.onError = function(error:String) {
				trace('update check error: $error');
				callback(version);
			};

			http.request();
		} else
			callback(version);
	}

	inline public static function browserLoad(site:String) {
		#if linux
		Sys.command("/usr/bin/xdg-open", [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	inline public static function openFolder(folder:String, absolute:Bool = false) {
		#if sys
		if (!absolute) folder = Sys.getCwd() + '$folder';

		folder = folder.replace("/", "\\");
		if (folder.endsWith("/")) folder.substr(0, folder.length - 1);

			/*#if linux
			var command:String = "/usr/bin/xdg-open";
			#else
			var command:String = "explorer.exe";
			#end */
		var command:String = #if linux "/usr/bin/xdg-open" #else "explorer.exe" #end;
		Sys.command(command, [folder]);
		trace('$command $folder');
		#else
		FlxG.error("Platform is not supported for CoolUtil.openFolder");
		#end
	}

	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String {
		final company:String = FlxG.stage.application.meta.get("company");
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get("file"))}';
	}
}