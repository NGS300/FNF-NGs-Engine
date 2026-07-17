package states;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

enum MainMenuColumn {
    LEFT;
    RIGHT_UP;
    RIGHT_DOWN;
}

class MainMenuState extends MusicBeatState {
    public static var engineVersion:String = '0.1.0'; // This is also used for Discord RPC
    public static var curSelected:Int = 0;
    public static var curColumn:MainMenuColumn = LEFT;
    var allowMouse:Bool = true;

    var menuItems:FlxTypedGroup<FlxSprite>;
    var rightUpItem:FlxSprite;
    var rightDownItem:FlxSprite;
    var bg:FlxSprite;
    var intendedColor:Int;
	var bgFlicker:FlxSprite;
    var camFollow:FlxObject;
    var NORMAL_X:Int = 625;
    
    var optionShit = [
        { name: "story_mode", color: "FFD84C" },
        { name: "freeplay", color: "4CDFFF" },
        #if MODS_ALLOWED { name: "mods", color: "FF9F4A" }, #end
        { name: "credits", color: "FF6BD6" }
    ];

    var rightUpOption = #if ACHIEVEMENTS_ALLOWED { name: 'achievements', color: '8B52FF' } #else null #end;
    var rightDownOption = { name: "options", color: "6CFF8D" };

    static var showOutdatedWarning:Bool = true;
    override function create() {
        super.create();

        #if MODS_ALLOWED
        Mods.pushGlobalMods();
        #end
        Mods.loadTopMod();

        #if DISCORD_ALLOWED
        // Updating Discord Rich Presence
        DiscordClient.changePresence("In the Main menu", null);
        #end

        persistentUpdate = persistentDraw = true;

        var yScroll:Float = 0.25;
        bg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.scrollFactor.set(0, yScroll);
        bg.setGraphicSize(Std.int(bg.width * 1.175));
        bg.updateHitbox();
        bg.screenCenter();
        add(bg);

        camFollow = new FlxObject(0, 0, 1, 1);
        add(camFollow);

        bgFlicker = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
        bgFlicker.antialiasing = ClientPrefs.data.antialiasing;
        bgFlicker.scrollFactor.set(0, yScroll);
        bgFlicker.setGraphicSize(Std.int(bgFlicker.width * 1.175));
        bgFlicker.updateHitbox();
        bgFlicker.screenCenter();
        bgFlicker.visible = false;
        bgFlicker.color = 0xFFFFFFFF; // 0xFFfd719b
        add(bgFlicker);

        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);

        for (num => option in optionShit) {
            var item:FlxSprite = createMenuItem(option.name, (FlxG.width / 2) - NORMAL_X, (num * 140) + 90);
            item.y += (4 - optionShit.length) * 70;
        }

        if (rightUpOption != null) {
            rightUpItem = createMenuItem(rightUpOption.name, FlxG.width - 45, 45);
            rightUpItem.x -= rightUpItem.width;
        }

        if (rightDownOption != null) {
            rightDownItem = createMenuItem(rightDownOption.name, FlxG.width - 35, 510);
            rightDownItem.x -= rightDownItem.width;
        }

