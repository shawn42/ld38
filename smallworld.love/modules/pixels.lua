local M = {}

local Pixgrid = require 'pixgrid'
local T = Pixgrid.Types

local automateTheCellular

M.newWorld = function(opts)
  local world = {
    bounds = opts.bounds,
    bgcolor = {0,0,0},
    t = 0,
    painter = {
      on = false,
      type = T.Off,
      color = {0,0,0},
      x = 0,
      y = 0,
    }
  }

  local pscale = 1
  world.pixgrid = Pixgrid({
    w=world.bounds.w/pscale,
    h=world.bounds.h/pscale,
    scale=pscale,
  })

  world.pixgrid:set(100,400, 150,255,150, T.Leaf)

  return world
end

M.updateWorld = function(world, action)
  if action.type == "tick" then
    -- world.t = world.t + action.dt

    local painter = world.painter
    if painter.on then
      world.pixgrid:set(painter.x, painter.y, painter.color[1], painter.color[2], painter.color[3], painter.type)
    end

    automateTheCellular(world.pixgrid)


  elseif action.type == 'mouse' then
    if action.state == 'pressed' then
      world.painter.on = true
      world.painter.type = T.Leaf
      world.painter.color = {150,255,150}
      world.painter.x = action.x
      world.painter.y = action.y
    elseif action.state == 'released' then
      world.painter.on = false
    elseif action.state == 'moved' then
      world.painter.x = action.x
      world.painter.y = action.y
    end
  end
  return world, nil
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))
  love.graphics.setPointSize(world.pixgrid.scale)
  love.graphics.points(world.pixgrid.buf)
end

function automateTheCellular(pixgrid)
  local sets = {}
  local clears = {}

  for i=1,#pixgrid.buf do
    local p = pixgrid.buf[i]
    if p.type == T.Leaf then
      local below = pixgrid:get(p[1],p[2]+1)
      if below and below.type == T.Off then
        -- move me down
        table.insert(clears, p) -- clear my current cell
        table.insert(sets, {below[1], below[2], p[3],p[4],p[5], p.type})
      end
    end
  end

  for i=1,#clears do
    pixgrid:clear(clears[i][1], clears[i][2])
  end

  for i=1,#sets do
    pixgrid:set(unpack(sets[i]))
  end
end

return M
