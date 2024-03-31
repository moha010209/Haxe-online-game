package backend;

class ScriptHandler extends tea.SScript
{
	public function new(scriptPath:String)
	{
		super("", false, false);
		doString(Paths.getData(scriptPath + ".hx", false));
        preset();
        execute();
        call("onCreate");
	}

	override function preset():Void
	{
		super.preset();

		// Only use 'set', 'setClass' or 'setClassString' in preset
		// Macro classes are not allowed to be set
		setClass(StringTools);
		set('NaN', Math.NaN);
		setClassString('sys.io.File');
        set("game", states.PlayState.instance);
        setClass(flixel.FlxSprite);
        setClass(Paths);
        setClass(ClientPrefs);
	}
}
