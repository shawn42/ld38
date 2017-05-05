local Pixgrid = require 'pixgrid'
local Pixtypes = require 'pixtypes'
local T = Pixtypes.Type
local Updaters = Pixtypes.Updaters

-- System to update the pixgrid

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

local changer = Pixgrid.Changer:new()
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

return pixgridSystem
