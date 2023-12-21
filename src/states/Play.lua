--[[
  Represents the state of the game in which we are actively playing;
  player should control the paddle, with the ball actively bouncing between
  the bricks, walls, and the paddle. If the ball goes below the paddle, then
  the player should lose one point of health and be taken either to the Game
  Over screen if at 0 health or the Serve screen otherwise.
]]

Play = Class { __includes = Base }

--[[
  We initialize what's in our Play state.
  Called once when we first enter the state.
]]
function Play:init()
  self.paddle = Paddle()
  self.paused = false
end

--[[
  Called whenever we update the state
  @param {number} dt - time since last update in seconds
]]
function Play:update(dt)
  -- exit game if we press escape
  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end

  -- when the game is paused, if space is pressed then unpause it; otherwise do nothing else
  -- when the game is not paused, if space is pressed pause the game and do nothing else
  if self.paused then
    if love.keyboard.wasPressed('space') then
      self.paused = false
      gSounds['pause']:play()
    else
      return
    end
  elseif love.keyboard.wasPressed('space') then
    self.paused = true
    gSounds['pause']:play()
    return
  end

  -- update positions based on velocity
  self.paddle:update(dt)
end

--[[
  Called each frame after update; is responsible simply for drawing all of our
  game objects and more to the screen.
]]
function Play:render()
  -- render paddle
  self.paddle:render()

  -- pause text, if paused
  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
  end
end
