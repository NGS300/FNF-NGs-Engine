function dir(path, ?lib) return getVar("dirModsStages")(path, lib);

var fogHandler:Dynamic;
var fogGroup:FlxSpriteGroup;
var blackBG:Graphic;
var lightEvent:Sprite;

function onCreate() {
    fogHandler = getVar("fog");

    precacheImage(dir("back"));
    var bg = new Sprite(dir("back"), null, -600, -200, 0.9, 0.9);
    game.insert(game.members.indexOf(game.gfGroup), bg);

    precacheImage(dir("front"));
    var front = new Sprite(dir("front"), null, -650, 600, 0.9, 0.9);
    front.setGraphicSize(Std.int(front.width * 1.1));
    front.updateHitbox();
    game.insert(game.members.indexOf(game.gfGroup), front);

    if (!ClientPrefs.data.lowQuality) {
        precacheImage(dir("light"));
        var light1 = new Sprite(dir("light"), null, -125, -100, 0.9, 0.9);
        light1.setGraphicSize(Std.int(light1.width * 1.1));
        light1.updateHitbox();
        game.insert(game.members.indexOf(game.uiGroup), light1);

        var light2 = new Sprite(dir("light"), null, 1225, -100, 0.9, 0.9);
        light2.setGraphicSize(Std.int(light2.width * 1.1));
        light2.updateHitbox();
        light2.flipX = true;
        game.insert(game.members.indexOf(game.uiGroup), light2);

        precacheImage(dir("curtains"));
        var curtains = new Sprite(dir("curtains"), null, -500, -300, 1.3, 1.3);
        curtains.setGraphicSize(Std.int(curtains.width * 0.9));
        curtains.updateHitbox();
        game.insert(game.members.indexOf(game.uiGroup), curtains);
    }
}

function onEventPushed(name:String, value1:String, value2:String, strumTime:Float) {
    var parts:Array<String> = name.split(" ");
    if (parts.length >= 2 && parts[1] == "Spotlight" && (parts[0] == "Stage" || parts[0] == "Dadbattle")) {
        blackBG = new Graphic(FlxColor.BLACK, Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), -800, -400, 0, 0);
        blackBG.alpha = 0.25;
        blackBG.visible = false;
        game.insert(game.members.indexOf(game.dadGroup), blackBG);

        lightEvent = new Sprite(dir("spotlight"), null, 400, -400);
        lightEvent.alpha = 0.375;
        lightEvent.blend = "add";
        lightEvent.visible = false;
        game.insert(game.members.indexOf(game.uiGroup), lightEvent);

        if (fogHandler != null)
            fogGroup = fogHandler("new");

        if (fogGroup != null) {
            fogGroup.visible = false;
            game.insert(game.members.indexOf(game.dadGroup), fogGroup);
        }
    }
}

function onEventCalled(eventName:String, value1:String, value2:String, flValue1:Float, flValue2:Float, strumTime:Float) {
    var parts:Array<String> = eventName.split(" ");
    if (parts.length >= 2 && parts[1] == "Spotlight" && (parts[0] == "Stage" || parts[0] == "Dadbattle")) {
        if (flValue1 == null) flValue1 = 0;

        var val:Int = Math.round(flValue1);
        switch (val) {
            case 1, 2, 3:
                if (val == 1) {
                    if (blackBG != null) blackBG.visible = true;
                    if (lightEvent != null) lightEvent.visible = true;
                    if (fogGroup != null) fogGroup.visible = true;
                    game.defaultCamZoom += 0.12;
                }

                var who = game.dad;
                if (val > 2)
                    who = game.boyfriend;

                if (lightEvent != null) {
                    lightEvent.alpha = 0;
                    new FlxTimer().start(0.12, (_) -> {
                        lightEvent.alpha = 0.375;
                    });
                    lightEvent.setPosition(who.getGraphicMidpoint().x - lightEvent.width / 2, who.y + who.height - lightEvent.height + 50);
                }

                if (fogGroup != null)
                    FlxTween.tween(fogGroup, {alpha: 0.7}, 1.5, {ease: FlxEase.quadInOut});

            default:
                if (blackBG != null) blackBG.visible = false;
                if (lightEvent != null) lightEvent.visible = false;
                game.defaultCamZoom -= 0.12;

                if (fogGroup != null) {
                    FlxTween.tween(fogGroup, {alpha: 0}, 0.7, {
                        onComplete: (_) -> fogGroup.visible = false
                    });
                }
        }
    }
}