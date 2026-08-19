package objects;

class StoryModeMenuItem extends MenuItem {
    public var disabled:Bool = false;
    
    // ângulo do CAMINHO (posição), em GRAUS (0 = direita, 90 = baixo, 180 = esquerda...)
    // NÃO usar o nome "angle" aqui -- FlxSprite já tem um campo "angle" nativo
    // que controla a ROTAÇÃO VISUAL do sprite. Sombrear esse nome faz o motor
    // rotacionar o sprite de verdade em vez de só usar o valor pra matemática de posição.
    public var pathAngle:Float = 119.7;
    
    // distância percorrida por unidade de targetY
    public var spacing:Float = 300;
    
    public var startX:Float = 0;
    public var startY:Float = 0;
    public var paddingY:Float = 64;
    
    public var scaleMultiplier:Float = 0.15;
    public var alphaMultiplier:Float = 0.4;
    
    var flashTimer:Float = 0;
    var flashInterval:Float = 0.1; // 0.1s = 10 vezes por segundo
    
    public function new(x:Float, y:Float, weekName:String = '') {
        super(x, y, weekName);
        startX = x;
        startY = y;
    }
    
    public inline function flashing():Void {
        isFlashing = true;
    }
    
    override function update(elapsed:Float) {
        // converte o ângulo do CAMINHO (graus) num vetor de direção real
        // isso só afeta x/y (posição) -- nunca o "angle" nativo de rotação do sprite
        var rad:Float = pathAngle * Math.PI / 180;
        var dirX:Float = Math.cos(rad);
        var dirY:Float = Math.sin(rad);
        
        // posição alvo = ponto inicial + direção * distância percorrida
        var distance:Float = targetY * spacing;
        
        var targetPosX:Float = startX + dirX * distance;
        var targetPosY:Float = startY + dirY * distance;
        
        var moveLerp:Float = 1 - Math.exp(-10 * elapsed);
        x = FlxMath.lerp(x, targetPosX, moveLerp);
        y = FlxMath.lerp(y, targetPosY, moveLerp);
        
        updateHitbox();
        
        alpha = 1 - Math.abs(targetY) * alphaMultiplier;
        
        if (disabled)
            color = 0xFF646464;
        else if (isFlashing && FlxG.save.data.flashing)
            super.update(elapsed);
        else
            color = FlxColor.WHITE;
    }
}
