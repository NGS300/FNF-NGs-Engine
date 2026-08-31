var sound:FlxSound;

var trainTimer = {
    timing: 0,
    wagons: 8,
    cooldown: 0
}

var trainAction = {
    startedMoving: false,
    isMoving: false,
    isFinishing: false
}

function onCreate() {
    var trainFunc:Dynamic = null;
    trainFunc = function(type:String, ?spr:Sprite, ?action:Dynamic):Dynamic {
        switch (type) {
            case "new":
                precacheImage('stages/philly/train');
                var trainSpr = new Sprite('stages/philly/train', null, 2000, 360);
                trainSpr.active = true;
                trainSpr.antialiasing = ClientPrefs.data.antialiasing;

                sound = new FlxSound().loadEmbedded(Paths.sound("philly/train_passes"));
                FlxG.sound.list.add(sound);

                return trainSpr;
            case "start":
                trainAction.isMoving = true;
                if (sound != null && !sound.playing)
                    sound.play(true);
            case "restart":
                if (game.gf != null) {
                    game.gf.danced = false;
                    game.gf.playAnim("hairFall");
                    game.gf.specialAnim = true;
                }
                if (spr != null)
                    spr.x = FlxG.width + 200;

                trainAction.isMoving = false;
                trainTimer.wagons = 8;
                trainAction.isFinishing = false;
                trainAction.startedMoving = false;
            case "beat":
                if (!trainAction.isMoving)
                    trainTimer.cooldown += 1;

                if (action % 8 == 4 && FlxG.random.bool(30) && !trainAction.isMoving && trainTimer.cooldown > 8) {
                    trainTimer.cooldown = FlxG.random.int(-4, 0);
                    trainFunc("start", spr);
                }
            case "update":
                if (trainAction.isMoving && spr != null) {
                    trainTimer.timing += action;
                    if (trainTimer.timing >= 1 / 24) {
                        if (sound != null && sound.time >= 4700) {
                            trainAction.startedMoving = true;
                            if (game.gf != null) {
                                game.gf.playAnim("hairBlow");
                                game.gf.specialAnim = true;
                            }
                        }
                    
                        if (trainAction.startedMoving) {
                            spr.x -= 400;
                            if (spr.x < -2000 && !trainAction.isFinishing) {
                                spr.x = -1150;
                                trainTimer.wagons -= 1;

                                if (trainTimer.wagons <= 0)
                                    trainAction.isFinishing = true;
                            }

                            if (spr.x < -4000 && trainAction.isFinishing)
                                trainFunc("restart", spr);
                        }
                        trainTimer.timing = 0;
                    }
                }
        }
        return null;
    };
    setVar("train", trainFunc);
}