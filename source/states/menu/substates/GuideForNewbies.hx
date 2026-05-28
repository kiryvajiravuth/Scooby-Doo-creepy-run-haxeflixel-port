package states.menu.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class GuideForNewbies extends FlxSubState
{
    // repeating background texture that slides infinitely across the screen width
    var bg:FlxBackdrop;

    // text header display object showing the user guide title name
    var title:FlxText;

    // core text block detailing control bindings and rule definitions
    var instructions:FlxText;

    // click target sprite used to close the current overlay state screen
    var backButton:FlxSprite;

    // state switch flag preventing duplicate trigger updates during closing tweens
    var isClosing:Bool = false;

    // constructor routine defining layout elements typography and animation delays
    override public function create():Void
    {
        super.create();

        // force system mouse arrow pointer visibility across the window framework
        FlxG.mouse.visible = true;

        // allocate scrolling background grid and configure continuous velocity values
        bg = new FlxBackdrop("assets/images/ui/UserGuideBG/UserGuideBG.png");

        // assign scroll velocity parameters to generate active scrolling effects
        bg.velocity.set(40, 40); 

        // clamp initial opacity levels to zero to set up clean fade-ins
        bg.alpha = 0; 

        // bind backdrop instances onto the base stage visual layer list
        add(bg);

        // construct header label text structure with specific custom font assets
        title = new FlxText(0, 40, FlxG.width, "HOW TO PLAY", 44);

        // center align title lettering templates and dye them bright yellow
        title.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 44, FlxColor.YELLOW, CENTER);

        // clear initial alphanumeric visibility to preserve transition state queues
        title.alpha = 0;

        // insert header graphics layout items directly onto screens
        add(title);

        // local string block mapping out keyboard controls and general survival loops
        var guideText:String = 
            "--- CONTROLS ---\n" +
            "UP / W -> JUMP\n" +
            "DOWN / S -> DUCK\n" +
            "RIGHT / D -> MOVE RIGHT\n" +
            "LEFT / A -> DOES NOTHING\n\n" +
            "--- GAMEPLAY ---\n" +
            "• JUMP OR DUCK TO DODGE OBSTACLES.\n" +
            "• THE GAME IS INFINITE - SURVIVE AS LONG AS POSSIBLE!\n" +
            "• A LURKING SKELETON IS ALWAYS CHASING YOU.\n";

        // bind full manual text block into a central formatted display canvas
        instructions = new FlxText(0, 120, FlxG.width, guideText, 22);

        // bind true custom typefaces and configure standard white color properties
        instructions.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 22, FlxColor.WHITE, CENTER);

        // suppress initial manual text opacity levels down to zero
        instructions.alpha = 0;

        // attach structural instructional guidelines text onto active displays
        add(instructions);

        // establish boundary vectors and texture files for the navigation close icon
        backButton = new FlxSprite(FlxG.width - 150, FlxG.height - 80);

        // locate graphic image maps inside the project repository folders
        backButton.loadGraphic("assets/images/ui/buttons/backButton/backButton.png"); 

        // clear active button visibility settings to run clean alpha tweens
        backButton.alpha = 0;

        // pass the initialized close graphic object over to standard display groups
        add(backButton);

        // execute sequence chain of smooth alpha interpolations using stagger delays
        FlxTween.tween(bg, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});

        // fade title labels in smoothly using gentle easing profiles
        FlxTween.tween(title, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.1});

        // transition guidebook data bodies into sight after brief frame delays
        FlxTween.tween(instructions, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.2});

        // activate back interface assets as the final element in the entry chain
        FlxTween.tween(backButton, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.3});
    }

    // running runtime frame loop scanning keyboard events and pointer collision regions
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // binary storage tracker evaluating successful cursor hit registration bounds
        var mouseClickedButton:Bool = false;

        // verify if the pointer index is currently intersecting target button bounds
        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(backButton)) {
            // mark confirmation true if click overlapping routines pass checks
            mouseClickedButton = true;
        }

        // initiate cleanup process if escape keys or exit targets are activated
        if ((FlxG.keys.justPressed.ESCAPE || mouseClickedButton) && !isClosing) 
        {
            // toggle boolean lockout tags to completely ignore extra closing inputs
            isClosing = true;

            // run reverse alpha fadeout paths to smoothly hide menu elements
            FlxTween.tween(title, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});

            // dim guidance details visibility out entirely during step sequences
            FlxTween.tween(instructions, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});

            // run standard closing transitions on the cancel navigation graphic
            FlxTween.tween(backButton, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});

            // drop layout backplate opacity and unload active substate on animation end
            FlxTween.tween(bg, {alpha: 0}, 0.4, {
                ease: FlxEase.quartIn,
                onComplete: function(twn:FlxTween) {
                    // execute native state destruction lines to delete layout sublayers
                    close();
                }
            });
        }
    }
}