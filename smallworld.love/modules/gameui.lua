local Stats = require 'stats'
local Pixels = require 'modules/pixels'
local Palette = require 'modules/palette'

local M = {}

M.newWorld = function(opts)
  local bounds = opts.bounds

  -- LAYOUT
  local paletteB = {x=150, y=bounds.y, w=bounds.w-150, h=60}
  local pixworldB = {x=0, y=bounds.y+paletteB.h, w=bounds.w, h=bounds.h-paletteB.h}
  local layout = {
    {pixworldB, Pixels, "pixworld"},
    {paletteB, Palette, "palette"},
  }
  local boxes = {
    pixworld=pixworldB,
    palette=paletteB,
  }

  -- SUB WORLDS
  local palette = Palette.newWorld({
    bounds={x=0, y=0, w=paletteB.w, h=paletteB.h}
  })
  local pixworld = Pixels.newWorld({
    bounds={x=0,y=0, w=pixworldB.w, h=pixworldB.h}, -- pixworld won't internally understand that it's been offset by this outer ui
    iterations=opts.pixels.iterations,
    scale=opts.pixels.scale,
  })

  -- WORLD
  local world = {
    bgcolor = {0,0,100},
    bounds = bounds,

    layout = layout,
    boxes = boxes,

    pixworld = pixworld,
    palette = palette,
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

  elseif action.type == "keyboard" then
    Pixels.updateWorld(world.pixworld, action)
  end
  return world, nil
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))
  love.graphics.setColor(0,0,255)

  local paletteB = world.boxes.palette
  love.graphics.push()
  love.graphics.translate(paletteB.x,paletteB.y)
  Palette.drawWorld(world.palette)
  love.graphics.pop()

  local pixworldB = world.boxes.pixworld
  love.graphics.push()
  love.graphics.translate(pixworldB.x, pixworldB.y)
  Pixels.drawWorld(world.pixworld)
  love.graphics.pop()

  Stats.drawFPSChart(2,2)
  Stats.drawUpdateTimesChart(2,30)
end

return M
