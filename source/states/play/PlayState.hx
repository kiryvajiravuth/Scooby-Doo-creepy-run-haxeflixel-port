package states.play;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import states.play.substates.GameOverState;
import states.play.substates.PausedState;

class PlayState extends FlxState
{
    // local map pairing animation state name keys to uniform visual size multipliers
    var animScales:Map<String, Float> = [
        "idle" => 1.2,
        "prepRun" => 0.6,
        "run" => 0.6,
        "prepCrouch" => 1.3,
        "crouch" => 1.3,
        "jump" => 1.2
    ];

    // mapping collection defining coordinate anchor offsets to fix texture alignments during action swaps
    var animOffsets:Map<String, Array<Float>> = [
        "idle" => [0.0, 0.0],
        "prepRun" => [150.0, 80.0],
        "run" => [150.0, 80.0],
        "prepCrouch" => [25.0, -30.0],
        "crouch" => [25.0, -30.0],
        "jump" => [0.0, 0.0]
    ];

    // horizontal center base line value locking the player starting destination
    var shaggyX:Float = 300.0;

    // vertical base coordinate defining the permanent ground layer height line
    var shaggyY:Float = 500.0;       

    // background map translation factor tracking leftward screen scroll pacing
    var currentScrollSpeed:Float = -1100.0;

    // delay tracking window boundary managing entry acceleration poses
    var prepThreshold:Float = 0.15;

    // downward movement factor tracking vertical weight accumulation curves
    var jumpVelocity:Float = 0.0;

    // world gravity multiplier regulating downward falling speeds over time
    var gravity:Float = 4000.0;    

    // initial vertical impulse power pushing the character upward off the ground
    var jumpForce:Float = 1500.0;

    // horizontal start position anchor locking the threat layer behind the screen border
    var skellyBaseX:Float = -200.0;

    // forward movement vector applied when chasing down slow or stuck players
    var skellyMaxCatchupSpeed:Float = 650.0; 

    // backward repositioning rate keeping the monster back during run inputs
    var skellyRetreatSpeed:Float = 250.0; 

    // horizontal dimension scaling factor adjusting the monster graphic width
    var skellyScaleX:Float = 0.7;         

    // vertical dimension scaling factor adjusting the monster graphic height
    var skellyScaleY:Float = 0.7;         

    // altitude position balancing variable lining the monster feet with the floor
    var skellyFloorOffset:Float = 175.0;

    // standard frames per second tracking the run animation cycle for the chaser
    var skellyAnimFPS:Int = 40;           

    // horizontal asset scale adjustment configuring the impact gameover animation canvas
    var deathScaleX:Float = 1.2;

    // vertical asset scale adjustment configuring the impact gameover animation canvas
    var deathScaleY:Float = 1.2;

    // horizontal positioning pad centering the crash impact sprite over the player
    var deathOffsetX:Float = -315.0;       

    // vertical positioning pad centering the crash impact sprite over the player
    var deathOffsetY:Float = -135.0;       

    // rendering playback frequency for the end game crash frame sequence
    var deathAnimFPS:Int = 25;

    // internal integer register counting total clear obstacle passes
    var score:Int = 0;

    // float clock property updating cumulative runtime duration counts
    var totalTimeSurvived:Float = 0.0;

    // storage pool referencing active instance elements for generated hazards
    var obstacles:FlxTypedGroup<Obstacle>;

    // logic timer updating current gaps between obstacle spawns
    var obstacleSpawnTimer:Float = 0.0;
    
    // interaction switch blocking input routines while taking damage
    var isStunned:Bool = false;

    // tracking countdown monitoring remaining stun phase duration steps
    var stunTimer:Float = 0.0;

    // temporary lock duration enforcing the crash recovery phase time window
    var stunDuration:Float = 1.5; 

    // instance field managing properties for the chasing creature sprite
    var skelly:FlxSprite;

    // scrolling backdrop plane drawing repeating environment walls
    var bgScrollLayer:FlxBackdrop;

    // instance field managing properties for the main player character sprite
    var shaggy:FlxSprite;

    // splash graphic element triggered when critical capture events pass
    var deathFX:FlxSprite;              
    
    // alphanumeric status layout text element showing overall score counts
    var scoreDisplay:FlxText;

