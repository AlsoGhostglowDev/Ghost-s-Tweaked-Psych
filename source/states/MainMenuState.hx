package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import options.OptionsState;
import objects.CinematicBars;
import flixel.util.FlxSignal.FlxTypedSignal;

class MainMenuState extends SelectableMenu {
    var menuItems:FlxTypedGroup<FlxSprite>;
    var buttonItems:FlxTypedGroup<FlxSprite>;
    var arrowButtons:FlxTypedGroup<FlxSprite>;
    var cinematicBars:CinematicBars;

    var curSelectedItem:FlxSprite;
    var _pressedEnter = false;
    
    var buttonRedirect:Map<String, Void->Void> = [];

	public function new() {
        super(new KeyValueArray<Void->Void>(['story_mode', 'freeplay', 'credits', 'donate', 'mods'], [
            () -> transition(menuItems.members[0], () -> MusicBeatState.switchState(new StoryMenuState())),
            () -> transition(menuItems.members[1], () -> MusicBeatState.switchState(new FreeplayState())),
            () -> transition(menuItems.members[2], () -> MusicBeatState.switchState(new CreditsState())),
            () -> trace('Donate Button'),
            () -> transition(menuItems.members[4], () -> MusicBeatState.switchState(new ModsMenuState()))
        ]), Paths.image('menuBG'));
        buttonRedirect = [
            "options"      => () -> transition(buttonItems.members[0], () -> MusicBeatState.switchState(new OptionsState())),
            "achievements" => () -> transition(buttonItems.members[1], () -> MusicBeatState.switchState(new AchievementsMenuState()))
        ];

        scrollMult = [1, 0];
        onItemChanged.add( (delta:Int) -> {
            FlxG.sound.play(Paths.sound('scrollMenu'));
            curSelectedItem = menuItems.members[curSelected[0]];

            curSelectedItem.animation.play('selected');
            curSelectedItem.alpha = 1;
            for (i => item in menuItems) { 
                if (i != curSelected[0]) {
                    item.animation.play('idle');
                    item.alpha = 0.7;
                }
                item.centerOffsets();
            }

            if (delta != 0)
                arrowButtons.members[delta < 0 ? 0 : 1].x += delta * 30;
        });
        onExit.add( () -> MusicBeatState.switchState(new TitleState()));

        @:privateAccess {
            _bg.scale.set(1.25, 1.25);
            _bg.y -= 25;
            _bg.updateHitbox();
        }

        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);

        cinematicBars = new CinematicBars();
        cinematicBars.toggle(1, 'expoOut');
        add(cinematicBars);

        buttonItems = new FlxTypedGroup<FlxSprite>();
        add(buttonItems);

        arrowButtons = new FlxTypedGroup<FlxSprite>();
        add(arrowButtons);

