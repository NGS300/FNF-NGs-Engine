package states.editors;

import objects.StoryModeMenuShape;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;
import backend.WeekData;
import backend.ui.PsychUIEventHandler.PsychUIEvent;

class NewWeekEditorState extends MusicBeatState implements PsychUIEvent {
    var tiledBG:FlxBackdrop;
    var blackCut:FlxSprite;
    var blueDeco:FlxSprite;
    
    var weekFile:WeekFile = null;
    
    var editorUI:PsychUIBox;
    
    public static var unsavedProgress:Bool = false;
    public static var weekFileName:String = 'week1';
    
    public function new(weekFile:WeekFile = null) {
        super();
        this.weekFile = WeekData.createWeekFile();
        if (weekFile != null)
            this.weekFile = weekFile;
        else
            weekFileName = 'week1';
    }
    
    override function create() {
        FlxG.mouse.visible = true;
        var path:String = "storymenu/";
        tiledBG = new FlxBackdrop(Paths.image(path + "storybg"));
        tiledBG.setGraphicSize(FlxG.width, FlxG.height);
        add(tiledBG);
        
        blueDeco = StoryModeMenuShape.buildLeftBlueSelection();
        add(blueDeco);
        
        blackCut = StoryModeMenuShape.buildCut(false);
        add(blackCut);
        
        super.create();
    }
    
    override function update(elapsed:Float) {
        tiledBG.x -= 20 * elapsed;
        super.update(elapsed);
    }
    
    public function UIEvent(id:String, sender:Dynamic) {
    }
    
    function addUI() {
        editorUI = new PsychUIBox(FlxG.width, FlxG.height, 250, 375, ['Other', 'Week']);
        editorUI.x -= editorUI.width;
        editorUI.y -= editorUI.height;
        editorUI.scrollFactor.set();
    }
}
