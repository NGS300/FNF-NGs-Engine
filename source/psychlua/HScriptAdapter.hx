package psychlua;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.ds.ObjectMap;
import haxe.ds.EnumValueMap;

class ScriptMap {
    var internalMap:Dynamic;

    public function new() this.internalMap = new StringMap<Dynamic>();

    public function get(key:Dynamic):Dynamic return internalMap.get(key);

	public function set(key:Dynamic, value:Dynamic):Void {
		if (Std.isOfType(key, Int) && Std.isOfType(internalMap, StringMap)) {
			var oldMap:StringMap<Dynamic> = cast internalMap;
			internalMap = new IntMap<Dynamic>();
			
			for (k in oldMap.keys())
				internalMap.set(Std.parseInt(k), oldMap.get(k));
		}
		internalMap.set(key, value);
	}

    public function exists(key:Dynamic):Bool return internalMap.exists(key);

    public function remove(key:Dynamic):Bool return internalMap.remove(key);

    public function keys():Array<Dynamic> {
        var arr = [];
        var it = internalMap.keys();
        while (it.hasNext()) arr.push(it.next());
        return arr;
    }

    public function iterator():Array<Dynamic> {
        var arr = [];
        var it = internalMap.iterator();
        while (it.hasNext()) arr.push(it.next());
        return arr;
    }
}

class CustomMap {
    public static function createStringMap():StringMap<Dynamic> return new StringMap<Dynamic>();

    public static function createIntMap():IntMap<Dynamic> return new IntMap<Dynamic>();

    public static function createObjectMap():ObjectMap<Dynamic, Dynamic> return new ObjectMap<Dynamic, Dynamic>();

    public static function createEnumValueMap():EnumValueMap<Dynamic, Dynamic> return new EnumValueMap<Dynamic, Dynamic>();

    public static function get(map:Dynamic, key:Dynamic):Dynamic {
        if (map == null) return null;
        return map.get(key);
    }

    public static function set(map:Dynamic, key:Dynamic, value:Dynamic):Void {
        if (map != null)
            map.set(key, value);
    }

    public static function exists(map:Dynamic, key:Dynamic):Bool {
        if (map == null) return false;
        return map.exists(key);
    }

    public static function remove(map:Dynamic, key:Dynamic):Bool {
        if (map == null) return false;
        return map.remove(key);
    }

    public static function clear(map:Dynamic):Void {
        if (map == null) return;
        #if (haxe_ver >= 4.0)
        map.clear();
        #else
        var keysList = keys(map);
        for (k in keysList)
            map.remove(k);
        #end
    }

    public static function keys(map:Dynamic):Array<Dynamic> {
        if (map == null) return [];
        var arr:Array<Dynamic> = [];
        var it = map.keys();
        while (it.hasNext())
            arr.push(it.next());
        return arr;
    }

    public static function iterator(map:Dynamic):Array<Dynamic> {
        if (map == null) return [];
        var arr:Array<Dynamic> = [];
        var it = map.iterator();
        while (it.hasNext())
            arr.push(it.next());
        return arr;
    }

    public static function keyValueIterator(map:Dynamic):Array<Dynamic> {
        if (map == null) return [];
        var arr:Array<Dynamic> = [];
        #if (haxe_ver >= 4.0)
        var it = map.keyValueIterator();
        while (it.hasNext()) {
            var item = it.next();
            arr.push({key: item.key, value: item.value});
        }
        #end
        return arr;
    }

    public static function copy(map:Dynamic):Dynamic {
        if (map == null) return null;
        if (Std.isOfType(map, StringMap))
            return (cast map : StringMap<Dynamic>).copy();
        else if (Std.isOfType(map, IntMap))
            return (cast map : IntMap<Dynamic>).copy();

        var newMap = createStringMap();
        var kList = keys(map);
        for (k in kList)
            newMap.set(k, map.get(k));
        return newMap;
    }

    public static function toString(map:Dynamic):String {
        if (map == null) return "null";
        return map.toString();
    }

    public static function count(map:Dynamic):Int {
        if (map == null) return 0;
        var total:Int = 0;
        var it = map.keys();
        while (it.hasNext()) {
            it.next();
            total++;
        }
        return total;
    }
}

