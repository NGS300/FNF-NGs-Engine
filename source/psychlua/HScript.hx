package psychlua;

import psychlua.LuaUtils;
import psychlua.CustomSubstate;

import sys.FileSystem;
import haxe.io.Path;

#if LUA_ALLOWED
import psychlua.FunkinLua;
#end

#if HSCRIPT_ALLOWED
import psychlua.HScriptAdapter;
import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;
import haxe.ValueException;

typedef HScriptInfos = {
	> haxe.PosInfos,
	var ?funcName:String;
	var ?showLine:Null<Bool>;
	#if LUA_ALLOWED
	var ?isLua:Null<Bool>;
	#end
}

class HScript extends Iris {
	public var filePath:String;
	public var modFolder:String;
	public var returnValue:Dynamic;

	#if LUA_ALLOWED
	public var parentLua:FunkinLua;
	public static function initHaxeModule(parent:FunkinLua) {
		if (parent.hscript == null) {
			trace('initializing haxe interp for: ${parent.scriptName}');
			parent.hscript = new HScript(parent);
		}
	}

	public static function initHaxeModuleCode(parent:FunkinLua, code:String, ?varsToBring:Any = null) {
		var hs:HScript = try parent.hscript catch (e) null;
		if (hs == null) {
			trace('initializing haxe interp for: ${parent.scriptName}');
			try {
				parent.hscript = new HScript(parent, code, varsToBring);
			} catch (e:IrisError) {
				var pos:HScriptInfos = cast {fileName: parent.scriptName, isLua: true};
				if (parent.lastCalledFunction != "") pos.funcName = parent.lastCalledFunction;
				Iris.error(Printer.errorToString(e, false), pos);
				parent.hscript = null;
			}
		} else {
			try {
				hs.scriptCode = code;
				hs.varsToBring = varsToBring;
				hs.parse(true);
				var ret:Dynamic = hs.execute();
				hs.returnValue = ret;
			} catch (e:IrisError) {
				var pos:HScriptInfos = cast hs.interp.posInfos();
				pos.isLua = true;
				if (parent.lastCalledFunction != "") pos.funcName = parent.lastCalledFunction;
				Iris.error(Printer.errorToString(e, false), pos);
				hs.returnValue = null;
			}
		}
	}
	#end

	public var origin:String;
	override public function new(?parent:Dynamic, ?file:String, ?varsToBring:Any = null, ?manualRun:Bool = false) {
		if (file == null)
			file = "";

		filePath = file;
		if (filePath != null && filePath.length > 0) {
			this.origin = filePath;
			#if MODS_ALLOWED
			var myFolder:Array<String> = filePath.split("/");
			if (myFolder[0] + "/" == Paths.mods() && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) //is inside mods folder
				this.modFolder = myFolder[1];
			#end
		}
		var scriptThing:String = file;
		var scriptName:String = null;
		if (parent == null && file != null) {
			var f:String = file.replace("\\", "/");
			if (f.contains("/") && !f.contains("\n")) {
				scriptThing = File.getContent(f);
				scriptName = f;
			}
		}
		#if LUA_ALLOWED
		if (scriptName == null && parent != null)
			scriptName = parent.scriptName;
		#end
		super(scriptThing, new IrisConfig(scriptName, false, false));
		var customInterp = new CustomInterp();
		customInterp.parentInstance = FlxG.state;
		customInterp.showPosOnLog = false;
		this.interp = customInterp;
		#if LUA_ALLOWED
		parentLua = parent;
		if (parent != null) {
			this.origin = parent.scriptName;
			this.modFolder = parent.modFolder;
		}
		#end
		preset();
		this.varsToBring = varsToBring;
		if (!manualRun) {
			try {
				var ret:Dynamic = execute();
				returnValue = ret;
			} catch (e:IrisError) {
				returnValue = null;
				this.destroy();
				throw e;
			}
		}
	}

	static function getHaxelibPath(libName:String):String {
        try {
            var proc = new sys.io.Process("haxelib", ["libpath", libName]);
            var result = proc.stdout.readAll().toString().trim();
            proc.close();
            return result;
        } catch (e:Dynamic)
            return "";
    }

