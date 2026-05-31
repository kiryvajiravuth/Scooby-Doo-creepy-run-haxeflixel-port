// This is the main menu state of the game where players can start the game view instructions or see credits
package states.menu;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.utils.Assets;
import states.menu.substates.GuideForNewbies;
import states.menu.substates.LOLItsTheGoofyAssTeam;
import states.play.PlayState;

// import thing
// main menu state class
class MainMenuState extends FlxState
{
	// variable for menu ui
	var bg:FlxSprite;
	var logo:FlxSprite;
	var playBut:FlxSprite;
	var instBut:FlxSprite;
    var credits:FlxSprite;
	// yeah this one i have no idea why its here, its probably useful for debugging purposes
	#if debug
    var debugText:FlxText;
    #end
	// buttons states (the names speaks for it self)
	var playState:String = "up";
	var instState:String = "up";
    var creditsState:String = "up";
	// image path (obiviously DUH)
	final playPath:String = "assets/images/ui/buttons/playButton/";
	final guidePath:String = "assets/images/ui/buttons/userGuide/";
	final creditsPath:String = "assets/images/ui/buttons/creditsButton/";
	final bgPath:String = "assets/images/ui/menuBG/menuBG.png"; 
    final logoPath:String = "assets/images/ui/menuBG/menuLOGO.png";

    override public function create():Void
    {
        super.create();

		bg = new FlxSprite(0, 0);
		if (Assets.exists(bgPath))
		{
			bg.loadGraphic(bgPath);
			bg.setGraphicSize(FlxG.width, FlxG.height);
            bg.updateHitbox();
		}
		else
		{
            bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(25, 25, 25));
		}
		bg.antialiasing = true;
        add(bg);

		logo = new FlxSprite(60, 40);
		if (Assets.exists(logoPath))
		{
			logo.loadGraphic(logoPath);
            logo.updateHitbox();
		}
		logo.antialiasing = true;
        add(logo);
		// this is unused cuz we dont have the budget for that
		if (Assets.exists("assets/music/menuMusic.ogg"))
		{
			if (FlxG.sound.music == null || !FlxG.sound.music.playing)
			{
                FlxG.sound.playMusic("assets/music/menuMusic.ogg", 1.0, true);
            }
        }

		playBut = new FlxSprite(875, 444);
		setButtonState(playBut, playPath, "up", true);
        add(playBut);

		instBut = new FlxSprite(875, 523);
		setButtonState(instBut, guidePath, "up", true);
        add(instBut);

		credits = new FlxSprite(876, 608);
		setButtonState(credits, creditsPath, "up", true);
        add(credits);

        FlxG.mouse.visible = true;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

		playState = handleButtonBehavior(playBut, playPath, playState, clickPlay);
		instState = handleButtonBehavior(instBut, guidePath, instState, clickInstructions);
        creditsState = handleButtonBehavior(credits, creditsPath, creditsState, clickCredits);
    }

    function handleButtonBehavior(button:FlxSprite, assetFolder:String, currentState:String, clickCallback:Void->Void):String
	{
        var targetState:String = "up";

		if (FlxG.mouse.overlaps(button))
		{
			if (FlxG.mouse.pressed)
				targetState = "down";
			else if (FlxG.mouse.justReleased)
				clickCallback();
            else targetState = "over";
		}

		if (targetState != currentState)
			setButtonState(button, assetFolder, targetState, false);
        return targetState;
    }

    function setButtonState(button:FlxSprite, folder:String, state:String, isInit:Bool):Void
	{
		button.loadGraphic(folder + state + "_1.png");
        button.updateHitbox();
    }
	// this one is when if the user clicked the play button it will switch the state to playstate which is the main game
	function clickPlay():Void
	{
		FlxG.switchState(() -> new PlayState());
	}
	// this one is when if the user clicked the instruction button it open a substate named GuideForNewbies which is the instruction of the game
	function clickInstructions():Void
	{
		openSubState(new GuideForNewbies());
	}
	// this one is when if the user clicked the credit button it open a substate named LOLItsTheGoofyAssTeam which is the credits of the game
	function clickCredits():Void
	{
		openSubState(new LOLItsTheGoofyAssTeam());
	}
}