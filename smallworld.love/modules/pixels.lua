local M = {}

local Pixgrid = require 'pixgrid'
local T = Pixgrid.Types

local automateTheCellular

M.newWorld = function(opts)
  local world = {
    timectrl = {
      interval = 1,  -- how often (in ticks, not time) to actually perform the update
      tickcounter = 0,
      stepwise = false,
      stepped = false,
    },
    bounds = opts.bounds,
    bgcolor = {0,0,0},
    painter = {
      on = false,
      type = T.Off,
      color = {0,0,0},
      x = 0,
      y = 0,
      brushSize = 10,
    }
  }

  local scale = opts.scale or 1
  world.pixgrid = Pixgrid({
    w=world.bounds.w/scale,
    h=world.bounds.h/scale,
    scale=scale,
  })

  world.pixgrid:set(100,400, 150,255,150, T.Leaf)

  return world
end

M.updateWorld = function(world, action)
  if action.type == "tick" then
    -- Use timectrl to decide if we should update this tick or not:
    local tc = world.timectrl
    local doUpdate = false
    if tc.stepwise then
      -- User must kick the simulation along by hitting a key
      if tc.stepped then
        doUpdate = true
        tc.stepped = false
      end
    else
      -- Rate-controlled:
      tc.tickcounter = tc.tickcounter + 1
      if tc.tickcounter >= tc.interval then -- in ticks, not time
        tc.tickcounter = 0
        doUpdate = true
      end
    end

    if doUpdate then
      local painter = world.painter
      if painter.on then
        for i=1,painter.brushSize do
          local x = painter.x + love.math.random(-painter.brushSize, painter.brushSize)
          local y = painter.y + love.math.random(-painter.brushSize, painter.brushSize)
          world.pixgrid:set(x, y, painter.color[1], painter.color[2], painter.color[3], painter.type)
        end
      end

      automateTheCellular(world.pixgrid)
    end

  elseif action.type == 'mouse' then
    local s = world.pixgrid.scale
    if action.state == 'pressed' then
      world.painter.on = true
      world.painter.type = T.Leaf
      world.painter.color = {150,255,150}
      world.painter.x = math.floor(action.x/s)
      world.painter.y = math.floor(action.y/s)
    elseif action.state == 'released' then
      world.painter.on = false
    elseif action.state == 'moved' then
      world.painter.x = math.floor(action.x/s)
      world.painter.y = math.floor(action.y/s)
    end

  elseif action.type == 'keyboard' then
    if action.state == 'pressed' then
      if action.key == 's' then
        world.timectrl.stepwise = not world.timectrl.stepwise
      elseif action.key == 'space' then
        world.timectrl.stepped = true
      end
    end
  end
  return world, nil
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))
  local s = world.pixgrid.scale
  love.graphics.setPointSize(s)
  love.graphics.scale(s,s)
  love.graphics.points(world.pixgrid.buf)
end

function automateTheCellular(pixgrid)
  local sets = {}
  local clears = {}

  for i=1,#pixgrid.buf do
    local p = pixgrid.buf[i]
    if p.type == T.Leaf then
      local above = pixgrid:get(p[1],p[2]-1)
      local below = pixgrid:get(p[1],p[2]+1)
      if below and below.type == T.Off then
        -- move me down
        table.insert(clears, p) -- clear my current cell
        table.insert(sets, {below[1], below[2], p[3],p[4],p[5], p.type})
      elseif above and above.type ~= T.Off then
        local left = pixgrid:get(p[1]-1,p[2])
        local right = pixgrid:get(p[1]+1,p[2])

        local goLeft = love.math.random(0,1) == 1
        if goLeft and left and left.type == T.Off then
          table.insert(clears, p)
          table.insert(sets, {left[1], left[2], p[3],p[4],p[5], p.type})
        elseif right and right.type == T.Off then
          table.insert(clears, p)
          table.insert(sets, {right[1], right[2], p[3],p[4],p[5], p.type})
        end
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
