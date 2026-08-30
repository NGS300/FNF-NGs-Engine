var particleData:Dynamic = {};
var nextId:Int = 0;

function onCreate() {
    setVar("glowParticle", function(type:String, ?spr:Sprite, ?action:Dynamic):Dynamic {
        switch (type) {
            case "new":
                var particleSpr = new Sprite('stages/philly/particle');
                particleSpr.color = FlxColor.WHITE;
                particleSpr.antialiasing = ClientPrefs.data.antialiasing;

                particleSpr.ID = nextId;
                nextId++;

                return particleSpr;
            case "start":
                if (spr != null) {
                    var lifeTime:Float = FlxG.random.float(0.6, 0.9);
                    var decay:Float = FlxG.random.float(0.8, 1);

                    if (!ClientPrefs.data.flashing) {
                        decay *= 0.5;
                        spr.alpha = 0.5;
                    } else
                        spr.alpha = 1;

                    var originalScale:Float = FlxG.random.float(0.75, 1);
                    spr.scale.set(originalScale, originalScale);

                    spr.scrollFactor.set(FlxG.random.float(0.3, 0.75), FlxG.random.float(0.65, 0.75));
                    spr.velocity.set(FlxG.random.float(-40, 40), FlxG.random.float(-175, -250));
                    spr.acceleration.set(FlxG.random.float(-10, 10), 25);

                    var key:String = "p_" + spr.ID;
                    Reflect.setField(particleData, key, {
                        lifeTime: lifeTime,
                        decay: decay,
                        originalScale: originalScale
                    });
                }
            case "update":
                if (spr != null) {
                    var key:String = "p_" + spr.ID;
                    var data:Dynamic = Reflect.field(particleData, key);

                    if (data != null) {
                        var elapsed:Float = action;

                        data.lifeTime -= elapsed;
                        if (data.lifeTime < 0) {
                            data.lifeTime = 0;
                            spr.alpha -= data.decay * elapsed;
                            if (spr.alpha > 0) {
                                var scaleVal:Float = data.originalScale * spr.alpha;
                                spr.scale.set(scaleVal, scaleVal);
                            }
                        }
                    }
                }
        }
        return null;
    });
}