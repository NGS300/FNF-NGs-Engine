function dir(path, ?lib) return getVar("dirModsStages")(path, lib);

var lightsColors:Array<FlxColor>;
var window:Sprite;
var street:Sprite;

var trainSpr:Sprite;
var trainHandler:Dynamic;

var particleHandler:Dynamic;
var glowParticles:FlxTypedGroup<Sprite>;

var glowGradient:Sprite;
var glowHandler:Dynamic;

var lightsBlack:Graphic;
var windowEvent:Sprite;
var curLight:Int = -1;
var curLightEvent:Int = -1;

function onCreate() {
    game.defaultCamZoom = 1.05;

    trainHandler = getVar("train");
    glowHandler = getVar("glowGradient");
    particleHandler = getVar("glowParticle");

    if (!ClientPrefs.data.lowQuality) {
        precacheImage(dir("sky"));
        var sky = new Sprite(dir("sky"), null, -100, 0, 0.1, 0.1);
        game.insert(game.members.indexOf(game.gfGroup), sky);
    }

    precacheImage(dir("city"));
    var city = new Sprite(dir("city"), null, -10, 0, 0.3, 0.3);
    city.setGraphicSize(Std.int(city.width * 0.85));
    city.updateHitbox();
    game.insert(game.members.indexOf(game.gfGroup), city);

    precacheImage(dir("window"));
    lightsColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
    window = new Sprite(dir("window"), null, city.x, city.y, 0.3, 0.3);
    window.setGraphicSize(Std.int(window.width * 0.85));
    window.updateHitbox();
    game.insert(game.members.indexOf(game.gfGroup), window);
    window.alpha = 0;

    if (!ClientPrefs.data.lowQuality) {
        precacheImage(dir("behindTrain"));
        var streetBehind = new Sprite(dir("behindTrain"), null, -40, 50);
        game.insert(game.members.indexOf(game.gfGroup), streetBehind);
    }

    if (trainHandler != null)
        trainSpr = trainHandler("new");

    if (trainSpr != null)
        game.insert(game.members.indexOf(game.gfGroup), trainSpr);

    precacheImage(dir("street"));
    street = new Sprite(dir("street"), null, -40, 50);
    game.insert(game.members.indexOf(game.gfGroup), street);
}

function onEventPushed(event) {
    if (event == "Philly Glow") {
        lightsBlack = new Graphic(FlxColor.BLACK, Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxG.width * -0.5, FlxG.height * -0.5);
        lightsBlack.visible = false;
        game.insert(game.members.indexOf(street), lightsBlack);

        windowEvent = new Sprite(dir('window'), window.x, window.y, 0.3, 0.3);
        windowEvent.setGraphicSize(Std.int(windowEvent.width * 0.85));
        windowEvent.updateHitbox();
        windowEvent.visible = false;
        game.insert(game.members.indexOf(lightsBlack) + 1, windowEvent);

        if (glowHandler != null)
            glowGradient = glowHandler("new");

        if (glowGradient != null) {
            glowGradient.visible = false;
            game.insert(game.members.indexOf(lightsBlack) + 1, glowGradient);
            if (!ClientPrefs.data.flashing && glowHandler != null)
                glowHandler("setAlpha", null, 0.7);
        }

        precacheImage(dir("particle"));
        glowParticles = new FlxTypedGroup();
        glowParticles.visible = false;
        game.insert(game.members.indexOf(glowGradient) + 1, glowParticles);
    }
}

function onUpdate(elapsed:Float) {
    window.alpha -= (Conductor.crochet / 1000) * elapsed * 1.5;

    if (trainHandler != null && trainSpr != null)
        trainHandler("update", trainSpr, elapsed);

    if (glowHandler != null && glowGradient != null)
        glowHandler("update", glowGradient, elapsed);

    if (glowParticles != null) {
        glowParticles.forEachAlive(function(particle:Sprite) {
            if (particleHandler != null)
                particleHandler("update", particle, elapsed);

            if (particle.alpha <= 0)
                particle.kill();
        });
    }
}

