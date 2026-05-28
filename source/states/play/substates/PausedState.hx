package states.play.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PausedState extends FlxSubState
{
    // repeating background grid pattern that scrolls across the screen
    var bg:FlxBackdrop;
    // main heading text object displayed at the top of the pause menu
    var title:FlxText;
    // secondary text label showing interaction instructions for the user
    var instruction:FlxText;
    // clickable sprite element used to resume or exit the paused state
    var backButton:FlxSprite;
    // state boolean preventing multiple trigger executions while closing
    var isClosing:Bool = false;

    // constructor routine preparing menu layout elements and rendering properties
    override public function create():Void
    {
        super.create();

        // set the mouse cursor to visible to allow interaction with buttons
        FlxG.mouse.visible = true;

        // allocate the scrolling background layer using the credit background asset
        bg = new FlxBackdrop("assets/images/ui/CreditsBG/CreditsBG.png");
        // set the velocity to make the background tile move constantly
        bg.velocity.set(40, 40); 
        // initialize alpha to zero to enable a smooth fade-in effect
        bg.alpha = 0; 
        // add the backdrop layer to the substate container
        add(bg);

        // construct the pause menu title banner with yellow coloring
        title = new FlxText(0, 50, FlxG.width, "PAUSED", 48);
        // set font properties to align to center and apply specific style assets
        title.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 48, FlxColor.YELLOW, CENTER);
        // set initial opacity to zero for the entrance animation sequence
        title.alpha = 0;
        // attach the title label to the display list
        add(title);

        // create navigation instructions text informing the player how to proceed
        instruction = new FlxText(0, 150, FlxG.width, "PRESS ESC TO RESUME", 32);
        // define font formatting for the instruction text block
        instruction.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 32, FlxColor.WHITE, CENTER);
        // hide the instructions until the entry tween finishes
        instruction.alpha = 0;
        // add instruction label to the screen
        add(instruction);

        // define the back button sprite at the bottom right of the screen
        backButton = new FlxSprite(FlxG.width - 150, FlxG.height - 80);
        // load the back button graphic from the ui assets folder
        backButton.loadGraphic("assets/images/ui/buttons/backButton/backButton.png"); 
        // set transparency to zero for the animation sequence
        backButton.alpha = 0;
        // add the button to the screen
        add(backButton);

        // perform sequential fade-in animations for all menu components
        FlxTween.tween(bg, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
        FlxTween.tween(title, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.1});
        FlxTween.tween(instruction, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.2});
        FlxTween.tween(backButton, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.3});
    }

    // handle user input and animation updates per frame
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        // initialize a flag to track if the back button was clicked
        var mouseClickedButton:Bool = false;

        // check if the mouse is pressed while overlapping the button area
        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(backButton)) {
            // update flag to true if interaction detected
            mouseClickedButton = true;
        }

        // check for closing conditions if escape is pressed or button is clicked
        if ((FlxG.keys.justPressed.ESCAPE || mouseClickedButton) && !isClosing) 
        {
            // set closing flag to prevent reentry during the tween
            isClosing = true;
            
            // run reverse fade-out tweens for all elements
            FlxTween.tween(title, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
            FlxTween.tween(instruction, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
            FlxTween.tween(backButton, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
            
            // fade out the background and close the substate upon completion
            FlxTween.tween(bg, {alpha: 0}, 0.4, {
                ease: FlxEase.quartIn,
                onComplete: function(twn:FlxTween) {
                    // invoke the close method to return to playstate
                    close();
                }
            });
        }
    }
}