	public static var autoFlixelBlacklist:Array<String> = [
		// Flixel Root
		"flixel.FlxStrip",

		// Flixel Subfolders
		"flixel.group.FlxGroup",
		"flixel.group.FlxSpriteGroup",
		"flixel.math.FlxPoint",
		"flixel.math.FlxVector",
		"flixel.util.FlxAxes",
		"flixel.util.FlxColor",
		"flixel.util.FlxDirection",
		"flixel.util.FlxDirectionFlags",
		"flixel.util.FlxPath",
		"flixel.util.FlxSignal"
    ];

	public static var autoStdBlacklist:Array<String> = [
		// Std Root
		"Any",
		"EnumValue",
		"IntIterator",
		"List",
		"Map",
		"StdTypes",
		"UInt",
		"UnicodeString",
		
		// Std Subfolders
		"sys.FileSystem",
		"sys.FileStat"
	];

	var varsToBring(default, set):Any = null;
	override function preset() {
		super.preset();
        var customInstances:Array<{key:String, value:Dynamic, ?nullable:Bool}> = [
			{key: "Map", value: ScriptMap},
			{key: "FlxMap", value: CustomMap},
			{key: "FlxColor", value: CustomFlxColor},
			{key: "Countdown", value: backend.BaseStage.Countdown},
			//{key: "FlxPoint", value:flixel.math.FlxPoint},
			//{key: "FlxAxes", value: flixel.util.FlxAxes},

			// Auto-Flixel Fixes
			{key: "FlxSpriteGroup", value: flixel.group.FlxSpriteGroup},
			{key: "FlxTypedGroup", value: flixel.group.FlxGroup.FlxTypedGroup},

			//Precaching
			{key: "precacheImage", value:  Paths.image},
            {key: "precacheSound", value: Paths.sound},
			{key: "precacheMusic", value: Paths.music},

			// Others
			{key: "this", value: this},
            {key: "game", value: FlxG.state},
            {key: "controls", value: Controls.instance},
            {key: "buildTarget", value: LuaUtils.getBuildTarget()},
            {key: "customSubstate", value: CustomSubstate.instance},
            {key: "customSubstateName", value: CustomSubstate.name},
			{key: "parentLua", value: #if LUA_ALLOWED parentLua #else null #end, nullable: true},
			{key: "FlxAnimate", value: #if flxanimate flxanimate.PsychFlxAnimate #else null #end},
        ];

        for (field in Type.getClassFields(LuaUtils))
            if (field.startsWith("Function_"))
                customInstances.push({key: field, value: Reflect.field(LuaUtils, field)});

		var customCounts = {registered: 0, ignored: 0};
        for (item in customInstances) {
            var canSet:Bool = (item.nullable == true) ? true : (item.value != null);
            if (canSet) {
                set(item.key, item.value);
				customCounts.registered++;
            } else {
                #if debug trace('[HScript Custom Instances WARNING] Ignored due to null: ${item.key}'); #end
				customCounts.ignored++;
            }
        }
		#if debug trace('[HScript Custom Instances] Total Registered: ${customCounts.registered} | Ignored: ${customCounts.ignored}'); #end

        var specificClasses:Array<String> = [
            // Game Source
			#if ACHIEVEMENTS_ALLOWED 'backend.Achievements' #else null #end,
			"backend.ClientPrefs",
			"backend.Conductor",
			"backend.Paths",
			"backend.PsychCamera",
			"objects.AnimatedSprite",
			"objects.Alphabet",
			"objects.BGSprite",
            "objects.Character",
			"objects.Graphic",
            "objects.Note",
			"objects.Sprite",
            "psychlua.CustomSubstate",
			"states.PlayState",

			// Auto-Flixel Fix
			"flixel.text.FlxText",
			"flixel.graphics.FlxGraphic",
            
            // System, Core, Utils, Others
			"openfl.filters.ShaderFilter",
            #if sys "sys.io.File" #else null #end,
            #if sys "sys.FileSystem" #else null #end,
			#if (!flash && sys) "flixel.addons.display.FlxRuntimeShader" #else null #end
        ];

		var specificCounts = {registered: 0, failed: 0};
        for (clsPath in specificClasses) {
            if (clsPath == null) continue;
            var resolvedItem:Dynamic = Type.resolveClass(clsPath);

            if (resolvedItem == null)
                resolvedItem = Type.resolveEnum(clsPath);

            var shortName = clsPath.split(".").pop();
            if (resolvedItem != null) {
                set(shortName, resolvedItem);
				specificCounts.registered++;
            } else {
                trace('[HScript Specific Classes WARNING] Unresolved by Type: $clsPath');
				specificCounts.failed++;
            }
        }
		#if debug trace('[HScript Specific Classes] Total Registered: ${specificCounts.registered} | Failed: ${specificCounts.failed}'); #end

		// Auto-Flixel shit
		var flixelSubFolders:Array<String> = ["group", "math", "sound", "tweens", "util"];
        var flixelBasePath:String = getHaxelibPath("flixel");
		var autoCounts = {registered: 0, blacklisted: 0}
        if (flixelBasePath != "" && FileSystem.exists(flixelBasePath)) {
			var flixelRootPath = Path.join([flixelBasePath, "flixel"]);
			if (FileSystem.exists(flixelRootPath) && FileSystem.isDirectory(flixelRootPath)) {
				for (file in FileSystem.readDirectory(flixelRootPath)) {
					if (!FileSystem.isDirectory(Path.join([flixelRootPath, file])) && Path.extension(file) == "hx") {
						var className = Path.withoutExtension(file);
						var fullClassPath = 'flixel.$className';

						if (!autoFlixelBlacklist.contains(fullClassPath)) {
							if (autoFlixelBlacklist.contains(fullClassPath)) {
								autoCounts.blacklisted++;
								continue;
							}

							var resolvedItem:Dynamic = Type.resolveClass(fullClassPath);
							if (resolvedItem == null) resolvedItem = Type.resolveEnum(fullClassPath);

							if (resolvedItem != null) {
								set(className, resolvedItem);
								autoCounts.registered++;
							} else
								trace('[HScript Auto-Flixel ROOT WARNING] Unresolved by Type: $fullClassPath');
						}
					}
				}
			}

			for (folderName in flixelSubFolders) {
				var fullFolderPath = Path.join([flixelBasePath, "flixel", folderName]);
				if (FileSystem.exists(fullFolderPath) && FileSystem.isDirectory(fullFolderPath)) {
					for (file in FileSystem.readDirectory(fullFolderPath)) {
						if (!FileSystem.isDirectory(Path.join([fullFolderPath, file])) && Path.extension(file) == "hx") {
							var className = Path.withoutExtension(file);
							var fullClassPath = 'flixel.$folderName.$className';

							if (autoFlixelBlacklist.contains(fullClassPath)) {
								autoCounts.blacklisted++;
								continue;
							}

							var resolvedItem:Dynamic = Type.resolveClass(fullClassPath);
							if (resolvedItem == null) resolvedItem = Type.resolveEnum(fullClassPath);
							
							if (resolvedItem != null) {
								set(className, resolvedItem);
								autoCounts.registered++;
							} else
								trace('[HScript Auto-Flixel SubFolders WARNING] Unresolved by Type: $fullClassPath');
						}
					}
				}
			}
			#if debug trace('[HScript Auto-Flixel] Total Registered: ${autoCounts.registered} | Blacklisted: ${autoCounts.blacklisted}'); #end
        } else
            trace("[HScript ERROR] Flixel Haxelib path not found!");

		var stdSubFolders:Array<String> = ["sys"]; // ["haxe", "haxe/crypto", "haxe/ds", "haxe/io", "sys", "sys/io"];
		var stdBasePath:String = Sys.getEnv("HAXEPATH");
		var autoStdCounts = {registered: 0, blacklisted: 0};
		if (stdBasePath != null && stdBasePath != "") {
			var stdPath = Path.join([stdBasePath, "std"]);
			if (FileSystem.exists(stdPath) && FileSystem.isDirectory(stdPath)) {
				for (file in FileSystem.readDirectory(stdPath)) {
					if (!FileSystem.isDirectory(Path.join([stdPath, file])) && Path.extension(file) == "hx") {
						var className = Path.withoutExtension(file);
						if (autoStdBlacklist.contains(className)) {
							autoStdCounts.blacklisted++;
							continue;
						}

						var resolvedItem:Dynamic = Type.resolveClass(className);
						if (resolvedItem == null) resolvedItem = Type.resolveEnum(className);

						if (resolvedItem != null) {
							set(className, resolvedItem);
							autoStdCounts.registered++;
						} else
							trace('[HScript Auto-Std ROOT WARNING] Unresolved by Type: $className');
					}
				}

				for (folderName in stdSubFolders) {
					var fullFolderPath = Path.join([stdPath, folderName]);
					if (FileSystem.exists(fullFolderPath) && FileSystem.isDirectory(fullFolderPath)) {
						for (file in FileSystem.readDirectory(fullFolderPath)) {
							if (!FileSystem.isDirectory(Path.join([fullFolderPath, file])) && Path.extension(file) == "hx") {
								var className = Path.withoutExtension(file);
								var pkgPath = folderName.replace("/", ".");

								var fullClassPath = '$pkgPath.$className';
								if (autoStdBlacklist.contains(fullClassPath)) {
									autoStdCounts.blacklisted++;
									continue;
								}

								var resolvedItem:Dynamic = Type.resolveClass(fullClassPath);
								if (resolvedItem == null) resolvedItem = Type.resolveEnum(fullClassPath);

								if (resolvedItem != null) {
									set(className, resolvedItem);
									autoStdCounts.registered++;
								} else
									trace('[HScript Auto-Std SubFolders WARNING] Unresolved by Type: $fullClassPath');
							}
						}
					}
				}
				#if debug trace('[HScript Auto-Std] Total Registered: ${autoStdCounts.registered} | Blacklisted: ${autoStdCounts.blacklisted}'); #end
			}
		} else
			trace("[HScript ERROR] HAXEPATH environment variable not found!");

		set("setVar", function(name:String, value:Dynamic) {
			MusicBeatState.getVariables().set(name, value);
			return value;
		});

		set("getVar", function(name:String) {
			var result:Dynamic = null;
			if (MusicBeatState.getVariables().exists(name)) result = MusicBeatState.getVariables().get(name);
			return result;
		});

		set("removeVar", function(name:String) {
			if (MusicBeatState.getVariables().exists(name)) {
				MusicBeatState.getVariables().remove(name);
				return true;
			}
			return false;
		});

		set("debugPrint", function(text:String, ?color:FlxColor = null) {
			if (color == null) color = FlxColor.WHITE;
			PlayState.instance.addTextToDebug(text, color);
		});

		set("getModSetting", function(saveTag:String, ?modName:String = null) {
			if (modName == null) {
				if (this.modFolder == null) {
					Iris.error("getModSetting: Argument #2 is null and script is not inside a packed Mod folder!", this.interp.posInfos());
					return null;
				}
				modName = this.modFolder;
			}
			return LuaUtils.getModSetting(saveTag, modName);
		});

		#if LUA_ALLOWED
		set("createGlobalCallback", function(name:String, func:Dynamic) {
			for (script in PlayState.instance.luaArray)
				if (script != null && script.lua != null && !script.closed)
					Lua_helper.add_callback(script.lua, name, func);
			FunkinLua.customFunctions.set(name, func);
		});

		set("createCallback", function(name:String, func:Dynamic, ?funk:FunkinLua = null) {
			if (funk == null) funk = parentLua;
			if (funk != null) funk.addLocalCallback(name, func);
			else Iris.error('createCallback ($name): 3rd argument is null', this.interp.posInfos());
		});
		#end

		set("addHaxeLibrary", function(libName:String, ?libPackage:String = "") {
			try {
				var str:String = "";
				if (libPackage.length > 0) str = libPackage + ".";
				set(libName, Type.resolveClass(str + libName));
			} catch (e:IrisError)
				Iris.error(Printer.errorToString(e, false), this.interp.posInfos());
		});

		// Keyboard & Gamepads
		set("keyboardJustPressed", function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));

		set("keyboardPressed", function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));

		set("keyboardReleased", function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));

