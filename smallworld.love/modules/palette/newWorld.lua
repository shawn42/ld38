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
    data={water=0,maxWater=100},
  },
  Leaf = {
    style='squareSpray',
    rate=5,
    size=10,
    color=C.Leaf,
    type=T.Leaf,
    data={life=100},
  },
  Water = {
    style='squareSpray',
    rate=10,
    size=5,
    color=C.Water,
    type=T.Water,
    data={water=200},
  },
  SingleWater = {
    style='pixel',
    color=C.Water,
    type=T.Water,
    data={water=200},
  },
  Stone = {
    style='squareSolid',
    size=5,
    color=C.Stone,
    type=T.Stone,
  },
  Soil = {
    style='squareSpray',
    rate=6,
    size=3,
    color=C.Soil,
    type=T.Soil,
    data={water=100,maxWater=100},
  },
  Seed = {
    style='pixel',
    color=C.Seed,
    type=T.Seed,
    data={t=0, water=0,maxWater=50},
  },
}

local items = {
  {key="1", label="1", brushName="Sand", color=C.Sand},
  {key="2", label="2", brushName="Leaf", color=C.Leaf},
  {key="3", label="3", brushName="Water", color=C.Water},
  {key="4", label="4", brushName="SingleWater", color={0,0,255}},
  {key="5", label="5", brushName="Stone", color=C.Stone},
  {key="6", label="6", brushName="Seed", color=C.Seed},
  -- {key="0", label="0", typeName="ERASER"}, -- this works, and adds eraser to the palette as a normal brush.
}


local function newWorld(opts)
  local world = {
    bounds=opts.bounds,
    items=items,
    brushes=brushes,
    brushName="Sand",    -- as defined in brushes
    eraserName="ERASER", -- as defined in brushes
  }
  return world
end

return newWorld
