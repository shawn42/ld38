local Pixtypes = require 'pixtypes'
local T = Pixtypes.Type
local C = Pixtypes.Color

local brushes = {
  ERASER = {
    style='eraser', -- these style refs need to match keys in Pixbrush.Styles
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
  SingleWater = {
    style='pixel',
    color=C.Water,
    type=T.Water,
  },
  Stone = {
    style='squareSolid',
    size=5,
    color=C.Stone,
    type=T.Stone,
  },
  Seed = {
    style='pixel',
    color=C.Seed,
    type=T.Seed,
    data={t=0},
  },
}

local items = {
  {label="1", brushName="Sand", color=C.Sand},
  {label="2", brushName="Leaf", color=C.Leaf},
  {label="3", brushName="Water", color=C.Water},
  {label="4", brushName="SingleWater", color={0,0,255}},
  {label="5", brushName="Stone", color=C.Stone},
  {label="6", brushName="Seed", color=C.Seed},
  -- {label="0", typeName="ERASER"}, -- this works, and adds eraser to the palette as a normal brush.
}


local function newWorld(opts)
  local world = {
    bounds=opts.bounds,
    items=items,
    brushes=brushes,
    brushName="Sand",
    eraserName="ERASER",
  }
  return world
end

return newWorld
