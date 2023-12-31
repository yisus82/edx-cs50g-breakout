--[[
  Originally developed by Atari in 1976. An effective evolution of
  Pong, Breakout ditched the two-player mechanic in favor of a single-
  player game where the player, still controlling a paddle, was tasked
  with eliminating a screen full of differently placed bricks of varying
  values by deflecting a ball back at them.

  This version is built to more closely resemble the NES than
  the original Pong machines or the Atari 2600 in terms of
  resolution, though in widescreen (16:9) so it looks nicer on
  modern systems.

  Credit for graphics (amazing work!):
  https://opengameart.org/users/buch

  Credit for music (great loop):
  http://freesound.org/people/joshuaempyre/sounds/251461/
  http://www.soundcloud.com/empyreanma
]]

require 'src/Dependencies'

--[[
  Called just once at the beginning of the game; used to set up
  game objects, variables, etc. and prepare the game world.
]]
function love.load()
  -- set love's default filter to "nearest-neighbor", which essentially
  -- means there will be no filtering of pixels (blurriness), which is
  -- important for a nice crisp, 2D look
  love.graphics.setDefaultFilter('nearest', 'nearest')

  -- seed the RNG so that calls to random are always random
  math.randomseed(os.time())

  -- set the application title bar
  love.window.setTitle('Breakout')

  -- initialize our nice-looking retro text fonts
  gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
  }
  love.graphics.setFont(gFonts['small'])

  -- load up the images we'll be using throughout our states
  gImages = {
    ['background'] = love.graphics.newImage('images/background.png'),
    ['main'] = love.graphics.newImage('images/breakout.png'),
    ['arrows'] = love.graphics.newImage('images/arrows.png'),
    ['hearts'] = love.graphics.newImage('images/hearts.png'),
    ['particle'] = love.graphics.newImage('images/particle.png')
  }

  -- Quads we will generate for all of our textures; Quads allow us
  -- to show only part of a texture and not the entire thing
  gQuads = {
    ['paddles'] = GenerateQuadsPaddles(gImages['main']),
    ['balls'] = GenerateQuadsBalls(gImages['main']),
    ['bricks'] = GenerateQuadsBricks(gImages['main']),
    ['hearts'] = GenerateQuads(gImages['hearts'], 10, 9),
    ['arrows'] = GenerateQuads(gImages['arrows'], 24, 24)
  }

  -- initialize our virtual resolution, which will be rendered within our
  -- actual window no matter its dimensions
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = false,
    resizable = true
  })

  -- set up our sound effects; later, we can just index this table and
  -- call each entry's `play` method
  gSounds = {
    -- SFXs
    ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
    ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
    ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
    ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
    ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
    ['no-select'] = love.audio.newSource('sounds/no-select.wav', 'static'),
    ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
    ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
    ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
    ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
    ['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
    ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
    ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),

    -- BGMs
    ['music'] = love.audio.newSource('sounds/music.wav', 'static')
  }

  -- the state machine we'll be using to transition between various states
  -- in our game instead of clumping them together in our update and draw
  -- methods
  --
  -- our current game state can be any of the following:
  -- 1. 'Start' (the beginning of the game, where we're told to press Enter)
  -- 2. 'PaddleSelect' (where we get to choose the color of our paddle)
  -- 3. 'Serve' (waiting on a key press to serve the ball)
  -- 4. 'Play' (the ball is in play, bouncing between paddles)
  -- 5. 'Victory' (the current level is over, with a victory jingle)
  -- 6. 'GameOver' (the player has lost; display score and allow restart)
  -- 7. 'HighScores' (where can can see the high scores)
  -- 8. 'EnterHighScore' (where we can enter our name when we get a high score)
  gStateMachine = StateMachine {
    ['Start'] = function() return Start() end,
    ['PaddleSelect'] = function() return PaddleSelect() end,
    ['Serve'] = function() return Serve() end,
    ['Play'] = function() return Play() end,
    ['Victory'] = function() return Victory() end,
    ['GameOver'] = function() return GameOver() end,
    ['HighScores'] = function() return HighScores() end,
    ['EnterHighScore'] = function() return EnterHighScore() end,
  }
  gStateMachine:change('Start')

  -- play our music outside of all states and set it to looping
  gSounds['music']:play()
  gSounds['music']:setLooping(true)

  -- a table we'll use to keep track of which keys have been pressed this
  -- frame, to get around the fact that LÖVE's default callback won't let us
  -- test for input from within other functions
  love.keyboard.keysPressed = {}
end

--[[
  Called whenever we change the dimensions of our window, as by dragging
  out its bottom corner, for example. In this case, we only need to worry
  about calling out to `push` to handle the resizing. Takes in a `w` and
  `h` variable representing width and height, respectively.
  @param {number} w - width of the window
  @param {number} h - height of the window
]]
function love.resize(w, h)
  push:resize(w, h)
end

--[[
  Called every frame, passing in `dt` since the last frame. `dt`
  is short for `deltaTime` and is measured in seconds. Multiplying
  this by any changes we wish to make in our game will allow our
  game to perform consistently across all hardware; otherwise, any
  changes we make will be applied as fast as possible and will vary
  across system hardware.
  @param {number} dt - time since last update in seconds
]]
function love.update(dt)
  -- this time, we pass in dt to the state object we're currently using
  gStateMachine:update(dt)

  -- reset keys pressed
  love.keyboard.keysPressed = {}
end

--[[
  A callback that processes key strokes as they happen, just the once.
  Does not account for keys that are held down, which is handled by a
  separate function (`love.keyboard.isDown`). Useful for when we want
  things to happen right away, just once, like when we want to quit.
  @param {string} key - the key that was pressed
]]
function love.keypressed(key)
  -- add to our table of keys pressed this frame
  love.keyboard.keysPressed[key] = true
end

--[[
  A custom function that will let us test for individual keystrokes outside
  of the default `love.keypressed` callback, since we can't call that logic
  elsewhere by default.
  @param {string} key - the key to test for press
]]
function love.keyboard.wasPressed(key)
  if love.keyboard.keysPressed[key] then
    return true
  else
    return false
  end
end

--[[
  Called each frame after update; is responsible for drawing all of our game
  objects and more to the screen.
]]
function love.draw()
  -- begin drawing with push, in our virtual resolution
  push:apply('start')

  -- background should be drawn regardless of state, scaled to fit our
  -- virtual resolution
  local backgroundWidth = gImages['background']:getWidth()
  local backgroundHeight = gImages['background']:getHeight()
  love.graphics.draw(gImages['background'],
    -- draw at coordinates 0, 0
    0, 0,
    -- no rotation
    0,
    -- scale factors on X and Y axis so it fills the screen
    VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))

  -- use the state machine to defer rendering to the current state we're in
  gStateMachine:render()

  -- end our drawing with push, pushing it to the screen
  push:apply('end')
