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

local moverSystem = defineUpdateSystem(
  hasComps('vel','pos','pixlist'),
  function(e,estore,input,res)
    local pixgrid = Helpers.getPixgrid(estore)
  end
)

-- System to update the pixgrid
local pixgridSystem = defineUpdateSystem(hasComps('pixgrid'), function(ge,estore,input,res)
    local pixgrid = ge.pixgrid.pixgrid

    -- Entities-in-pixgrid update:
    changer:reset()
    estore:walkEntities(hasComps('pixlist'), function(be)
      local pixlist = be.pixlist

      local x,y = getPos(be)
      x = x + be.vel.dx
      y = y + be.vel.dy

      x = math.round0(x)
      y = math.round0(y)
      if pixlist.lastx == x and pixlist.lasty == y then
        -- no pixel-level change, skip
        be.pos.x = be.pos.x + be.vel.dx
        be.pos.y = be.pos.y + be.vel.dy
      else
        local bump = false
        for i=1,#pixlist.pix do
          local p = pixlist.pix[i]
          local op = pixgrid:get(p[1]+x,p[2]+y)
          if op.type == T.NaP or op.type == T.Off or op.type == T.Entity then
            -- 

          else
            bump = true
          end
        end
        if not bump then
          changer:movePixlist(pixlist.pix, pixlist.lastx, pixlist.lasty, x,y)
          pixlist.lastx = x
          pixlist.lasty = y
          be.pos.x = be.pos.x + be.vel.dx
          be.pos.y = be.pos.y + be.vel.dy
        else
          --
        end
      end
    end)
    changer:apply(pixgrid)

    -- General pixgrid update
    changer:reset()
    for i=1,#pixgrid.buf do
      local p = pixgrid.buf[i]
      local fn = Updaters[p.type]
      if fn then fn(p,pixgrid,changer) end
    end
    changer:apply(pixgrid)

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