        FlxG.mouse.visible = true;
    }

    override function create() {
        super.create();

        for (i => option in optionOrder) {
            var menuItem:FlxSprite = new FlxSprite(0, 0);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + option);
			menuItem.animation.addByPrefix('idle', option + " basic", 24);
			menuItem.animation.addByPrefix('selected', option + " white", 24);
			menuItem.animation.play('idle');
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.updateHitbox();
			menuItem.screenCenter(XY);
            menuItem.x += (FlxG.width / 2) * i;
        }
        curSelectedItem = menuItems.members[0];
        onItemChanged.dispatch(0);

        for (i in 0...2) {
            var arrow = new FlxSprite(i == 0 ? 40 : FlxG.width - (209 * 0.4) - 40);
            arrow.loadGraphic(Paths.image('mainmenu/menu_arrow'), true, 209, 358);
            arrow.animation.add('idle', [0, 1, 2], 12, true);
            arrow.animation.play('idle');
            arrow.scale.set(0.4, 0.4); arrow.updateHitbox();
            arrow.screenCenter(Y);
            arrow.flipX = i == 0;
            arrowButtons.add(arrow);
        }

        for (i => button in ['options', 'achievements']) {
            var buttonItem = new MenuButton(FlxG.width - (150 * (i+1)), FlxG.height - 150, button);
            buttonItem.onClick.add(buttonRedirect.get(button));
            buttonItems.add(buttonItem);
        }

        var modVer:FlxText = new FlxText(12, FlxG.height - 64, 0, Mods.getPack()?.name ?? 'No Mods Loaded', 12);
		modVer.scrollFactor.set();
		modVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(modVer);
		if (Mods.getPack() != null) modVer.text += ' v${Global.modVersion}';

		var gtpVer:FlxText = new FlxText(12, FlxG.height - 44, 0, 'Ghost\'s Tweaked Psych v${Global.forkVersion}', 12);
		gtpVer.scrollFactor.set();
		gtpVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(gtpVer);

		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, 'Friday Night Funkin\' v${Global.fnfVersion}', 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.keys.justPressed.SEVEN) openSubState(new substates.EditorSelectionSubState());

        for (i => item in menuItems) {
            item.x = FlxMath.lerp(item.x, (FlxG.width - item.width) / 2 + ((FlxG.width / 2) * (i - curSelected[0])), 0.2);
            item.scale.x = item.scale.y = FlxMath.lerp(item.scale.x, i == curSelected[0] ? 1 : 0.8, 0.2);
        }

        if (FlxG.mouse.overlaps(curSelectedItem) && FlxG.mouse.justPressed) options.get(optionOrder[curSelected[0]])();

        for (i => arrow in arrowButtons) {
            arrow.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
            if (FlxG.mouse.overlaps(arrow)) {
                arrow.setColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);
                if (FlxG.mouse.justPressed) changeItem(i == 0 ? -1 : 1);
            }

            arrow.x = FlxMath.lerp(arrow.x, i == 0 ? 40 : FlxG.width - (209 * 0.4) - 40, 0.2);
        }

        @:privateAccess
        _bg.x = FlxMath.lerp(_bg.x, -(( (_bg.width - FlxG.width) / optionOrder.length) * curSelected[0] ), 0.2);
    }

    function transition(item:FlxSprite, func:Void->Void) {
        if (!_pressedEnter) {
            _pressedEnter = true;
            cinematicBars.tweenToDiv(6.5, .8, 'expoOut');
            FlxG.sound.play(Paths.sound('confirmMenu'));

            FlxTween.tween(FlxG.camera, {zoom: 1.5}, .8, {ease: FlxEase.expoOut});
            @:privateAccess FlxTween.tween(_bg, {alpha: 0.6}, .8, {ease: FlxEase.expoOut});
            if (buttonItems.members.contains(item)) {
                FlxTween.tween(item, {
                    x: (FlxG.width - item.width) / 2,
                    y: (FlxG.height - item.height) / 2,
                    "scale.x": 1.5,
                    "scale.y": 1.5
                }, .6, {ease: FlxEase.expoOut});
                for (item in menuItems) FlxTween.tween(item, {alpha: 0.15}, .6, {ease: FlxEase.expoOut});
            }

            new flixel.util.FlxTimer().start(0.8, (_) -> {
                FlxTween.tween(FlxG.camera, {zoom: 3}, .5, {ease: FlxEase.smootherStepIn});
            });
            FlxFlicker.flicker(item, 1, 0.06, false, false, (_) -> func());
        }
    }
}

private class MenuButton extends FlxSprite {
    public var onClick:FlxTypedSignal<Void->Void>;
    var _wasHovered:Bool = false; 

    public function new(x:Float, y:Float, graphic:String) {
        super(x, y);
        frames = Paths.getSparrowAtlas('mainmenu/button/menu_' + graphic);
        antialiasing = ClientPrefs.data.antialiasing;
        animation.addByPrefix('idle', graphic + " idle", 24, false);
		animation.addByPrefix('selected', graphic + " selected", 24, false);
        animation.play('idle');
        scrollFactor.set();
        scale.set(0.7, 0.7);
        updateHitbox();

        onClick = new FlxTypedSignal<Void->Void>();
    }

    override function update(elapsed) {
        super.update(elapsed);

        if (FlxG.mouse.overlaps(this)) {
            if (FlxG.mouse.justPressed) onClick.dispatch();
            if (!_wasHovered) {
                _wasHovered = true;
                animation.play('selected', false);

                FlxG.sound.play(Paths.sound('scrollMenu'));
                centerOrigin(); centerOffsets();
            }
        } else if (!FlxG.mouse.overlaps(this) && _wasHovered) { 
            _wasHovered = false;
            animation.play('idle', false);
            centerOrigin(); centerOffsets();
        }
    }
} 