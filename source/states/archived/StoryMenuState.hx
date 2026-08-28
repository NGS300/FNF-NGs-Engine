package states;

import objects.StoryModeMenuItem;
import flixel.addons.display.FlxBackdrop;
import backend.WeekData;
import backend.Highscore;
import backend.Song;
import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;
import objects.MenuItem;
import objects.MenuCharacter;
import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;
import backend.StageData;

class StoryMenuStateOld extends MusicBeatState {
    public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
    
    var scoreText:FlxText;
    
    private static var lastDifficultyName:String = '';
    
    var curDifficulty:Int = 1;
    
    var txtWeekTitle:FlxText;
    var bgSprite:FlxSprite;
    
    private static var curWeek:Int = 0;
    
    var txtTracklist:FlxText;
    
    var grpWeekText:FlxTypedGroup<StoryModeMenuItem>;
    var grpDifficulties:FlxTypedGroup<StoryModeMenuItem>;
    
    var grpLocks:FlxTypedGroup<FlxSprite>;
    
    var difficultySelectors:FlxGroup;
    var sprDifficulty:FlxSprite;
    var leftArrow:FlxSprite;
    var rightArrow:FlxSprite;
    
    var loadedWeeks:Array<WeekData> = [];
    
    // =======================
    var tiledBG:FlxBackdrop;
    
    var diffGraphics:Array<FlxGraphic> = [];
    
    var blackCut:FlxSprite;
    var leftBlue:FlxSprite;
    var rightPink:FlxSprite;
    
    var lockAngle:Float = 0;
    var lockSize:Float = 1;
    
    var curMode:Int = 0;
    var allowedModes:Array<String> = ["weeks", "diffs"];
    var modeSelectorSprites:Map<String, FlxSprite>;
    
