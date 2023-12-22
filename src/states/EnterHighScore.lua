--[[
  Screen that allows us to input a new high score in the form of ten characters.
]]

EnterHighScore = Class { __includes = Base }

-- individual chars of our string
local chars = {
  [1] = 65,
  [2] = 65,
  [3] = 65,
  [4] = 65,
  [5] = 65,
  [6] = 65,
  [7] = 65,
  [8] = 65,
  [9] = 65,
  [10] = 65
}

-- char we're currently changing
local highlightedChar = 1

--[[
  Called when we first enter the EnterHighScore state.
  @param {table} params - contains the high scores we passed in, the score and the index that score is in
]]
function EnterHighScore:enter(params)
  self.highScores = params.highScores
  self.score = params.score
  self.scoreIndex = params.scoreIndex
end

--[[
  Called whenever we update the state; here, we just want to update our char
  selection based on which key was pressed
  @param {number} dt - time since last update in seconds
]]
function EnterHighScore:update(dt)
  -- if we press enter, we should add our new high score, sort, and update the file and finally switch to HighScore state
  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    -- update scores table
    local name = string.char(unpack(chars))

    -- go backwards through high scores table till this score, shifting scores
    for i = 10, self.scoreIndex, -1 do
      self.highScores[i + 1] = {
        name = self.highScores[i].name,
        score = self.highScores[i].score
      }
    end

    -- update new score
    self.highScores[self.scoreIndex].name = name
    self.highScores[self.scoreIndex].score = self.score

    -- write scores to file
    local scoresStr = ''

    for i = 1, 10 do
      scoresStr = scoresStr .. self.highScores[i].name .. '\n'
      scoresStr = scoresStr .. tostring(self.highScores[i].score) .. '\n'
    end

    love.filesystem.write('breakout.lst', scoresStr)

    gStateMachine:change('HighScores', {
      highScores = self.highScores
    })
  end

  -- scroll through character slots
  if love.keyboard.wasPressed('left') and highlightedChar > 1 then
    highlightedChar = highlightedChar - 1
    gSounds['select']:play()
  elseif love.keyboard.wasPressed('right') and highlightedChar < 10 then
    highlightedChar = highlightedChar + 1
    gSounds['select']:play()
  end

  -- scroll through characters
  if love.keyboard.wasPressed('up') then
    chars[highlightedChar] = chars[highlightedChar] + 1
    if chars[highlightedChar] == 91 then
      chars[highlightedChar] = 32
    elseif chars[highlightedChar] == 33 then
      chars[highlightedChar] = 65
    end
  elseif love.keyboard.wasPressed('down') then
    chars[highlightedChar] = chars[highlightedChar] - 1
    if chars[highlightedChar] == 64 then
      chars[highlightedChar] = 32
    elseif chars[highlightedChar] == 31 then
      chars[highlightedChar] = 90
    end
  end
end

--[[
  Renders the state; called once each frame
]]
function EnterHighScore:render()
  love.graphics.setFont(gFonts['medium'])
  love.graphics.printf('Your score: ' .. tostring(self.score), 0, 30,
    VIRTUAL_WIDTH, 'center')
  love.graphics.printf('Enter your name: ', 0, 50, VIRTUAL_WIDTH, 'center')

  love.graphics.setFont(gFonts['large'])

  -- render all ten characters of the name
  for key, char in ipairs(chars) do
    if key == highlightedChar then
      love.graphics.setColor(103 / 255, 1, 1, 1)
    else
      love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.print(string.char(char), VIRTUAL_WIDTH / 2 - 120 + (key - 1) * 24, VIRTUAL_HEIGHT / 2)
  end

  -- instructions
  love.graphics.setFont(gFonts['small'])
  love.graphics.printf('Press Enter to confirm!', 0, VIRTUAL_HEIGHT - 18,
    VIRTUAL_WIDTH, 'center')
end
