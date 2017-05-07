
local function newWorld(opts)
  local world = {
    bgcolor=opts.bgcolor,
    bordercolor=opts.bordercolor,
    label=opts.label,
    bounds=opts.bounds
  }
  return world
end

local function updateWorld(world,action)
  if action.type == 'widgetClicked' then
    print(world.label.." CLICKED:")
    print(tdebug(action.action))

  elseif action.type == 'widgetReleased' then
    print(world.label.." RELEASED.")

  elseif action.type == 'widgetMove' then
    print(world.label.." MOVE: "..tflatten(action.action))
  end
  return world
end

-- onmouse* below are tables to be used as templates for actions that
-- will get delivered to updateWorld() in this module.
-- Such delivered actions will have an 'action' field set to the current mouse action.
-- Note: 'wrap' is given to us by a containing module to provide its own wrapping; don't mess with that guy.
local function getStructure(wrap,world)
  return {
    bounds=world.bounds,
    wrap=wrap,
    onmousepressed={type='widgetClicked'},
    onmousereleased={type='widgetReleased'},
    onmousemoved={type='widgetMove'},
    children={},
  }
end

local function drawWorld(world)
  love.graphics.setColor(unpack(world.bgcolor))
  love.graphics.rectangle("fill", world.bounds.x, world.bounds.y, world.bounds.w, world.bounds.h)
  love.graphics.setColor(unpack(world.bordercolor))
  love.graphics.rectangle("line", world.bounds.x, world.bounds.y, world.bounds.w, world.bounds.h)
  love.graphics.printf(world.label, world.bounds.x, world.bounds.y+(math.floor(world.bounds.h/2)-5), world.bounds.w, "center")
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  getStructure=getStructure,
  drawWorld=drawWorld,
}
