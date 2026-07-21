package states;

import openfl.Assets;
import flixel.util.FlxGradient;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxFrame;
import flixel.input.gamepad.FlxGamepad;
import shaders.ColorSwap;
import states.StoryMenuState;
import states.MainMenuState;

typedef LogoBeatData = {
    startScale:Float,
    beatScale:Float, // change this var to set how much the logo will bump
    scaleTarget:Float,
}

class TitleState extends MusicBeatState {
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
    public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
    public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
    public static var initialized:Bool = false;
    public static var closedState:Bool = false;
    
    /*var credGroup:FlxGroup = new FlxGroup();
        var textGroup:FlxGroup = new FlxGroup();
        var blackScreen:FlxSprite;
        var credTextShit:Alphabet;
        var ngSpr:FlxSprite;
        var gradDown:FlxSprite;
        var gradUp:FlxSprite;

        var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
        var titleTextAlphas:Array<Float> = [1, .64];
        var curWacky:Array<String> = [];

        var logoBeat:LogoBeatData = {
            startScale: 0.34,
            beatScale: 0.365,
            scaleTarget: 0.34,
        };

        // var startScale:Float = 0.34;
        // var beatScale:Float = 0.365; // change this var to set how much the logo will bump
        // var scaleTarget:Float = 0.34;

        /*override public function create():Void {
            Paths.clearStoredMemory();
            super.create();
            Paths.clearUnusedMemory();
            
            if (!initialized) {
                ClientPrefs.loadPrefs();
                Language.reloadPhrases();
            }
            curWacky = FlxG.random.getObject(getIntroTextShit());
            
            if (!initialized) {
                if (FlxG.save.data != null && FlxG.save.data.fullscreen)
                    FlxG.fullscreen = FlxG.save.data.fullscreen;
                persistentUpdate = true;
                persistentDraw = true;
            }
            
            if (FlxG.save.data.weekCompleted != null)
                StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
                
            FlxG.mouse.visible = false;
            #if FREEPLAY
            MusicBeatState.switchState(new FreeplayState());
            #elseif CHARTING
            MusicBeatState.switchState(new ChartingState());
            #else
            if (FlxG.save.data.flashing == null && !FlashingState.leftState) {
                FlxTransitionableState.skipNextTransIn = true;
                FlxTransitionableState.skipNextTransOut = true;
                MusicBeatState.switchState(new FlashingState());
            }
            else
                startIntro();
            #end
        }

        var logoBl:FlxSprite;
        var titleText:FlxSprite;
        var swagShader:ColorSwap = null;

        function startIntro() {
            persistentUpdate = true;
            if (!initialized && FlxG.sound.music == null)
                FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
            Conductor.bpm = 102;
            
            /*logoBl = new FlxSprite(logoPosition.x, logoPosition.y);
                logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
                logoBl.antialiasing = ClientPrefs.data.antialiasing;

                logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
                logoBl.animation.play('bump');
                logoBl.updateHitbox();

            }
            
            gradDown = FlxGradient.createGradientFlxSprite(1880, 256, [0xFFFFFFFF, 0x00FFFFFF], 3);
            gradDown.antialiasing = true;
            gradDown.color = 0xFF680000;
            gradDown.screenCenter(X);
            gradDown.y = FlxG.height - gradDown.height;
            gradDown.y += 30;
            gradDown.flipY = true;
            gradDown.alpha = 0.5;
            add(gradDown);
            
            gradUp = FlxGradient.createGradientFlxSprite(1880, 256, [0x00FFFFFF, 0xFFFFFFFF], 3);
            gradUp.antialiasing = true;
            gradUp.color = 0xFFFF0000;
            gradUp.y -= 30;
            gradUp.screenCenter(X);
            gradUp.flipY = true;
            gradUp.alpha = 0.3;
            add(gradUp);
            
            logoBl = new FlxSprite(250, 142);
            logoBl.loadGraphic(Paths.image("EngineLogo"));
            logoBl.scale.set(logoBeat.scaleTarget, logoBeat.scaleTarget);
            logoBl.centerOrigin();
            logoBl.screenCenter();
            logoBl.antialiasing = true;
            logoBl.updateHitbox();
            
            add(logoBl);
            
            if (ClientPrefs.data.shaders) {
                swagShader = new ColorSwap();
                logoBl.shader = swagShader.shader;
            }
            
            var animFrames:Array<FlxFrame> = [];
            titleText = new FlxSprite(enterPosition.x, enterPosition.y);
            titleText.frames = Paths.getSparrowAtlas('titleEnter');
            @:privateAccess {
                titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
                titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
            }
            
            if (newTitle = animFrames.length > 0) {
                titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
                titleText.animation.addByPrefix('press', ClientPrefs.data.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
            }
            else {
                titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
                titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
            }
            titleText.animation.play('idle');
            titleText.updateHitbox();
            
            blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
            blackScreen.scale.set(FlxG.width, FlxG.height);
            blackScreen.updateHitbox();
            credGroup.add(blackScreen);
            
            credTextShit = new Alphabet(0, 0, "", true);
            credTextShit.screenCenter();
            credTextShit.visible = false;
            
            ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
            ngSpr.visible = false;
            ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
            ngSpr.updateHitbox();
            ngSpr.screenCenter(X);
            ngSpr.antialiasing = ClientPrefs.data.antialiasing;
            
            add(titleText);
            add(credGroup);
            add(ngSpr);
            if (initialized)
                skipIntro();
            else
                initialized = true;
        }

        var enterPosition:FlxPoint = FlxPoint.get(110, 576);

        function getIntroTextShit():Array<Array<String>> {
            #if MODS_ALLOWED
            var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt');
            #else
            var fullText:String = Assets.getText(Paths.txt('introText'));
            var firstArray:Array<String> = fullText.split('\n');
            #end
            var swagGoodArray:Array<Array<String>> = [];
            for (i in firstArray)
                swagGoodArray.push(i.split('--'));
            return swagGoodArray;
        }

        var transitioning:Bool = false;
        var newTitle:Bool = false;
        var titleTimer:Float = 0;

        override function update(elapsed:Float) {
            if (FlxG.sound.music != null)
                Conductor.songPosition = FlxG.sound.music.time;
                
            logoBeat.scaleTarget = FlxMath.lerp(logoBeat.scaleTarget, logoBeat.startScale, 0.094);
            // logoBl.scale.set(logoBeat.scaleTarget, logoBeat.scaleTarget);
            
            var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
            #if mobile
            for (touch in FlxG.touches.list)
                if (touch.justPressed)
                    pressedEnter = true;
            #end
            
            var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
            if (gamepad != null) {
                if (gamepad.justPressed.START)
                    pressedEnter = true;
                #if switch
                if (gamepad.justPressed.B)
                    pressedEnter = true;
                #end
            }
            
            if (newTitle) {
                titleTimer += FlxMath.bound(elapsed, 0, 1);
                if (titleTimer > 2)
                    titleTimer -= 2;
            }
            
            if (initialized && !transitioning && skippedIntro) {
                if (newTitle && !pressedEnter) {
                    var timer:Float = titleTimer;
                    if (timer >= 1)
                        timer = (-timer) + 2;
                    timer = FlxEase.quadInOut(timer);
                    
                    titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
                    titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
                }
                
                if (pressedEnter) {
                    titleText.color = FlxColor.WHITE;
                    titleText.alpha = 1;
                    if (titleText != null)
                        titleText.animation.play('press');
                        
                    FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
                    FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
                    
                    transitioning = true;
                    new FlxTimer().start(1, function(tmr:FlxTimer) {
                        MusicBeatState.switchState(new MainMenuState());
                        closedState = true;
                    });
                }
            }
            
            if (initialized && pressedEnter && !skippedIntro)
                skipIntro();
                
            if (swagShader != null) {
                if (controls.UI_LEFT)
                    swagShader.hue -= elapsed * 0.1;
                if (controls.UI_RIGHT)
                    swagShader.hue += elapsed * 0.1;
            }
            super.update(elapsed);
        }

        function createCoolText(textArray:Array<String>, ?offset:Float = 0) {
            for (i in 0...textArray.length) {
                var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
                money.screenCenter(X);
                money.y += (i * 60) + 200 + offset;
                if (credGroup != null && textGroup != null) {
                    credGroup.add(money);
                    textGroup.add(money);
                }
            }
        }

        function addMoreText(text:String, ?offset:Float = 0) {
            if (textGroup != null && credGroup != null) {
                var coolText:Alphabet = new Alphabet(0, 0, text, true);
                coolText.screenCenter(X);
                coolText.y += (textGroup.length * 60) + 200 + offset;
                credGroup.add(coolText);
                textGroup.add(coolText);
            }
        }

        function deleteCoolText() {
            while (textGroup.members.length > 0) {
                credGroup.remove(textGroup.members[0], true);
                textGroup.remove(textGroup.members[0], true);
            }
        }

        private var sickBeats:Int = 0; // Basically curBeat but won't be skipped if you hold the tab or resize the screen

        public static var closedState:Bool = false;

        override function beatHit() {
            super.beatHit();
            
            if (logoBl != null)
                logoBeat.scaleTarget = logoBeat.beatScale;
                
            if (!closedState) {
                sickBeats++;
                switch (sickBeats) {
                    case 1:
                        FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
                        FlxG.sound.music.fadeIn(4, 0, 0.7);
                    case 2:
                        createCoolText(['NGs Engine by'], 40);
                    case 4:
                        addMoreText('NGS300', 40);
                        addMoreText('CloudyNimbus', 40);
                    case 5:
                        deleteCoolText();
                    case 6:
                        createCoolText(['Not associated', 'with'], -40);
                    case 8:
                        addMoreText('newgrounds', -40);
                        ngSpr.visible = true;
                    case 9:
                        deleteCoolText();
                        ngSpr.destroy();
                    case 10:
                        createCoolText([curWacky[0]]);
                    case 12:
                        addMoreText(curWacky[1]);
                    case 13:
                        deleteCoolText();
                    case 14:
                        addMoreText('Friday');
                    case 15:
                        addMoreText('Night');
                    case 16:
                        addMoreText('Funkin');
                    case 17:
                        skipIntro();
                }
            }
        }

        var skippedIntro:Bool = false;

        function skipIntro():Void {
            if (!skippedIntro) {
                remove(ngSpr);
                remove(credGroup);
                FlxG.camera.flash(FlxColor.WHITE, 4);
            }
            skippedIntro = true;
    }*/
    var textGroup:FlxGroup;
    var curShit:Array<String> = [];
    var blackScreen:FlxSprite;
    var titleText:FlxSprite;
    var logoSpr:FlxSprite;
    var gradDown:FlxSprite;
    var gradUp:FlxSprite;
    var logoNewgrounds:FlxSprite;
    
