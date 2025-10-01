package objects;

import psychlua.LuaUtils;

class CinematicBars extends FlxSpriteGroup {
    public var topBar:FlxSprite;
    public var bottomBar:FlxSprite;
    public var barColor(default, set):FlxColor;
    private function set_barColor(col:FlxColor) {
        topBar.color = bottomBar.color = col;
        return barColor = col;
    }

    var _division:Float;
    var _topTwn:FlxTween;
    var _bottomTwn:FlxTween;
    var _toggle:Bool = false;

    public function new() {
        super();

        topBar = new FlxSprite(0, -FlxG.height).makeGraphic(1, 1, FlxColor.WHITE);
        bottomBar = new FlxSprite(0, FlxG.height).makeGraphic(1, 1, FlxColor.WHITE);

        /* Makes the game only draw 1 pixel but stretching it across the screen. */
        topBar.scale.set(FlxG.width, FlxG.height);
        topBar.updateHitbox();
        bottomBar.scale.set(FlxG.width, FlxG.height);
        bottomBar.updateHitbox();

        add(topBar);
        add(bottomBar);

        barColor = FlxColor.BLACK;
        _division = 7;
    }

    public function tweenToDiv(division:Float, duration:Float, ?ease:String = 'linear') {
        if (topBar == null || bottomBar == null) {
            error('tweenToDiv: topBar or bottomBar is null.');
            return;
        }

        if (!_toggle) _toggle = true;
        _division = division;

        final tweenEase = LuaUtils.getTweenEaseByString(ease);
        if (_topTwn != null) _topTwn.cancel();
        _topTwn = FlxTween.tween(topBar, {y: (-FlxG.height) + (FlxG.height / division)}, duration, {ease: tweenEase, onComplete: (_) -> _topTwn = null});
        if (_bottomTwn != null) _bottomTwn.cancel();
        _bottomTwn = FlxTween.tween(bottomBar, {y: FlxG.height - (FlxG.height / division)}, duration, {ease: tweenEase, onComplete: (_) -> _bottomTwn = null});
    }

    public function toggle(?duration:Float = 1, ?ease:String = 'linear') {
        _toggle = !_toggle;

        if (_toggle)
            tweenToDiv(_division, duration, ease);
        else {
            final tweenEase = LuaUtils.getTweenEaseByString(ease);
            if (_topTwn != null) _topTwn.cancel();
            _topTwn = FlxTween.tween(topBar, {y: -FlxG.height}, duration, {ease: tweenEase, onComplete: (_) -> _topTwn = null});
            if (_bottomTwn != null) _bottomTwn.cancel();
            _bottomTwn = FlxTween.tween(bottomBar, {y: FlxG.height}, duration, {ease: tweenEase, onComplete: (_) -> _bottomTwn = null});
        }
    }
}