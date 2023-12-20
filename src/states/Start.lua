--[[
  Represents the state the game is in when we've just started; should
  simply display "Breakout" in large text, as well as a message to press
  Enter to begin.
]]

-- the "__includes" bit here means we're going to inherit all of the methods
-- that Base state has, so it will have empty versions of all StateMachine methods
-- even if we don't override them ourselves; handy to avoid superfluous code!
Start = Class { __includes = Base }

-- our highlighted menu item
local highlighted = 1

-- our menu items
local menuItems = {
  [1] = {
    text = 'START'
  },
  [2] = {
    text = 'HIGH SCORES',
  }
}

--[[
  Update the highlighted menu item if we press an arrow key up or down
  @param {number} dt - time since last update in seconds
]]
function Start:update(_dt)
  -- change the highlighted menu item if we press the up arrow key
  if love.keyboard.wasPressed('up') then
    -- make sure the highlighted menu item doesn't exceed the size of our table
    highlighted = highlighted - 1 <= 0 and #menuItems or highlighted - 1
    gSounds['paddle-hit']:play()
  end

  -- change the highlighted menu item if we press the down arrow key
  if love.keyboard.wasPressed('down') then
    -- make sure the highlighted menu item doesn't exceed the size of our table
    highlighted = highlighted + 1 > #menuItems and 1 or highlighted + 1
    gSounds['paddle-hit']:play()
  end

  -- exit game if we press escape
  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end
end

--[[
  Render our menu items along with highlighting the currently highlighted menu item
]]
function Start:render()
  -- title
  love.graphics.setFont(gFonts['large'])
  love.graphics.printf("BREAKOUT", 0, VIRTUAL_HEIGHT / 3,
    VIRTUAL_WIDTH, 'center')

  -- menu items
  love.graphics.setFont(gFonts['medium'])
  for key, menuItem in ipairs(menuItems) do
    -- if we're highlighting this current item, draw it with a tint
    if highlighted == key then
      love.graphics.setColor(103 / 255, 1, 1, 1)
    else
      love.graphics.setColor(1, 1, 1, 1)
    end

    -- draw menu item text
    love.graphics.printf(menuItem.text, 0, VIRTUAL_HEIGHT / 2 + 20 * (key - 1), VIRTUAL_WIDTH, 'center')
  end
end
