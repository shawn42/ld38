local M = {}

M.newWorld = function()
  local world = {
    bgcolor = {255,255,255},
    timePassed = 0,
    textLocation = {0,0},
  }
  return world
end

M.updateWorld = function(world, action)
  if action.type == "tick" then
    world.timePassed = world.timePassed + action.dt
  end
  return world, nil
end

M.drawWorld = function(world)
  love.graphics.setBackgroundColor(unpack(world.bgcolor))
  love.graphics.setColor(0,0,255)
  love.graphics.print("Hello world! "..tostring(world.timePassed), 15,100)
end

return M