        var engineVer:FlxText = new FlxText(2, FlxG.height - 42, 0, "NGs Engine v" + engineVersion, 16);
        engineVer.scrollFactor.set();
        engineVer.setFormat(Paths.font("fredoka_One.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(engineVer);
        var fnfVer:FlxText = new FlxText(2, FlxG.height - 22, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 16);
        fnfVer.scrollFactor.set();
        fnfVer.setFormat(Paths.font("fredoka_One.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(fnfVer);
        changeItem();

        #if ACHIEVEMENTS_ALLOWED
        // Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
        var leDate = Date.now();
        if (leDate.getDay() == 5 && leDate.getHours() >= 18)
            Achievements.unlock('friday_night_play');

        #if MODS_ALLOWED
        Achievements.reloadList();
        #end
        #end

        #if CHECK_FOR_UPDATES
        if (showOutdatedWarning && ClientPrefs.data.checkForUpdates && substates.OutdatedSubState.updateVersion != engineVersion) {
            persistentUpdate = false;
            showOutdatedWarning = false;
            openSubState(new substates.OutdatedSubState());
        }
        #end
        FlxG.camera.follow(camFollow, null, 0.15);
    }

    function createMenuItem(name:String, x:Float, y:Float):FlxSprite {
        var menuItem:FlxSprite = new FlxSprite(x, y);
        menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_$name');
        menuItem.animation.addByPrefix('idle', '$name idle', 24, true);
        menuItem.animation.addByPrefix('selected', '$name selected', 24, true);
        menuItem.animation.play('idle');
        menuItem.updateHitbox();
        
        menuItem.antialiasing = ClientPrefs.data.antialiasing;
        menuItem.scrollFactor.set();
        menuItems.add(menuItem);
        return menuItem;
    }

    var selectedSomethin:Bool = false;
    var timeNotMoving:Float = 0;
    override function update(elapsed:Float) {
        if (FlxG.sound.music.volume < 0.8)
            FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

        if (!selectedSomethin) {
            if (curColumn == LEFT) {
                if (controls.UI_UP_P)
                    changeItem(-1);
                else if (controls.UI_DOWN_P)
                    changeItem(1);
            } else {
                if (controls.UI_UP_P && rightUpOption != null) {
                    curColumn = RIGHT_UP;
                    changeItem();
                } else if (controls.UI_DOWN_P && rightDownOption != null) {
                    curColumn = RIGHT_DOWN;
                    changeItem();
                }
            }

            var allowMouse:Bool = allowMouse;
            if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) {
                allowMouse = false;
                FlxG.mouse.visible = true;
                timeNotMoving = 0;

                var selectedItem:FlxSprite;
                switch (curColumn) {
                    case LEFT: selectedItem = menuItems.members[curSelected];
                    case RIGHT_UP: selectedItem = rightUpItem;
                    case RIGHT_DOWN: selectedItem = rightDownItem;
                }

                if (rightUpItem != null && FlxG.mouse.overlaps(rightUpItem)) {
                    allowMouse = true;
                    if (selectedItem != rightUpItem) {
                        curColumn = RIGHT_UP;
                        changeItem();
                    }
                } else if (rightDownItem != null && FlxG.mouse.overlaps(rightDownItem)) {
                    allowMouse = true;
                    if (selectedItem != rightDownItem) {
                        curColumn = RIGHT_DOWN;
                        changeItem();
                    }
                } else {
                    var dist:Float = -1;
                    var distItem:Int = -1;
                    for (i in 0...optionShit.length) {
                        var memb:FlxSprite = menuItems.members[i];
                        if (FlxG.mouse.overlaps(memb)) {
                            var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
                            if (dist < 0 || distance < dist) {
                                dist = distance;
                                distItem = i;
                                allowMouse = true;
                            }
                        }
                    }

                    if (distItem != -1 && selectedItem != menuItems.members[distItem]) {
                        curColumn = LEFT;
                        curSelected = distItem;
                        changeItem();
                    }
                }
            } else {
                timeNotMoving += elapsed;
                if (timeNotMoving > 1.5) FlxG.mouse.visible = false;
            }

            switch (curColumn) {
                case LEFT:
                    if (controls.UI_RIGHT_P && rightDownOption != null) {
                        curColumn = RIGHT_DOWN;
                        changeItem();
                    }

                case RIGHT_UP, RIGHT_DOWN:
                    if (controls.UI_LEFT_P) {
                        curColumn = LEFT;
                        changeItem();
                    }
            }

            if (controls.BACK) {
                selectedSomethin = true;
                FlxG.mouse.visible = false;
                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new TitleState());
            }

            if (controls.ACCEPT || (FlxG.mouse.justPressed && allowMouse)) {
                FlxG.sound.play(Paths.sound('confirmMenu'));
                selectedSomethin = true;
                FlxG.mouse.visible = false;

                if (ClientPrefs.data.flashing)
                    FlxFlicker.flicker(bgFlicker, 1.1, 0.15, false);

                var item:FlxSprite;
                var option:String;
                switch (curColumn) {
                    case LEFT:
                        option = optionShit[curSelected].name;
                        item = menuItems.members[curSelected];

                    case RIGHT_UP:
                        option = rightUpOption.name;
                        item = rightUpItem;

                    case RIGHT_DOWN:
                        option = rightDownOption.name;
                        item = rightDownItem;
                }

                FlxFlicker.flicker(item, 1, 0.06, false, false, function(flick:FlxFlicker) {
                    switch (option) {
                        case 'story_mode': MusicBeatState.switchState(new StoryMenuState());
                        case 'freeplay': MusicBeatState.switchState(new FreeplayState());

                        #if MODS_ALLOWED
                        case 'mods': MusicBeatState.switchState(new ModsMenuState());
                        #end

                        #if ACHIEVEMENTS_ALLOWED
                        case 'achievements': MusicBeatState.switchState(new AchievementsMenuState());
                        #end

                        case 'credits': MusicBeatState.switchState(new CreditsState());
                        case 'options':
                            MusicBeatState.switchState(new OptionsState());
                            OptionsState.onPlayState = false;
                            if (PlayState.SONG != null) {
                                PlayState.SONG.arrowSkin = null;
                                PlayState.SONG.splashSkin = null;
                                PlayState.stageUI = 'normal';
                            }
                        case 'donate':
                            CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
                            selectedSomethin = false;
                            item.visible = true;
                        default:
                            trace('Menu Item ${option} doesn\'t do anything');
                            selectedSomethin = false;
                            item.visible = true;
                    }
                });
                
                for (memb in menuItems) {
                    if (memb == item) continue;
                    FlxTween.tween(memb, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
                }
            }
            #if desktop
            if (controls.justPressed('debug_1')) {
                selectedSomethin = true;
                FlxG.mouse.visible = false;
                MusicBeatState.switchState(new MasterEditorMenu());
            }
            #end
        }
        super.update(elapsed);
    }

    function changeItem(change:Int = 0) {
        if (change != 0) curColumn = LEFT;
        curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
        FlxG.sound.play(Paths.sound('scrollMenu'));

        final SELECTED_X = NORMAL_X - 90;
        for (i in 0...menuItems.length) {
            var item = menuItems.members[i];
            item.animation.play('idle');
            item.centerOffsets();
            
            if (i < optionShit.length)
                item.x = (FlxG.width / 2) - NORMAL_X;
        }

        var selectedItem:FlxSprite;
        switch (curColumn) {
            case LEFT: selectedItem = menuItems.members[curSelected];
            case RIGHT_UP: selectedItem = rightUpItem;
            case RIGHT_DOWN: selectedItem = rightDownItem;
        }
        selectedItem.animation.play('selected');
        selectedItem.centerOffsets();

        if (curColumn == LEFT) {
            var moreX:Float;
            switch (optionShit[curSelected].name) {
                case 'freeplay': moreX = 16;
                case 'mods': moreX = 68;
                case 'credits': moreX = 2;
                default: moreX = 0;
            }
            selectedItem.x = (FlxG.width / 2) - (SELECTED_X + moreX);
        }
        camFollow.y = selectedItem.getGraphicMidpoint().y;
        
        var targetColor:String = "FFFFFF";
        switch(curColumn) {
            case LEFT:  targetColor = optionShit[curSelected].color;
            case RIGHT_UP: if (rightUpOption != null) targetColor = rightUpOption.color;
            case RIGHT_DOWN: if (rightDownOption != null) targetColor = rightDownOption.color;
        }

        var newColor:Int = (0xFF << 24) | Std.parseInt("0x" + targetColor);
        if (newColor != intendedColor) {
            intendedColor = newColor;
            FlxTween.cancelTweensOf(bg);
            FlxTween.color(bg, 0.5, bg.color, intendedColor);
        }
    }
}