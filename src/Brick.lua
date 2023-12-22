--[[
  Represents a brick in the world space that the ball can collide with;
  differently colored bricks have different point values. On collision,
  the ball will bounce away depending on the angle of collision. When all
  bricks are cleared in the current map, the player should be taken to a new
  layout of bricks.
]]

Brick = Class {}

--[[
  Called once at the beginning of each level; initializes the brick
]]
function Brick:init(x, y)
  -- used for coloring and score calculation
  self.tier = 0
  self.color = 1

  -- position
  self.x = x
  self.y = y

  -- dimensions
  self.width = 32
  self.height = 16

  -- used to determine whether this brick should be rendered
  self.active = true
end

--[[
  Triggers a hit on the brick, taking it out of play if at 0 health or
  changing its color otherwise.
]]
function Brick:hit()
  -- sound on hit
  gSounds['brick-hit-2']:stop()
  gSounds['brick-hit-2']:play()

  -- if we're at a higher tier than the base, we need to go down a tier
  -- if we're already at the lowest color, else just go down a color
  if self.tier > 0 then
    if self.color == 1 then
      self.tier = self.tier - 1
      self.color = 5
    else
      self.color = self.color - 1
    end
  else
    -- if we're in the first tier and the base color, deactivate the brick
    if self.color == 1 then
      self.active = false
    else
      self.color = self.color - 1
    end
  end

  -- play a second layer sound if the brick is destroyed
  if not self.active then
    gSounds['brick-hit-1']:stop()
    gSounds['brick-hit-1']:play()
  end
end

--[[
  Renders the brick.
]]
function Brick:render()
  -- if the brick is active, render it
  if self.active then
    love.graphics.draw(gImages['main'],
      -- multiply color by 4 (-1) to get our color offset, then add tier to that
      -- to draw the correct tier and color brick onto the screen
      gQuads['bricks'][1 + ((self.color - 1) * 4) + self.tier],
      self.x, self.y)
  end
end
