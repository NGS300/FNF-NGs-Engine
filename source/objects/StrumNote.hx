package objects;

import backend.animation.PsychAnimationController;
import shaders.RGBPalette.RGBShaderReference;

class StrumNote extends FlxSprite {
	public var rgbShader:RGBShaderReference;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;
	public var downScroll:Bool = false;
	public var sustainReduce:Bool = true;
	private var player:Int;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if (texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public var useRGBShader:Bool = true;
	public function new(x:Float, y:Float, leData:Int, player:Int) {
		animation = new PsychAnimationController(this);

		rgbShader = new RGBShaderReference(this, Note.initializeGlobalRGBShader(leData));
		rgbShader.enabled = false;
		if (PlayState.SONG != null && PlayState.SONG.disableNoteRGB) useRGBShader = false;
		
		var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[leData];
		if (PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[leData];
		
		if (leData <= arr.length) {
			@:bypassAccessor {
				rgbShader.r = arr[0];
				rgbShader.g = arr[1];
				rgbShader.b = arr[2];
			}
		}

		noteData = leData;
		this.player = player;
		this.noteData = leData;
		this.ID = noteData;
		super(x, y);

		var skin:String = null;
		if (PlayState.SONG != null && PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1)
			skin = PlayState.SONG.arrowSkin;
		else skin = Note.defaultNoteSkin;

		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if (Paths.fileExists("images/" + Note.defaultNotePath + '$customSkin.png', IMAGE)) skin = customSkin;

		texture = skin; //Load texture and anims
		scrollFactor.set();
		playAnim("static");
	}

	public function reloadNote() {
		var lastAnim:String = null;
		if (animation.curAnim != null) lastAnim = animation.curAnim.name;

		var noteDataIdx:Int = Std.int(Math.abs(noteData) % 4);
		var path:String = "notes/skins/";
		if (PlayState.isPixelStage) {
			var pixel:String = path + "pixel/" + texture;
			loadGraphic(Paths.image(pixel));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image(pixel), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			var baseFrames:Array<Int> = [4, 5, 6, 7];
			for (i in 0...Note.colArray.length)
				animation.add(Note.colArray[i], [baseFrames[i]]);

			var pixelAnims:Array<Array<Int>> = [ // [static, pressed1, pressed2, confirm1, confirm2]
				[0, 4, 8, 12, 16], // Left / Purple
				[1, 5, 9, 13, 17], // Down / Blue
				[2, 6, 10, 14, 18], // Up / Green
				[3, 7, 11, 15, 19]  // Right / Red
			];

			var anim = pixelAnims[noteDataIdx];
			animation.add("static", [anim[0]]);
			animation.add("pressed", [anim[1], anim[2]], 12, false);
			animation.add("confirm", [anim[3], anim[4]], 24, false);
		} else {
			frames = Paths.getSparrowAtlas(path + texture);
			var dirNames:Array<String> = ["left", "down", "up", "right"];
			for (i in 0...Note.colArray.length)
				animation.addByPrefix(Note.colArray[i], "arrow" + dirNames[i].toUpperCase());

			antialiasing = ClientPrefs.data.antialiasing;
			setGraphicSize(Std.int(width * 0.7));

			var dir = dirNames[noteDataIdx];
			animation.addByPrefix("static", "arrow" + dir.toUpperCase());
			animation.addByPrefix("pressed", '$dir press', 24, false);
			animation.addByPrefix("confirm", '$dir confirm', 24, false);
		}
		updateHitbox();
		if (lastAnim != null)
			playAnim(lastAnim, true);
	}

	public function playerPosition() {
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
	}

	override function update(elapsed:Float) {
		if (resetAnim > 0) {
			resetAnim -= elapsed;
			if (resetAnim <= 0) {
				playAnim("static");
				resetAnim = 0;
			}
		}
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		if (animation.curAnim != null) {
			centerOffsets();
			centerOrigin();
		}
		if (useRGBShader) rgbShader.enabled = (animation.curAnim != null && animation.curAnim.name != "static");
	}
}