    override function create() {
        Paths.clearStoredMemory();
        Paths.clearUnusedMemory();
        
        persistentUpdate = persistentDraw = true;
        PlayState.isStoryMode = true;
        WeekData.reloadWeekFiles(true);
        
        modeSelectorSprites = new Map<String, FlxSprite>();
        
        #if DISCORD_ALLOWED
        // Updating Discord Rich Presence
        DiscordClient.changePresence("In the Storymode menu", null);
        #end
        
        if (WeekData.weeksList.length < 1) {
            FlxTransitionableState.skipNextTransIn = true;
            persistentUpdate = false;
            MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR STORY MODE\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
                function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
                function() MusicBeatState.switchState(new states.MainMenuState())));
            return;
        }
        
        if (curWeek >= WeekData.weeksList.length)
            curWeek = 0;
            
        scoreText = new FlxText(10, 10, 0, Language.getPhrase('week_score', 'WEEK SCORE: {1}', [lerpScore]), 36);
        scoreText.setFormat(Paths.font("vcr.ttf"), 32);
        
        txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
        txtWeekTitle.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
        txtWeekTitle.alpha = 0.7;
        
        WeekData.setDirectoryFromWeek(loadedWeeks[0]);
        
        var path = 'storymenu/';
        
        tiledBG = new FlxBackdrop(Paths.image(path + "storybg"));
        tiledBG.setGraphicSize(FlxG.width, FlxG.height);
        add(tiledBG);
        
        blackCut = new FlxSprite();
        blackCut.loadGraphic(Paths.image(path + "story_bg_overlay"));
        
        leftBlue = new FlxSprite();
        leftBlue.loadGraphic(Paths.image(path + "bg_selection_left"));
        leftBlue.visible = false;
        modeSelectorSprites.set("weeks", leftBlue);
        
        rightPink = new FlxSprite();
        rightPink.loadGraphic(Paths.image(path + "bg_selection_right"));
        rightPink.visible = false;
        modeSelectorSprites.set("diffs", rightPink);
        
        add(leftBlue);
        add(rightPink);
        add(blackCut);
        
        grpWeekText = new FlxTypedGroup<StoryModeMenuItem>();
        add(grpWeekText);
        
        grpDifficulties = new FlxTypedGroup<StoryModeMenuItem>();
        add(grpDifficulties);
        
        grpLocks = new FlxTypedGroup<FlxSprite>();
        add(grpLocks);
        
        var num:Int = 0;
        // var itemTargetY:Float = 0;
        for (i in 0...WeekData.weeksList.length) {
            var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
            var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
            if (!isLocked || !weekFile.hiddenUntilUnlocked) {
                loadedWeeks.push(weekFile);
                WeekData.setDirectoryFromWeek(weekFile);
                
                var weekThing:StoryModeMenuItem = new StoryModeMenuItem(150, 200, WeekData.weeksList[i]);
                weekThing.pathAngle = 119.7;
                weekThing.startX = 80;
                weekThing.startY = 230;
                weekThing.spacing = 150;
                weekThing.y += ((weekThing.height + weekThing.paddingY) * i);
                weekThing.alphaMultiplier = 0.23;
                weekThing.targetY = i;
                grpWeekText.add(weekThing);
                
                var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
                lock.loadGraphic(Paths.image(path + "lock_new"));
                lock.antialiasing = ClientPrefs.data.antialiasing;
                lock.ID = i;
                lock.visible = weekIsLocked(weekFile.fileName);
                grpLocks.add(lock);
                
                num++;
            }
        }
        
        Difficulty.resetList();
        if (lastDifficultyName == '')
            lastDifficultyName = Difficulty.getDefault();
        curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
        
        changeWeek();
        // changeDifficulty();
        changeDiff();
        
        switchMode();
        
        super.create();
    }
    
    override function closeSubState() {
        persistentUpdate = true;
        changeWeek();
        super.closeSubState();
    }
    
    function switchMode(mode:Int = 0) {
        curMode = FlxMath.wrap(curMode + mode, 0, allowedModes.length - 1);
        
        for (mode => sprites in modeSelectorSprites)
            sprites.visible = false;
            
        modeSelectorSprites[allowedModes[curMode]].visible = true;
        FlxG.sound.play(Paths.sound("scrollMenu"));
    }
    
    function reloadDifficulties():Void {
        WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);
        Difficulty.loadFromWeek();
        grpDifficulties.clear();
        
        for (idx in 0...Difficulty.list.length) {
            var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(Difficulty.list[idx]));
            
            final diffSprite:StoryModeMenuItem = new StoryModeMenuItem(FlxG.width * 2, 600, "");
            diffSprite.antialiasing = ClientPrefs.data.antialiasing;
            diffSprite.pathAngle = 119.7;
            diffSprite.spacing = 150;
            diffSprite.y += ((diffSprite.height + diffSprite.paddingY) * idx);
            diffSprite.alphaMultiplier = 0.23;
            diffSprite.targetY = idx;
            if (diffSprite.graphic != newImage)
                diffSprite.loadGraphic(newImage);
            grpDifficulties.add(diffSprite);
        }
    }
    
    function changeDiff(change:Int = 0):Void {
        reloadDifficulties();
        curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.defaultList.length - 1);
        
        var idx:Int = 0;
        for (item in grpDifficulties.members) {
            if (item != null)
                item.targetY = idx - curDifficulty;
            idx++;
        }
        FlxG.sound.play(Paths.sound("scrollMenu"));
    }
    
    override function update(elapsed:Float) {
        tiledBG.x -= 20 * elapsed;
        
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;
            
        if (WeekData.weeksList.length < 1) {
            if (controls.BACK && !movedBack && !selectedWeek) {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                movedBack = true;
                MusicBeatState.switchState(new MainMenuState());
            }
            super.update(elapsed);
            return;
        }
        
        if (intendedScore != lerpScore) {
            lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
            if (Math.abs(intendedScore - lerpScore) < 10)
                lerpScore = intendedScore;
            scoreText.text = Language.getPhrase('week_score', 'WEEK SCORE: {1}', [lerpScore]);
        }
        
        if (!movedBack && !selectedWeek) {
            var changeDiff = false;
            
            if (FlxG.mouse.wheel != 0) {
                FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
                changeWeek(-FlxG.mouse.wheel);
                // changeDifficulty();
            }
            
            var mode = allowedModes[curMode];
            var dir = controls.UI_UP_P ? -1 : controls.UI_DOWN_P ? 1 : 0;
            if (dir != 0)
                switch (mode) {
                    case "weeks":
                        changeWeek(dir);
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                        changeDiff = true;
                    case "diffs":
                        if (changeDiff)
                            // changeDifficulty();
                            reloadDifficulties();
                        else
                            reloadDifficulties();
                        // changeDifficulty(dir);
                }
                
            if (controls.UI_RIGHT_P)
                switchMode(-1);
            else if (controls.UI_LEFT_P)
                switchMode(1);
                
            if (FlxG.keys.justPressed.CONTROL) {
                persistentUpdate = false;
                openSubState(new GameplayChangersSubstate());
            }
            else if (controls.RESET) {
                persistentUpdate = false;
                openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
            }
            else if (controls.ACCEPT)
                selectWeek();
        }
        
        if (controls.BACK && !movedBack && !selectedWeek) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            movedBack = true;
            MusicBeatState.switchState(new MainMenuState());
        }
        
        super.update(elapsed);
        /*var offY:Float = grpWeekText.members[curWeek].targetY;
            for (num => item in grpWeekText.members)
                item.y = FlxMath.lerp(item.targetY - offY + 480, item.y, Math.exp(-elapsed * 10.2)); */
        
        for (i in 0...grpLocks.members.length) {
            var lock:FlxSprite = grpLocks.members[i];
            var item:StoryModeMenuItem = grpWeekText.members[lock.ID];
            lock.x = item.x + item.width + 10;
            lock.y = item.y;
            lock.alpha = item.alpha;
            lockSize = FlxMath.lerp(lockSize, 1.2, 0.1);
            lock.scale.set(lockSize, lockSize);
            lock.angle = FlxMath.lerp(lock.angle, lockAngle, 0.075);
        }
        // lock.y = grpWeekText.members[lock.ID].y + grpWeekText.members[lock.ID].height / 2 - lock.height / 2;
    }
    
    var movedBack:Bool = false;
    var selectedWeek:Bool = false;
    var stopspamming:Bool = false;
    
    function selectWeek() {
        if (!weekIsLocked(loadedWeeks[curWeek].fileName)) {
            var songArray:Array<String> = [];
            var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
            for (i in 0...leWeek.length)
                songArray.push(leWeek[i][0]);
                
            try {
                PlayState.storyPlaylist = songArray;
                PlayState.isStoryMode = true;
                selectedWeek = true;
                
                var diffic = Difficulty.getFilePath(curDifficulty);
                if (diffic == null)
                    diffic = '';
                    
                PlayState.storyDifficulty = curDifficulty;
                
                Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
                PlayState.campaignScore = 0;
                PlayState.campaignMisses = 0;
            }
            catch (e:Dynamic) {
                trace('ERROR! $e');
                return;
            }
            
            if (stopspamming == false) {
                FlxG.sound.play(Paths.sound('confirmMenu'));
                grpWeekText.members[curWeek].isFlashing = true;
                /*for (char in grpWeekCharacters.members) {
                    if (char.character != '' && char.hasConfirmAnimation)
                        char.animation.play('confirm');
                }*/
                stopspamming = true;
            }
            
            var directory = StageData.forceNextDirectory;
            LoadingState.loadNextDirectory();
            StageData.forceNextDirectory = directory;
            @:privateAccess
            if (PlayState._lastLoadedModDirectory != Mods.currentModDirectory) {
                trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
                Paths.freeGraphicsFromMemory();
            }
            LoadingState.prepareToSong();
            new FlxTimer().start(1, function(tmr:FlxTimer) {
                #if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
                LoadingState.loadAndSwitchState(new PlayState(), true);
                FreeplayState.destroyFreeplayVocals();
            });
            
            #if (MODS_ALLOWED && DISCORD_ALLOWED)
            DiscordClient.loadModRPC();
            #end
        }
        else
            FlxG.sound.play(Paths.sound('cancelMenu'));
    }
    
    function changeDifficulty(change:Int = 0):Void {
        curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length - 1);
        
        WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);
        
        var diff:String = Difficulty.getString(curDifficulty, false);
        var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
        
        grpDifficulties.clear();
        for (idx in 0...Difficulty.defaultList.length) {
            // var item:StoryModeMenuItem = createDifficultyItem(idx, newImage);
        }
        
        lastDifficultyName = diff;
        
        #if !switch
        intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
        #end
    }
    
    var lerpScore:Int = 49324858;
    var intendedScore:Int = 0;
    
    function changeWeek(change:Int = 0):Void {
        curWeek = FlxMath.wrap(curWeek + change, 0, loadedWeeks.length - 1);
        
        var leWeek:WeekData = loadedWeeks[curWeek];
        WeekData.setDirectoryFromWeek(leWeek);
        
        grpWeekText.members[curWeek].disabled = weekIsLocked(leWeek.fileName);
        
        var index:Int = 0;
        for (item in grpWeekText.members) {
            if (item != null)
                item.targetY = index - curWeek;
            index++;
        }
        PlayState.storyWeek = curWeek;
        
        Difficulty.loadFromWeek();
        
        if (Difficulty.list.contains(Difficulty.getDefault()))
            curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
        else
            curDifficulty = 0;
            
        var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
        if (newPos > -1)
            curDifficulty = newPos;
        updateText();
    }
    
    function weekIsLocked(name:String):Bool {
        var leWeek:WeekData = WeekData.weeksLoaded.get(name);
        return (!leWeek.startUnlocked
            && leWeek.weekBefore.length > 0
            && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
    }
    
    function updateText() {
        var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
        
        var leWeek:WeekData = loadedWeeks[curWeek];
        var stringThing:Array<String> = [];
        for (i in 0...leWeek.songs.length)
            stringThing.push(leWeek.songs[i][0]);
            
        #if !switch
        intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
        #end
    }
    
    override function beatHit() {
        super.beatHit();
        
        var even:Bool = curBeat % 2 == 0;
        lockAngle = even ? 12 : -12;
        lockSize = even ? 1.6 : 1.5;
    }
}
