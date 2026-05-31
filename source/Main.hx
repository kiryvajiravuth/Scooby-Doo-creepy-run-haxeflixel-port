package;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import states.menu.MainMenuState;

class Main extends Sprite
{
    public function new()
    {
        super();

        var game:FlxGame = new FlxGame(0, 0, MainMenuState);

        addChild(game);

        #if FLX_SOUND_SYSTEM
        FlxG.sound.volumeUpKeys = null;
        FlxG.sound.volumeDownKeys = null;
        FlxG.sound.muteKeys = null;
        #end
    }
}