    // flag tracking state conditions during aerial arc loops
    var isJumping:Bool = false;

    // flag tracking active key down compression configurations
    var isCrouching:Bool = false;

    // text tracking tag checking active poses against engine states
    var movementState:String = "idle"; 

    // accumulator tracking internal frame time across start runtime blocks
    var prepTimer:Float = 0.0;

    // main state environment creation entry building visual assets and sound systems
    override public function create():Void
    {
        super.create();

        // fetch global audio items to verify context maps and launch music tracks
        if (FlxG.sound.music == null || !FlxG.sound.music.playing)
        {
            FlxG.sound.playMusic("assets/music/CHASETHEME.ogg", 0.7, true);
        }

        // instantiate infinite tiling layer tracking horizontally across standard view bounds
        bgScrollLayer = new FlxBackdrop("assets/images/Gameplay/BackGround.png", FlxAxes.X, 0, 0);

        // calculate screen alignment levels to attach background paths tightly onto the bottom floor
        bgScrollLayer.y = FlxG.height - bgScrollLayer.height; 

        // push background layers into base container stacks to ensure behind rendering
        add(bgScrollLayer);

        // construct safe storage array containers processing procedural hazard blocks
        obstacles = new FlxTypedGroup<Obstacle>();

        // apply the blank typed container cluster layer directly onto display systems
        add(obstacles);

        // draw base tracking vectors configuring default spawn metrics for the chaser
        skelly = new FlxSprite(skellyBaseX, shaggyY);

        // parse sparrow texture atlases to pull structural asset maps for the monster
        skelly.frames = FlxAtlasFrames.fromSparrow("assets/images/Gameplay/SKELLYWAG/skelly-ton.png", "assets/images/Gameplay/SKELLYWAG/skelly-ton.xml");

        // map custom animation keys binding specific frame ranges from the loaded file atlas
        skelly.animation.addByPrefix("run", "SKELLYWAGRUNNING", skellyAnimFPS, true);

        // reduce master dimensions to conform with the general game screen sizes
        skelly.scale.set(skellyScaleX, skellyScaleY);

        // recalculate hardware boundaries matching newly downsized image assets
        skelly.updateHitbox();

        // smooth vector scale edges to mask block pixelation problems across screen devices
        skelly.antialiasing = true;

        // trigger looping run animations right at initial state instantiation steps
        skelly.animation.play("run");

        // embed the completed monster sprite layer right over layout trees
        add(skelly);

        // prepare player node coordinate pointers lining up standard baseline points
        shaggy = new FlxSprite(shaggyX, shaggyY);

        // index internal asset maps loading complete sprite sheets for player sheets
        shaggy.frames = FlxAtlasFrames.fromSparrow("assets/images/Gameplay/Shaggy-Rogers/Shaggy-Rogers.png", "assets/images/Gameplay/Shaggy-Rogers/Shaggy-Rogers.xml");

        // assign core identifier names targeting standard standing image files
        shaggy.animation.addByPrefix("idle", "Idle", 24, true);

        // load preparation acceleration frames defining quick wind up loops
        shaggy.animation.addByPrefix("prepRun", "PrepRun", 36, false);

        // link default continuous running animations to process normal motion updates
        shaggy.animation.addByPrefix("run", "shaggyRun", 24, true);

        // capture down pose transitions preparing ducking height shifts
        shaggy.animation.addByPrefix("prepCrouch", "PrepCrouch", 36, false);

        // attach standard flat looping duck poses managing active slide actions
        shaggy.animation.addByPrefix("crouch", "CROUCH", 36, false); 

        // map standard launch animation sequences targeting upward jump states
        shaggy.animation.addByPrefix("jump", "Jump", 36, false);

        // activate texture edge smoothing arrays to handle clean scaling transitions
        shaggy.antialiasing = true;

        // attach the finished character model straight to active layout nodes
        add(shaggy);

        // generate baseline structure points processing final capture sequence graphics
        deathFX = new FlxSprite(0, 0);

        // unpack system animation files tracking endgame explosion paths
        deathFX.frames = FlxAtlasFrames.fromSparrow("assets/images/Gameplay/DEATH/NOOOOO.png", "assets/images/Gameplay/DEATH/NOOOOO.xml");

        // bind action reference strings mapping the complete defeat data sheet
        deathFX.animation.addByPrefix("playDeath", "DEATH", deathAnimFPS, false);

        // expand frame box sizes to cover overall game display zones
        deathFX.scale.set(deathScaleX, deathScaleY);

        // refresh physical check lines matching updated scale variables
        deathFX.updateHitbox();

        // toggle anti aliasing features to ensure sharp vector render tracks
        deathFX.antialiasing = true;

        // set default layer visible parameter false to hide endgame items on boot
        deathFX.visible = false; 

        // push the defeat effects layer directly into state node arrays
        add(deathFX);

        // construct localized text block boxes holding score text items
        scoreDisplay = new FlxText(20, 20, 0, "0", 48);

        // define bold white lettering wrapped with distinct dark background borders
        scoreDisplay.setFormat("fonts/FridayNightFunkinTypeFont.ttf", 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        // decouple world scroll calculations so that UI objects remain stuck to screen positions
        scoreDisplay.scrollFactor.set(0, 0);

        // write out final score overlay data onto game camera stages
        add(scoreDisplay);
        
        // initialize visual components using standard standing animation loops
        playAnimation("idle");
    }

    // parsing function matching graphic layouts offset trackers and scale bounds during state shifts
    function playAnimation(name:String):Void
    {
        // break execution branches immediately if the request targets the current active sheet
        if (shaggy.animation.name == name) return;

        // launch target animation sequence using string descriptor keywords
        shaggy.animation.play(name);

        // lookup map registers to grab correct size multipliers or apply unit defaults
        var scale = animScales.exists(name) ? animScales.get(name) : 1.0;

        // extract vector balance pads or load zeros if maps do not hold matches
        var offset = animOffsets.exists(name) ? animOffsets.get(name) : [0.0, 0.0];

        // transform current body proportions using selected scale data multipliers
        shaggy.scale.set(scale, scale);

        // force alignment tracking lines to recalculate around current texture metrics
        shaggy.updateHitbox();

        // shift frame offsets to keep visual center pins aligned during action transitions
        shaggy.offset.set(offset[0], offset[1]);
    }

    // digital clock parser calculating raw decimal metrics into clean timestamp loops
    function formatTime(seconds:Float):String 
    {
        // compute complete minute segments by separating global seconds with scale blocks
        var mins:Int = Math.floor(seconds / 60);

        // isolate standard left over seconds using standard modulo arithmetic blocks
        var secs:Int = Math.floor(seconds % 60);

        // gather fractional remainders to establish short millisecond displays
        var millis:Int = Math.floor((seconds * 1000) % 1000);

        // append zero padding labels if time strings register single digits
        var minStr = (mins < 10) ? "0" + mins : "" + mins;

        // format current second counters into clear double character strings
        var secStr = (secs < 10) ? "0" + secs : "" + secs;

        // combine three digits tracking internal millisecond progress details
        var milStr = (millis < 100) ? ((millis < 10) ? "00" + millis : "0" + millis) : "" + millis;

        // join individual elements using standard semicolon separator marks
        return minStr + ":" + secStr + ":" + milStr;
    }

    // structural factory routine instantiating new hazard sprites at separate path heights
    function spawnObstacle():Void
    {
        // flip randomized fifty fifty weight equations to choose next threat variants
        var isHigh:Bool = FlxG.random.bool(50);

        // offset start coordinates outside visibility limits to create entrance spacing
        var spawnX:Float = FlxG.width + 200;

        // initiate vertical tracking placeholders at standard baseline values
        var spawnY:Float = 0;

        // look up high layout flags to establish aerial pumpkin placements
        if (isHigh) {
            // raise vertical targets slightly over floor lines to force slide solutions
            spawnY = shaggyY - 60;
        } else {
            // align base grave structures right along floor line pathways
            spawnY = shaggyY + 100;
        }

        // construct fresh hazard blocks holding type metrics and entry vectors
        var obs = new Obstacle(spawnX, spawnY, isHigh);

        // pass the completed item directly into active game loop structures
        obstacles.add(obs);
    }

    // master frame execution sequence tracking player loops collision queries and hardware flags
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // bypass all movement processing logic if global state paths match defeat labels
        if (movementState == "dead")
        {
            // evaluate progress flags to determine if defeat animations wrapped up playback
            if (deathFX.animation.finished) 
            {
                // clean up raw clock tracking numbers into display ready timestamps
                var finalTime:String = formatTime(totalTimeSurvived);

                // shift game contexts directly into the gameover substate layer
                openSubState(new GameOverState(score, finalTime));
            }

            // kill method runtime branches to prevent background update loops from processing
            return;
        }

        // track cumulative runtime counts by appending frame step times
        totalTimeSurvived += elapsed;

        // track safety frames if recovery period attributes are verified true
        if (isStunned)
        {
            // reduce recovery timers using elapsed frame time values
            stunTimer -= elapsed;

            // turn off recovery rules once safety windows drain below zero
            if (stunTimer <= 0)
            {
                // clear active stun tags to re enable standard collision tracks
                isStunned = false;

                // turn off visual display blinking routines on the character sprite
                FlxFlicker.stopFlickering(shaggy);
            }
        }

        // detect quick keyboard cancel triggers to pull up standard pause modals
        if (FlxG.keys.justPressed.ESCAPE)
        {
            // pop pause states smoothly over active gameplay displays
            openSubState(new PausedState());
        }

        // initialize standard boolean containers tracking movement status queries
        var keyUp:Bool = false;
        var keyDown:Bool = false;
        var keyRight:Bool = false;

        // block user control reading loops entirely if the stun countdown is active
        if (!isStunned)
        {
            // monitor jump keys mapping cross directional arrow parameters and standard typing layouts
            keyUp = FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W;

            // check system key profiles reading crouch inputs from arrow keys or s codes
            keyDown = FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S;

            // query forward run tracking triggers linking right arrow keys or d buttons
            keyRight = FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D;
        }
        else
        {
            // drop ducking flags if the character is currently stuck in recovery frames
            isCrouching = false;
        }

        // evaluate timing variables to trigger new obstacle spawns when clear
        if (!isStunned)
        {
            // increment hazard countdown parameters using frame loop steps
            obstacleSpawnTimer += elapsed;

            // prompt fresh factory generation routines every two seconds
            if (obstacleSpawnTimer >= 2.0)
            {
                // reset spawn countdown containers back to standard base zero states
                obstacleSpawnTimer = 0.0;

                // trigger structural generation systems to throw a new hazard item
                spawnObstacle();
            }
        }

        // determine scrolling translation multipliers depending on character running inputs
        var scrollMultiplier:Float = keyRight ? 1.0 : 0.2; 

        // compute adjusted world speeds by combining base scroll values with scale variables
        var currentSpeed:Float = currentScrollSpeed * scrollMultiplier;

        // push position changes down across all active background objects
        obstacles.forEachAlive(function(obs:Obstacle) {
            // apply scroll rates to step horizontal positions over frame windows
            obs.x += currentSpeed * elapsed;
            
            // confirm object coordinates to evaluate successful player passes
            if (!obs.passed && obs.x + obs.width < shaggy.x)
            {
                // register confirmation flags to prevent duplicate point tallies
                obs.passed = true;

                // increment system point counters by unit values
                score += 1;

                // parse current values into strings to rewrite font layers
                scoreDisplay.text = Std.string(score);
            }

            // clear out old elements passing far beyond left camera frames
            if (obs.x < -300) {
                // strip active life tags to safely drop elements from memory
                obs.kill();
            }
        });

        // evaluate overlapping bounds if recovery frames are currently down
        if (!isStunned)
        {
            // query framework collision maps checking the player sprite against active hazards
            FlxG.overlap(shaggy, obstacles, function(player:FlxSprite, obsObj:FlxSprite) {
                // securely cast item types to examine specialized obstacle data fields
                var obs = cast(obsObj, Obstacle);
                
                // bypass impact code sequences if ducking setups align with aerial threats
                if (obs.isHigh && isCrouching) return; 

                // check elevation limits to bypass impacts if jumps clear ground objects
                if (!obs.isHigh && isJumping && shaggy.y < shaggyY - 50) return; 
                
                // apply damage state switches and launch sprite flashing loops
                isStunned = true;

                // load configured delay steps into recovery tracker fields
                stunTimer = stunDuration;

                // launch flashing routines over the character texture using short swap intervals
                FlxFlicker.flicker(shaggy, stunDuration, 0.04, true);
                
                // destroy the hit obstacle to clear duplicate overlapping logs across frames
                obs.kill(); 
            });
        }

        // -------------------------------------------------------------
        // module 1: vertical physics & ground input detection
        // -------------------------------------------------------------
        if (isJumping)
        {
            // add gravitational speed increments onto active jump tracking variables
            jumpVelocity += gravity * elapsed;

            // recalculate player vertical heights using updated speed variables
            shaggy.y += jumpVelocity * elapsed;

            // clamp vertical paths back onto baseline coordinates if models fall below floor lines
            if (shaggy.y >= shaggyY) 
            {
                // align character locations precisely onto specified ground markers
                shaggy.y = shaggyY;

                // clear active jumping validation parameters to permit new commands
                isJumping = false;

                // drain current movement accumulation values back down to zero
                jumpVelocity = 0;
            }
        }
        else 
        {
            // capture up commands to launch the character upward into jumping loops
            if (keyUp) 
            {
                // lock jump validation flags to initialize gravity tracks
                isJumping = true;

                // shut off crouching flags to clear overlapping layout maps
                isCrouching = false;

                // apply negative vertical force vectors to throw models upward
                jumpVelocity = -jumpForce;
            }
            // scan system state requests to initiate crouch slide loops
            else if (keyDown) 
            {
                // verify that recovery animations are clear before locking slide states
                if (movementState != "uncrouching") {
                    // confirm slide state validation checks to adjust tracking heights
                    isCrouching = true;
                }
            }
            else 
            {
                // clear ducking states if active buttons are released
                isCrouching = false;
            }
        }

        // -------------------------------------------------------------
        // module 2: pipeline animation manager
        // -------------------------------------------------------------
        if (isStunned)
        {
            // force standing configurations if recovery states are verified true
            movementState = "idle";

            // apply standard idling loops to visual drawing nodes
            playAnimation("idle");
        }
        else if (isJumping) 
        {
            // trigger upward leaping graphic maps across player nodes
            playAnimation("jump");

            // track status variables using custom jump tags
            movementState = "jumping";
        }
        else if (isCrouching) 
        {
            // identify entry actions to trigger transitional wind up loops
            if (movementState != "preppingCrouch" && movementState != "crouchingHold") {
                // track active pose status using prep keywords
                movementState = "preppingCrouch";

                // render transitional crouching animations over drawing frames
                playAnimation("prepCrouch");
            }
            
            // halt texture index progression once wind up sequences finish loops
            if (movementState == "preppingCrouch" && shaggy.animation.finished) {
                // update system trackers to lock flat down poses
                movementState = "crouchingHold";

                // freeze frame playback routines to maintain uniform flat layouts
                shaggy.animation.pause();
            }
        }
        else if (movementState == "crouchingHold" || movementState == "uncrouching")
        {
            // handle release actions to run standard recovery animations
            if (movementState == "crouchingHold") {
                // select recovery keywords to clear holding patterns
                movementState = "uncrouching";

                // trigger the upward rising animation layout cycle
                playAnimation("crouch"); 
            }
            
            // check frame completion markers to route contexts back to basic tracks
            if (movementState == "uncrouching" && shaggy.animation.finished) {
                // determine if run buttons remain pressed upon recovery completion
                if (keyRight) {
                    // assign active running status descriptor tags
                    movementState = "running";

                    // switch texture fields to draw continuous run frames
                    playAnimation("run");
                } else {
                    // return status flags back to base default markers
                    movementState = "idle";

                    // run standard resting stance textures over the character model
                    playAnimation("idle");
                }
            }
        }
        else if (keyRight) 
        {
            // capture initial input updates to trigger running wind up states
            if (movementState != "prepping" && movementState != "running") {
                // set wind up status tracking strings across player variables
                movementState = "prepping";

                // load temporary starting acceleration animations onto screens
                playAnimation("prepRun");

                // clear active transition timers back to base zero states
                prepTimer = 0.0;
            }
            
            // process ongoing acceleration delays until target checkpoints clear
            if (movementState == "prepping") {
                // increment tracking timers using system frame step times
                prepTimer += elapsed;

                // trigger full velocity animations once delays pass threshold boundaries
                if (prepTimer >= prepThreshold) {
                    // lock master running description labels across trackers
                    movementState = "running";

                    // map permanent fast running animation sheets onto models
                    playAnimation("run");
                }
            }
        }
        else 
        {
            // route tracking labels back into basic resting statuses
            movementState = "idle";

            // apply standard idling animation sheets onto the player character
            playAnimation("idle");
        }

        // -------------------------------------------------------------
        // module 3: dynamic skeleton chase engine
        // -------------------------------------------------------------
        if (keyRight && !isStunned)
        {
            // translate background backdrop assets to create moving stage illusions
            bgScrollLayer.x += currentScrollSpeed * elapsed;

            // push monster coordinate vectors leftward to simulate retreat loops
            skelly.x -= skellyRetreatSpeed * elapsed;
            
            // clamp retreat paths to prevent chasers from shifting completely offscreen
            if (skelly.x < -400.0) {
                // secure monster position anchors at set leftward boundaries
                skelly.x = -400.0;
            }
        }
        else 
        {
            // accelerate forward velocity tracking paths if players stop or crash
            skelly.x += skellyMaxCatchupSpeed * elapsed;
        }

        // evaluate frame heights to anchor chasing models tightly along floor layers
        skelly.y = shaggyY - (skelly.height - skellyFloorOffset);

        // -------------------------------------------------------------
        // module 4: collision overlap (death)
        // -------------------------------------------------------------
        if (FlxG.overlap(shaggy, skelly))
        {
            // switch status tracking states to match the dead keyword tag
            movementState = "dead";

            // turn off any running flash loops to clean up sprite processing variables
            if (FlxFlicker.isFlickering(shaggy))
            {
                // force flicker tracking tools to completely drop the target model
                FlxFlicker.stopFlickering(shaggy);
            }

            // clear visibility variables to hide basic character frames from view
            shaggy.visible = false;

            // clear visibility variables to hide basic monster frames from view
            skelly.visible = false;

            // translate impact explosion graphics straight to the final crash site coordinates
            deathFX.x = shaggy.x + deathOffsetX;

            // balance vertical targets matching player heights using offset pads
            deathFX.y = shaggy.y + deathOffsetY;

            // flip visibility parameters true to render target explosion animations
            deathFX.visible = true;

            // launch the terminal defeat sequence directly over drawing nodes
            deathFX.animation.play("playDeath");
            
            // access global sound controllers to safely dismantle background channels
            if (FlxG.sound.music != null) FlxG.sound.music.stop();

            // trigger terminal sound files using full system volume settings
            FlxG.sound.play("assets/sounds/SadShaggyDeath.wav", 1.0);

            // exit updates instantly to avoid processing extra framework lines
            return;
        }
    }
}

