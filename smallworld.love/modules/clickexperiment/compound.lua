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
  if action.type == 'widget' then
    Widget.updateWorld(world.widgets[action.idx],action.action)
  elseif action.type == 'inTheOpen' then
    print("Compound: "..tflatten(action.action))
  end
  return world
end

-- bounds,tag,children, [onmousepressed ... ]
local function getStructure(tag,world)
  local children={}
  for i=1,#world.widgets do
    table.insert(children, Widget.getStructure({type='widget',idx=i}, world.widgets[i]))
  end
  return {
    bounds=world.bounds,
    tag=tag,
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
