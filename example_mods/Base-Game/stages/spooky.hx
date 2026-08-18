var bg:BGSprite;
var whiteBG:BGSprite;
var lighting = {
    beat: 0,
    offset: 8
}

function dir(path, ?lib) return getVar("dirModsStages")(path, lib);

function onCreatePost() {
    if (!ClientPrefs.data.lowQuality)
        bg = new BGSprite(dir("bg"), -200, -100, 1, 1, ["bg", "lighting strike"]);
    else
        bg = new BGSprite(dir("bg_low"), -200, -100);
    game.insert(game.members.indexOf(game.gfGroup), bg);

    whiteBG = new BGSprite(null, -800, -400, 0, 0);
    whiteBG.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
    whiteBG.alpha = 0;
    whiteBG.blend = "add";
    game.insert(game.members.indexOf(game.uiGroup), whiteBG);

    for (i in 1...3)
        Paths.sound(dir("thunder_" + i, [""]));

    //if (isStoryMode && !seenCutscene && songName.toLowerCase() == 'monster')
        //PlayState.instance.startCallback = monsterCutscene;
        //game.setStartCallback(monsterCutscene);
}

function onBeatHit() {
    if (FlxG.random.bool(10) && curBeat > lighting.beat + lighting.offset)
        lightningStrikeShit();
}

function lightningStrikeShit() {
    FlxG.sound.play(Paths.soundRandom(dir("thunder_", [""]), 1, 2));
    if (!ClientPrefs.data.lowQuality)
        bg.animation.play("lighting strike");

    lighting.beat = curBeat;
    lighting.offset = FlxG.random.int(8, 24);

    if (game.boyfriend != null && game.boyfriend.hasAnimation('scared'))
        game.boyfriend.playAnim('scared', true);

    if (game.dad != null && game.dad.hasAnimation('scared'))
        game.dad.playAnim('scared', true);

    if (game.gf != null && game.gf.hasAnimation('scared'))
        game.gf.playAnim('scared', true);

    if (ClientPrefs.data.camZooms) {
        FlxG.camera.zoom += 0.015;
        game.camHUD.zoom += 0.03;
        game.camNOTE.zoom += 0.03;
        if (!game.camZooming) {
            FlxTween.tween(FlxG.camera, {zoom: game.defaultCamZoom}, 0.5);
            FlxTween.tween(game.camHUD, {zoom: 1}, 0.5);
            FlxTween.tween(game.camNOTE, {zoom: 1}, 0.5);
        }
    }

    if (ClientPrefs.data.flashing) {
        whiteBG.alpha = 0.4;
        FlxTween.tween(whiteBG, {alpha: 0.5}, 0.075);
        FlxTween.tween(whiteBG, {alpha: 0}, 0.25, {startDelay: 0.15});
    }
}

function monsterCutscene() {
    game.inCutscene = true;
    game.camHUD.visible = false;
    game.camNOTE.visible = false;
    FlxG.camera.focusOn(new FlxPoint(game.dad.getMidpoint().x + 150, game.dad.getMidpoint().y - 100));

    if (game.gf != null) game.gf.playAnim("scared", true);
    if (game.boyfriend != null) game.boyfriend.playAnim("scared", true);
    FlxG.sound.play(Paths.soundRandom(dir("thunder_", [""]), 1, 2));

    var whiteScreen = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
    whiteScreen.scrollFactor.set();
    whiteScreen.blend = "add";
    game.insert(game.members.indexOf(game.uiGroup), whiteScreen);
    FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
        startDelay: 0.1,
        ease: FlxEase.linear,
        onComplete: function(twn:FlxTween) {
            whiteScreen.destroy();
            game.camHUD.visible = true;
            game.camNOTE.visible = true;
            game.startCountdown();
        }
    });
}