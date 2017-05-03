require 'ecs/ecshelpers'
local Pixgrid = require 'pixgrid'
local Pixtypes = require 'pixtypes'
local T = Pixtypes.Type
local Updaters = Pixtypes.Updaters
local Helpers = require 'modules.pixels-ecs.helpers'
local scriptSystem = require 'systems.script'

-- Function to update the Pixgrid
local changer = Pixgrid.Changer:new()

local function clearEntityPixels(pixgrid)
  changer:reset()
  for i=1,#pixgrid.buf do
    if pixgrid.buf[i].type == T.Entity then
      changer:clear(pixgrid.buf[i])
    end
  end
  changer:apply(pixgrid)
end

local function updatePixgrid(pixgrid, iterations)
  for i=1, iterations do
    changer:reset()
    -- Accumulate pixgrid updates:
    for i=1,#pixgrid.buf do
      local p = pixgrid.buf[i]
      local fn = Updaters[p.type]
      if fn then fn(p,pixgrid,changer) end
    end
    -- Apply accumulated updates to the pixgrid:
    changer:apply(pixgrid)
  end
end

-- System to update the pixgrid
local pixgridSystem = defineUpdateSystem(hasComps('pixgrid'), function(ge,estore,input,res)
    local pixgrid = ge.pixgrid.pixgrid

    clearEntityPixels(pixgrid)

    estore:walkEntities(hasComps('pixbuf'), function(be)
      local x,y = getPos(be)
      pixgrid:applyBufferAt(be.pixbuf.buffer, math.round0(x), math.round0(y))
    end)

    updatePixgrid(pixgrid, 1)

end)

-- System to apply paint event to the pixgrid
local paintSystem = defineUpdateSystem(hasComps('pixgrid'), function(e,estore,input,res)
  local evt = input.paintEvent
  if evt then
    local paintFunc = res.pixbrushStyles[evt.brush.style]
    if paintFunc then
      local s = e.pixgrid.pixgrid.scale
      local pgx = math.floor(evt.x / s)
      local pgy = math.floor(evt.y / s)
      paintFunc(e.pixgrid.pixgrid, pgx, pgy, evt.brush, evt.count)
    end
  end
end)


--
-- Update the world
--
local function updateWorld(world, action)
  if action.type == "tick" then
    pixgridSystem(world.estore, world.input, world.resources)
    scriptSystem(world.estore, world.input, world.resources)
    -- pixbufSystem(world.estore, world.input, {})
    world.input = {}

  elseif action.type == 'paint' then
    -- Apply the paintSystem to the ecs world immediately
    world.input.paintEvent = action
    paintSystem(world.estore, world.input, world.resources)
    world.input.paintEvent = nil

  end

  return world, nil
end


return updateWorld
