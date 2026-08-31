package objects;

class Sprite extends FlxSprite {
	public function new(image:String, ?parentFolder:String, x:Float = 0, y:Float = 0, ?scrollX:Float, ?scrollY:Float) {
		super(x, y);
		if (image != null) loadGraphic(Paths.image(image, parentFolder));
		active = false;
		scrollFactor.set(scrollX ?? 1, scrollY ?? 1);
		antialiasing = ClientPrefs.data.antialiasing;
	}
}