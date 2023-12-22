--[[
  Represents the screen where we can view all high scores previously recorded.
]]

HighScores = Class { __includes = Base }

--[[
  Called when we first enter the HighScores state.
  @param {table} params - contains the high scores we passed in
]]
function HighScores:enter(params)
  self.highScores = params.highScores
end

--[[
  Called whenever we update the state; here, we just want to exit to the
  start screen if we press escape.
  @param {number} dt - time since last update in seconds
]]
function HighScores:update(dt)
  -- return to the start screen if we press escape
  if love.keyboard.wasPressed('escape') then
    gSounds['wall-hit']:play()

    gStateMachine:change('Start')
  end
end

--[[
  Called each frame after update; is responsible simply for drawing all of our
  buttons and labels to the screen.
]]
function HighScores:render()
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf('High Scores', 0, 20, VIRTUAL_WIDTH, 'center')

  love.graphics.setFont(gFonts['medium'])

  -- iterate over all high score indices in our high scores table
  for i = 1, 10 do
    local name = self.highScores[i].name or '---'
    local score = self.highScores[i].score or '---'

    -- score number (1-10)
    love.graphics.printf(tostring(i) .. '.', VIRTUAL_WIDTH / 4,
      60 + i * 13, 50, 'left')

    -- score name
    love.graphics.printf(name, VIRTUAL_WIDTH / 4 + 2,
      60 + i * 13, 150, 'center')

    -- score itself
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH / 2,
      60 + i * 13, 100, 'right')
  end

  -- instructions on how to return to start screen
  love.graphics.setFont(gFonts['small'])
  love.graphics.printf("Press Escape to return to the main menu!",
    0, VIRTUAL_HEIGHT - 18, VIRTUAL_WIDTH, 'center')
end
