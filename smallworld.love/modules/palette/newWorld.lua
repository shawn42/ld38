local Pixtypes = require 'pixtypes'
local T = Pixtypes.Type
local C = Pixtypes.Color

local brushes = {
  ERASER = {
    style='eraser',
    size=10,
    color={100,100,100},
    type=T.Off,
  },
  Sand = {
    style='squareSpray',
    rate=10,
    size=10,
    color=C.Sand,
    type=T.Sand,
  },
  Leaf = {
    style='squareSpray',
    rate=5,
    size=10,
    color=C.Leaf,
    type=T.Leaf,
  },
  Water = {
    style='squareSpray',
    rate=10,
    size=5,
    color=C.Water,
    type=T.Water,
  },
  Stone = {
    style='squareSolid',
    size=5,
    color=C.Stone,
    type=T.Stone,
  }
}

local items = {
  {label="1", typeName="Sand"},
  {label="2", typeName="Leaf"},
  {label="3", typeName="Water"},
  {label="4", typeName="Stone"},
  {label="0", typeName="ERASER"},
}


local function newWorld(opts)
  local world = {
    bounds=opts.bounds,
    items=items,
    brushes=brushes,
    brushName="Sand",
  }
  return world
end

return newWorld