		set("keyJustPressed", function(name:String = "") {
			name = name.toLowerCase();
			switch (name) {
				case "left": return Controls.instance.NOTE_LEFT_P;
				case "down": return Controls.instance.NOTE_DOWN_P;
				case "up": return Controls.instance.NOTE_UP_P;
				case "right": return Controls.instance.NOTE_RIGHT_P;
				default: return Controls.instance.justPressed(name);
			}
			return false;
		});

		set("keyPressed", function(name:String = "") {
			name = name.toLowerCase();
			switch (name) {
				case "left": return Controls.instance.NOTE_LEFT;
				case "down": return Controls.instance.NOTE_DOWN;
				case "up": return Controls.instance.NOTE_UP;
				case "right": return Controls.instance.NOTE_RIGHT;
				default: return Controls.instance.pressed(name);
			}
			return false;
		});

		set("keyReleased", function(name:String = "") {
			name = name.toLowerCase();
			switch (name) {
				case "left": return Controls.instance.NOTE_LEFT_R;
				case "down": return Controls.instance.NOTE_DOWN_R;
				case "up": return Controls.instance.NOTE_UP_R;
				case "right": return Controls.instance.NOTE_RIGHT_R;
				default: return Controls.instance.justReleased(name);
			}
			return false;
		});

