local Pixgrid = require 'pixgrid'
local Pixtypes = require 'pixtypes'
-- local T = Pixtypes.Type
-- local Color = Pixtypes.Color
local Updaters = Pixtypes.Updaters

local Pixbrush = require 'pixbrush'

local changer = Pixgrid.Changer:new()
local function updateWorld(world, action)
  if action.type == "tick" then
    local pixgrid = world.pixgrid
    for i=1,world.iterations do
      -- Accumulate pixgrid updates:
      changer:reset()
      for i=1,#pixgrid.buf do
        local p = pixgrid.buf[i]
        local fn = Updaters[p.type]
        if fn then fn(p,pixgrid,changer) end
      end
      -- Apply accumulated updates to the pixgrid:
      changer:apply(pixgrid)
    end

  elseif action.type == 'paint' then
    local paintFunc = Pixbrush.Styles[action.brush.style]
    if paintFunc then
      local s = world.pixgrid.scale
      local bounds = world.pixgridBounds
      local pgx = math.floor(action.x / s)
      local pgy = math.floor(action.y / s)
      paintFunc(world.pixgrid, pgx, pgy, action.brush, action.count)
    end

  elseif action.type == 'keyboard' then
    -- ?
  end

  return world, nil
end


return updateWorld
