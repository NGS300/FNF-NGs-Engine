function onCreate() {
    setVar("fog", function(type:String, ?action:Dynamic):Dynamic {
        switch (type) {
            case "new":
                var fog = new FlxSpriteGroup();
                fog.alpha = 0;
                fog.blend = "add";

                var offset = { x: 200, y: 660 };
                var path = "stages/stage/smoke";

                var smoke1 = new Sprite(path, null, -1550 + offset.x, offset.y + FlxG.random.float(-20, 20), 1.2, 1.05);
                smoke1.setGraphicSize(Std.int(smoke1.width * FlxG.random.float(1.1, 1.22)));
                smoke1.updateHitbox();
                smoke1.velocity.x = FlxG.random.float(15, 22);
                smoke1.active = true;
                fog.add(smoke1);

                var smoke2 = new Sprite(path, null, 1550 + offset.x, offset.y + FlxG.random.float(-20, 20), 1.2, 1.05);
                smoke2.setGraphicSize(Std.int(smoke2.width * FlxG.random.float(1.1, 1.22)));
                smoke2.updateHitbox();
                smoke2.velocity.x = FlxG.random.float(-15, -22);
                smoke2.active = true;
                smoke2.flipX = true;
                fog.add(smoke2);

                return fog;
        }
        return null;
    });
}