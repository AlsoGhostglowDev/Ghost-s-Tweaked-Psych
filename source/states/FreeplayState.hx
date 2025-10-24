package states;

import flixel.system.FlxAssets.FlxGraphicAsset;
import backend.WeekData;
import backend.WeekData.*;
import objects.*;

class FreeplayState extends SelectableMenu {
    public static var vocals:FlxSound;
    public static var staticSelect:Int = 0;

    public static function destroyFreeplayVocals() {

    }

    public var curSong(get, never):String;
    function get_curSong() {
        var selectedItem = items.getFirstSelected();

        @:privateAccess
        return selectedItem != null ? selectedItem.songName : 'null';
    }

    var targetScroll:Float = 0;
    var targetColor:FlxColor = 0xFFFFFFFF;

    var items:FreeplayItemGroup;
    var weeks:FlxTypedSpriteGroup<FreeplayWeekGroup>;

    public function new() {
        super(
            new KeyValueArray<Void->Void>(
                [], 
                []
        ), Paths.image('menuDesat'));

        items = new FreeplayItemGroup();

        weeks = new FlxTypedSpriteGroup<FreeplayWeekGroup>();
        add(weeks);

        reloadWeekFiles(false); // called from WeekData

        var songsAdded:Int = 0;
        for (i => week in weeksList) {
            var grpWeek = new FreeplayWeekGroup(25, 25 + songsAdded * (100 + 45), week);
            weeks.add(grpWeek);

            trace(
                '\n    registered week: ' + week +
                '\n    songs: ' + weeksLoaded.get(week).songs.toString() +
                '\n'
            );

            for (songData in weeksLoaded.get(week).songs) {
                songsAdded++;

                final songName = songData[0];
                optionOrder.push(songName);
                options.set(songName, () -> trace('selected $songName'));
            }
        }

        for (week in weeks) {
            for (item in week) {
                if (item is FreeplayItem)
                    items.add(cast item);
            }
        }

        @:privateAccess _bg.scrollFactor.set();

        scrollMult = [0, 1];
        lead = 1;

        onItemChanged.add( (delta:Int, index:Int) -> {
            if (index == 1) {
                FlxG.sound.play(Paths.sound('scrollMenu'));

                @:privateAccess
                items.members[__previousIndex[1]].selected = false;
                items.members[curSelected[1]].selected = true;

                targetScroll = FlxMath.bound(
                    items.members[curSelected[1]].y - FlxG.camera.height / 2 + items.members[curSelected[1]].height / 2,
                    0, items.height - FlxG.camera.height + 100
                );

                targetColor = FlxColor.fromRGB(
                    items.members[curSelected[1]].songData.colors[0],
                    items.members[curSelected[1]].songData.colors[1],
                    items.members[curSelected[1]].songData.colors[2]
                );
                
                trace('[${curSelected[1]}] Selected Song: $curSong');
            }
        } );

        changeItem(0, 0);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        for (item in items)
            item.x = FlxMath.lerp(item.x, item.selected ? 60 : 25, .2);

        FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, targetScroll, .1);

        @:privateAccess
        _bg.color = FlxColor.interpolate(_bg.color, targetColor, .1);
    }
}

@:structInit class SongData {
    public var name:String = 'tutorial';
    public var character:String = 'face';
    public var colors:Array<Int> = [146, 113, 253];
}

class FreeplayWeekData {
    public var weekName(default, set):String = 'tutorial'; // fail-safe as long as week tutorial exists
    public var weekData:WeekData;
    public var songs:Array<SongData> = [];
    public var locked:Bool = false;

    public function new(weekName:String, ?locked:Bool = false) {
        this.weekName = weekName;
        this.locked = locked;

        for (data in weekData.songs) {
            var songData:SongData = {
                name: data[0],
                character: data[1],
                colors: data[2]
            };

            if (songData.colors == null || songData.colors.length < 3)
                songData.colors = [146, 113, 253];

            songs.push(songData);
            trace('Added song "${songData.name}" to freeplay week "$weekName"');
        }
    }

    function set_weekName(newWeek:String) {
        if (weeksLoaded.exists(newWeek)) {
            weekData = weeksLoaded.get(newWeek);
        } else {
            @:privateAccess
            weekData = new WeekData(getWeekFile(getValidPath(newWeek)), weekName);
        }
        return weekName = newWeek;
    }

    function getValidPath(weekName:String):String {
        var directories = [#if MODS_ALLOWED Paths.mods(), #end Paths.getSharedPath()];
        #if MODS_ALLOWED
        for (mod in Mods.parseList().enabled)
            directories.push(Paths.mods(mod + '/'));
        #end

        for (dir in directories) {
            var path:String = dir + 'weeks/' + weekName + '.json';
            if (FileSystem.exists(path)) {
                return path;
            }
        }
        return '';
    }
}

class FreeplayWeekGroup extends FreeplayItemGroup {
    public var week:String = '';
    public var selected(get, never):Bool;
    public var locked(get, never):Bool;
    public var meta:FreeplayWeekData;

    var weekTxt:FlxText;
    var weekBackground:FlxGraphicAsset;

    function get_selected() return getFirstSelected() != null;
    function get_locked() {
        return false; // TODO: implement week locking
    }

    public function new(x:Float, y:Float, week:String, ?weekBackground:FlxGraphicAsset) {
        super(x, y);

        this.week = week;
        this.weekBackground = weekBackground ?? Paths.image('menuDesat');

        loadWeek(week);

        weekTxt = new FlxText(0, 0, 0, meta.weekData.weekName)
            .setFormat(Paths.font('funkin.ttf'), 28, 0xFF000000, LEFT, OUTLINE, -1);
        weekTxt.borderSize = 1;

        for (i => song in getSongs()) {
            var item = new FreeplayItem(meta, 25, i * 115 + 35, song, getIcon(song));
            add(item);
        }
    }

    function getSongs():Array<String> {
        var ret = [];
        for (song in meta.songs)
            ret.push(song.name);

        return ret;
    }

    function getIcon(songName:String) {
        for (songData in meta.songs) {
            if (songData.name == songName)
                return songData.character;
        }
        return 'face';
    }

    function loadWeek(weekName:String)
        return meta = new FreeplayWeekData(weekName);

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
    // Information
    public var songName:String;
    public var songPB:Int;
    public var songRating:String;

    public var weekData:FreeplayWeekData;
    public var songData:SongData;

    // Objects
    var background:FlxSprite;
    var icon:HealthIcon;
    var songTxt:FlxText;
    var pbTxt:FlxText;
    var ratingTxt:FlxText;

    // used to get the icon color
    var opponent:Character;
    var iconColor(get, never):FlxColor;
    private function get_iconColor()
        return FlxColor.fromRGB(
            opponent.healthColorArray[0],
            opponent.healthColorArray[1],
            opponent.healthColorArray[2]
        );

    public var selected:Bool = false;

    public function new(weekData:FreeplayWeekData, x:Float, y:Float, songName:String, char:String) {
        super(x, y);

        this.weekData = weekData;
        for (songData in weekData.songs)
            if (songData.name == songName)
                this.songData = songData;
        
        background = new FlxSprite()
            .makeGraphic(1, 1, 0xFFFFFFFF);
        background.alpha = 0.6;
        add(background);

        opponent = new Character(0, 0, char);

        icon = new HealthIcon(char, false);
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