package ui;

@:access(ui.UITheme)
class GhostUIButton extends BaseButton {
    public var label:FlxText;
    public var text(default, set):String = '';

    var colors:MouseInteractableColors = {};
    var labelColors:MouseInteractableColors = {};
    var targetColor:FlxColor;
    var targetLabelColor:FlxColor;

    public function new(x:Float, y:Float, ?text:String = '_button_', ?width:Int, ?height:Int) {
        super(x, y);

        colors = UITheme._getColors().button;
        labelColors = UITheme._getColors().label;

        sprite.makeGraphic(width, height, -1);
        
        label = new FlxText(0, (height*0.6)/4, width, text);
        label.setFormat(Paths.font('vcr.ttf'), int(height * 0.6), -1, CENTER);
        add(label);

        targetColor = colors.base;
        targetLabelColor = labelColors.base;
        onPress.add(() -> {
            sprite.color = colors.pressed;
            label.color = labelColors.pressed;
        });
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        targetColor = hovered ? (FlxG.mouse.pressed ? colors.pressed : colors.hovered) : colors.base;
        targetLabelColor = hovered ? (FlxG.mouse.pressed ? labelColors.pressed : labelColors.hovered) : labelColors.base;

        sprite.color = FlxColor.interpolate(sprite.color, targetColor, .3);
        label.color = FlxColor.interpolate(label.color, targetLabelColor, .3);
    }

    private function set_text(value:String) return text = label.text = value;
}