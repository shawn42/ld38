local Stats = require 'stats'
local Pixgrid = require 'pixgrid'
local Pixtypes = require 'pixtypes'
-- local T = Pixtypes.Type
-- local Color = Pixtypes.Color
local Updaters = Pixtypes.Updaters

local Pixbrush = require 'pixbrush'

local automateTheCellular


local changer = Pixgrid.Changer()
local function updateWorld(world, action)
  if action.type == "tick" then
    local startTime = love.timer.getTime()
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
    end

    Stats.trackUpdateTime(love.timer.getTime() - startTime)
    Stats.trackFPS(love.timer.getFPS())

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
    if action.state == 'pressed' then

      -- Stepping
      if action.key == 's' then
        world.timectrl.stepwise = not world.timectrl.stepwise
      elseif action.key == 'space' then
        world.timectrl.stepped = true

      end
    end
  end

  return world, nil
end


return updateWorld
