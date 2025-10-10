package debug;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;

class Framerate extends Sprite {
    var __bitmap(get, default):BitmapData;
    var __color(default, set):Int = 0xFF000000;
    var __targetAlpha(get, default):Float = 1.0;
    var __focused:Bool = true;
    var __unfocusedAlpha:Float = 0.3;
    var __hidden(default, null):Bool = false;

    function get___bitmap():BitmapData {
        return new BitmapData(1, 1, __color);
    }

    function set___color(value:Int):Int {
        __color = value;
        get___bitmap();

        return __color;
    }

    function get___targetAlpha():Float {
        return __targetAlpha = __hidden ? 0 : (__focused ? 1 : __unfocusedAlpha);
    }

    public var fpsText:FPSCounter;
    public var background:Bitmap;

    public function new() {
        super();

        if (__bitmap == null)
            __bitmap = new BitmapData(1, 1, __color);

        background = new Bitmap(__bitmap);
        background.alpha = 0.6;
        addChild(background);

        fpsText = new FPSCounter(5, 5, 0xFFFFFF);
        addChild(fpsText);
    }

    private override function __enterFrame(deltaTime:Float) {
        if (visible) {
            @:privateAccess fpsText.__enterFrame(deltaTime); 
            update(deltaTime);
        }
    } 

    public dynamic function update(elapsed:Float) {
        if (background != null && fpsText != null) {
            background.x = fpsText.x - 2;
            background.y = fpsText.y - 2;
            background.scaleX = fpsText.width + 8;
            background.scaleY = fpsText.height + 4;
        }
    }

    public function toggleVisibility(?instant:Bool = false) {
        __hidden = !__hidden;
        if (!__hidden) visible = true;
        
        if (instant) {
            alpha = __targetAlpha;
            visible = !__hidden;
        } else {
            final targetX = __hidden ? -width - 10 : 0;
            FlxTween.cancelTweensOf(this);
            FlxTween.tween(this, {
                x: targetX,
                alpha: __targetAlpha
            }, 0.6, {ease: FlxEase.expoOut, onComplete: _ -> if (__hidden) visible = false });
        }
    }

    public function unfocus() {
        __focused = false;
        FlxTween.tween(this, {alpha: __unfocusedAlpha}, 3, {ease: FlxEase.quadIn});
    }

    public function focus() {
        __focused = true;
        FlxTween.tween(this, {alpha: __targetAlpha}, 0.8, {ease: FlxEase.expoOut});
    }
}