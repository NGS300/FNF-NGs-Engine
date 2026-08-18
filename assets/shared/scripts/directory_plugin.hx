function onCreate() {
    setVar('dirMods', function(path:String, ?libArray:Array<String>):String {
        var finalLib:String = (libArray != null && libArray[0] != null) ? libArray[0] : "";
        var finalExtra:String = (libArray != null && libArray[1] != null) ? libArray[1] : "";

        var parts:Array<String> = [];
        if (finalLib != '') parts.push(finalLib);
        if (finalExtra != '') parts.push(finalExtra);
        if (path != '') parts.push(path);

        return parts.join('/');
    });
    setVar('dirModsStages', function(path:String, ?libArray:Array<String>):String {
        var finalLib:String = (libArray != null && libArray[0] != null) ? libArray[0] : "stages";
        var finalExtra:String = (libArray != null && libArray[1] != null) ? libArray[1] : PlayState.SONG.stage;

        var parts:Array<String> = [];
        if (finalLib != '') parts.push(finalLib);
        if (finalExtra != '') parts.push(finalExtra);
        if (path != '') parts.push(path);

        return parts.join('/');
    });
}