		set("anyGamepadJustPressed", function(name:String) return FlxG.gamepads.anyJustPressed(name));
		set("anyGamepadPressed", function(name:String) FlxG.gamepads.anyPressed(name));
		set("anyGamepadReleased", function(name:String) return FlxG.gamepads.anyJustReleased(name));
		set("gamepadAnalogX", function(id:Int, ?leftStick:Bool = true) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;
			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});

		set("gamepadAnalogY", function(id:Int, ?leftStick:Bool = true) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;
			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});

		set("gamepadJustPressed", function(id:Int, name:String) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;
			return Reflect.getProperty(controller.justPressed, name) == true;
		});

		set("gamepadPressed", function(id:Int, name:String) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;
			return Reflect.getProperty(controller.pressed, name) == true;
		});

		set("gamepadReleased", function(id:Int, name:String) {
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;
			return Reflect.getProperty(controller.justReleased, name) == true;
		});
	}

	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua) {
		funk.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic {
			initHaxeModuleCode(funk, codeToRun, varsToBring);
			if (funk.hscript != null) {
				final retVal:IrisCall = funk.hscript.call(funcToRun, funcArgs);
				if (retVal != null)
					return (LuaUtils.isLuaSupported(retVal.returnValue)) ? retVal.returnValue : null;
				else if (funk.hscript.returnValue != null)
					return funk.hscript.returnValue;
			}
			return null;
		});
		
		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
			if (funk.hscript != null) {
				final retVal:IrisCall = funk.hscript.call(funcToRun, funcArgs);
				if (retVal != null)
					return (LuaUtils.isLuaSupported(retVal.returnValue)) ? retVal.returnValue : null;
			} else {
				var pos:HScriptInfos = cast {fileName: funk.scriptName, showLine: false};
				if (funk.lastCalledFunction != "") pos.funcName = funk.lastCalledFunction;
				Iris.error("runHaxeFunction: HScript has not been initialized yet! Use \"runHaxeCode\" to initialize it", pos);
			}
			return null;
		});

		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = "") { // This function is unnecessary because import already exists in HScript as a native feature
			var str:String = "";
			if (libPackage.length > 0)
				str = libPackage + ".";
			else if (libName == null)
				libName = "";

			var c:Dynamic = Type.resolveClass(str + libName);
			if (c == null)
				c = Type.resolveEnum(str + libName);

			if (funk.hscript == null)
				initHaxeModule(funk);

			var pos:HScriptInfos = cast funk.hscript.interp.posInfos();
			pos.showLine = false;
			if (funk.lastCalledFunction != "")
				pos.funcName = funk.lastCalledFunction;

			try {
				if (c != null)
					funk.hscript.set(libName, c);
			} catch (e:IrisError)
				Iris.error(Printer.errorToString(e, false), pos);
			FunkinLua.lastCalledScript = funk;
			if (FunkinLua.getBool("luaDebugMode") && FunkinLua.getBool("luaDeprecatedWarnings"))
				Iris.warn("addHaxeLibrary is deprecated! Import classes through \"import\" in HScript!", pos);
		});
	}
	#end

	override function call(funcToRun:String, ?args:Array<Dynamic>):IrisCall {
		if (funcToRun == null || interp == null) return null;

		if (!exists(funcToRun)) {
			Iris.error('No function named: $funcToRun', this.interp.posInfos());
			return null;
		}

		try {
			var func:Dynamic = interp.variables.get(funcToRun); // function signature
			final ret = Reflect.callMethod(null, func, args ?? []);
			return {funName: funcToRun, signature: func, returnValue: ret};
		} catch (e:IrisError) {
			var pos:HScriptInfos = cast this.interp.posInfos();
			pos.funcName = funcToRun;
			#if LUA_ALLOWED
			if (parentLua != null) {
				pos.isLua = true;
				if (parentLua.lastCalledFunction != "") pos.funcName = parentLua.lastCalledFunction;
			}
			#end
			Iris.error(Printer.errorToString(e, false), pos);
		} catch (e:ValueException) {
			var pos:HScriptInfos = cast this.interp.posInfos();
			pos.funcName = funcToRun;
			#if LUA_ALLOWED
			if (parentLua != null) {
				pos.isLua = true;
				if (parentLua.lastCalledFunction != "") pos.funcName = parentLua.lastCalledFunction;
			}
			#end
			Iris.error('$e', pos);
		}
		return null;
	}

	override public function destroy() {
		origin = null;
		#if LUA_ALLOWED parentLua = null; #end
		super.destroy();
	}

	function set_varsToBring(values:Any) {
		if (varsToBring != null)
			for (key in Reflect.fields(varsToBring))
				if (exists(key.trim()))
					interp.variables.remove(key.trim());

		if (values != null) {
			for (key in Reflect.fields(values)) {
				key = key.trim();
				set(key, Reflect.field(values, key));
			}
		}
		return varsToBring = values;
	}
}

