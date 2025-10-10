package backend;

import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.system.FlxAssets.FlxGraphicAsset;

// made to be extended - this is basically the same thing as SelectableMenu :sob:
class SelectableSubState extends MusicBeatSubstate {
    var _bg:FlxSprite;
    public var curSelected:Array<Int> = [0, 0];
    public var scrollMult:Array<Float> = [0, 0];
    public var allowMouseWheel:Bool = true;
    public var allowWrapping:Bool = true;
    public var allowEnter:Bool = true;
    public var canLeave:Bool = true;
    public var lead:Int = 0;

    public var optionOrder:Array<String>;
    public var options:Map<String, Void->Void> = new Map();

    public var onEnterPressed:FlxTypedSignal<Void->Void>;
    public var onItemChanged:FlxTypedSignal<Void->Void>;
    public var onExit:FlxTypedSignal<Void->Void>;
    public var onExitAttempt:FlxTypedSignal<Void->Void>;

    public function new(options:KeyValueArray<Void->Void>, background:FlxGraphicAsset) {
        super();

        optionOrder = options.keys;
        this.options = options.map;

        _bg = new FlxSprite().loadGraphic(background);
        _bg.antialiasing = ClientPrefs.data.antialiasing;
        add(_bg);

        onEnterPressed = new FlxTypedSignal<Void->Void>();
        onItemChanged = new FlxTypedSignal<Void->Void>();
        onExit = new FlxTypedSignal<Void->Void>();
        onExitAttempt = new FlxTypedSignal<Void->Void>();
    }

    override function create() super.create();
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (controls.ACCEPT && allowEnter) __enter();

        if (controls.UI_UP_P || controls.UI_DOWN_P || controls.UI_LEFT_P || controls.UI_RIGHT_P) {
            final i = (controls.UI_UP_P || controls.UI_DOWN_P) ? 1 : 0;
            final delta = int( ((controls.UI_DOWN_P || controls.UI_RIGHT_P) ? 1 : -1) * scrollMult[i] );

            changeItem(delta, i);
        }

        if (allowMouseWheel && FlxG.mouse.wheel != 0 && lead != 1) changeItem(int(-FlxG.mouse.wheel * scrollMult[lead]));

        if (controls.BACK) { 
            if (canLeave) onExit.dispatch();
            else onExitAttempt.dispatch();
        }
    }

    public function changeItem(delta:Int, ?index:Int) {
        index ??= lead ?? 0;

        curSelected[index] += delta;
        if (allowWrapping)
            curSelected[index] %= optionOrder.length;
            if (curSelected[index] < 0) curSelected[index] = optionOrder.length-1;
        else
            curSelected[index] = FlxMath.wrap(curSelected[index], 0, optionOrder.length-1);
        
        onItemChanged.dispatch();
    }

    private function __enter() {
        onEnterPressed.dispatch();
        options.get(optionOrder[curSelected[lead]])();
    }
}