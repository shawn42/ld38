local Root = require 'modules.clickexperiment.compound'

-- An experiment in adding a generic hierarchy for wrapping/unwrapping and delivering mouse actions
-- down to the "widgets" they actually strike.

-- This module ('clickexperiment') is designed as a generic root point that uses its child module's "getStructure()"
-- results to decide where a mouse event should be homed.
-- Each module decides how it wants to "dress" mouse events that are aimed at their zones, or how to wrap
-- events from their child modules.

-- This is an adaptation of the Elm Architecture's gui action dispatcher but instead of using Signals to map events bubbling up from the DOM,
-- I assume that all bubbling events should be mapped and wrapped in such a way that any given Module's updateWorld() can route events
-- back down to the submodules where they originated.
-- Speaking of the DOM: we don't have one. Module.drawWorld() is almost always pure-side-effects graphics work, we have no common type or structure to play with.
-- So I added a fourth Module method called getStructure(), which returns a generic recursive bounds-and-handlers structure,
-- to facilitate the dispatching of mouse actions according to space and each Module's semantic decoration of such events.

-- This example's modules are like this:
-- clickexperiment
--   Root=Compound
--     Widgets=[ w1, w2, w3 ]

-- When clickexperiment is updated with a mouse event, the Root's structure is searched
-- for the lowest child element whose bounds encompasse the x,y of the mouse action.

-- The struck item may define 'onmousepressed', 'onmousemoved', 'onmousereleased'.
-- The values are tables used as templates... the 'action' field will be set to contain the original mouse action.
-- If an element in the structure has a 'wrap' (also a table), the 'wrap' item will be used as a template and have its
-- 'action' field set to the already-wrapped action.

-- The resulting action (wrapped at each step as it bubbles back up to the root) is delivered to Root.updateWorld()
-- Root.updateWorld only needs to know about the layer of fields in the given action according to what it prepared
-- in its getStructure() ...

-- In this example, Compound tags each of its widget children with {type='widget', idx=i}, meaning that any of
-- the actions mapped by a widget child will be associated with that widget by its index.
-- Root.updateWorld() sees type=widget, uses idx=i to lookup the proper widget, and invokes Widget.updateWorld(world.widgets[i], action.action)

local function newWorld(opts)
  local world = {
    root=Root.newWorld({
      bounds=opts.bounds
    })
  }
  return world
end


-- struct := {bounds={x=,y=,w=,h=}, children=<struct>}
local function searchStructure(struct,x,y)
  if math.pointinbounds(x,y,struct.bounds) then
    for i=#struct.children,1, -1 do -- go backward to match draw order
      local hit = searchStructure(struct.children[i],x,y)
      if hit then return hit end
    end
    return struct
  else
    return nil
  end
end

local function updateWorld(world,action)
  if action.type == "mouse" then
    if Root.getStructure then
      local struct = Root.getStructure(nil,world.root)
      local hitStruct = searchStructure(struct, action.x,action.y)

      local handlerName = "onmouse"..action.state
      if hitStruct then
        if hitStruct[handlerName] then
          action = tcopy(hitStruct[handlerName], {action=action}) -- shallow copy hitStruct and set action
          if hitStruct.wrap then
            action = tcopy(hitStruct.wrap, {action=action})
          end
          Root.updateWorld(world.root, action)
        end
      end
    end
  end
  return world
end

local function drawWorld(world)
  Root.drawWorld(world.root)
end

return {
  newWorld=newWorld,
  updateWorld=updateWorld,
  drawWorld=drawWorld,
}
