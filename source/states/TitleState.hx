package states;

import shaders.ColorSwap;
import flixel.group.FlxGroup;
import flixel.util.FlxGradient;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxFrame;
import flixel.input.gamepad.FlxGamepad;

typedef LogoScale = {
    var start:Float;
    var bump:Float;
    var target:Float;
}

class TitleState extends MusicBeatState {
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
    public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
    public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
    public static var initialized:Bool = false;
    public static var engineData = {
        name: "NGs Engine",
        version: "0.0.3"
    }
    
    var credGroup:FlxGroup = new FlxGroup();
    var textGroup:FlxGroup = new FlxGroup();
    var blackScreen:FlxSprite;
    var ngSpr:FlxSprite;
    
    var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
    var titleTextAlphas:Array<Float> = [1, .64];
    var curWacky:Array<String> = [];
    
    override public function create():Void {
        Paths.clearStoredMemory();
        super.create();
        Paths.clearUnusedMemory();
        
        if (!initialized) {
            ClientPrefs.loadSys();
            ClientPrefs.loadPrefs();
            Language.reloadPhrases();
        }
        curWacky = FlxG.random.getObject(getIntroTextShit());
        
        if (!initialized) {
            persistentUpdate = true;
            persistentDraw = true;
        }
        
        if (FlxG.save.data.weekCompleted != null)
            states.StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
            
        FlxG.mouse.visible = false;
        #if FREEPLAY
        MusicBeatState.switchState(new FreeplayState());
        #elseif CHARTING
        MusicBeatState.switchState(new ChartingState());
        #else
        if (ClientPrefs.data.flashing == null && !FlashingState.leftState) {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
            MusicBeatState.switchState(new FlashingState());
        }
        else
            startIntro();
        #end
    }
    
    var gradDown:FlxSprite;
    var gradUp:FlxSprite;
    var logoSpr:FlxSprite;
    var swagShader:ColorSwap = null;
    var scale:LogoScale = {
        start: 0.34,
        bump: 0.365,
        target: 0
    };
    var titleText:FlxSprite;
    
    function startIntro() {
        persistentUpdate = true;
        if (!initialized && FlxG.sound.music == null)
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
        Conductor.bpm = 102;
        
        gradDown = FlxGradient.createGradientFlxSprite(1880, 256, [0xFFFFFFFF, 0x00FFFFFF], 3);
        gradDown.antialiasing = ClientPrefs.data.antialiasing;
        gradDown.color = 0xFF680000;
        gradDown.screenCenter(X);
        gradDown.y = FlxG.height - gradDown.height;
        gradDown.y += 60;
        gradDown.flipY = true;
        gradDown.alpha = .5;
        add(gradDown);
        FlxTween.color(gradDown, 2, 0xFFff0000, 0xFF680000, {
            ease: FlxEase.quadInOut,
            type: PINGPONG,
        });
        
        gradUp = FlxGradient.createGradientFlxSprite(1880, 256, [0x00FFFFFF, 0xFFFFFFFF], 3);
        gradUp.antialiasing = ClientPrefs.data.antialiasing;
        gradUp.color = 0xFFFF0000;
        gradUp.y -= 60;
        gradUp.screenCenter(X);
        gradUp.flipY = true;
        gradUp.alpha = .3;
        add(gradUp);
        FlxTween.color(gradUp, 2, 0xFF680000, 0xFFff0000, {
            ease: FlxEase.quadInOut,
            type: PINGPONG,
        });
        
        var i = "titlemenu";
        logoSpr = new FlxSprite().loadGraphic(Paths.image('$i/logo'));
        logoSpr.scale.set(scale.start, scale.start);
        logoSpr.updateHitbox();
        logoSpr.centerOrigin();
        logoSpr.screenCenter();
        scale.target = scale.start;
        if (ClientPrefs.data.shaders) {
            swagShader = new ColorSwap();
            logoSpr.shader = swagShader.shader;
        }
        add(logoSpr);
        FlxTween.angle(logoSpr, -6, 6, 2.5, {
            ease: FlxEase.quadInOut,
            type: PINGPONG,
        });
        
        var animFrames:Array<FlxFrame> = [];
        #if mobile
        var isMobile = true;
        #else
        var isMobile = false;
        #end
        titleText = new FlxSprite((isMobile ? 60 : 122) + (flixel.math.FlxPoint.get().x / 2), 590);
        titleText.frames = Paths.getSparrowAtlas('$i/titleEnter' + (!isMobile ? '' : '_mobile'));
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
        add(titleText);
        
        blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        blackScreen.scale.set(FlxG.width, FlxG.height);
        blackScreen.updateHitbox();
        credGroup.add(blackScreen);
        
        if (FlxG.random.int(0, 100) < 10) {
            ngSpr = new FlxSprite();
            ngSpr.loadGraphic(Paths.image('$i/newgrounds_logo_animated'), true, 591, 591);
            ngSpr.animation.add("idle", [0, 1], 8, true);
            ngSpr.scale.set(scale.start, scale.start);
            ngSpr.updateHitbox();
            ngSpr.screenCenter();
            ngSpr.y += 160;
            ngSpr.antialiasing = ClientPrefs.data.antialiasing;
            ngSpr.animation.play("idle", true);
            ngSpr.visible = false;
        }
        else {
            ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('$i/newgrounds_logo'));
            ngSpr.visible = false;
            scale.start = 0.76;
            scale.bump = 0.80;
            ngSpr.scale.set(scale.start, scale.start);
            ngSpr.updateHitbox();
            ngSpr.screenCenter(X);
            ngSpr.antialiasing = ClientPrefs.data.antialiasing;
        }
        
        add(credGroup);
        add(ngSpr);
        initialized ? skipIntro() : initialized = true;
    }
    
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
            
        scale.target = FlxMath.lerp(scale.target, scale.start, 0.094);
        logoSpr.scale.set(scale.target, scale.target);
        ngSpr.scale.set(scale.target, scale.target);
        
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
        
        if (initialized) {
            if (!skippedIntro) {
                if (pressedEnter)
                    skipIntro();
            }
            else if (!transitioning) {
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
                    FlxTween.tween(logoSpr, {x: logoSpr.x + 1000}, 2.8, {
                        ease: FlxEase.backInOut,
                        type: PERSIST,
                        onStart: (_) -> {
                            FlxTween.tween(titleText, {y: titleText.y + 400}, 3, {
                                ease: FlxEase.backInOut,
                                type: PERSIST,
                            });
                        },
                        onComplete: (_) -> {
                            changeState(states.MainMenuState);
                            closedState = true;
                        }
                    });
                    FlxTween.tween(gradDown, {y: gradDown.y + 500}, 3.2, {
                        ease: FlxEase.quartInOut,
                        type: PERSIST
                    });
                    FlxTween.tween(gradUp, {y: gradUp.y - 500}, 3.2, {
                        ease: FlxEase.quartInOut,
                        type: PERSIST
                    });
                }
            }
        }
        
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
        scale.target = scale.bump;
        
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
                    ngSpr.visible = false;
                    
                    scale.start = 0.34;
                    scale.bump = 0.365;
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
            FlxG.camera.flash(FlxColor.WHITE, 2.5);
        }
        skippedIntro = true;
    }
}
