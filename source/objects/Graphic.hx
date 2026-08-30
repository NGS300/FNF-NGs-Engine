package objects;

class Graphic extends FlxSprite {
	public function new(?color:FlxColor, width:Int, height:Int, x:Float = 0, y:Float = 0, ?scrollX:Float, ?scrollY:Float) {
		super(x, y);
		makeGraphic(width, height, color ?? FlxColor.WHITE);
		scrollFactor.set(scrollX ?? 1, scrollY ?? 1);
		antialiasing = ClientPrefs.data.antialiasing;
	}
}