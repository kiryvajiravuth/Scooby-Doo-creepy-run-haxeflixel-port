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
        
        // initialize the game container with default window dimensions and set the initial entry state to mainmenustate
        var game:FlxGame = new FlxGame(0, 0, MainMenuState);
        
        // add the initialized game instance onto the openfl sprite display hierarchy
        addChild(game);

        // disable the default engine volume keys to prevent flixel from attempting to load its native sound tray interface
        #if FLX_SOUND_SYSTEM
        FlxG.sound.volumeUpKeys = null;
        FlxG.sound.volumeDownKeys = null;
        FlxG.sound.muteKeys = null;
        #end
    }
}