package ui;

class BaseButton extends BasicUI {
    public var onPress:FlxTypedSignal<Void->Void>;
    public var allowPressing:Bool = true;
    public var pressTarget:flixel.FlxBasic;
    public var hovered(get, null):Bool;
    public var sprite:FlxSprite;

    public function new(?x:Float, ?y:Float, ?simpleGraphic:flixel.system.FlxAssets.FlxGraphicAsset) {
        super(x, y);

        pressTarget = this;
        
        add(sprite = new FlxSprite().loadGraphic(simpleGraphic));
        onPress = new FlxTypedSignal<Void->Void>();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (hovered && allowPressing && FlxG.mouse.justPressed) onPress.dispatch();
    }

    private function get_hovered() return FlxG.mouse.overlaps(pressTarget);
}