class CustomInterp extends crowplexus.hscript.Interp {
	public var parentInstance(default, set):Dynamic = [];
	private var _instanceFields:Array<String>;
	function set_parentInstance(inst:Dynamic):Dynamic {
		parentInstance = inst;
		if (parentInstance == null) {
			_instanceFields = [];
			return inst;
		}
		_instanceFields = Type.getInstanceFields(Type.getClass(inst));
		return inst;
	}

	public function new() super();

	override function fcall(o:Dynamic, funcToRun:String, args:Array<Dynamic>):Dynamic {
		for (_using in usings) {
			var v = _using.call(o, funcToRun, args);
			if (v != null)
				return v;
		}

		var f = get(o, funcToRun);
		if (f == null) {
			Iris.error('Tried to call null function $funcToRun', posInfos());
			return null;
		}
		return Reflect.callMethod(o, f, args);
	}

	override function resolve(id: String):Dynamic {
		if (locals.exists(id)) {
			var l = locals.get(id);
			return l.r;
		}

		if (variables.exists(id)) {
			var v = variables.get(id);
			return v;
		}

		if (imports.exists(id)) {
			var v = imports.get(id);
			return v;
		}

		if (parentInstance != null && _instanceFields.contains(id)) {
			var v = Reflect.getProperty(parentInstance, id);
			return v;
		}
		error(EUnknownVariable(id));
		return null;
	}
}
#else
class HScript {
	#if LUA_ALLOWED
	public static function implement(funk:FunkinLua) {
		funk.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):Dynamic {
			PlayState.instance.addTextToDebug("HScript is not supported on this platform!", FlxColor.RED);
			return null;
		});
		funk.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
			PlayState.instance.addTextToDebug("HScript is not supported on this platform!", FlxColor.RED);
			return null;
		});
		funk.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = "") {
			PlayState.instance.addTextToDebug("HScript is not supported on this platform!", FlxColor.RED);
			return null;
		});
	}
	#end
}
#end