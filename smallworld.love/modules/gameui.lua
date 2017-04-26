local Stats = require 'stats'
local Pixels = require 'modules/pixels'

local M = {}

M.newWorld = function(opts)
  local bounds = opts.bounds

  local pixworldB = {x=0, y=bounds.y+100, w=bounds.w, h=bounds.h-100}
  local pixworld = Pixels.newWorld({
    bounds={x=0,y=0, w=pixworldB.w, h=pixworldB.h}, -- pixworld won't internally understand that it's been offset by this outer ui
    iterations=opts.pixels.iterations,
    scale=opts.pixels.scale,
  })

  local layout = {
    {pixworldB, Pixels, "pixworld"},
  }

  local world = {
    bgcolor = {0,0,100},
    bounds = bounds,
    widgets = widgets,
    pixworld = pixworld,
    layout = layout,
  }
  return world
end

M.updateWorld = function(world, action)
  if action.type == "tick" then
    local startTime = love.timer.getTime()

    Pixels.updateWorld(world.pixworld, action)

    Stats.trackUpdateTime(love.timer.getTime() - startTime)
    Stats.trackFPS(love.timer.getFPS())

  elseif action.type == "mouse" then
    if action.state == "pressed" or action.state == "moved" then
      for i=1,#world.layout do
        local bounds,module,name = unpack(world.layout[i])
        print(tostring(bounds))
        print(tostring(module))
        print(tostring(name))
        if math.pointinbounds(action.x,action.y, bounds) then
          local subworld = world[name]
          if subworld then
            action.x = action.x - bounds.x
            action.y = action.y - bounds.y
            module.updateWorld(subworld, action)
          end
        end
      end
    elseif action.state == "released" then
      for i=1,#world.layout do
        local bounds,module,name = unpack(world.layout[i])
        local x = action.x
        local y = action.y
        action.x = x - bounds.x
        action.y = y - bounds.y
        module.updateWorld(world[name], action)
        action.x = x
        action.y = y
      end
    end
    -- action.y = action.y -100
    -- Pixels.updateWorld(world.pixworld, action)

  elseif action.type == "keyboard" then
    Pixels.updateWorld(world.pixworld, action)
  end
  return world, nil
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))
  love.graphics.setColor(0,0,255)

  -- love.graphics.print("Hello world! "..tostring(world.timePassed), 15,100)
  love.graphics.push()
  love.graphics.translate(0,100)
  Pixels.drawWorld(world.pixworld)
  love.graphics.pop()

  Stats.drawFPSChart(2,2)
  Stats.drawUpdateTimesChart(2,30)
end

return M
