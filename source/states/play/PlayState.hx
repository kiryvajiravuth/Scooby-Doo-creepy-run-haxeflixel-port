package states.play;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxRuntimeShader;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.utils.Assets;
import states.play.substates.GameOverState;
import states.play.substates.PausedState;

class PlayState extends FlxState
{
    var animScales:Map<String, Float> = [
        "idle" => 1.2,
        "prepRun" => 0.6,
        "run" => 0.6,
        "prepCrouch" => 1.3,
        "crouch" => 1.3,
        "jump" => 1.2
	];
    var animOffsets:Map<String, Array<Float>> = [
        "idle" => [0.0, 0.0],
        "prepRun" => [150.0, 80.0],
        "run" => [150.0, 80.0],
        "prepCrouch" => [25.0, -30.0],
        "crouch" => [25.0, -30.0],
        "jump" => [0.0, 0.0]
	];
	var shaggyX:Float = 300.0;
	var shaggyY:Float = 500.0;       
	var currentScrollSpeed:Float = -1100.0;
	var prepThreshold:Float = 0.15;
	var jumpVelocity:Float = 0.0;
	var gravity:Float = 4000.0;    
	var jumpForce:Float = 1500.0;
	var skellyBaseX:Float = -200.0;
	var skellyMaxCatchupSpeed:Float = 650.0; 
	var skellyRetreatSpeed:Float = 250.0; 
	var skellyScaleX:Float = 0.7;         
	var skellyScaleY:Float = 0.7;         
	var skellyFloorOffset:Float = 175.0;
	var skellyAnimFPS:Int = 40;           
	var deathScaleX:Float = 1.2;
	var deathScaleY:Float = 1.2;
	var deathOffsetX:Float = -315.0;       
	var deathOffsetY:Float = -135.0;       
	var deathAnimFPS:Int = 25;
	var score:Int = 0;
	var totalTimeSurvived:Float = 0.0;
	var obstacles:FlxTypedGroup<Obstacle>;
    var obstacleSpawnTimer:Float = 0.0;

