package states.editors;

import flixel.group.FlxGroup.FlxTypedGroup;

import objects.StrumNote;
import backend.BaseStage;
import states.stages.StageWeek1 as BackgroundStage;
import states.PlayState;

class ModchartEditorState extends MusicBeatState {
    var camGame:FlxCamera;
    var camHUD:FlxCamera;
    var camUI:FlxCamera;

    var stage:BaseStage;

    var playerStrums:FlxTypedGroup<StrumNote>;
    var opponentStrums:FlxTypedGroup<StrumNote>;
    var strumLineNotes:FlxTypedGroup<StrumNote>;

    var downScroll:Bool = false;
    var middleScroll:Bool = false;

    public function new() super();

    override function create() {
        super.create();

        add(playerStrums = new FlxTypedGroup<StrumNote>());
        add(opponentStrums = new FlxTypedGroup<StrumNote>());
        add(strumLineNotes = new FlxTypedGroup<StrumNote>());

        FlxG.cameras.setDefaultDrawTarget(FlxG.camera, false);

        camGame = new FlxCamera();
        camGame.zoom = 0.6;
        camGame.scroll.set(-10, 0);
        FlxG.cameras.add(camGame, true);

        Paths.setCurrentLevel('week1');
        stage = new BackgroundStage();
        add(stage);

        camHUD = new FlxCamera();
        camHUD.bgColor = 0x0;
        FlxG.cameras.add(camHUD, false);

        camUI = new FlxCamera();
        camUI.bgColor = 0x0;
        FlxG.cameras.add(camUI, false);

        camGame.flashSprite.scaleX = camHUD.flashSprite.scaleX = camGame.flashSprite.scaleY = camHUD.flashSprite.scaleY = 0.45;
        camGame.y = camHUD.y = -200;

        addUI(new GhostUIButton(100, 100, 'Button Example', 200, 30));

        var dropdown = new GhostUIDropdown(100, 160, 'Dropdown Example', 200, 30);
        dropdown.addButton('drop1');
        dropdown.addButton('drop2');
        addUI(dropdown);

        setupStrums();
    }

    function addUI(elem:BasicUI) {
        elem.camera = camUI;
        add(elem);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        //if (controls.UI_LEFT_P || controls.UI_RIGHT_P) camGame.scroll.x += (controls.UI_LEFT_P ? -20 : 20);
        //if (controls.UI_UP_P || controls.UI_DOWN_P) camGame.scroll.y += (controls.UI_DOWN_P ? -20 : 20);
    }

    function setupStrums() {
        for (i in 0...8) {
            var strumX:Float = middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X;
		    var strumY:Float = downScroll ? (FlxG.height - 150) : 50;

            final player = Math.floor(i/4);
            var strum = new StrumNote(strumX, strumY, i%4, player);
            strum.camera = camHUD;

            if (player == 1) playerStrums.add(strum);
            else {
                if (middleScroll) {
                    strum.x += 310;
				    if (i > 1) strum.x += FlxG.width / 2 + 25;
                }
                opponentStrums.add(strum);
            }

            strumLineNotes.add(strum);
            strum.postAddedToGroup();
        }
    }
}