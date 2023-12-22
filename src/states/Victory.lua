--[[
  Represents the state that the game is in when we've just completed a level.
  Very similar to the Serve state, except here we increment the level
]]

Victory = Class { __includes = Base }

--[[
  Called when we first enter the victory state.
  @param {table} params - contains the level we're on, the paddle we're controlling, the health and score we're going to, and the ball
]]
function Victory:enter(params)
  self.level = params.level
  self.score = params.score
  self.paddle = params.paddle
  self.health = params.health
  self.ball = params.ball
end

--[[
  Called whenever we update the state; used to transition to the Serve state
  when we press Enter
  @param {number} dt - time since last update in seconds
]]
function Victory:update(dt)
  -- update positions based on velocity
  self.paddle:update(dt)

  -- have the ball track the player
  self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
  self.ball.y = self.paddle.y - 8

  -- go to play screen if the player presses Enter
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    gStateMachine:change('Serve', {
      level = self.level + 1,
      bricks = LevelMaker:createMap(self.level + 1),
      paddle = self.paddle,
      health = self.health,
      score = self.score
    })
  end
end

--[[
  Renders the state
]]
function Victory:render()
  -- renders the paddle and the ball
  self.paddle:render()
  self.ball:render()

  -- renders the health and score
  RenderHealth(self.health)
  RenderScore(self.score)

  -- level complete text
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf("Level " .. tostring(self.level) .. " complete!",
    0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

  -- instructions text
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf('Press Enter to play the next level!', 0, VIRTUAL_HEIGHT / 2,
    VIRTUAL_WIDTH, 'center')
end
