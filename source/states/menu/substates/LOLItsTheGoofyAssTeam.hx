package states.menu.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class LOLItsTheGoofyAssTeam extends FlxSubState
{
    // repeating background texture that slides infinitely across the screen width
    var bg:FlxBackdrop;

    // text header display object showing the development team screen title
    var title:FlxText;

    // core text block detailing individual project members and assigned project roles
    var names:FlxText;

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
        bg = new FlxBackdrop("assets/images/ui/CreditsBG/CreditsBG.png");

        // assign scroll speed values to keep the background tiling smoothly
        bg.velocity.set(40, 40); 

        // set initial transparency to completely hidden for transition entry setups
        bg.alpha = 0; 

        // append the backdrop sprite array into the drawing container list
        add(bg);

        // construct header label text structure with specific custom font assets
        title = new FlxText(0, 50, FlxG.width, "DEVELOPMENT TEAM", 48);

        // define formatting properties to center alignment and apply golden hues
        title.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 48, FlxColor.YELLOW, CENTER);

        // clamp initial opacity down to zero to hide the text until tweens fire
        title.alpha = 0;

        // inject the header banner text layer onto the rendering tree
        add(title);

        // complete roster listing individual project members linked with their project roles
        var staffList:String = 
            "vuth : coder-commenter\n" +
            "seng : coder\n" +
            "hak : debugger\n" +
            "sovathana : does nothing and dies";

        // bind team roster data into a central formatted display canvas
        names = new FlxText(0, 150, FlxG.width, staffList, 32);

        // format user text with clean white colors and the main font style
        names.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 32, FlxColor.WHITE, CENTER);

        // hide roster contents initially to prepare for active fade sequences
        names.alpha = 0;

        // publish the credit names string onto active layout nodes
        add(names);

        // establish boundary vectors and texture files for the navigation close icon
        backButton = new FlxSprite(FlxG.width - 150, FlxG.height - 80);

        // pull the cancel image asset directly out of path directory addresses
        backButton.loadGraphic("assets/images/ui/buttons/backButton/backButton.png"); 

        // apply transparent default visibility states to prevent flashing rendering errors
        backButton.alpha = 0;

        // attach the exit button layer onto the highest display tier
        add(backButton);

        // execute sequence chain of smooth alpha interpolations using stagger delays
        FlxTween.tween(bg, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});

        // activate secondary title banner fade scripts after brief delay intervals
        FlxTween.tween(title, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.1});

        // run internal text cluster transitions shortly after headers complete
        FlxTween.tween(names, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.2});

        // reveal return buttons once main panel informational animations wrap up
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

            // strip roster opacity values down during closing routines
            FlxTween.tween(names, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});

            // fade out visibility tags for the navigation button components
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