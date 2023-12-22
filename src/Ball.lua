--[[
  Represents a ball which will bounce back and forth between the sides
  of the world space, the player's paddle, and the bricks laid out above
  the paddle. The ball can have a skin, which is chosen at random, just
  for visual variety.
]]

Ball = Class {}

--[[
  Our Ball should initialize at the same spot every time, in the middle
  of the screen, going neither left nor right.
  @param {number} skin - index of the ball skin to use
]]
function Ball:init(skin)
  -- simple positional and dimensional variables
  self.width = 8
  self.height = 8

  -- these variables are for keeping track of our velocity on both the
  -- X and Y axis, since the ball can move in two dimensions
  self.dy = 0
  self.dx = 0

  -- this will effectively be the color of our ball, and we will index
  -- our table of Quads relating to the global block texture using this
  self.skin = skin
end

--[[
  Expects an argument with a bounding box, be that a paddle or a brick,
  and returns true if the bounding boxes of this and the argument overlap.
  @param {table} target - the other object we're checking collision with
]]
function Ball:collides(target)
  -- first, check to see if the left edge of either is farther to the right
  -- than the right edge of the other
  if self.x > target.x + target.width or target.x > self.x + self.width then
    return false
  end

  -- then check to see if the bottom edge of either is higher than the top
  -- edge of the other
  if self.y > target.y + target.height or target.y > self.y + self.height then
    return false
  end

  -- if the above aren't true, they're overlapping
  return true
end

--[[
  Places the ball in the middle of the screen, with no movement.
]]
function Ball:reset()
  self.x = VIRTUAL_WIDTH / 2 - 2
  self.y = VIRTUAL_HEIGHT / 2 - 2
  self.dx = 0
  self.dy = 0
end

--[[
  Simply applies velocity to position, scaled by deltaTime.
  @param {number} dt - time since last frame, in seconds
]]
function Ball:update(dt)
  -- apply velocity to position
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt

  -- allow the ball to bounce off walls
  -- if we reach the left edge of the screen
  if self.x <= 0 then
    self.x = 0
    self.dx = -self.dx
    gSounds['wall-hit']:play()
  end
  -- if we reach the right edge of the screen
  if self.x >= VIRTUAL_WIDTH - 8 then
    self.x = VIRTUAL_WIDTH - 8
    self.dx = -self.dx
    gSounds['wall-hit']:play()
  end
  -- if we reach the top edge of the screen
  if self.y <= 0 then
    self.y = 0
    self.dy = -self.dy
    gSounds['wall-hit']:play()
  end
end

--[[
  Renders the ball.
]]
function Ball:render()
  love.graphics.draw(gImages['main'], gQuads['balls'][self.skin],
    self.x, self.y)
end