    var startScale:Float = 0.34;
    var beatScale:Float = 0.365; // change this var to set how much the logo will bump
    var scaleTarget:Float = 0.34;
    var lastBeat:Int = 0;
    
    private var sickBeats:Int = 0;
    
    var transitioning:Bool = false;
    var skippedIntro:Bool = false;
    
    override function create() {
        super.create();
        
        // Conductor.change(102);
        Conductor.bpm = 102;
        
        textGroup = new FlxGroup();
        
        persistentUpdate = true;
        
        if (!initialized && FlxG.sound.music == null) {
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
            FlxG.sound.music.fadeIn(4, 0, 0.7);
        }
        
        var path:String = 'menus/title/';
        
        add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK).screenCenter());
        gradDown = FlxGradient.createGradientFlxSprite(1880, 256, [0xFFFFFFFF, 0x00FFFFFF], 3);
        gradDown.antialiasing = true;
        gradDown.color = 0xFF680000;
        gradDown.screenCenter(X);
        gradDown.y = FlxG.height - gradDown.height;
        gradDown.y += 30;
        gradDown.flipY = true;
        gradDown.alpha = 0.5;
        add(gradDown);
        
        gradUp = FlxGradient.createGradientFlxSprite(1880, 256, [0x00FFFFFF, 0xFFFFFFFF], 3);
        gradUp.antialiasing = true;
        gradUp.color = 0xFFFF0000;
        gradUp.y -= 30;
        gradUp.screenCenter(X);
        gradUp.flipY = true;
        gradUp.alpha = 0.3;
        add(gradUp);
        
        logoSpr = new FlxSprite(250, 142);
        logoSpr.loadGraphic(Paths.image(path + 'EngineLogo'));
        logoSpr.scale.set(scaleTarget, scaleTarget);
        logoSpr.centerOrigin();
        logoSpr.screenCenter();
        logoSpr.antialiasing = true;
        logoSpr.updateHitbox();
        
        add(logoSpr);
        
        var animFrames:Array<FlxFrame> = [];
        titleText = new FlxSprite(122 + (flixel.math.FlxPoint.get().x / 2), 590);
        titleText.frames = Paths.getSparrowAtlas('titleEnter');
        @:privateAccess {
            titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
            titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
        }
        
        titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
        titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
        
        titleText.animation.play('idle');
        titleText.updateHitbox();
        add(titleText);
        
        logoNewgrounds = new FlxSprite();
        logoNewgrounds.loadGraphic(Paths.image("newgrounds_logo_animated"), true, 591, 591);
        logoNewgrounds.animation.add("idle", [0, 1], 8, true);
        logoNewgrounds.scale.set(startScale, startScale);
        logoNewgrounds.updateHitbox();
        logoNewgrounds.screenCenter();
        logoNewgrounds.y += 160;
        
        logoNewgrounds.visible = false;
        
        add(logoNewgrounds);
        
        curShit = FlxG.random.getObject(getIntroText());
        
        if (!initialized)
            add(textGroup);
            
        initialized ? skipIntro() : initialized = true;
    }
    
    override function update(elapsed:Float) {
        scaleTarget = FlxMath.lerp(scaleTarget, startScale, 0.094);
        logoSpr.scale.set(scaleTarget, scaleTarget);
        logoNewgrounds.scale.set(scaleTarget, scaleTarget);
        
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;
            
        var pressed:Bool = FlxG.keys.justPressed.ENTER;
        
        if (initialized && pressed) {
            if (!skippedIntro)
                skipIntro();
            else if (!transitioning) {
                FlxTween.cancelTweensOf(titleText);
                titleText.color = 0xFFFFFFFF;
                titleText?.animation.play('press');
                transitioning = true;
                FlxG.camera.flash(FlxColor.WHITE, 1);
                FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
                FlxTween.tween(logoSpr, {x: logoSpr.x + 1000}, 2.9, {
                    ease: FlxEase.backInOut,
                    type: PERSIST,
                    onStart: function(twn:FlxTween) {
                        FlxTween.tween(titleText, {y: titleText.y + 400}, 3, {
                            ease: FlxEase.backInOut,
                            type: PERSIST,
                        });
                    },
                    onComplete: (_) -> {
                        FlxG.switchState(new MainMenuState());
                        closedState = true;
                    }
                });
                FlxTween.tween(gradDown, {y: gradDown.y + 500}, 3.2, {
                    ease: FlxEase.quartInOut,
                    type: PERSIST,
                    onComplete: (_) -> gradDown.destroy()
                });
                FlxTween.tween(gradUp, {y: gradUp.y - 500}, 3.2, {
                    ease: FlxEase.quartInOut,
                    type: PERSIST,
                    onComplete: (_) -> gradUp.destroy()
                });
            }
        }
        super.update(elapsed);
    }
    
    override function beatHit() {
        scaleTarget = beatScale;
        
        if (skippedIntro)
            return;
            
        if (curBeat > lastBeat)
            for (b in lastBeat...curBeat)
                switch (++sickBeats) {
                    case 1:
                        introSet(['NGS Engine by'], 40);
                    case 3:
                        introPush('Hiro Sora', 50);
                        introPush('KiwiSky', 50);
                    case 4:
                        introClear();
                    case 5:
                        introSet(['Not associated', 'with'], -50);
                    case 7:
                        logoNewgrounds.visible = true;
                        logoNewgrounds.animation.play("idle");
                        introPush('Newgrounds', -50);
                    case 8:
                        introClear();
                        logoNewgrounds.kill(); // kill this mf
                    case 9:
                        introSet([curShit[0]]);
                    case 11:
                        introPush(curShit[1]);
                    case 12:
                        introClear();
                    case 13:
                        introPush('Friday');
                    case 14:
                        introPush('Night');
                    case 15:
                        introPush('Funkin');
                    case 16:
                        skipIntro();
                }
        lastBeat = curBeat;
    }
    
    inline function getIntroText():Array<Array<String>>
        return Assets.getText(Paths.txt('introText')).split('\n').map(line -> line.split('--'));
        
    inline function introClear():Void {
        while (textGroup.members.length > 0 && textGroup != null)
            textGroup.remove(textGroup.members[0], true);
    }
    
    inline function introPush(text:String, ?off = 0.0):Void {
        var a = new Alphabet(0, 20, text, true);
        a.screenCenter(X);
        a.y += (textGroup.length * 60) + 230 + off;
        textGroup.add(a);
    }
    
    inline function introSet(lines:Array<String>, ?off:Float):Void {
        introClear();
        for (l in lines)
            introPush(l, off);
    }
    
    private function skipIntro() {
        if (!skippedIntro) {
            introClear();
            logoNewgrounds.kill();
            FlxG.camera.flash(FlxColor.WHITE, initialized ? 1 : 4);
            remove(blackScreen);
            skippedIntro = true;
            logoSpr.screenCenter();
            FlxTween.angle(logoSpr, -6, 6, 2.5, {
                ease: FlxEase.quadInOut,
                type: PINGPONG,
            });
            FlxTween.color(gradDown, 2, 0xFFff0000, 0xFF680000, {
                ease: FlxEase.quadInOut,
                type: PINGPONG,
            });
            FlxTween.color(gradUp, 2, 0xFF680000, 0xFFff0000, {
                ease: FlxEase.quadInOut,
                type: PINGPONG,
            });
            FlxTween.color(titleText, 2, 0xFF33FFFF, 0xFF3333CC, {
                ease: FlxEase.linear,
                type: PINGPONG,
            });
        }
    }
}