// =============================================================================
// --- OBSTACLE DATA CLASS ---
// =============================================================================
class Obstacle extends FlxSprite
{
    // categorization flag tracking if objects map to high or low layers
    public var isHigh:Bool;

    // validation variable tracking if items cleared player boundaries safely
    public var passed:Bool;

    // constructor engine assigning coordinate parameters and graphic paths
    public function new(x:Float, y:Float, high:Bool)
    {
        super(x, y);

        // set type flags defining vertical elevation properties for the obstacle
        this.isHigh = high;

        // initialize clear tracker markers at standard default false values
        this.passed = false;
        
        // examine path variables to load matching graphic illustration files
        if (isHigh) 
        {
            // bind pumpkin image mappings from folder structures to create high items
            loadGraphic("assets/images/Gameplay/obstacles/duck/pumpkin.png");

            // adjust layout dimensions uniformly to scale up pumpkin textures
            scale.set(1.4, 1.4);
        } 
        else 
        {
            // bind tombstone image mappings from folder structures to create ground items
            loadGraphic("assets/images/Gameplay/obstacles/jump/grave.png");

            // adjust layout dimensions uniformly to scale up tombstone textures
            scale.set(1.5, 1.5);
        }

        // apply anti aliasing adjustments to keep scales smooth across screens
        antialiasing = true;

        // update internal physical lines to match newly selected dimensions
        updateHitbox();
    }
}