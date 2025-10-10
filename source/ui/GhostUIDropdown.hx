package ui;

@:access(ui.UITheme)
class GhostUIDropdown extends GhostUIButton {
    public var name(default, set):String;
    public var show(default, set):Bool = false;

    var toggleButton:GhostUIButton;
    var toggleIndicator:Map<String, String> = [
        'true' => '▲',
        'false' => '▼'
    ];

    var buttonWidth:Int;
    var buttonHeight:Int;
    var __dropdownList:Array<String> = [];
    var __dropdownButtons:Array<DropdownButton> = [];

    public function new(x:Float, y:Float, name:String, width:Int, height:Int, ?show:Bool = false) {
        super(x, y, name, width, height);

        colors = UITheme._getColors().header;
        labelColors = UITheme._getColors().headerLabel;

        this.name = name;
        this.show = show;
        buttonWidth = width;
        buttonHeight = height;
        pressTarget = sprite;
        onPress.add(toggleShow);

        toggleButton = new GhostUIButton(width, 0, getIndicator(), height, height);
        toggleButton.colors = DropdownButton.defaultColors.button;
        toggleButton.labelColors = DropdownButton.defaultColors.label;
        toggleButton.onPress.add(toggleShow);
        add(toggleButton);

        FlxSpriteUtil.drawRect(toggleButton.sprite, 0, 0, height, height, UITheme.inversedAccent,
            {thickness: 2},
            {smoothing: ClientPrefs.data.antialiasing}
        );
    }

    public function addButton(label:String, ?onPress:Void->Void) {
        var button = new DropdownButton(this, 0, (__dropdownList.length + 1) * buttonHeight, label);
        button.visible = button.allowPressing = show;
        if (onPress != null) button.onPress.add(onPress);
        add(button);

        __dropdownList.push(label);
        __dropdownButtons.push(button);
    }

    function getIndicator() return toggleIndicator.get(string(show));
    function toggleShow() {
        show = !show;
        toggleButton.text = getIndicator();
    }

    private function set_name(value:String) {
        return name = label.text = value;
    }

    private function set_show(value:Bool) {
        allowPressing = value;
        for (button in __dropdownButtons) {
            button.visible = button.allowPressing = value;
        }

        return show = value;
    }
}

@:access(ui.GhostUIDropdown)
class DropdownButton extends GhostUIButton {
    public var parent:GhostUIDropdown;
    public static var defaultColors = {
        button: {
            base: 0xFFA2A2A2,
            hovered: 0xFF838383,
            pressed: 0xFF4E4E4E
        },
        label: {
            base: 0xFF000000,
            hovered: 0xFF232323,
            pressed: 0xFFC6C6C6
        }
    };

    public function new(parent:GhostUIDropdown, ?x:Float, ?y:Float, ?label:String = '_dropdown_', ?colors:MouseInteractableColors, ?labelColors:MouseInteractableColors) {
        super(x, y, label, parent.buttonWidth, parent.buttonHeight);
        this.parent = parent;

        this.colors = colors ?? defaultColors.button;
        this.labelColors = labelColors ?? defaultColors.label;

        this.label.alignment = LEFT;
        this.label.x += 4; this.label.fieldWidth -= 8;

        // cool outline :D
        FlxSpriteUtil.drawRect(sprite, 0, 0, parent.buttonWidth, parent.buttonHeight, UITheme.inversedAccent,
            {thickness: 2},
            {smoothing: ClientPrefs.data.antialiasing}
        );
    }
}