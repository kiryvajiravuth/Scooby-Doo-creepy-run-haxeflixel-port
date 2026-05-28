package states.play.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class GameOverState extends FlxSubState
{
    // repeating background grid sliding continuously across the screen
    var bg:FlxBackdrop;
    // main heading text announcing the game over condition
    var title:FlxText;
    // display block showing the final score and survival time stats
    var stats:FlxText;
    // prompt text indicating which keys to press for restarting
    var prompt:FlxText;
    // button sprite used to exit the game over screen
    var backButton:FlxSprite;
    // boolean tag to prevent multiple closing animations
    var isClosing:Bool = false;

    // storage definitions for values passed from playstate
    var finalScore:Int;
    var finalTime:String;

    // constructor for the substate receiving game statistics
    public function new(score:Int, time:String)
    {
        super();
        // save the passed score value to a local field
        this.finalScore = score;
        // save the passed time string to a local field
        this.finalTime = time;
    }

    // construct visual elements and initialize animation sequences
    override public function create():Void
    {
        super.create();

        // show the mouse cursor for interactive button selection
        FlxG.mouse.visible = true;

        // initialize the background backdrop pattern
        bg = new FlxBackdrop("assets/images/ui/CreditsBG/CreditsBG.png");
        // set velocity to scroll the background
        bg.velocity.set(40, 40);
        // start hidden for the fade-in effect
        bg.alpha = 0;
        // add the backdrop to the drawing list
        add(bg);

        // define the game over header text
        title = new FlxText(0, 50, FlxG.width, "GAME OVER", 48);
        // set format and color properties for the header
        title.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 48, FlxColor.RED, CENTER);
        // start invisible for the fade-in sequence
        title.alpha = 0;
        // attach header to the screen
        add(title);

        // format the statistics display string with score and time
        stats = new FlxText(0, 150, FlxG.width, "SCORE: " + finalScore + "\nTIME: " + finalTime, 32);
        // set formatting properties for the statistics block
        stats.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 32, FlxColor.WHITE, CENTER);
        // start invisible for animation
        stats.alpha = 0;
        // add stats text to screen
        add(stats);

        // set up instructions text for restarting the game
        prompt = new FlxText(0, 300, FlxG.width, "PRESS R TO RESTART", 24);
        // apply standard font formatting
        prompt.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 24, FlxColor.YELLOW, CENTER);
        // start invisible
        prompt.alpha = 0;
        // add restart prompt to screen
        add(prompt);

        // define back button position and load assets
        backButton = new FlxSprite(FlxG.width - 150, FlxG.height - 80);
        backButton.loadGraphic("assets/images/ui/buttons/backButton/backButton.png");
        // start invisible
        backButton.alpha = 0;
        // add back button to screen
        add(backButton);

        // animate in all components using stagger delays
        FlxTween.tween(bg, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
        FlxTween.tween(title, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.1});
        FlxTween.tween(stats, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.2});
        FlxTween.tween(prompt, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.3});
        FlxTween.tween(backButton, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.4});
    }

    // handle user input, update game state, and manage closing sequences
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // ignore update calls if the state is already closing
        if (isClosing) return;

        // check if r is pressed to trigger a state reset
        if (FlxG.keys.justPressed.R) {
            // reload the current game state
            FlxG.resetState();
        }

        // check if escape is pressed or back button is clicked to close menu
        if (FlxG.keys.justPressed.ESCAPE || (FlxG.mouse.justPressed && FlxG.mouse.overlaps(backButton))) {
            // set closing flag to true
            isClosing = true;

            // fade out all UI components
            FlxTween.tween(title, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
            FlxTween.tween(stats, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
            FlxTween.tween(prompt, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
            FlxTween.tween(backButton, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
            
            // fade out background and finish closing substate
            FlxTween.tween(bg, {alpha: 0}, 0.4, {
                ease: FlxEase.quartIn,
                onComplete: function(twn:FlxTween) {
                    // return to the previous state
                    close();
                }
            });
        }
    }
}