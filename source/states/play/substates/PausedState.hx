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
	var bg:FlxBackdrop;
	var title:FlxText;
	var instruction:FlxText;
	var backButton:FlxSprite;
    var isClosing:Bool = false;

    override public function create():Void
    {
        super.create();

        FlxG.mouse.visible = true;

		if (FlxG.sound.music != null)
			FlxG.sound.music.pause();

		bg = new FlxBackdrop("assets/images/ui/CreditsBG/CreditsBG.png");
		bg.velocity.set(40, 40); 
		bg.alpha = 0; 
        add(bg);

		title = new FlxText(0, 50, FlxG.width, "PAUSED", 48);
		title.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 48, FlxColor.YELLOW, CENTER);
		title.alpha = 0;
        add(title);

		instruction = new FlxText(0, 150, FlxG.width, "PRESS ESC TO RESUME", 32);
		instruction.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 32, FlxColor.WHITE, CENTER);
		instruction.alpha = 0;
        add(instruction);

		backButton = new FlxSprite(FlxG.width - 150, FlxG.height - 80);
		backButton.loadGraphic("assets/images/ui/buttons/backButton/backButton.png"); 
		backButton.alpha = 0;
        add(backButton);

        FlxTween.tween(bg, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
        FlxTween.tween(title, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.1});
        FlxTween.tween(instruction, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.2});
        FlxTween.tween(backButton, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.3});
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        var mouseClickedButton:Bool = false;

		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(backButton))
		{
            mouseClickedButton = true;
        }

        if ((FlxG.keys.justPressed.ESCAPE || mouseClickedButton) && !isClosing) 
		{
            isClosing = true;

            FlxTween.tween(title, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
            FlxTween.tween(instruction, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
            FlxTween.tween(backButton, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});

            FlxTween.tween(bg, {alpha: 0}, 0.4, {
                ease: FlxEase.quartIn,
				onComplete: function(twn:FlxTween)
				{
					if (FlxG.sound.music != null)
						FlxG.sound.music.resume();
                    close();
                }
            });
        }
    }
}