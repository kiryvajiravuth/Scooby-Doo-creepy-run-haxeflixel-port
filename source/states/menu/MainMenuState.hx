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

class MainMenuState extends FlxState
{
    // visual canvas background sprite component
    var bg:FlxSprite;

    // title menu brand illustration overlay sprite
    var logo:FlxSprite;

    // interaction area bounds for game launch trigger
    var playBut:FlxSprite;

    // interaction area bounds for viewing help substate
    var instBut:FlxSprite;

    // interaction area bounds for viewing credits list
    var credits:FlxSprite;

    #if debug
    // textual debugging tracker field visible in testing environments
    var debugText:FlxText;
    #end

    // pointer monitoring active input render layout for play button
    var playState:String = "up";

    // pointer monitoring active input render layout for user guide button
    var instState:String = "up";

    // pointer monitoring active input render layout for team credits button
    var creditsState:String = "up";

    // asset folder path containing state image frames for the play button
    final playPath:String = "assets/images/ui/buttons/playButton/";

    // asset folder path containing state image frames for the user guide button
    final guidePath:String = "assets/images/ui/buttons/userGuide/";

    // asset folder path containing state image frames for the credits button
    final creditsPath:String = "assets/images/ui/buttons/creditsButton/";

    // image path destination targeting the main background graphic file
    final bgPath:String = "assets/images/ui/menuBG/menuBG.png"; 

    // image path destination targeting the decorative menu logo asset
    final logoPath:String = "assets/images/ui/menuBG/menuLOGO.png";

    // initialization step preparing background graphics music items and screen parameters
    override public function create():Void
    {
        super.create();

        // allocate empty canvas memory space for the primary background object
        bg = new FlxSprite(0, 0);

        // evaluate directory files to safely apply the local menu image asset
        if (Assets.exists(bgPath))
        {
            // load target menu graphic from path asset allocation folder
            bg.loadGraphic(bgPath);

            // resize graphic size limits to fill screen resolution bounds
            bg.setGraphicSize(FlxG.width, FlxG.height);

            // recompute local physical tracking box to ensure precise asset scale limits
            bg.updateHitbox();
        }
        else
        {
            // fallback rendering option establishing a fallback dark frame block
            bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(25, 25, 25));
        }
        
        // activate smooth filtering behaviors to retain vector rendering clarity
        bg.antialiasing = true;

        // attach the completed menu background layer into the current screen group
        add(bg);

        // construct the main display layer positioning the branding overlay item
        logo = new FlxSprite(60, 40);

        // parse storage fields to bind the decorative menu identity title graphic
        if (Assets.exists(logoPath))
        {
            // pull title image files directly out of active directory structures
            logo.loadGraphic(logoPath);

            // refresh drawing boundaries to ensure exact texture aspect ratios
            logo.updateHitbox();
        }
        
        // toggle graphic filtering routines to suppress distorted pixel scaling artifacts
        logo.antialiasing = true;

        // attach the visual branding logo directly over background menu canvases
        add(logo);

        // look up directory pathways to activate looping theme tracks
        if (Assets.exists("assets/music/menuMusic.ogg"))
        {
            // launch music loops if track items are currently resting or empty
            if (FlxG.sound.music == null || !FlxG.sound.music.playing)
            {
                // load background sound track and toggle permanent loop playback
                FlxG.sound.playMusic("assets/music/menuMusic.ogg", 1.0, true);
            }
        }

        // assign screen coordinate bounds for the game start trigger button
        playBut = new FlxSprite(875, 444);

        // apply the standard up texture image to initialize button rendering profiles
        setButtonState(playBut, playPath, "up", true);

        // bind the play state interaction asset block into the game group
        add(playBut);

        // assign screen coordinate bounds for the tutorial guide substate trigger
        instBut = new FlxSprite(875, 523);

        // apply the standard up texture image to initialize help button frames
        setButtonState(instBut, guidePath, "up", true);

        // bind the user tutorial menu asset straight to display screens
        add(instBut);

        // assign screen coordinate bounds for the development team credits window
        credits = new FlxSprite(876, 608);

        // apply the standard up texture image to initialize credits button layouts
        setButtonState(credits, creditsPath, "up", true);

        // bind the project credits component view onto the display list
        add(credits);

        // force device cursor properties to display over active state interfaces
        FlxG.mouse.visible = true;
    }

    // framerate refresh loop feeding controller mouse properties into button managers
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // continuously evaluate bounding interactions for the start option component
        playState = handleButtonBehavior(playBut, playPath, playState, clickPlay);

        // continuously evaluate bounding interactions for the manual instruction view
        instState = handleButtonBehavior(instBut, guidePath, instState, clickInstructions);

        // continuously evaluate bounding interactions for the credits display asset
        creditsState = handleButtonBehavior(credits, creditsPath, creditsState, clickCredits);
    }

    // processing script verifying pointer overlay zones to apply matching interaction frames
    function handleButtonBehavior(button:FlxSprite, assetFolder:String, currentState:String, clickCallback:Void->Void):String
    {
        // declare baseline variable defaults mapping standard unused asset frames
        var targetState:String = "up";

        // intercept active device mouse vectors to perform tracking intersection checks
        if (FlxG.mouse.overlaps(button))
        {
            // evaluate click pressure thresholds to register active depression layout frames
            if (FlxG.mouse.pressed) targetState = "down";

            // fire the attached execution callback routine upon release detection steps
            else if (FlxG.mouse.justReleased) clickCallback();

            // assign basic hovering layout states when cursor overlaps are verified
            else targetState = "over";
        }
        
        // update local graphic items if texture states differ from previous ticks
        if (targetState != currentState) setButtonState(button, assetFolder, targetState, false);

        // return the finalized calculation state back to monitoring state variables
        return targetState;
    }

    // helper subroutine altering texture paths to apply specific input graphic assets
    function setButtonState(button:FlxSprite, folder:String, state:String, isInit:Bool):Void
    {
        // append targeted status keywords to extract required button frame images
        button.loadGraphic(folder + state + "_1.png");

        // align boundaries matching newly selected graphics texture configurations
        button.updateHitbox();
    }

    // menu option route cleaning up memory fields to switch straight into game runtime loops
    function clickPlay():Void 
    { 
        // transition state context targets into main playstate game loops using lambdas
        FlxG.switchState(() -> new PlayState());
    }
    
    // instruction option menu action launching newbie guidance substate modals
    function clickInstructions():Void 
    { 
        // prompt tutorial screen overlay templates directly on top of active states
        openSubState(new GuideForNewbies());
    }

    // developer information menu shortcut launching the credits modal display
    function clickCredits():Void 
    { 
        // prompt authors credit listings over active interface backdrops
        openSubState(new LOLItsTheGoofyAssTeam()); 
    }
}