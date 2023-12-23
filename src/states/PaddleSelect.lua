--[[
  In this state we can select the paddle we want to use. We can cycle through
  all four paddles with the left and right arrow keys. Pressing Enter or Return
  will select a paddle and move us on to the Serve state, at which point we're
  playing the game for real, and the player can move the paddle to bounce the
  ball around.
]]

PaddleSelect = Class { __includes = Base }

--[[
  Called when we first enter the PaddleSelect state.
]]
function PaddleSelect:init()
  -- the paddle we're highlighting; will be passed to the ServeState
  -- when we press Enter
  self.currentPaddle = 1
end

--[[
  Update the PaddleSelect screen, changing which paddle we have highlighted
  if we press the left or right arrow keys. If we press Enter, we should
  go into the Serve state, passing in the paddle we have highlighted.
  @param {number} dt - time since last update in seconds
]]
function PaddleSelect:update(dt)
  if love.keyboard.wasPressed('left') then
    if self.currentPaddle == 1 then
      gSounds['no-select']:play()
    else
      gSounds['select']:play()
      self.currentPaddle = self.currentPaddle - 1
    end
  elseif love.keyboard.wasPressed('right') then
    if self.currentPaddle == 4 then
      gSounds['no-select']:play()
    else
      gSounds['select']:play()
      self.currentPaddle = self.currentPaddle + 1
    end
  end

  -- select paddle and move on to the serve state, passing in the selection
  if love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
    gSounds['confirm']:play()

    gStateMachine:change('Serve', {
      paddle = Paddle(self.currentPaddle),
      bricks = LevelMaker:createMap(1),
      health = 3,
      score = 0,
      level = 1
    })
  end

  -- go back to the start screen if we press escape
  if love.keyboard.wasPressed('escape') then
    gStateMachine:change('Start')
  end
end

--[[
  Render the paddles and the instructions to select one.
]]
function PaddleSelect:render()
  -- instructions
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf("Select your paddle with left and right", 0, VIRTUAL_HEIGHT / 4,
    VIRTUAL_WIDTH, 'center')
  love.graphics.setFont(gFonts['small'])
  love.graphics.printf("(Press Enter to confirm your selection)", 0, VIRTUAL_HEIGHT / 3,
    VIRTUAL_WIDTH, 'center')

  -- left arrow; should render normally if we're higher than 1, else
  -- in a shadowy form to let us know we're as far left as we can go
  if self.currentPaddle == 1 then
    -- tint; give it a dark gray with half opacity
    love.graphics.setColor(40 / 255, 40 / 255, 40 / 255, 128 / 255)
  end

  love.graphics.draw(gImages['arrows'], gQuads['arrows'][1], VIRTUAL_WIDTH / 4 - 24,
    VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)

  -- reset drawing color to full white for proper rendering
  love.graphics.setColor(1, 1, 1, 1)

  -- right arrow; should render normally if we're less than 4, else
  -- in a shadowy form to let us know we're as far right as we can go
  if self.currentPaddle == 4 then
    -- tint; give it a dark gray with half opacity
    love.graphics.setColor(40 / 255, 40 / 255, 40 / 255, 128 / 255)
  end

  love.graphics.draw(gImages['arrows'], gQuads['arrows'][2], VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4,
    VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)

  -- reset drawing color to full white for proper rendering
  love.graphics.setColor(1, 1, 1, 1)

  -- draw the paddle itself, based on which we have selected
  love.graphics.draw(gImages['main'], gQuads['paddles'][2 + 4 * (self.currentPaddle - 1)],
    VIRTUAL_WIDTH / 2 - 32, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3)
end
