package objects;

import openfl.display.Shape;
import openfl.display.BitmapData;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;

class StoryModeMenuShape {
    // só constrói a geometria -- não sabe nada sobre câmera ou sprite
    public static function buildCut():FlxSprite {
        var shape:Shape = new Shape();
        
        shape.graphics.beginFill(0xFFFFFFFF);
        shape.graphics.moveTo(0, 0);
        shape.graphics.lineTo(729, 0);
        shape.graphics.lineTo(319, FlxG.height);
        shape.graphics.lineTo(0, FlxG.height);
        shape.graphics.lineTo(0, 0);
        shape.graphics.endFill();
        
        shape.graphics.beginFill(0xFFFFFFFF);
        shape.graphics.moveTo(855 - 48, 0);
        shape.graphics.lineTo(FlxG.width, 0);
        shape.graphics.lineTo(FlxG.width, 92 + 48);
        shape.graphics.lineTo(936 - 48, 92 + 48);
        shape.graphics.endFill();
        
        shape.graphics.beginFill(0xFF000000);
        shape.graphics.moveTo(855, 0);
        shape.graphics.lineTo(FlxG.width, 0);
        shape.graphics.lineTo(FlxG.width, 92);
        shape.graphics.lineTo(936, 92);
        shape.graphics.endFill();
        
        shape.graphics.beginFill(0xFF000000);
        shape.graphics.moveTo(916, FlxG.height);
        shape.graphics.lineTo(FlxG.width, FlxG.height);
        shape.graphics.lineTo(FlxG.width, 400);
        shape.graphics.lineTo(1080, 400);
        shape.graphics.endFill();
        
        return toSprite(shape);
    }
    
    public static function buildLeftBlueSelection():FlxSprite {
        var shape:Shape = new Shape();
        shape.graphics.beginFill(0xFF00FDFF);
        shape.graphics.moveTo(0, 0);
        shape.graphics.lineTo(729 + 48, 0);
        shape.graphics.lineTo(319 + 48, FlxG.height);
        shape.graphics.lineTo(0, FlxG.height);
        shape.graphics.lineTo(0, 0);
        shape.graphics.endFill();
        return toSprite(shape);
    }
    
    public static function buildPinkRightSelection():FlxSprite {
        var shape:Shape = new Shape();
        shape.graphics.beginFill(0xFFFB00EB);
        shape.graphics.moveTo(916 - 48, FlxG.height);
        shape.graphics.lineTo(FlxG.width, FlxG.height);
        shape.graphics.lineTo(FlxG.width, 400 - 48);
        shape.graphics.lineTo(1080 - 32, 400 - 48);
        shape.graphics.endFill();
        return toSprite(shape);
    }
    
    // rasteriza o MESMO shape num FlxSprite pra desenhar normalmente na tela
    // (aqui sim a cor de cada região aparece de verdade, branco/preto)
    public static function toSprite(shape:Shape):FlxSprite {
        var bmd:BitmapData = new BitmapData(FlxG.width, FlxG.height, true, 0x00000000);
        bmd.draw(shape);
        
        var spr:FlxSprite = new FlxSprite();
        spr.loadGraphic(bmd);
        return spr;
    }
}
