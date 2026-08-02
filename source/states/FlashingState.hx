package states;

class FlashingState extends MusicBeatState {
	public static var leftState:Bool = false;

	var texts = new FlxTypedSpriteGroup<FlxText>();
	var isBouce:Bool = false;
	var isYes:Bool = true;
	var selector:FlxText;

	override function create() {
		super.create();
		add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

		texts.alpha = 0;
		add(texts);

		var warnText:FlxText = new FlxText(0, 0, FlxG.width,
			"Hey, watch out!\n
			This Mod contains some flashing lights!\n
			Do you wish to disable them?");
		warnText.setFormat(Paths.font("fredoka_One.ttf"), 22, FlxColor.WHITE, CENTER);
		warnText.y = (FlxG.height - warnText.height) / 2.4;
		warnText.updateHitbox();
		texts.add(warnText);

		final keys = ["Yes", "No"];
		for (i in 0...keys.length) {
			final button = new FlxText(0, 0, FlxG.width, keys[i]);
			button.setFormat(Paths.font("fredoka_One.ttf"), 28, FlxColor.WHITE, CENTER);
			button.y = (warnText.y + warnText.height) + 32;
			button.x += (160 * i) - 80;
			texts.add(button);
		}

		selector = new FlxText(0, 0, 0, ">");
		selector.setFormat(Paths.font("fredoka_One.ttf"), 28, FlxColor.WHITE, LEFT);
		selector.angle = -90;
		texts.add(selector);
		FlxTween.tween(texts, {alpha: 1.0}, 0.4, {
			onComplete: (_) -> updateItems()
		});
	}

	override function update(elapsed:Float) {
		if (leftState) {
			super.update(elapsed);
			return;
		}

		var next = isYes;
		if (controls.UI_LEFT_P)
			next = true;
		else if (controls.UI_RIGHT_P)
			next = false;
		if (next != isYes) {
			isYes = next;
			FlxG.sound.play(Paths.sound("scrollMenu"), 0.7);
			updateItems();
		}

		var back:Bool = controls.BACK;
		if (controls.ACCEPT || back) {
			leftState = true;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			if (!back) {
				var i = isYes;
				//ClientPrefs.data.flashingCheck = i;
				ClientPrefs.data.flashing = !i;
				ClientPrefs.saveSettings();
                FlxG.sound.play(Paths.sound("confirmMenu"));
                var button = texts.members[i ? 1 : 2];
                flixel.effects.FlxFlicker.flicker(button, 0.8, 0.1, false, true, function(_) {
                    FlxTween.tween(texts, {alpha: 0}, 0.25, {
						onComplete: (_) -> MusicBeatState.switchState(new TitleState())
                    });
                });
            } else {
				FlxG.sound.play(Paths.sound("cancelMenu"));
				FlxTween.tween(texts, {alpha: 0}, 0.4, {
					onComplete: (_) -> MusicBeatState.switchState(new TitleState())
				});
            }
		}
		super.update(elapsed);
	}

	function updateItems() {
		var yes = texts.members[1];
		var no = texts.members[2];

		var target = isYes ? yes : no;
		var other = isYes ? no : yes;

		target.alpha = 1.0;
		other.alpha = 0.5;

		target.color = FlxColor.YELLOW;
		other.color = FlxColor.WHITE;

		selector.x = target.x + (target.width / 2) - (selector.width / 2);
		selector.y = target.y + target.height - 6;

		target.scale.set(1.1, 1.1);
		FlxTween.tween(target.scale, {x: 1, y: 1}, 0.15);
		if (!isBouce) {
            FlxTween.tween(selector, {y: selector.y + 4}, 0.6, {
                type: PINGPONG,
                ease: FlxEase.sineInOut
            });
			isBouce = true;
        }
	}
}