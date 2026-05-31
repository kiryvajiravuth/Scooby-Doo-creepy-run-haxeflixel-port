// this one is self explainatory
package states.menu.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
// this is a very cool effect (i ripped this off codename engine)
class GuideForNewbies extends FlxSubState
{
	var bg:FlxBackdrop;
	var title:FlxText;
	var instructions:FlxText;
	var backButton:FlxSprite;
    var isClosing:Bool = false;

    override public function create():Void
    {
        super.create();
		// load image
		FlxG.mouse.visible = true;
		bg = new FlxBackdrop("assets/images/ui/UserGuideBG/UserGuideBG.png");
		bg.velocity.set(40, 40); 
		bg.alpha = 0; 
        add(bg);
		// load text (i also stole the font from funkin sorry ninjamuffin99 and kawaisprite :<)
		title = new FlxText(0, 40, FlxG.width, "HOW TO PLAY", 44);
		title.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 44, FlxColor.YELLOW, CENTER);
		title.alpha = 0;
        add(title);

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

		instructions = new FlxText(0, 120, FlxG.width, guideText, 22);
		instructions.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 22, FlxColor.WHITE, CENTER);
		instructions.alpha = 0;
        add(instructions);
		// back button (also stolen from codename engine)
		backButton = new FlxSprite(FlxG.width - 150, FlxG.height - 80);
		backButton.loadGraphic("assets/images/ui/buttons/backButton/backButton.png"); 
		backButton.alpha = 0;
        add(backButton);
		// cool effect
		FlxTween.tween(bg, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
		FlxTween.tween(title, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.1});
		FlxTween.tween(instructions, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.2});
        FlxTween.tween(backButton, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.3});
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
		// WHY DID YOU CLOSE THE MENU
		var mouseClickedButton:Bool = false;
		if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(backButton))
		{
            mouseClickedButton = true;
        }
		// incase if the user is lazy , use the esc button
        if ((FlxG.keys.justPressed.ESCAPE || mouseClickedButton) && !isClosing) 
		{
			isClosing = true;
			FlxTween.tween(title, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
			FlxTween.tween(instructions, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
			FlxTween.tween(backButton, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
            FlxTween.tween(bg, {alpha: 0}, 0.4, {
                ease: FlxEase.quartIn,
				onComplete: function(twn:FlxTween)
				{
                    close();
                }
            });
        }
    }
}