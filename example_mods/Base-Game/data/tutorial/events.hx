var cameraTwn:FlxTween;
function zoomCam(targetZoom:Float) {
    if (cameraTwn == null && FlxG.camera.zoom != targetZoom) {
        cameraTwn = FlxTween.tween(FlxG.camera, {zoom: targetZoom}, (Conductor.stepCrochet * 4 / 1000), {
            ease: FlxEase.elasticInOut,
            onComplete: (_) -> cameraTwn = null
        });
    }
}

function onMoveCamera(focus:String) {
    zoomCam(focus == "bf" ? 1 : 1.3);
}

function opponentNoteHitPre(note:Note) {
	var canCamZooming = false;
    return canCamZooming;
}