function onBeatHit() {
    if (trainHandler != null && trainSpr != null)
        trainHandler("beat", trainSpr, curBeat);

    if (curBeat % 4 == 0) {
        curLight = FlxG.random.int(0, lightsColors.length - 1, [curLight]);
        window.color = lightsColors[curLight];
        window.alpha = 1;
    }
}

function onEventCalled(eventName:String, value1:String, value2:String, flValue1:Float, flValue2:Float, strumTime:Float) {
    if (eventName == "Philly Glow") {
        if (flValue1 == null || flValue1 <= 0) flValue1 = 0;
        var lightId:Int = Math.round(flValue1);

        var chars = [game.boyfriend, game.gf, game.dad];
        switch (lightId) {
            case 0:
                if (glowGradient != null && glowGradient.visible) {
                    doFlash();
                    if (ClientPrefs.data.camZooms) {
                        FlxG.camera.zoom += 0.5;
                        game.camHUD.zoom += 0.1;
                    }

                    lightsBlack.visible = false;
                    windowEvent.visible = false;
                    glowGradient.visible = false;
                    if (glowParticles != null) glowParticles.visible = false;
                    curLightEvent = -1;

                    for (who in chars)
                        if (who != null) who.color = FlxColor.WHITE;
                    street.color = FlxColor.WHITE;
                }
            case 1:
                curLightEvent = FlxG.random.int(0, lightsColors.length - 1, [curLightEvent]);
                var color:FlxColor = lightsColors[curLightEvent];

                if (glowGradient != null && !glowGradient.visible) {
                    doFlash();
                    if (ClientPrefs.data.camZooms) {
                        FlxG.camera.zoom += 0.5;
                        game.camHUD.zoom += 0.1;
                    }

                    lightsBlack.visible = true;
                    lightsBlack.alpha = 1;
                    windowEvent.visible = true;
                    glowGradient.visible = true;
                    if (glowParticles != null) glowParticles.visible = true;
                } else if (ClientPrefs.data.flashing) {
                    var colorButLower:Int = FlxColor.setAlphaFloat(color, 0.25);
                    FlxG.camera.flash(colorButLower, 0.5, null, true);
                }

                var charColor:FlxColor = color;
                var satMult:Float = (!ClientPrefs.data.flashing) ? 0.5 : 0.75;
                var curSat:Float = FlxColor.getSaturation(charColor);
                charColor = FlxColor.setSaturation(charColor, curSat * satMult);

                for (who in chars)
                    if (who != null) who.color = charColor;

                if (glowParticles != null) {
                    glowParticles.forEachAlive(function(particle:Sprite) {
                        particle.color = color;
                    });
                }
                if (glowGradient != null) glowGradient.color = color;
                windowEvent.color = color;

                var currentBright:Float = FlxColor.getBrightness(color);
                var streetColor:Int = FlxColor.setBrightness(color, currentBright * 0.5);
                street.color = streetColor;

            case 2:
                if (!ClientPrefs.data.lowQuality && particleHandler != null && glowParticles != null) {
                    var particlesNum:Int = FlxG.random.int(8, 12);
                    var width:Float = (2000 / particlesNum);
                    var color:FlxColor = lightsColors[curLightEvent];

                    for (j in 0...3) {
                        for (i in 0...particlesNum) {
                            var particle:Sprite = glowParticles.recycle(Sprite, function():Sprite {
                                return particleHandler("new");
                            });

                            particle.x = -400 + width * i + FlxG.random.float(-width / 5, width / 5);
                            particle.y = 225 + 200 + (FlxG.random.float(0, 125) + j * 40); // 225 = originalY do gradiente
                            particle.color = color;
                            
                            particleHandler("start", particle);
                            glowParticles.add(particle);
                        }
                    }
                }

                if (glowHandler != null && glowGradient != null)
                    glowHandler("bop", glowGradient);
        }
    }
}

function doFlash() {
    var color:FlxColor = FlxColor.WHITE;
    if (!ClientPrefs.data.flashing) color = FlxColor.setAlphaFloat(color, 0.5);
    FlxG.camera.flash(color, 0.15, null, true);
}