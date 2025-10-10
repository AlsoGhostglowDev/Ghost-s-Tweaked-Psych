package ui;

enum Themes {
    DARK;
    LIGHT;
}

typedef MouseInteractableColors = {
    @:optional var base:FlxColor;
    @:optional var pressed:FlxColor;
    @:optional var hovered:FlxColor;
}

@:structInit class ColorFields {
    @:optional public var accentColor:FlxColor;
    @:optional public var inversedAccent:FlxColor;
    @:optional public var button:MouseInteractableColors = {};
    @:optional public var label:MouseInteractableColors = {};
    @:optional public var header:MouseInteractableColors = {};
    @:optional public var headerLabel:MouseInteractableColors = {};
}

@:keep class UITheme {
    private static var __colors:Map<String, Map<Themes, FlxColor>> = [
        // Accent
        'accentColor' => [ 
            DARK => 0xFF1D1D1D,
            LIGHT => 0xFFFFFFFF
        ],
        'inversedAccent' => [
            DARK => 0xFFFFFFFF,
            LIGHT => 0xFF1D1D1D
        ],

        // Button
        'button_base' => [ 
            DARK => 0xFF161616,
            LIGHT => 0xFFA3A3A3
        ],
        'button_hovered' => [ 
            DARK => 0xFF404040,
            LIGHT => 0xFF464646
        ],
        'button_pressed' => [ 
            DARK => 0xFF707070,
            LIGHT => 0xFF1C1C1C
        ],

        'label_base' => [ 
            DARK => 0xFFE1E1E1,
            LIGHT => 0xFF464646
        ],
        'label_hovered' => [ 
            DARK => 0xFFD3D3D3,
            LIGHT => 0xFFA3A3A3
        ],
        'label_pressed' => [ 
            DARK => 0xFF2C2C2C,
            LIGHT => 0xFFFFFFFF
        ],

        // Header
        'header_base' => [ 
            DARK => 0xFFFFFFFF,
            LIGHT => 0xFF000000
        ],
        'header_hovered' => [ 
            DARK => 0xFFC9C9C9,
            LIGHT => 0xFF272727
        ],
        'header_pressed' => [ 
            DARK => 0xFF464646,
            LIGHT => 0xFFFFFFFF
        ],

        'headerLabel_base' => [ 
            DARK => 0xFF000000,
            LIGHT => 0xFFFFFFFF
        ],
        'headerLabel_hovered' => [ 
            DARK => 0xFF1A1A1A,
            LIGHT => 0xFFD3D3D3
        ],
        'headerLabel_pressed' => [ 
            DARK => 0xFFD5D5D5,
            LIGHT => 0xFF000000
        ],
    ];

    public static var accentColor(get, null):FlxColor;
    public static var inversedAccent(get, null):FlxColor;

    public static var buttonBase(get, null):FlxColor;
    public static var buttonPressed(get, null):FlxColor;
    public static var buttonHovered(get, null):FlxColor;

    public static var labelBase(get, null):FlxColor;
    public static var labelPressed(get, null):FlxColor;
    public static var labelHovered(get, null):FlxColor;

    public static var headerBase(get, null):FlxColor;
    public static var headerPressed(get, null):FlxColor;
    public static var headerHovered(get, null):FlxColor;

    public static var headerLabelBase(get, null):FlxColor;
    public static var headerLabelPressed(get, null):FlxColor;
    public static var headerLabelHovered(get, null):FlxColor;

    public static var defaultTheme:Themes = DARK;
    public static var curTheme(default, set):Themes = DARK;
    public static var onThemeChanged:FlxTypedSignal<Themes->Void>;

    public static function init() {
        onThemeChanged = new FlxTypedSignal<Themes->Void>();
        curTheme = defaultTheme;
    }

    private static function _getColors(?theme:Themes):ColorFields {
        var colorFields:ColorFields = {};
        theme ??= DARK;

        for (k => color in __colors) {
            if (k.contains('_')) {
                var element = k.split('_')[0];
                var field = k.split('_')[1];

                Reflect.setField(Reflect.field(colorFields, element), field, color.get(theme));
            } else {
                Reflect.setField(colorFields, k, color.get(theme));
            }
        }
        
        return colorFields;
    }

    private static function get_accentColor() return _getColors().accentColor;
    private static function get_inversedAccent() return _getColors().inversedAccent;

    private static function get_buttonBase()    return _getColors().button.base;
    private static function get_buttonHovered() return _getColors().button.hovered;
    private static function get_buttonPressed() return _getColors().button.pressed;

    private static function get_labelBase()    return _getColors().label.base;
    private static function get_labelHovered() return _getColors().label.hovered;
    private static function get_labelPressed() return _getColors().label.pressed;

    private static function get_headerBase()    return _getColors().header.base;
    private static function get_headerHovered() return _getColors().header.hovered;
    private static function get_headerPressed() return _getColors().header.pressed;

    private static function get_headerLabelBase()    return _getColors().headerLabel.base;
    private static function get_headerLabelHovered() return _getColors().headerLabel.hovered;
    private static function get_headerLabelPressed() return _getColors().headerLabel.pressed;

    private static function set_curTheme(value:Themes) {
        onThemeChanged.dispatch(value);
        return curTheme = value;
    }
}