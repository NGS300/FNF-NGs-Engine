function onCreatePost() {
    var bg = new BGSprite("editors/bgback", -600, -200, 0.9, 0.9);
    game.insert(game.members.indexOf(game.gfGroup), bg);

	var front = new BGSprite("editors/bgfront", -650, 600, 0.9, 0.9);
	front.setGraphicSize(Std.int(front.width * 1.1));
	front.updateHitbox();
	game.insert(game.members.indexOf(game.gfGroup), front);
}