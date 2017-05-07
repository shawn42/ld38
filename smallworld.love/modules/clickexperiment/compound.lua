local Widget = require 'modules.clickexperiment.widget'

local function newWorld(opts)
  local world = {
    bounds=opts.bounds,
    widgets={},
  }

  local w1 = Widget.newWorld({
    bounds={x=30,y=30,w=100,h=120},
    bgcolor={100,100,255},
    bordercolor={180,180,255},
    label="W1",
  })
  local w2 = Widget.newWorld({
    bounds={x=150,y=30,w=100,h=120},
    bgcolor={255,100,100},
    bordercolor={255,180,180},
    label="W2",
  })
  local w3 = Widget.newWorld({
    bounds={x=100,y=100,w=300,h=120},
    bgcolor={100,255,100},
    bordercolor={0,200,0},
    label="W3",
  })

  table.insert(world.widgets, w1)
  table.insert(world.widgets, w2)
  table.insert(world.widgets, w3)
  return world
end

local function updateWorld(world,action)
  -- Note these action types are defined by the tags/onmouse* wrappers we specifide in getStructure()
  if action.type == 'widget' then
    Widget.updateWorld(world.widgets[action.idx],action.action)
  elseif action.type == 'inTheOpen' then
    print("Compound: "..tflatten(action.action))
  end
  return world
end

-- The children list below is a list of box structures based on world.widgets.
-- Each is built by invoking Widget.getStructure with a 'wrap' structure
-- including a 'type' which our updateWorld() function will dispatch on,
-- AND ALSO the 'idx' field, set to the proper widget index so we know where to deliver the unwrapped event.
--
-- onmouse* below are tables to be used as templates for actions that
-- will get delivered to updateWorld() in this module.
-- Such delivered actions will have an 'action' field set to the current mouse action.
-- THIS MODULE WILL ONLY HANDLE MOUSE ACTIONS THAT AREN'T AIMED AT THE CHILDREN.
--
-- Note: 'wrap' is given to us by a containing module to provide its own wrapping; don't mess with that guy.
local function getStructure(wrap,world)
  local children={}
  for i=1,#world.widgets do
    table.insert(children, Widget.getStructure({type='widget',idx=i}, world.widgets[i]))
  end
  return {
    bounds=world.bounds,
    wrap=wrap,
    onmousepressed={type='inTheOpen'},
    -- onmousemoved={type='inTheOpen'},
    onmousereleased={type='inTheOpen'},
    children=children,
  }
end

local function drawWorld(world)
  love.graphics.setBackgroundColor(0,0,0)
  --
  for i=1,#world.widgets do
    Widget.drawWorld(world.widgets[i])
  end
  --
  love.graphics.setColor(255,255,255)
  love.graphics.rectangle("line", world.bounds.x, world.bounds.y, world.bounds.w, world.bounds.h)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  getStructure=getStructure,
  drawWorld=drawWorld,
}
