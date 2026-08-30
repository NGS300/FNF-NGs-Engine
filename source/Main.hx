package;

#if android
import android.content.Context;
#end

import debug.FPSCounter;
import debug.MemoryCounter;

import openfl.Lib;
import openfl.display.Sprite;

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
import psychlua.HScript.HScriptInfos;
#end

#if desktop
import backend.ALSoftConfig; // Just to make sure DCE doesn't remove this, since it's not directly referenced anywhere else.
#end

#if CRASH_HANDLER //crash handler stuff
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

#if (linux && !debug) // NATIVE API STUFF, YOU CAN IGNORE THIS AND SCROLL //
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end

class Main extends Sprite {
	public static final game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: states.TitleState, // initial game state
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPSCounter;
	public static var ramVar:MemoryCounter;

	public static function main():Void Lib.current.addChild(new Main());

	public function new() {
		super();
		#if (cpp && windows) backend.Native.fixScaling(); #end

		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end

		#if VIDEOS_ALLOWED hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0")  ["--no-lua"] #end); #end
		#if LUA_ALLOWED Mods.pushGlobalMods(); #end
		Mods.loadTopMod();

		FlxG.save.bind("funkin", CoolUtil.getSavePath());
		backend.Highscore.load();

		#if HSCRIPT_ALLOWED
		Iris.warn = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(WARN, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : "")  + '${newPos.fileName}:';

			#if LUA_ALLOWED
			if (newPos.isLua == true) {
				msgInfo += "HScript:";
				newPos.showLine = false;
			}
			#end

			if (newPos.showLine == true)
				msgInfo += '${newPos.lineNumber}:';
			msgInfo += ' $x';

			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('WARNING: $msgInfo', FlxColor.YELLOW);
		}

		Iris.error = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(ERROR, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';

			#if LUA_ALLOWED
			if (newPos.isLua == true) {
				msgInfo += "HScript:";
				newPos.showLine = false;
			}
			#end

			if (newPos.showLine == true)
				msgInfo += '${newPos.lineNumber}:';
			msgInfo += ' $x';

			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('ERROR: $msgInfo', FlxColor.RED);
		}

		Iris.fatal = function(x, ?pos:haxe.PosInfos) {
			Iris.logLevel(FATAL, x, pos);
			var newPos:HScriptInfos = cast pos;
			if (newPos.showLine == null) newPos.showLine = true;
			var msgInfo:String = (newPos.funcName != null ? '(${newPos.funcName}) - ' : '')  + '${newPos.fileName}:';

			#if LUA_ALLOWED
			if (newPos.isLua == true) {
				msgInfo += "HScript:";
				newPos.showLine = false;
			}
			#end

			if (newPos.showLine == true)
				msgInfo += '${newPos.lineNumber}:';
			msgInfo += ' $x';

			if (PlayState.instance != null)
				PlayState.instance.addTextToDebug('FATAL: $msgInfo', 0xFFBB0000);
		}
		#end

		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
		var game = new flixel.FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen);
		@:privateAccess
		game._customSoundTray = backend.SoundTray;
		addChild(game);

		#if !mobile
		var data = ClientPrefs.data.showFPS;
		fpsVar = new FPSCounter(data != 2 ? 2 : 14);
		addChild(fpsVar);
		ramVar = new MemoryCounter(2);
		addChild(ramVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = openfl.display.StageScaleMode.NO_SCALE;
		if (Main.fpsVar != null) Main.fpsVar.visible = (data == 0 ? false : true);
		if (Main.ramVar != null) Main.ramVar.visible = (data == 2 ? true : false);
		#end

		#if (linux || mac) // fix the app icon not showing up on the Linux Panel / Mac Dock
		var icon = lime.graphics.Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];
		
		#if CRASH_HANDLER Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash); #end
		#if DISCORD_ALLOWED DiscordClient.prepare(); #end

		FlxG.signals.gameResized.add(function (w, h) {
		    if (FlxG.cameras != null) {
			   	for (cam in FlxG.cameras.list)
					if (cam != null && cam.filters != null)
						resetSpriteCache(cam.flashSprite);
			}
			if (FlxG.game != null) resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		    sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void {
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);

		var dateNow:String = Date.now().toString();
		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + CoolUtil.engine.name.replace(" ", "") + '_$dateNow.txt';
		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column): errMsg += file + " (line " + line + ")\n";
				default: Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;
		errMsg += "\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/")) FileSystem.createDirectory("./crash/");
		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		lime.app.Application.current.window.alert(errMsg, "Error!");
		#if DISCORD_ALLOWED DiscordClient.shutdown(); #end
		Sys.exit(1);
	}
	#end
}