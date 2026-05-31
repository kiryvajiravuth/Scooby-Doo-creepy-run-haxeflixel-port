// the team :3
package states.menu.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
// this is a very cool effect (i ripped this off codename engine again)
class LOLItsTheGoofyAssTeam extends FlxSubState
{
	var bg:FlxBackdrop;
	var title:FlxText;
	var names:FlxText;
	var backButton:FlxSprite;
    var isClosing:Bool = false;

    override public function create():Void
    {
        super.create();

		FlxG.mouse.visible = true;
		bg = new FlxBackdrop("assets/images/ui/CreditsBG/CreditsBG.png");
		bg.velocity.set(40, 40); 
		bg.alpha = 0; 
        add(bg);

		title = new FlxText(0, 50, FlxG.width, "DEVELOPMENT TEAM", 48);
		title.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 48, FlxColor.YELLOW, CENTER);
		title.alpha = 0;
        add(title);
		// SOVATHANA DIDNT DO ANYTHING
        var staffList:String = 
            "vuth : coder-commenter\n" +
            "seng : coder\n" +
            "hak : debugger\n" +
            "sovathana : does nothing and dies";

		names = new FlxText(0, 150, FlxG.width, staffList, 32);
		names.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 32, FlxColor.WHITE, CENTER);
		names.alpha = 0;
        add(names);

		backButton = new FlxSprite(FlxG.width - 150, FlxG.height - 80);
		backButton.loadGraphic("assets/images/ui/buttons/backButton/backButton.png"); 
		backButton.alpha = 0;
        add(backButton);

		FlxTween.tween(bg, {alpha: 1}, 0.5, {ease: FlxEase.quartOut});
		FlxTween.tween(title, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.1});
		FlxTween.tween(names, {alpha: 1}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.2});
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
			FlxTween.tween(names, {alpha: 0}, 0.25, {ease: FlxEase.quartIn});
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
// mostly copied from the guide for newbies state but with some changes to fit the credits screen, also this is the credits screen so it has the names of the people who worked on the game and their roles, also a cool background and a cool effect when you open and close the menu also a back button to close the menu (and you can also use the esc key)