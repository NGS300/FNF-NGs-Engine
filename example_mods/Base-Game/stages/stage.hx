var blackBG:BGSprite;
var lightEvent:BGSprite;
var fogGroup:FlxSpriteGroup;
function dir(path, ?lib) return getVar("dirModsStages")(path, lib);

function createFogGroup():FlxSpriteGroup {
    var fog = new FlxSpriteGroup();
    fog.alpha = 0;
    fog.blend = "add";

    var offset = { x: 200, y: 660 }
    var smoke1 = new BGSprite(dir("smoke"), -1550 + offset.x, offset.y + FlxG.random.float(-20, 20), 1.2, 1.05);
    smoke1.setGraphicSize(Std.int(smoke1.width * FlxG.random.float(1.1, 1.22)));
    smoke1.updateHitbox();
    smoke1.velocity.x = FlxG.random.float(15, 22);
    smoke1.active = true;
    fog.add(smoke1);

    var smoke2 = new BGSprite(dir("smoke"), 1550 + offset.x, offset.y + FlxG.random.float(-20, 20), 1.2, 1.05);
    smoke2.setGraphicSize(Std.int(smoke2.width * FlxG.random.float(1.1, 1.22)));
    smoke2.updateHitbox();
    smoke2.velocity.x = FlxG.random.float(-15, -22);
    smoke2.active = true;
    smoke2.flipX = true;
    fog.add(smoke2);
    return fog;
}

function onCreatePost() {
    var bg = new BGSprite(dir("back"), -600, -200, 0.9, 0.9);
    game.insert(game.members.indexOf(game.gfGroup), bg);

    var front = new BGSprite(dir("front"), -650, 600, 0.9, 0.9);
    front.setGraphicSize(Std.int(front.width * 1.1));
    front.updateHitbox();
    game.insert(game.members.indexOf(game.gfGroup), front);

    if (!ClientPrefs.data.lowQuality) {
        var light1 = new BGSprite(dir("light"), -125, -100, 0.9, 0.9);
        light1.setGraphicSize(Std.int(light1.width * 1.1));
        light1.updateHitbox();
        game.insert(game.members.indexOf(game.uiGroup), light1);

        var light2 = new BGSprite(dir("light"), 1225, -100, 0.9, 0.9);
        light2.setGraphicSize(Std.int(light2.width * 1.1));
        light2.updateHitbox();
        light2.flipX = true;
        game.insert(game.members.indexOf(game.uiGroup), light2);

        var curtains = new BGSprite(dir("curtains"), -500, -300, 1.3, 1.3);
        curtains.setGraphicSize(Std.int(curtains.width * 0.9));
        curtains.updateHitbox();
        game.insert(game.members.indexOf(game.uiGroup), curtains);
    }
}

function onEventPushed(name:String, value1:String, value2:String, strumTime:Float) {
    switch (name) {
        case "Dadbattle Spotlight":
            blackBG = new BGSprite(null, -800, -400, 0, 0);
            blackBG.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
            blackBG.alpha = 0.25;
            blackBG.visible = false;
            game.insert(game.members.indexOf(game.dadGroup), blackBG);

            lightEvent = new BGSprite(dir("spotlight"), 400, -400);
            lightEvent.alpha = 0.375;
            lightEvent.blend = "add";
            lightEvent.visible = false;
            game.insert(game.members.indexOf(game.uiGroup), lightEvent);

            fogGroup = createFogGroup();
            fogGroup.visible = false;
            game.insert(game.members.indexOf(game.dadGroup), fogGroup);
    }
}

function onEventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float) {
    switch (eventName) {
        case "Dadbattle Spotlight":
            if (flValue1 == null) flValue1 = 0;

            var val:Int = Math.round(flValue1);
            switch (val) {
                case 1, 2, 3:
                    if (val == 1) {
                        blackBG.visible = true;
                        lightEvent.visible = true;
                        fogGroup.visible = true;
                        game.defaultCamZoom += 0.12;
                    }
                    var who = game.dad;
                    if (val > 2) who = game.boyfriend;

                    lightEvent.alpha = 0;
                    new FlxTimer().start(0.12, function(tmr:FlxTimer) {
                        lightEvent.alpha = 0.375;
                    });

                    lightEvent.setPosition(who.getGraphicMidpoint().x - lightEvent.width / 2, who.y + who.height - lightEvent.height + 50);
                    FlxTween.tween(fogGroup, {alpha: 0.7}, 1.5, {ease: FlxEase.quadInOut});
                default:
                    blackBG.visible = false;
                    lightEvent.visible = false;
                    game.defaultCamZoom -= 0.12;
                    FlxTween.tween(fogGroup, {alpha: 0}, 0.7, {
                        onComplete: (_) -> fogGroup.visible = false
                    });
            }
    }
}