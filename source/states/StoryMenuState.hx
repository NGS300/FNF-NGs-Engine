package states;

import backend.Highscore;
import objects.StoryModeMenuShape;
import backend.StageData;
import backend.Song;
import substates.ResetScoreSubState;
import options.GameplayChangersSubstate;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxBackdrop;
import objects.StoryModeMenuItem;
import backend.WeekData;

class StoryMenuState extends MusicBeatState {
    public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
    private static var lastDifficultyName:String = '';
    private static var curWeek:Int = 0;
    
    var curDifficulty:Int = 1;
    var loadedWeeks:Array<WeekData> = [];
    var grpWeekText:FlxTypedGroup<StoryModeMenuItem>;
    var grpDifficulties:FlxTypedGroup<StoryModeMenuItem>;
    
    var grpLocks:FlxTypedGroup<FlxSprite>;
    
    var tiledBG:FlxBackdrop;
    
    var blackCut:FlxSprite;
    var blackCutWhiteBorder:FlxSprite;
    var leftBlue:FlxSprite;
    var rightPink:FlxSprite;
    var textWeekName:FlxText;
    var textWeekScore:FlxText;
    
    var lockAngle:Float = 0;
    var lockSize:Float = 1;
    
    var curMode:Int = 0;
    
    var allowedModes:Array<String> = ["weeks", "diffs"];
    var modeSelectorSprites:Map<String, FlxSprite>;
    
    var lerpScore:Int = 49324858;
    var intendedScore:Int = 0;
    
    var movedBack:Bool = false;
    var selectedWeek:Bool = false;
    var spamStop:Bool = false;
    
    override function create() {
        Paths.clearUnusedMemory();
        Paths.clearStoredMemory();
        persistentUpdate = persistentDraw = true;
        PlayState.isStoryMode = true;
        WeekData.reloadWeekFiles(true);
        
        // group initializations //
        modeSelectorSprites = new Map<String, FlxSprite>();
        
        // this var is a wildcard across the entire class //
        var path:String = "storymenu/";
        
        #if DISCORD_ALLOWED
        // Updating Discord Rich Presence only if allowed
        DiscordClient.changePresence("In the Storymode menu", null);
        #end
        
        // configure transition shit //
        if (WeekData.weeksList.length < 1) {
            FlxTransitionableState.skipNextTransIn = true;
            persistentUpdate = false;
            MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR STORY MODE\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
                function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
                function() MusicBeatState.switchState(new states.MainMenuState())));
            return;
        }
        
        // objects //
        
        tiledBG = new FlxBackdrop(Paths.image(path + "storybg"));
        tiledBG.setGraphicSize(FlxG.width, FlxG.height);
        add(tiledBG);
        
        blackCut = StoryModeMenuShape.buildCut();
        
        leftBlue = StoryModeMenuShape.buildLeftBlueSelection();
        leftBlue.visible = false;
        modeSelectorSprites.set("weeks", leftBlue);
        
        rightPink = StoryModeMenuShape.buildPinkRightSelection();
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
        
        // texts and shit //
        textWeekName = new FlxText();
        textWeekName.text = "This is some cool text";
        textWeekName.setFormat(Paths.font("vcr.ttf"), 25, FlxColor.WHITE, FlxTextAlign.LEFT);
        textWeekName.x = 920;
        textWeekName.y = 16;
        add(textWeekName);
        
        textWeekScore = new FlxText();
        textWeekScore.text = "9876543210";
        textWeekScore.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, FlxTextAlign.LEFT);
        textWeekScore.x = 940;
        textWeekScore.y = 40;
        add(textWeekScore);
        
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
        
        reloadDifficulties();
        changeWeek();
        switchMode();
        
        super.create();
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
        
        if (!movedBack && !selectedWeek) {
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
                    case "diffs":
                        changeDifficulty(dir);
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
        
        if (intendedScore != lerpScore) {
            lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
            if (Math.abs(intendedScore - lerpScore) < 10)
                lerpScore = intendedScore;
                
            textWeekScore.text = Language.getPhrase('week_score', 'WEEK SCORE: {1}', [lerpScore]);
        }
        
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
    }
    
    override function closeSubState() {
        persistentUpdate = true;
        changeWeek();
        super.closeSubState();
    }
    
    override function beatHit() {
        super.beatHit();
        
        var even:Bool = curBeat % 2 == 0;
        lockAngle = even ? 12 : -12;
        lockSize = even ? 1.6 : 1.5;
    }
    
    override function destroy() {
        super.destroy();
        Paths.clearStoredMemory();
    }
    
    function weekIsLocked(name:String):Bool {
        var leWeek:WeekData = WeekData.weeksLoaded.get(name);
        return (!leWeek.startUnlocked
            && leWeek.weekBefore.length > 0
            && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
    }
    
    function reloadDiffImages() {
    }
    
    function reloadDifficulties():Void {
        WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);
        Difficulty.loadFromWeek();
        grpDifficulties.clear();
        
        for (idx in 0...Difficulty.defaultList.length) {
            var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(Difficulty.list[idx]));
            final diffSprite:StoryModeMenuItem = new StoryModeMenuItem(700, 400, "", false);
            diffSprite.antialiasing = ClientPrefs.data.antialiasing;
            diffSprite.pathAngle = 119.7;
            diffSprite.startX = FlxG.width - 230;
            diffSprite.startY = 500;
            diffSprite.spacing = 150;
            diffSprite.y += ((diffSprite.height + diffSprite.paddingY) * idx);
            diffSprite.alphaMultiplier = 0.76;
            diffSprite.targetY = idx;
            
            diffSprite.loadGraphic(newImage);
            diffSprite.updateHitbox();
            grpDifficulties.add(diffSprite);
        }
    }
    
    function changeDifficulty(change:Int = 0):Void {
        curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.defaultList.length - 1);
        
        var idx:Int = 0;
        for (item in grpDifficulties.members) {
            if (item != null)
                item.targetY = idx - curDifficulty;
            idx++;
        }
        FlxG.sound.play(Paths.sound("scrollMenu"));
        
        intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
    }
    
    function switchMode(mode:Int = 0) {
        curMode = FlxMath.wrap(curMode + mode, 0, allowedModes.length - 1);
        
        for (mode => sprites in modeSelectorSprites)
            sprites.visible = false;
            
        modeSelectorSprites[allowedModes[curMode]].visible = true;
        FlxG.sound.play(Paths.sound("scrollMenu"));
    }
    
    function changeWeek(change:Int = 0):Void {
        reloadDifficulties();
        curWeek = FlxMath.wrap(curWeek + change, 0, loadedWeeks.length - 1);
        
        var leWeek:WeekData = loadedWeeks[curWeek];
        WeekData.setDirectoryFromWeek(leWeek);
        
        grpWeekText.members[curWeek].disabled = weekIsLocked(leWeek.fileName);
        textWeekName.text = leWeek.storyName;
        
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
            
        intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
    }
    
    function updateText() {
        var leWeek:WeekData = loadedWeeks[curWeek];
        var stringThing:Array<String> = [];
        for (i in 0...leWeek.songs.length)
            stringThing.push(leWeek.songs[i][0]);
            
        #if !switch
        intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
        #end
    }
    
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
            
            if (!spamStop) {
                FlxG.sound.play(Paths.sound('confirmMenu'));
                grpWeekText.members[curWeek].isFlashing = true;
                /*for (char in grpWeekCharacters.members) {
                    if (char.character != '' && char.hasConfirmAnimation)
                        char.animation.play('confirm');
                }*/
                spamStop = true;
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
}
