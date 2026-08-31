function onEndSong() {
    var currentWeekFile:String = WeekData.getWeekFileName();
    var difficulty = Difficulty.getString().toUpperCase();
    var songName = PlayState.SONG.song.toLowerCase();

    var usedPractice:Bool = (game.practiceMode || game.cpuControlled || game.botPlay);
    if (game.chartingMode || usedPractice) return;

    if (songName == "test")
        unlockAchievement("debugger");

    var isHard:Bool = (Difficulty.getString().toUpperCase() == "HARD");
    if (isStoryMode && difficulty == "HARD" && !changedDifficulty && storyPlaylist.length <= 1 && (campaignMisses + songMisses) < 1)
        unlockAchievement(currentWeekFile + "_nomiss");
}