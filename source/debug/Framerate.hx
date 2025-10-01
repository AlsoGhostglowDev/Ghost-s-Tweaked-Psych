package debug;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;

class Framerate extends Sprite {
    var __bitmap(get, default):BitmapData;
    var __color(default, set):Int = 0xFF000000;

    function get___bitmap():BitmapData {
        return new BitmapData(1, 1, __color);
    }

    function set___color(value:Int):Int {
        __color = value;
        get___bitmap();

        return __color;
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
}