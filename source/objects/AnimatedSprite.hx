package objects;

class AnimatedSprite extends FlxSprite {
	var idleAnim:String;
	public function new(x:Float = 0, y:Float = 0, ?scrollX:Float, ?scrollY:Float, image:String, ?parentFolder:String, ?animArray:Array<String> = null, ?loop:Bool) {
		super(x, y);
		if (animArray != null) {
			frames = Paths.getSparrowAtlas(image);
			for (i in 0...animArray.length) {
				var anim:String = animArray[i];
				animation.addByPrefix(anim, anim, 24, loop ?? false);
				if (idleAnim == null) {
					idleAnim = anim;
					animation.play(anim);
				}
			}
		}
		scrollFactor.set(scrollX ?? 1, scrollY ?? 1);
		antialiasing = ClientPrefs.data.antialiasing;
	}

	public function dance(?forceplay:Bool) {
		if (idleAnim != null)
			animation.play(idleAnim, forceplay ?? false);
	}
}