	var isStunned:Bool = false;
	var stunTimer:Float = 0.0;
	var stunDuration:Float = 1.5; 
	var skelly:FlxSprite;
	var bgScrollLayer:FlxBackdrop;
	var shaggy:FlxSprite;
	var runhitbox:FlxSprite;
	var deathFX:FlxSprite;              
	var scoreDisplay:FlxText;
	var isJumping:Bool = false;
	var isCrouching:Bool = false;
	var movementState:String = "idle"; 
	var playerHitboxPadding:Float = 16.0;
	var gameOverOpened:Bool = false;
	var clampNextElapsed:Bool = false;
	var ignoreInputFrames:Int = 0;
	var prepTimer:Float = 0.0;
    override public function create():Void
    {
		super.create();
        if (FlxG.sound.music == null || !FlxG.sound.music.playing)
        {
            FlxG.sound.playMusic("assets/music/CHASETHEME.ogg", 0.7, true);
		}
		bgScrollLayer = new FlxBackdrop("assets/images/Gameplay/BackGround.png", FlxAxes.X, 0, 0);
		bgScrollLayer.y = FlxG.height - bgScrollLayer.height; 
		add(bgScrollLayer);
		obstacles = new FlxTypedGroup<Obstacle>();
		add(obstacles);
		skelly = new FlxSprite(skellyBaseX, shaggyY);
		skelly.frames = FlxAtlasFrames.fromSparrow("assets/images/Gameplay/SKELLYWAG/skelly-ton.png", "assets/images/Gameplay/SKELLYWAG/skelly-ton.xml");
		skelly.animation.addByPrefix("run", "SKELLYWAGRUNNING", skellyAnimFPS, true);
		skelly.scale.set(skellyScaleX, skellyScaleY);
		skelly.updateHitbox();
		skelly.antialiasing = true;
		skelly.animation.play("run");
		add(skelly);
		shaggy = new FlxSprite(shaggyX, shaggyY);
		shaggy.frames = FlxAtlasFrames.fromSparrow("assets/images/Gameplay/Shaggy-Rogers/Shaggy-Rogers.png",
			"assets/images/Gameplay/Shaggy-Rogers/Shaggy-Rogers.xml");
		shaggy.animation.addByPrefix("idle", "Idle", 24, true);
		shaggy.animation.addByPrefix("prepRun", "PrepRun", 36, false);
		shaggy.animation.addByPrefix("run", "shaggyRun", 24, true);
		shaggy.animation.addByPrefix("prepCrouch", "PrepCrouch", 36, false);
		shaggy.animation.addByPrefix("crouch", "CROUCH", 36, false); 
		shaggy.animation.addByPrefix("jump", "Jump", 36, false);
		shaggy.antialiasing = true;
		add(shaggy);
		runhitbox = new FlxSprite(shaggyX, shaggyY);
		runhitbox.frames = shaggy.frames;
		runhitbox.animation.addByPrefix("idle", "Idle", 24, true);
		runhitbox.animation.play("idle");
		runhitbox.visible = false;
		runhitbox.antialiasing = true;
		var idleScale:Float = animScales.get("idle");
		runhitbox.scale.set(idleScale, idleScale);
		runhitbox.updateHitbox();
		runhitbox.setSize(runhitbox.width + playerHitboxPadding, runhitbox.height + playerHitboxPadding);
		var idleOffset:Array<Float> = animOffsets.get("idle");
		runhitbox.offset.set(idleOffset[0], idleOffset[1]);
		add(runhitbox);
		deathFX = new FlxSprite(0, 0);
		deathFX.frames = FlxAtlasFrames.fromSparrow("assets/images/Gameplay/DEATH/NOOOOO.png", "assets/images/Gameplay/DEATH/NOOOOO.xml");
		deathFX.animation.addByPrefix("playDeath", "DEATH", deathAnimFPS, false);
		deathFX.scale.set(deathScaleX, deathScaleY);
		deathFX.updateHitbox();
		deathFX.antialiasing = true;
		deathFX.visible = false; 
		add(deathFX);
		scoreDisplay = new FlxText(20, 20, 0, "0", 48);
		scoreDisplay.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreDisplay.scrollFactor.set(0, 0);
        add(scoreDisplay);

        playAnimation("idle");
	}
    function playAnimation(name:String):Void
	{
		if (shaggy.animation.name == name)
			return;
		shaggy.animation.play(name);
		var scale = animScales.exists(name) ? animScales.get(name) : 1.0;
		var offset = animOffsets.exists(name) ? animOffsets.get(name) : [0.0, 0.0];
		shaggy.scale.set(scale, scale);
        shaggy.updateHitbox();
		updatePlayerHitbox();
        shaggy.offset.set(offset[0], offset[1]);
	}
	function updatePlayerHitbox():Void
	{
		var padding:Float = playerHitboxPadding;
		shaggy.setSize(shaggy.width + padding, shaggy.height + padding);
	}
    function formatTime(seconds:Float):String 
	{
		var mins:Int = Math.floor(seconds / 60);
		var secs:Int = Math.floor(seconds % 60);
		var millis:Int = Math.floor((seconds * 1000) % 1000);
		var minStr = (mins < 10) ? "0" + mins : "" + mins;
		var secStr = (secs < 10) ? "0" + secs : "" + secs;
		var milStr = (millis < 100) ? ((millis < 10) ? "00" + millis : "0" + millis) : "" + millis;
        return minStr + ":" + secStr + ":" + milStr;
	}
    function spawnObstacle():Void
	{
		var isHigh:Bool = FlxG.random.bool(50);
		var spawnX:Float = FlxG.width + 200;
		var spawnY:Float = 0;
		if (isHigh)
		{
            spawnY = shaggyY - 60;
		}
		else
		{
            spawnY = shaggyY + 100;
		}
		var obs = new Obstacle(spawnX, spawnY, isHigh);
        obstacles.add(obs);
	}
    override public function update(elapsed:Float):Void
    {
		super.update(elapsed);
		if (subState != null)
			return;
        if (movementState == "dead")
		{
			if (deathFX.animation.finished && !gameOverOpened) 
			{
				gameOverOpened = true;
				var finalTime:String = formatTime(totalTimeSurvived);
				clampNextElapsed = true;
				ignoreInputFrames = 1;
                openSubState(new GameOverState(score, finalTime));
			}
            return;
		}
		if (clampNextElapsed)
		{
			if (elapsed > 0.05)
				elapsed = 0.05;
			clampNextElapsed = false;
		}
		totalTimeSurvived += elapsed;
        if (isStunned)
		{
			stunTimer -= elapsed;
            if (stunTimer <= 0)
			{
				isStunned = false;
                FlxFlicker.stopFlickering(shaggy);
            }
		}
        if (FlxG.keys.justPressed.ESCAPE)
		{
			clampNextElapsed = true;
			ignoreInputFrames = 1;
            openSubState(new PausedState());
			return;
		}
        var keyUp:Bool = false;
        var keyDown:Bool = false;
		var keyRight:Bool = false;
		var skipInput:Bool = false;
		if (ignoreInputFrames > 0)
		{
			skipInput = true;
			ignoreInputFrames -= 1;
		}
		if (!isStunned && !skipInput)
		{
			keyUp = FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W;
			keyDown = FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S;
            keyRight = FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D;
        }
        else
		{
            isCrouching = false;
		}
		if (!isStunned && keyRight && !skipInput)
		{
			obstacleSpawnTimer += elapsed;
            if (obstacleSpawnTimer >= 2.0)
			{
				obstacleSpawnTimer = 0.0;
                spawnObstacle();
            }
        }
		else
		{
			obstacleSpawnTimer = 0.0;
		}
		var scrollMultiplier:Float = keyRight ? 1.0 : 0.0; 
		var currentSpeed:Float = currentScrollSpeed * scrollMultiplier;
		obstacles.forEachAlive(function(obs:Obstacle)
		{
            obs.x += currentSpeed * elapsed;

            if (!obs.passed && obs.x + obs.width < shaggy.x)
			{
				obs.passed = true;
				score += 1;
                scoreDisplay.text = Std.string(score);
			}
			if (obs.x < -300)
			{
                obs.kill();
            }
		});
        if (!isStunned)
        {
			var colSprite:FlxSprite = shaggy;
			if (movementState == "running")
			{
				runhitbox.setPosition(shaggy.x, shaggy.y);
				colSprite = runhitbox;
			}
			FlxG.overlap(colSprite, obstacles, function(player:FlxSprite, obsObj:FlxSprite)
			{
                var obs = cast(obsObj, Obstacle);

				if (obs.isHigh && isCrouching)
					return; 
                if (!obs.isHigh && isJumping && shaggy.y < shaggyY - 50) return; 

				isStunned = true;
				stunTimer = stunDuration;
                FlxFlicker.flicker(shaggy, stunDuration, 0.04, true);

                obs.kill(); 
            });
		}
        if (isJumping)
		{
			jumpVelocity += gravity * elapsed;
			shaggy.y += jumpVelocity * elapsed;
            if (shaggy.y >= shaggyY) 
			{
				shaggy.y = shaggyY;
				isJumping = false;
                jumpVelocity = 0;
            }
        }
        else 
		{
            if (keyUp) 
			{
				isJumping = true;
				isCrouching = false;
                jumpVelocity = -jumpForce;
			}
            else if (keyDown) 
			{
				if (movementState != "uncrouching")
				{
                    isCrouching = true;
                }
            }
            else 
			{
                isCrouching = false;
            }
		}
        if (isStunned)
		{
			movementState = "idle";
            playAnimation("idle");
        }
        else if (isJumping) 
		{
			playAnimation("jump");
            movementState = "jumping";
        }
        else if (isCrouching) 
		{
			if (movementState != "preppingCrouch" && movementState != "crouchingHold")
			{
				movementState = "preppingCrouch";
                playAnimation("prepCrouch");
            }

			if (movementState == "preppingCrouch" && shaggy.animation.finished)
			{
				movementState = "crouchingHold";
                shaggy.animation.pause();
            }
        }
        else if (movementState == "crouchingHold" || movementState == "uncrouching")
		{
			if (movementState == "crouchingHold")
			{
				movementState = "uncrouching";
                playAnimation("crouch"); 
            }

			if (movementState == "uncrouching" && shaggy.animation.finished)
			{
				if (keyRight)
				{
					movementState = "running";
                    playAnimation("run");
				}
				else
				{
					movementState = "idle";
                    playAnimation("idle");
                }
            }
        }
        else if (keyRight) 
		{
			if (movementState != "prepping" && movementState != "running")
			{
				movementState = "prepping";
				playAnimation("prepRun");
                prepTimer = 0.0;
            }

			if (movementState == "prepping")
			{
				prepTimer += elapsed;
				if (prepTimer >= prepThreshold)
				{
					movementState = "running";
                    playAnimation("run");
                }
            }
        }
        else 
		{
			movementState = "idle";
            playAnimation("idle");
		}
		if (!skipInput)
		{
			if (keyRight && !isStunned)
			{
				bgScrollLayer.x += currentScrollSpeed * elapsed;
				skelly.x -= skellyRetreatSpeed * elapsed;
				if (skelly.x < -400.0)
				{
					skelly.x = -400.0;
				}
			}
			else
			{
				skelly.x += skellyMaxCatchupSpeed * elapsed;
			}
		}
		skelly.y = shaggyY - (skelly.height - skellyFloorOffset);
		var colSprite:FlxSprite = shaggy;
		if (movementState == "running")
		{
			runhitbox.setPosition(shaggy.x, shaggy.y);
			colSprite = runhitbox;
		}
		if (FlxG.overlap(colSprite, skelly))
		{
			movementState = "dead";
            if (FlxFlicker.isFlickering(shaggy))
			{
                FlxFlicker.stopFlickering(shaggy);
			}
			shaggy.visible = false;
			skelly.visible = false;
			deathFX.x = shaggy.x + deathOffsetX;
			deathFX.y = shaggy.y + deathOffsetY;
			deathFX.visible = true;
            deathFX.animation.play("playDeath");

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			FlxG.sound.play("assets/sounds/SadShaggyDeath.wav", 1.0);
            return;
        }
    }
}
class Obstacle extends FlxSprite
{
	public var isHigh:Bool;
	public var passed:Bool;
	static var shaderCode:String = "";
    public function new(x:Float, y:Float, high:Bool)
    {
		super(x, y);
		this.isHigh = high;
        this.passed = false;

		var padding:Int = 20;
		var graphicPath:String = isHigh ? "assets/images/Gameplay/obstacles/duck/pumpkin.png" : "assets/images/Gameplay/obstacles/jump/grave.png";
		var originalBitmap:BitmapData = Assets.getBitmapData(graphicPath);
		var paddedBitmap:BitmapData = new BitmapData(originalBitmap.width + padding, originalBitmap.height + padding, true, 0);
		paddedBitmap.copyPixels(originalBitmap, originalBitmap.rect, new Point(padding / 2, padding / 2));
        if (isHigh) 
		{
			loadGraphic(paddedBitmap);
            scale.set(1.4, 1.4);
        } 
        else 
        {
			loadGraphic(paddedBitmap);
            scale.set(1.5, 1.5);
		}
		antialiasing = true;
		updateHitbox();
		width -= padding * scale.x;
		height -= padding * scale.y;
		offset.add((padding / 2) * scale.x, (padding / 2) * scale.y);
		if (shaderCode == "")
		{
			shaderCode = Assets.getText("assets/shaders/outline.frag");
		}
		if (shaderCode != null && shaderCode != "")
		{
			var outlineShader = new FlxRuntimeShader(shaderCode);
			outlineShader.setFloat("outlineSize", 2.0);
			outlineShader.setFloatArray("outlineColor", [1.0, 1.0, 1.0]);
			this.shader = outlineShader;
		}
    }
}