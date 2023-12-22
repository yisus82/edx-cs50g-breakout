--[[
  The state in which we are waiting to serve the ball; here, we are
  basically just moving the paddle left and right with the ball until we
  press Enter, though everything in the actual game now should render in
  preparation for the serve, including our current health and score, as
  well as the level we're on.
]]

Serve = Class { __includes = Base }

--[[
  Called when we first enter the Serve state.
  @param {table} params - contains the paddle we're controlling and the bricks in our game, and the
    health and score when we're transitioning from another state, and the level we're on
]]
function Serve:enter(params)
  -- grab game state from params
  self.paddle = params.paddle
  self.bricks = params.bricks
  self.health = params.health
  self.score = params.score
  self.level = params.level

  -- init new ball (random color for fun)
  self.ball = Ball()
  self.ball.skin = math.random(7)
end

--[[
  Called whenever we update the state
  @param {number} dt - time since last update in seconds
]]
function Serve:update(dt)
  -- have the ball track the player
  self.paddle:update(dt)
  self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
  self.ball.y = self.paddle.y - 8

  -- if we press enter, go to play and pass in all the state we need to
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    gStateMachine:change('Play', {
      paddle = self.paddle,
      bricks = self.bricks,
      health = self.health,
      score = self.score,
      ball = self.ball,
      level = self.level
    })
  end

  -- exit game if we press escape
  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end

--[[
  Called whenever we want to draw the state to the screen.
]]
function Serve:render()
  -- render paddle and ball
  self.paddle:render()
  self.ball:render()

  -- render bricks
  for _, brick in pairs(self.bricks) do
    brick:render()
  end

  -- render score, health and level
  RenderScore(self.score)
  RenderHealth(self.health)
  RenderLevel(self.level)

  -- instructions
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2,
    VIRTUAL_WIDTH, 'center')
end
