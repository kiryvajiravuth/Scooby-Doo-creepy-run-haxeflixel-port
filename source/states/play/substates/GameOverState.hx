package states.play.substates;
// in summary this one is the same with other one BUT it displays the final score and the time that you somehow survived and yeah
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import states.menu.MainMenuState;

class GameOverState extends FlxSubState
{
	var bg:FlxBackdrop;
	var title:FlxText;
	var stats:FlxText;
	var prompt:FlxText;
	var backButton:FlxSprite;
    var isClosing:Bool = false;

    var finalScore:Int;
    var finalTime:String;

    public function new(score:Int, time:String)
    {
		super();
		this.finalScore = score;
        this.finalTime = time;
    }

    override public function create():Void
    {
        super.create();

        FlxG.mouse.visible = true;

		bg = new FlxBackdrop("assets/images/ui/CreditsBG/CreditsBG.png");
		bg.velocity.set(40, 40);
		bg.alpha = 0;
        add(bg);

		title = new FlxText(0, 50, FlxG.width, "GAME OVER", 48);
		title.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 48, FlxColor.RED, CENTER);
		title.alpha = 0;
        add(title);

		stats = new FlxText(0, 150, FlxG.width, "SCORE: " + finalScore + "\nTIME: " + finalTime, 32);
		stats.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 32, FlxColor.WHITE, CENTER);
		stats.alpha = 0;
        add(stats);

		prompt = new FlxText(0, 300, FlxG.width, "PRESS R TO RESTART", 24);
		prompt.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 24, FlxColor.YELLOW, CENTER);
		prompt.alpha = 0;
        add(prompt);

        backButton = new FlxSprite(FlxG.width - 150, FlxG.height - 80);
		backButton.loadGraphic("assets/images/ui/buttons/backButton/backButton.png");
		backButton.alpha = 0;
        add(backButton);

        FlxTween.tween(bg, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
        FlxTween.tween(title, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.1});
        FlxTween.tween(stats, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.2});
        FlxTween.tween(prompt, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.3});
        FlxTween.tween(backButton, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.4});
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (isClosing) return;

		if (FlxG.keys.justPressed.R)
		{
            FlxG.resetState();
        }

		if (FlxG.keys.justPressed.ESCAPE || (FlxG.mouse.justPressed && FlxG.mouse.overlaps(backButton)))
		{
            isClosing = true;

            FlxTween.tween(title, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
            FlxTween.tween(stats, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
            FlxTween.tween(prompt, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
            FlxTween.tween(backButton, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});

            FlxTween.tween(bg, {alpha: 0}, 0.4, {
                ease: FlxEase.quartIn,
				onComplete: function(twn:FlxTween)
				{
					FlxG.switchState(() -> new MainMenuState());
                }
            });
        }
    }
}