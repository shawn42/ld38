local Pixgrid = require 'pixgrid'
local Pixtypes = require 'pixtypes'
local T = Pixtypes.Type
local Updaters = Pixtypes.Updaters

-- System to update the pixgrid

local function tryMoveX(e,pixgrid,changer)
  local pixlist = e.pixlist
  local x,y = getPos(e)
  local movx = e.vel.dx
  local gridx = math.round0(x + movx)
  local gridy = math.round0(y)
  if pixlist.lastx == gridx then
    e.pos.x = e.pos.x + movx
  else
    -- Detect if the proposed move would cause a collision
    for i=1,#pixlist.pix do
      local p = pixlist.pix[i]
      local op = pixgrid:get(p[1] + gridx, p[2] + gridy)
      -- FIXME this is jank:
      if op and (op.type == T.NaP or op.type == T.Off or op.type == T.Entity) then
        -- no collision on this pixel
      else
        -- collision on this pixel
        e.bumper.bumped = true
        if movx < 0 then
          e.bumper.left = true
        else
          e.bumper.right = true
        end
        movx = 0
        return
      end
    end
    e.pos.x = e.pos.x + movx
    changer:reset()
    changer:movePixlist(pixlist.pix, pixlist.lastx, pixlist.lasty, gridx, gridy)
    changer:apply(pixgrid)
    pixlist.lastx = gridx
    pixlist.lasty = gridy
  end
end


local function tryMoveY(e,pixgrid,changer)
  local pixlist = e.pixlist
  local x,y = getPos(e)
  local movy = e.vel.dy
  local gridx = math.round0(x)
  local gridy = math.round0(y + movy)
  if pixlist.lasty == gridy then
    e.pos.y = e.pos.y + movy
  else
    -- Detect if the proposed move would cause a collision
    for i=1,#pixlist.pix do
      local p = pixlist.pix[i]
      local op = pixgrid:get(p[1] + gridx, p[2] + gridy)
      -- FIXME this is jank:
      if op and (op.type == T.NaP or op.type == T.Off or op.type == T.Entity) then
        -- no collision on this pixel
      else
        -- collision on this pixel
        e.bumper.bumped = true
        if movy < 0 then
          e.bumper.top = true
        else
          e.bumper.bottom = true
        end
        movy = 0
        return
      end
    end
    e.pos.y = e.pos.y + movy
    changer:reset()
    changer:movePixlist(pixlist.pix, pixlist.lastx, pixlist.lasty, gridx, gridy)
    changer:apply(pixgrid)
    pixlist.lastx = gridx
    pixlist.lasty = gridy
  end
end

local function moveEntityInPixgrid(e, pixgrid, changer)
  e.bumper.bumped = false
  e.bumper.left = false
  e.bumper.right = false
  e.bumper.top = false
  e.bumper.bottom = false

  if e.vel.dy ~= 0 then
    tryMoveY(e,pixgrid,changer)
  end
  if e.vel.dx ~= 0 then
    tryMoveX(e,pixgrid,changer)
  end
end

local changer = Pixgrid.Changer:new()
local pixgridSystem = defineUpdateSystem(hasComps('pixgrid'), function(ge,estore,input,res)
    local pixgrid = ge.pixgrid.pixgrid

    -- Entities-in-pixgrid update:
    estore:walkEntities(hasComps('pixlist'), function(be)
      moveEntityInPixgrid(be, pixgrid, changer)
    end)

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
