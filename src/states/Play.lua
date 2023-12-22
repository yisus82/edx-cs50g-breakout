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
  @param {table} params - contains the paddle we're controlling, the ball and the bricks in our game, and the
    health and score when we're transitioning from another state
]]
function Play:enter(params)
  self.paddle = params.paddle
  self.bricks = params.bricks
  self.health = params.health
  self.score = params.score
  self.ball = params.ball

  -- give ball random starting velocity
  self.ball.dx = math.random(-200, 200)
  self.ball.dy = math.random(-50, -60)
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

  -- detect collision with paddle, reversing dy if true and slightly increasing it, then altering the dx based on the position of collision
  if self.ball:collides(self.paddle) then
    -- raise ball above paddle in case it goes below it, then reverse dy
    self.ball.y = self.paddle.y - 8

    -- reverse dy
    self.ball.dy = -self.ball.dy

    -- if we hit the paddle on its left side while moving left
    -- else if we hit the paddle on its right side while moving right
    if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
      self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
    elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
      self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
    end

    -- play paddle collision sound
    gSounds['paddle-hit']:play()
  end

  -- detect collision across all bricks with the ball
  for _, brick in pairs(self.bricks) do
    -- only check collision if brick is active
    if brick.active and self.ball:collides(brick) then
      -- trigger the brick's hit function, which deactivates it
      brick:hit()

      -- add to score
      self.score = self.score + (brick.tier * 200 + brick.color * 25)

      -- we check to see if the opposite side of our ball is outside of the brick;
      -- if it is, we trigger a collision on that side; otherwise we're within the X + width of
      -- the brick and we should check to see if the top or bottom edge is outside of the brick,
      -- colliding on the top or bottom accordingly

      -- left edge; only check if we're moving right
      if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
        -- flip x velocity and reset position outside of brick
        self.ball.dx = -self.ball.dx
        self.ball.x = brick.x - self.ball.width
        -- right edge; only check if we're moving left
      elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then
        -- flip x velocity and reset position outside of brick
        self.ball.dx = -self.ball.dx
        self.ball.x = brick.x + brick.width
        -- top edge if no X collisions, always check
      elseif self.ball.y < brick.y then
        -- flip y velocity and reset position outside of brick
        self.ball.dy = -self.ball.dy
        self.ball.y = brick.y - self.ball.height
        -- bottom edge if no X collisions or top collision, last possibility
      else
        -- flip y velocity and reset position outside of brick
        self.ball.dy = -self.ball.dy
        self.ball.y = brick.y + brick.height
      end

      -- slightly scale the y velocity to speed up the game
      self.ball.dy = self.ball.dy * 1.02

      -- we only allow colliding with one brick, for corners
      break
    end
  end

  -- check if ball goes below bounds
  if self.ball.y >= VIRTUAL_HEIGHT then
    -- decrease health and play sound
    self.health = self.health - 1
    gSounds['hurt']:play()

    -- if health is 0, game is over, otherwise go to serve state
    if self.health == 0 then
      gStateMachine:change('GameOver', {
        score = self.score
      })
    else
      gStateMachine:change('Serve', {
        paddle = self.paddle,
        bricks = self.bricks,
        health = self.health,
        score = self.score
      })
    end
  end
end

--[[
  Called each frame after update; is responsible simply for drawing all of our
  game objects and more to the screen.
]]
function Play:render()
  -- render bricks
  for _, brick in pairs(self.bricks) do
    brick:render()
  end

  -- render paddle
  self.paddle:render()

  -- render ball
  self.ball:render()

  -- render score and health
  RenderScore(self.score)
  RenderHealth(self.health)

  -- pause text, if paused
  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
  end
end
