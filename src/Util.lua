--[[
  Helper functions for writing games.
]]

--[[
  Given an "atlas" (an image with multiple sprites), as well as a
  width and a height for the tiles therein, split the image into
  all of the quads by simply dividing it evenly.
  @param {Image} atlas - the atlas to split into frames
  @param {number} tilewidth - the width of each individual tile
  @param {number} tileheight - the height of each individual tile
]]
function GenerateQuads(atlas, tilewidth, tileheight)
  local sheetWidth = atlas:getWidth() / tilewidth
  local sheetHeight = atlas:getHeight() / tileheight

  local sheetCounter = 1
  local spritesheet = {}

  for y = 0, sheetHeight - 1 do
    for x = 0, sheetWidth - 1 do
      spritesheet[sheetCounter] =
          love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
            tileheight, atlas:getDimensions())
      sheetCounter = sheetCounter + 1
    end
  end

  return spritesheet
end

--[[
  Utility function for slicing tables, like in Python.

  https://stackoverflow.com/questions/24821045/does-lua-have-something-like-pythons-slice

  @param {table} tbl - the table to slice
  @param {number} first - the first element to include in the slice
  @param {number} last - the last element to include in the slice
  @param {number} step - the iteration step for the slice
]]
function table.slice(tbl, first, last, step)
  local sliced = {}

  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced + 1] = tbl[i]
  end

  return sliced
end

--[[
  This function is specifically made to piece out the paddles from the
  sprite sheet. For this, we have to piece out the paddles a little more
  manually, since they are all different sizes.
]]
function GenerateQuadsPaddles(atlas)
  local x = 0
  local y = 64

  local counter = 1
  local quads = {}

  for i = 0, 3 do
    -- smallest
    quads[counter] = love.graphics.newQuad(x, y, 32, 16,
      atlas:getDimensions())
    counter = counter + 1
    -- medium
    quads[counter] = love.graphics.newQuad(x + 32, y, 64, 16,
      atlas:getDimensions())
    counter = counter + 1
    -- large
    quads[counter] = love.graphics.newQuad(x + 96, y, 96, 16,
      atlas:getDimensions())
    counter = counter + 1
    -- huge
    quads[counter] = love.graphics.newQuad(x, y + 16, 128, 16,
      atlas:getDimensions())
    counter = counter + 1

    -- prepare X and Y for the next set of paddles
    x = 0
    y = y + 32
  end

  return quads
end
