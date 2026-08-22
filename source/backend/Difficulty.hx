package backend;

class Difficulty {
    public static final defaultList:Array<String> = ['Easy', 'Normal', 'Hard'];
    private static final defaultDifficulty:String = 'Normal'; // The chart that has no postfix and starting difficulty on Freeplay/Story Mode
    
    public static var list:Array<String> = [];
    
    /**
        get the difficulty file path
    **/
    public static function getFilePath(num:Null<Int> = null) {
        if (num == null)
            num = PlayState.storyDifficulty;
            
        var filePostfix:String = list[num];
        if (filePostfix != null && Paths.formatToSongPath(filePostfix) != Paths.formatToSongPath(defaultDifficulty))
            filePostfix = '-' + filePostfix;
        else
            filePostfix = '';
        return Paths.formatToSongPath(filePostfix);
    }
    
    /**
        Load all available difficulties from a week
    **/
    public static function loadFromWeek(week:WeekData = null) {
        if (week == null)
            week = WeekData.getCurrentWeek();
            
        var diffStr:String = week.difficulties;
        if (diffStr != null && diffStr.length > 0) {
            var diffs:Array<String> = diffStr.trim().split(',');
            var i:Int = diffs.length - 1;
            while (i > 0) {
                if (diffs[i] != null) {
                    diffs[i] = diffs[i].trim();
                    if (diffs[i].length < 1)
                        diffs.remove(diffs[i]);
                }
                --i;
            }
            
            if (diffs.length > 0 && diffs[0].length > 0)
                list = diffs;
        }
        else
            resetList();
    }
    
    /**
        resets the Difficulty list to a default one    
    **/
    inline public static function resetList() {
        list = defaultList.copy();
    }
    
    /**
        copy a difficulty list from one to another
    **/
    inline public static function copyFrom(diffs:Array<String>) {
        list = diffs.copy();
    }
    
    /**
        get difficulty name based on translation
    **/
    inline public static function getString(?num:Null<Int> = null, ?canTranslate:Bool = true):String {
        var diffName:String = list[num == null ? PlayState.storyDifficulty : num];
        if (diffName == null)
            diffName = defaultDifficulty;
        return canTranslate ? Language.getPhrase('difficulty_$diffName', diffName) : diffName;
    }
    
    /**
        return the default difficulty
    **/
    inline public static function getDefault():String {
        return defaultDifficulty;
    }
}
