function onCreate() {
    //if (game.isStoryMode && !game.seenCutscene && game.songName.toLowerCase() == 'monster')
        //PlayState.instance.startCallback = monsterCutscene;
        //game.setStartCallback(monsterCutscene);
}

function monsterCutscene() {
    game.inCutscene = true;

    game.camHUD.visible = false;
    game.camNOTE.visible = false;
    FlxG.camera.focusOn(new FlxPoint(game.dad.getMidpoint().x + 150, game.dad.getMidpoint().y - 100));

    if (game.gf != null)
        game.gf.playAnim("scared", true);
    if (game.boyfriend != null)
        game.boyfriend.playAnim("scared", true);

    FlxG.sound.play(Paths.soundRandom(dir("thunder_", [""]), 1, 2));

    var whiteScreen = new Graphic(null, Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0, 0, 0, 0);
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