class CustomFlxColor {
    public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	public static var BLACK(default, null):Int = FlxColor.BLACK;
	public static var WHITE(default, null):Int = FlxColor.WHITE;
	public static var GRAY(default, null):Int = FlxColor.GRAY;

	public static var GREEN(default, null):Int = FlxColor.GREEN;
	public static var LIME(default, null):Int = FlxColor.LIME;
	public static var YELLOW(default, null):Int = FlxColor.YELLOW;
	public static var ORANGE(default, null):Int = FlxColor.ORANGE;
	public static var RED(default, null):Int = FlxColor.RED;
	public static var PURPLE(default, null):Int = FlxColor.PURPLE;
	public static var BLUE(default, null):Int = FlxColor.BLUE;
	public static var BROWN(default, null):Int = FlxColor.BROWN;
	public static var PINK(default, null):Int = FlxColor.PINK;
	public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
	public static var CYAN(default, null):Int = FlxColor.CYAN;

    public static function fromInt(Value:Int):Int return cast FlxColor.fromInt(Value);
    public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);
    public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);
    public static function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);
    public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);
    public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);
    public static function fromString(str:String):Dynamic {
        var res = FlxColor.fromString(str);
        return (res != null) ? (res : Int) : null;
    }

    public static function getHSBColorWheel(Alpha:Int = 255):Array<Int> {
        var wheel = FlxColor.getHSBColorWheel(Alpha);
        return [for (c in wheel) (c : Int)];
    }

    public static function interpolate(Color1:Int, Color2:Int, Factor:Float = 0.5):Int {
        return FlxColor.interpolate(Color1, Color2, Factor);
    }

    public static function gradient(Color1:Int, Color2:Int, Steps:Int, ?Ease:Float->Float):Array<Int> {
        var grad = FlxColor.gradient(Color1, Color2, Steps, Ease);
        return [for (c in grad) (c : Int)];
    }

    public static function multiply(lhs:Int, rhs:Int):Int {
        var c1:FlxColor = lhs;
        var c2:FlxColor = rhs;
        return c1 * c2;
    }

    public static function add(lhs:Int, rhs:Int):Int {
        var c1:FlxColor = lhs;
        var c2:FlxColor = rhs;
        return c1 + c2;
    }

    public static function subtract(lhs:Int, rhs:Int):Int {
        var c1:FlxColor = lhs;
        var c2:FlxColor = rhs;
        return c1 - c2;
    }

    public static function getRed(color:Int):Int { var f:FlxColor = color; return f.red; }
    public static function getGreen(color:Int):Int { var f:FlxColor = color; return f.green; }
    public static function getBlue(color:Int):Int { var f:FlxColor = color; return f.blue; }
    public static function getAlpha(color:Int):Int { var f:FlxColor = color; return f.alpha; }

    public static function setRed(color:Int, val:Int):Int { var f:FlxColor = color; f.red = val; return f; }
    public static function setGreen(color:Int, val:Int):Int { var f:FlxColor = color; f.green = val; return f; }
    public static function setBlue(color:Int, val:Int):Int { var f:FlxColor = color; f.blue = val; return f; }
    public static function setAlpha(color:Int, val:Int):Int { var f:FlxColor = color; f.alpha = val; return f; }

    public static function getRedFloat(color:Int):Float { var f:FlxColor = color; return f.redFloat; }
    public static function getGreenFloat(color:Int):Float { var f:FlxColor = color; return f.greenFloat; }
    public static function getBlueFloat(color:Int):Float { var f:FlxColor = color; return f.blueFloat; }
    public static function getAlphaFloat(color:Int):Float { var f:FlxColor = color; return f.alphaFloat; }

    public static function setRedFloat(color:Int, val:Float):Int { var f:FlxColor = color; f.redFloat = val; return f; }
    public static function setGreenFloat(color:Int, val:Float):Int { var f:FlxColor = color; f.greenFloat = val; return f; }
    public static function setBlueFloat(color:Int, val:Float):Int { var f:FlxColor = color; f.blueFloat = val; return f; }
    public static function setAlphaFloat(color:Int, val:Float):Int { var f:FlxColor = color; f.alphaFloat = val; return f; }

    public static function getCyan(color:Int):Float { var f:FlxColor = color; return f.cyan; }
    public static function getMagenta(color:Int):Float { var f:FlxColor = color; return f.magenta; }
    public static function getYellow(color:Int):Float { var f:FlxColor = color; return f.yellow; }
    public static function getBlack(color:Int):Float { var f:FlxColor = color; return f.black; }

    public static function setCyan(color:Int, val:Float):Int { var f:FlxColor = color; f.cyan = val; return f; }
    public static function setMagenta(color:Int, val:Float):Int { var f:FlxColor = color; f.magenta = val; return f; }
    public static function setYellow(color:Int, val:Float):Int { var f:FlxColor = color; f.yellow = val; return f; }
    public static function setBlack(color:Int, val:Float):Int { var f:FlxColor = color; f.black = val; return f; }

    public static function getHue(color:Int):Float { var f:FlxColor = color; return f.hue; }
    public static function getSaturation(color:Int):Float { var f:FlxColor = color; return f.saturation; }
    public static function getBrightness(color:Int):Float { var f:FlxColor = color; return f.brightness; }
    public static function getLightness(color:Int):Float { var f:FlxColor = color; return f.lightness; }

    public static function setHue(color:Int, val:Float):Int { var f:FlxColor = color; f.hue = val; return f; }
    public static function setSaturation(color:Int, val:Float):Int { var f:FlxColor = color; f.saturation = val; return f; }
    public static function setBrightness(color:Int, val:Float):Int { var f:FlxColor = color; f.brightness = val; return f; }
    public static function setLightness(color:Int, val:Float):Int { var f:FlxColor = color; f.lightness = val; return f; }

    public static function getRgb(color:Int):Int { var f:FlxColor = color; return f.rgb; }
    public static function setRgb(color:Int, val:Int):Int { var f:FlxColor = color; f.rgb = val; return f; }

    public static function getComplementHarmony(color:Int):Int { var f:FlxColor = color; return f.getComplementHarmony(); }
    public static function getAnalogousHarmony(color:Int, Threshold:Int = 30):Dynamic { var f:FlxColor = color; return f.getAnalogousHarmony(Threshold); }
    public static function getSplitComplementHarmony(color:Int, Threshold:Int = 30):Dynamic { var f:FlxColor = color; return f.getSplitComplementHarmony(Threshold); }
    public static function getTriadicHarmony(color:Int):Dynamic { var f:FlxColor = color; return f.getTriadicHarmony(); }

    public static function to24Bit(color:Int):Int { var f:FlxColor = color; return f.to24Bit(); }
    public static function toHexString(color:Int, Alpha:Bool = true, Prefix:Bool = true):String { var f:FlxColor = color; return f.toHexString(Alpha, Prefix); }
    public static function toWebString(color:Int):String { var f:FlxColor = color; return f.toWebString(); }
    public static function getColorInfo(color:Int):String { var f:FlxColor = color; return f.getColorInfo(); }

    public static function getDarkened(color:Int, Factor:Float = 0.2):Int { var f:FlxColor = color; return f.getDarkened(Factor); }
    public static function getLightened(color:Int, Factor:Float = 0.2):Int { var f:FlxColor = color; return f.getLightened(Factor); }
    public static function getInverted(color:Int):Int { var f:FlxColor = color; return f.getInverted(); }

    public static function setRGB(color:Int, Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int { var f:FlxColor = color; return f.setRGB(Red, Green, Blue, Alpha); }
    public static function setRGBFloat(color:Int, Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int { var f:FlxColor = color; return f.setRGBFloat(Red, Green, Blue, Alpha); }
    public static function setCMYK(color:Int, Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int { var f:FlxColor = color; return f.setCMYK(Cyan, Magenta, Yellow, Black, Alpha); }
    public static function setHSB(color:Int, Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float):Int { var f:FlxColor = color; return f.setHSB(Hue, Saturation, Brightness, Alpha); }
    public static function setHSL(color:Int, Hue:Float, Saturation:Float, Lightness:Float, Alpha:Float):Int { var f:FlxColor = color; return f.setHSL(Hue, Saturation, Lightness, Alpha); }
}