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

local function moveEntityInPixgrid(e, pixgrid, changer)
  local pixlist = e.pixlist
  local x,y = getPos(e)

  e.bumper.bumped = false

  local tryx = x + e.vel.dx
  local tryy = y + e.vel.dy

  -- Figure out next desired grid location:
  local gridx = math.round0(x + e.vel.dx)
  local gridy = math.round0(y + e.vel.dy)

  if pixlist.lastx == gridx and pixlist.lasty == gridy then
    -- no pixel-level change, no pixgrid update needed.
    -- Just update the virtual location:
    e.pos.x = tryx
    e.pos.y = tryy
  else
    -- Detect if the proposed move to gridx,gridy would cause any of the pixgrid pixels to collide:
    local bump = false
    for i=1,#pixlist.pix do
      local p = pixlist.pix[i]
      local op = pixgrid:get(p[1] + gridx, p[2] + gridy)
      -- FIXME this is jank:
      if op and (op.type == T.NaP or op.type == T.Off or op.type == T.Entity) then
        -- no collision
      else
        bump = true
      end
    end
    if bump then
      -- collision
      e.bumper.bumped = true
      e.bumper.rightbump = (e.vel.dx > 0)
      e.bumper.leftbump = (e.vel.dx < 0)
      e.bumper.bottombump = (e.vel.dy > 0)
      e.bumper.topbump = (e.vel.dy < 0)
    else
      -- no collision
      changer:movePixlist(pixlist.pix, pixlist.lastx, pixlist.lasty, gridx, gridy)
      pixlist.lastx = gridx
      pixlist.lasty = gridy
      e.pos.x = tryx
      e.pos.y = tryy
    end
  end
end

-- System to update the pixgrid
local pixgridSystem = defineUpdateSystem(hasComps('pixgrid'), function(ge,estore,input,res)
    local pixgrid = ge.pixgrid.pixgrid

    -- Entities-in-pixgrid update:
    changer:reset()
    estore:walkEntities(hasComps('pixlist'), function(be)
      moveEntityInPixgrid(be, pixgrid, changer)
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
