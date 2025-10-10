package substates;

import states.editors.*;
import states.WarningState;
import states.MainMenuState;
import objects.Alphabet;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.effects.FlxFlicker;

class EditorSelectionSubState extends SelectableSubState {
    public var items:FlxTypedGroup<SelectionSprite>; 

    public function new() {
        super(new KeyValueArray<Void->Void>(['Chart', 'Character', 'Modchart', 'Stage', 'Week', 'Menu Character', 'Dialogue', 'Dialogue Character', 'Note Splashes'], [
            () -> LoadingState.loadAndSwitchState(new ChartingState(), false),
			() -> LoadingState.loadAndSwitchState(new CharacterEditorState(objects.Character.DEFAULT_CHARACTER, false)),
            () -> LoadingState.loadAndSwitchState(new ModchartEditorState(), false),
            () -> MusicBeatState.switchState(new WarningState('W.I.P',
				'Hey there! The <*>stage editor<*> is currently\n' +
                'in a <!>work of progress<!>. Sorry for the inconvinience.',
				{enter: ()->{}, back: ()->{}, both: () -> {
                    trace('TODO: Stage Editor');
					MusicBeatState.switchState(new MainMenuState());
                }}
			)),
			() -> MusicBeatState.switchState(new WeekEditorState()),
			() -> MusicBeatState.switchState(new MenuCharacterEditorState()),
			() -> LoadingState.loadAndSwitchState(new DialogueEditorState(), false),
			() -> LoadingState.loadAndSwitchState(new DialogueCharacterEditorState(), false),
			() -> MusicBeatState.switchState(new NoteSplashDebugState())
        ]), new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000).pixels);

        @:privateAccess _bg.alpha = 0.5;

        scrollMult = [0, 1];
        lead = 1;
        allowEnter = false;

        onEnterPressed.add( () -> trace('Enter has been pressed') );
        onItemChanged.add( () -> {
            FlxG.sound.play(Paths.sound('scrollMenu'));

            for (item in items) item.selected = false;
            items.members[curSelected[1]].selected = true;
        });
        onExit.add(close);

        items = new FlxTypedGroup<SelectionSprite>();
        add(items);
    }

    override function create() {
        super.create();

        for (i => option in optionOrder) {
            var item = new SelectionSprite(0, FlxG.height/4 * i, int(FlxG.height/4), Paths.image('editors/master/unknown'), '$option Editor');
            item.onPress = options.get(option);
            items.add(item);
        }
        onItemChanged.dispatch();
    }

    var mouseTimeout:Float = 0;
    var usingMouse(default, set):Bool = true;
    function set_usingMouse(value:Bool) {
        for (item in items) item.useMouse = value;
        return usingMouse = value;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (mouseTimeout < 1) mouseTimeout += elapsed;
        if (mouseTimeout > 1 && usingMouse) { mouseTimeout = 0 ; usingMouse = false; }
    
        final mouseActivity = FlxG.mouse.wheel != 0 || FlxG.mouse.deltaX != 0 || FlxG.mouse.deltaY != 0 || FlxG.mouse.justPressed || FlxG.mouse.justPressedRight || FlxG.mouse.justPressedMiddle;
        if (mouseActivity && FlxG.mouse.visible) {
            mouseTimeout = 0;
            usingMouse = true;
        }

        if (usingMouse && FlxG.mouse.wheel != 0) changeItem(-FlxG.mouse.wheel);
        if (controls.ACCEPT) accept();

        for (i => item in items.members) {
            item.y = FlxMath.lerp(item.y, (FlxG.height/4) * (i - (curSelected[1] > 2 ? (curSelected[1] < optionOrder.length-1 ? curSelected[1] - 2 : curSelected[1] - 3) : 0)), .25);
        }
    }

    function accept() items.members[curSelected[1]].select();
}

class SelectionSprite extends FlxSpriteGroup {
    public var selected:Bool = false;
    public var useMouse:Bool = false;
    public var onPress:Void->Void;
    var background:FlxSprite;
    var thumbnail:FlxSprite;
    var title:Alphabet;

    public function new(?x:Float, ?y:Float, height:Int, thumb:FlxGraphicAsset, titleText:String) {
        super(x, y);

        background = new FlxSprite().makeGraphic(FlxG.width, height, FlxColor.WHITE);
        background.alpha = 0.2;
        add(background);

        thumbnail = new FlxSprite(2.5, 2.5).loadGraphic(thumb);
        thumbnail.setGraphicSize(height - 10, height - 10);
        thumbnail.updateHitbox();
        add(thumbnail);

        title = new Alphabet(height + 10, (height - 60) / 2, titleText, true);
		add(title);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        for (item in this)
            item.alpha = FlxMath.lerp(item.alpha, ((FlxG.mouse.overlaps(this) && useMouse) || selected) ? item == background ? 0.5 : 1 : item == background ? 0.2 : 0.7, 0.2);
        
        if (FlxG.mouse.overlaps(this) && FlxG.mouse.justPressed && useMouse) select();
    }

    public function select() {
        FlxG.sound.play(Paths.sound('confirmMenu'));
        background.alpha = 1;
        background.color = 0xFF82FFDA;
        FlxFlicker.flicker(this, 1, 0.06, false, false, (_) -> {
            if (onPress != null) onPress();
        });
    }
}