end

--[[
  Renders hearts based on how much health the player has. First renders
  full hearts, then empty hearts for however much health we're missing.
  @param {number} health - the player's current health
]]
function RenderHealth(health)
  -- start of our health rendering
  local healthX = VIRTUAL_WIDTH / 2 - 50

  -- render health left
  for i = 1, health do
    love.graphics.draw(gImages['hearts'], gQuads['hearts'][1], healthX, 4)
    healthX = healthX + 11
  end

  -- render missing health
  for i = 1, 3 - health do
    love.graphics.draw(gImages['hearts'], gQuads['hearts'][2], healthX, 4)
    healthX = healthX + 11
  end
end

--[[
  Simply renders the player's score at the top right, with left-side padding
  for the score number.
  @param {number} score - the player's current score
]]
function RenderScore(score)
  love.graphics.setFont(gFonts['small'])
  love.graphics.print('Score: ' .. tostring(score), VIRTUAL_WIDTH / 2, 5)
end

--[[
  Renders the crrent level at the bottom center of the screen.
]]
function RenderLevel(level)
  love.graphics.setFont(gFonts['small'])
  love.graphics.printf('Level: ' .. tostring(level), 0, VIRTUAL_HEIGHT - 8, VIRTUAL_WIDTH, 'center')
end

--[[
  Loads high scores from a .lst file, saved in LÖVE2D's default save directory in a subfolder
  called 'breakout'.
]]
function LoadHighScores()
  -- set the write directory
  love.filesystem.setIdentity('breakout')

  -- if the file doesn't exist, initialize it with some default scores
  if not love.filesystem.getInfo('breakout.lst') then
    local scores = ''
    for i = 10, 1, -1 do
      scores = scores .. 'BREAKOUT\n'
      scores = scores .. tostring(i * 100) .. '\n'
    end

    love.filesystem.write('breakout.lst', scores)
  end

  -- flag for whether we're reading a name or not
  local name = true

  -- counter for the high scores
  local counter = 1

  -- initialize scores table with at least 10 blank entries
  local scores = {}

  for i = 1, 10 do
    -- blank table; each will hold a name and a score
    scores[i] = {
      name = nil,
      score = nil
    }
  end

  -- iterate over each line in the file, filling in names and scores
  for line in love.filesystem.lines('breakout.lst') do
    if name then
      scores[counter].name = string.sub(line, 1, 10)
    else
      scores[counter].score = tonumber(line)
      counter = counter + 1
    end

    -- flip the name flag
    name = not name
  end

  return scores
end
