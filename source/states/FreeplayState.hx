package states;

import flixel.system.FlxAssets.FlxGraphicAsset;
import objects.*;

class FreeplayState extends SelectableMenu {
    public static var vocals:FlxSound;
    public static var staticSelect:Int = 0;

    public static function destroyFreeplayVocals() {

    }

    var items:FreeplayItemGroup;
    var weeks:FlxTypedSpriteGroup<FreeplayWeekGroup>;

    public function new() {
        super(
            new KeyValueArray<Void->Void>(['Bopeebo', 'Fresh', 'Dadbattle', 'Bopeebo', 'Fresh', 'Dadbattle'], [
                () -> trace('OMG'),
                () -> trace('OMG2'),
                () -> trace('OMG6'),
                () -> trace('OM7'),
                () -> trace('OMG8'),
                () -> trace('OMG9')
            ]
        ), Paths.image('menuDesat'));

        items = new FreeplayItemGroup();

        weeks = new FlxTypedSpriteGroup<FreeplayWeekGroup>();
        add(weeks);

        var week1 = new FreeplayWeekGroup(25, 25, 'Week 1');
        weeks.add(week1);

        var week2 = new FreeplayWeekGroup(25, (FlxG.height / 2) + 35, 'Guess what, Week 1');
        weeks.add(week2);

        for (week in weeks) {
            for (item in week) {
                if (item is FreeplayItem)
                    items.add(cast item);
            }
        }

        scrollMult = [0, 1];
        lead = 1;

        onItemChanged.add( (delta:Int, index:Int) -> {
            if (index == 1) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                if (delta != 0) {
                    @:privateAccess
                    items.members[__previousIndex[1]].selected = false;
                    items.members[curSelected[1]].selected = true;
                }
            }
        } );

        changeItem(0, 0);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        for (item in items)
            item.x = FlxMath.lerp(item.x, item.selected ? 60 : 25, .2);
    }
}

class FreeplayWeekGroup extends FreeplayItemGroup {
    public var week:String = '';
    public var selected(get, never):Bool;

    var weekTxt:FlxText;
    var weekBackground:FlxGraphicAsset;

    function get_selected() return getFirstSelected() != null;

    public function new(x:Float, y:Float, week:String, ?weekBackground:FlxGraphicAsset) {
        super(x, y);

        this.week = week;
        this.weekBackground = weekBackground ?? Paths.image('menuDesat');

        weekTxt = new FlxText(0, 0, 0, week)
            .setFormat(Paths.font('funkin.ttf'), 28, 0xFF000000, LEFT, OUTLINE, -1);
        weekTxt.borderSize = 1;

        for (i => song in ['Bopeebo', 'Fresh', 'Dadbattle']) {
            var item = new FreeplayItem(25, i * 115 + 35, song);
            add(item);
        }
    }

    override function draw() {
        super.draw();
        weekTxt.setPosition(x, y);
        weekTxt.draw();
    }
}

class FreeplayItemGroup extends FlxTypedSpriteGroup<FreeplayItem> {
    public function getFirstSelected():Null<FreeplayItem> {
        for (item in this)
            if (item.selected) return item;

        return null;
    }
}

class FreeplayItem extends FlxSpriteGroup {
    var songName:String;
    var songPB:Int;
    var songRating:String;

    var background:FlxSprite;
    var icon:HealthIcon;
    var songTxt:FlxText;
    var pbTxt:FlxText;
    var ratingTxt:FlxText;

    var opponent:Character;
    var iconColor(get, never):FlxColor;
    private function get_iconColor()
        return FlxColor.fromRGB(
            opponent.healthColorArray[0],
            opponent.healthColorArray[1],
            opponent.healthColorArray[2]
        );

    public var selected:Bool = false;

    public function new(x:Float, y:Float, songName:String) {
        super(x, y);
        
        background = new FlxSprite()
            .makeGraphic(1, 1, 0xFFFFFFFF);
        background.alpha = 0.6;
        add(background);

        opponent = new Character(0, 0, 'dad');

        icon = new HealthIcon('dad', false);
        icon.scale.set(0.5, 0.5); 
        icon.updateHitbox(); 
        icon.centerOffsets();
        icon.setPosition(10, 10);
        add(icon);

        songTxt = new FlxText(icon.width + 25, 12, 0, songName)
            .setFormat(Paths.font('funkin.ttf'), 32, -1, LEFT, OUTLINE, 0xFF000000);
        songTxt.borderSize = 2;
        add(songTxt);

        pbTxt = new FlxText(icon.width + 25, icon.height - 12, 0, 'PB: 0')
            .setFormat(Paths.font('funkin.ttf'), 18, -1, LEFT, OUTLINE, 0xFF000000);
        pbTxt.borderSize = 1;
        add(pbTxt);

        ratingTxt = new FlxText(0, icon.height - 12, 0, 'N/A')
            .setFormat(Paths.font('funkin.ttf'), 18, -1, LEFT, OUTLINE, 0xFF000000);
        ratingTxt.borderSize = 1;
        add(ratingTxt);

        background.scale.set( 
            500,
            icon.height + 20
        );
        background.updateHitbox();
        ratingTxt.x = background.width - ratingTxt.width - 20;

        this.songName = songName;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        final targetColor = selected ? iconColor : 0xFF000000;
        final targetAlpha = selected ? 0.6 : 0.45;
        background.color = FlxColor.interpolate(background.color, targetColor, .2);
        background.alpha = FlxMath.lerp(background.alpha, targetAlpha, .2);
    }
}

class Jukebox extends FlxSpriteGroup {
    // todo: finish this
}