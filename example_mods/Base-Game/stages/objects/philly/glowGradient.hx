
var gradient = {
    y: 225.0, // originalY
    height: 400, // originalHeight
    alpha: 1.0 // intendedAlpha
}

function onCreate() {
    setVar("glowGradient", function(type:String, ?spr:Sprite, ?action:Dynamic):Dynamic {
        switch (type) {
            case "new":
                var particleSpr = new Sprite('stages/philly/gradient', null, -400, gradient.y, 0, 0.75);
                particleSpr.setGraphicSize(2000, gradient.height);
                particleSpr.updateHitbox();
                particleSpr.antialiasing = ClientPrefs.data.antialiasing;
                return particleSpr;
            case "setAlpha":
                if (action != null)
                    gradient.alpha = action;
            case "bop":
                if (spr != null) {
                    spr.setGraphicSize(2000, gradient.height);
                    spr.updateHitbox();
                    spr.y = gradient.y;
                    spr.alpha = gradient.alpha;
                }
            case "update":
                if (spr != null) {
                    var elapsed:Float = action;
                    var newHeight:Int = Math.round(spr.height - 1000 * elapsed);
                    if (newHeight > 0) {
                        spr.alpha = gradient.alpha;
                        spr.setGraphicSize(2000, newHeight);
                        spr.updateHitbox();
                        spr.y = gradient.y + (gradient.height - spr.height);
                    } else {
                        spr.alpha = 0;
                        spr.y = -5000;
                    }
                }
        }
        return null;
    });
}