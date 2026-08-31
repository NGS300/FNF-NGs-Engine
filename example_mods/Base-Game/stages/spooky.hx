function dir(path, ?lib) return getVar("dirModsStages")(path, lib);

var bg:FlxSprite;
var whiteBG:Graphic;

var lighting = {
    beat: 0,
    offset: 8
}

function onCreate() {
    game.defaultCamZoom = 1.05;

    var path = dir("bg");
    if (!ClientPrefs.data.lowQuality) {
        precacheImage(path);
        bg = new AnimatedSprite(-200, -100, 1, 1, path, null, ["bg", "lighting strike"]);
    } else {
        path = dir("bg_low");
        precacheImage(path);
        bg = new Sprite(path, -200, -100);
    }
    game.insert(game.members.indexOf(game.gfGroup), bg);

    whiteBG = new Graphic(null, Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), -800, -400, 0, 0);
    whiteBG.alpha = 0;
    whiteBG.blend = "add";
    game.insert(game.members.indexOf(game.uiGroup), whiteBG);

    for (i in 1...3)
        precacheSound(dir("thunder_" + i, [""]));
}

function onBeatHit() {
    if (FlxG.random.bool(10) && curBeat > lighting.beat + lighting.offset) {
        FlxG.sound.play(Paths.soundRandom(dir("thunder_", [""]), 1, 2));
        if (!ClientPrefs.data.lowQuality)
            bg.animation.play("lighting strike");

        lighting.beat = curBeat;
        lighting.offset = FlxG.random.int(8, 24);

        if (game.boyfriend != null && game.boyfriend.hasAnimation("scared"))
            game.boyfriend.playAnim("scared", true);

        if (game.dad != null && game.dad.hasAnimation("scared"))
            game.dad.playAnim("scared", true);

        if (game.gf != null && game.gf.hasAnimation("scared"))
            game.gf.playAnim("scared", true);

        if (ClientPrefs.data.camZooms) {
            FlxG.camera.zoom += 0.015;
            game.camHUD.zoom += 0.03;
            game.camNOTE.zoom += 0.03;
            if (!game.camZooming) {
                FlxTween.tween(FlxG.camera, { zoom: game.defaultCamZoom }, 0.5);
                FlxTween.tween(game.camHUD, { zoom: 1 }, 0.5);
                FlxTween.tween(game.camNOTE, { zoom: 1 }, 0.5);
            }
        }

        if (ClientPrefs.data.flashing) {
            whiteBG.alpha = 0.4;
            FlxTween.tween(whiteBG, { alpha: 0.5 }, 0.075);
            FlxTween.tween(whiteBG, { alpha: 0 }, 0.25, { startDelay: 0.15 });
        }
    }
}