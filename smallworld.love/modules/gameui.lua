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

  local worlds = {
    -- Normal 2x world:
    ["1"] = Pixels.newWorld({
      bounds={x=0,y=0, w=pixworldB.w, h=pixworldB.h}, -- pixworld won't internally understand that it's been offset by this outer ui
      iterations=opts.pixels.iterations,
      scale=opts.pixels.scale,
    }),
    -- Zoomed-in giant pixel world:
    ["2"] = Pixels.newWorld({
      bounds={x=0,y=0, w=pixworldB.w, h=pixworldB.h}, -- pixworld won't internally understand that it's been offset by this outer ui
      iterations=opts.pixels.iterations,
      scale=20 -- opts.pixels.scale,
    }),
  }

  -- WORLD
  local world = {
    bgcolor = {0,0,100},
    bounds = bounds,

    layout = layout,
    boxes = boxes,

    worlds = worlds,
    pixworld = worlds["1"],

    palette = palette,

    painter = {
      on = false,
      erase = false,
      x = 0,
      y = 0,
      count = 0,
    },
    kbd = {
      cmd = false,
    },
  }
  return world
end

M.updateWorld = function(world, action)
  if action.type == "tick" then
    local startTime = love.timer.getTime()

    if world.painter.eraser or world.painter.on then
      -- Generate a "paint" action to the pixworld:
      local painter = world.painter
      local brush
      if painter.eraser then
        brush = world.palette.brushes[world.palette.eraserName] -- mmmmm... is it ok to peek inside another world's state?
      else
        brush = world.palette.brushes[world.palette.brushName] -- mmmmm... is it ok to peek inside another world's state?
        painter.count = painter.count + 1
      end
      local paintAction = {
        type="paint",
        x=painter.x,
        y=painter.y,
        brush=brush,
        count=painter.count,
      }
      Pixels.updateWorld(world.pixworld, paintAction)
    end

    -- Forward the tick event to subworlds:
    Pixels.updateWorld(world.pixworld, action)
    Palette.updateWorld(world.palette, action)

    Stats.trackUpdateTime(love.timer.getTime() - startTime)
    Stats.trackFPS(love.timer.getFPS())

  elseif action.type == "mouse" then
    if action.state == "pressed" then
      local pixworldB = world.boxes.pixworld
      if math.pointinbounds(action.x,action.y, pixworldB) then
        world.painter.x = action.x - pixworldB.x
        world.painter.y = action.y - pixworldB.y
        if action.button == 1 then
          world.painter.on = true
          world.painter.count = 0
        elseif action.button == 2 then
          world.painter.eraser = true
        end
      end

    elseif action.state == "moved" then
      local pixworldB = world.boxes.pixworld
      if math.pointinbounds(action.x,action.y, pixworldB) then
        world.painter.x = action.x - pixworldB.x
        world.painter.y = action.y - pixworldB.y
      else
        world.painter.on = false
      end

    elseif action.state == "released" then
      if action.button == 1 then
        world.painter.on = false
        world.painter.count = 0
      elseif action.button == 2 then
        world.painter.eraser = false
      end
    end

  elseif action.type == "keyboard" then
    -- print(tflatten(action))
    if action.key == "lgui" or action.key == "rgui" then
      world.kbd.cmd = (action.state == "pressed")
    end
    if world.kbd.cmd then
      local nextworld = world.worlds[action.key]
      if nextworld then
        world.pixworld = nextworld
      end
    else
      Palette.updateWorld(world.palette, action)
      Pixels.updateWorld(world.pixworld, action)
    end
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
