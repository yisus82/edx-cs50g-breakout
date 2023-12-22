--[[
  The state in which we've lost all of our health and get our score displayed to us. Should
  transition to the EnterHighScore state if we exceeded one of our stored high scores, else back
  to the Start state.
]]

GameOver = Class { __includes = Base }

--[[
  Called when we first enter the GameOver state.
  @param {table} params - contains the score from the previous state
]]
function GameOver:enter(params)
  self.score = params.score
end

--[[
  Called whenever we update the state
  @param {number} dt - time since last update in seconds
]]
function GameOver:update(dt)
  -- if we press enter, go back to the start screen
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    gStateMachine:change('Start')
  end

  -- exit game if we press escape
  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end

--[[
  Called whenever we want to draw the state to the screen.
]]
function GameOver:render()
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf('GAME OVER', 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf('Final Score: ' .. tostring(self.score), 0, VIRTUAL_HEIGHT / 2,
    VIRTUAL_WIDTH, 'center')
  love.graphics.printf('Press Enter!', 0, VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 4,
    VIRTUAL_WIDTH, 'center')
end
