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
  -- in the beginning, the game is not paused
  self.paused = false

  -- initialize our paddle
  self.paddle = Paddle()

  -- initialize our ball with a random skin
  self.ball = Ball(math.random(7))

  -- give the ball random starting velocity
  self.ball.dx = math.random(-200, 200)
  self.ball.dy = math.random(-50, -60)

  -- give the ball position in the center
  self.ball.x = VIRTUAL_WIDTH / 2 - 4
  self.ball.y = VIRTUAL_HEIGHT - 42
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
  self.ball:update(dt)

  -- detect collisions
  -- reverse Y velocity if collision detected between paddle and ball
  if self.ball:collides(self.paddle) then
    self.ball.dy = -self.ball.dy
    gSounds['paddle-hit']:play()
  end

  -- detect if ball goes below bounds of screen
  if self.ball.y >= VIRTUAL_HEIGHT then
    gSounds['hurt']:play()
    self.ball:reset()
  end
end

--[[
  Called each frame after update; is responsible simply for drawing all of our
  game objects and more to the screen.
]]
function Play:render()
  -- render paddle
  self.paddle:render()

  -- render ball
  self.ball:render()

  -- pause text, if paused
  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
  end
end
