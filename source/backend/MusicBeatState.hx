package backend;

import flixel.addons.ui.FlxUIState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxState;
import backend.PsychCamera;
#if HSCRIPT_ALLOWED
import psychlua.HScript;
import psychlua.FunkinLua;
#end

class MusicBeatState extends FlxUIState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	public var debugCam:FlxCamera;
	public var grpDebugTxt:FlxTypedGroup<psychlua.DebugLuaText>;
	#end

	public var controls(get, never):Controls;
	private function get_controls()
	{
		return Controls.instance;
	}

	private var _psychCameraInitialized:Bool = false;
	private var _debugGroupInitialized:Bool = false;
	
	#if HSCRIPT_ALLOWED
	public var scripts:Array<HScript> = [];
	#end
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();

	override function create() {
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		#if MODS_ALLOWED Mods.updatedOnState = false; #end

		if(!_psychCameraInitialized) initPsychCamera();
		if(!_debugGroupInitialized)  initDebugGroup();

		super.create();

		if(!skip) {
			openSubState(new CustomFadeTransition(0.6, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;

		if (Main.fpsVar != null) {
			if (getState() == PlayState.instance)
				Main.fpsVar.unfocus();
			else
				Main.fpsVar.focus();
		}
	}

	public function initDebugGroup():FlxTypedGroup<psychlua.DebugLuaText> {
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		debugCam = new FlxCamera();
		debugCam.bgColor.alpha = 0;
		FlxG.cameras.add(debugCam, false);

		grpDebugTxt = new FlxTypedGroup<psychlua.DebugLuaText>();
		grpDebugTxt.camera = debugCam;
		add(grpDebugTxt);

		_debugGroupInitialized = true;

		addTextToDebug('[backend Test] whats up people of america', -1);
		#end

		return grpDebugTxt;
	}

	public function initPsychCamera():PsychCamera
	{
		var camera = new PsychCamera();
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		_psychCameraInitialized = true;
		//trace('initialized psych camera ' + Sys.cpuTime());
		return camera;
	}

	public static var timePassedOnState:Float = 0;
	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;
		timePassedOnState += elapsed;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;
		
		stagesFunc(function(stage:BaseStage) {
			stage.update(elapsed);
		});

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState = null) {
		if(nextState == null) nextState = FlxG.state;
		if(nextState == FlxG.state)
		{
			resetState();
			return;
		}

		if(FlxTransitionableState.skipNextTransIn) FlxG.switchState(nextState);
		else startTransition(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function resetState() {
		if(FlxTransitionableState.skipNextTransIn) FlxG.resetState();
		else startTransition();
		FlxTransitionableState.skipNextTransIn = false;
	}

	// Custom made Trans in
	public static function startTransition(nextState:FlxState = null)
	{
		if(nextState == null)
			nextState = FlxG.state;

		FlxG.state.openSubState(new CustomFadeTransition(0.6, false));
		if(nextState == FlxG.state)
			CustomFadeTransition.finishCallback = function() FlxG.resetState();
		else
			CustomFadeTransition.finishCallback = function() FlxG.switchState(nextState);
	}

	public static function getState():MusicBeatState {
		return cast (FlxG.state, MusicBeatState);
	}

	public function stepHit():Void
	{
		stagesFunc(function(stage:BaseStage) {
			stage.curStep = curStep;
			stage.curDecStep = curDecStep;
			stage.stepHit();
		});

		if (curStep % 4 == 0)
			beatHit();
	}

	public var stages:Array<BaseStage> = [];
	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
		stagesFunc(function(stage:BaseStage) {
			stage.curBeat = curBeat;
			stage.curDecBeat = curDecBeat;
			stage.beatHit();
		});
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
		stagesFunc(function(stage:BaseStage) {
			stage.curSection = curSection;
			stage.sectionHit();
		});
	}

	function stagesFunc(func:BaseStage->Void)
	{
		for (stage in stages)
			if(stage != null && stage.exists && stage.active)
				func(stage);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	public function addTextToDebug(text:String, color:FlxColor, ?isError:Bool = false) {
		if (grpDebugTxt != null) {
			var newText:psychlua.DebugLuaText = grpDebugTxt.recycle(psychlua.DebugLuaText);
			newText.text = text;
			newText.color = color;
			newText.disableTime = 6;
			newText.alpha = 1;
			newText.setPosition(10, 8 - newText.height);

			grpDebugTxt.forEachAlive(function(spr:psychlua.DebugLuaText) {
				spr.y += newText.height + 2;
			});
			grpDebugTxt.add(newText);
		}

		if (color == FlxColor.RED) isError = true;
		(isError ? error : info)(text);
	}
	#else
	public function addTextToDebug(text:String, color:FlxColor, ?isError:Bool = false) 
		(isError ? error : info)(text);
	#end
	
	#if HSCRIPT_ALLOWED
	public function importScript(path:String, absolute:Bool = false) {
		var scriptPath = ((Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0) ? Paths.mods(Mods.currentModDirectory + '/' + path) : Paths.mods(path));
		try {
			this.scripts.push(new HScript((absolute ? path : scriptPath)));
			return true;
		} catch(e) {
			FunkinLua.luaTrace('importScript: Path "${(absolute ? path : scriptPath)}" does not exist!', true, false, 0xFFFF0000);
		}
		return false;
	}
	#end
}
