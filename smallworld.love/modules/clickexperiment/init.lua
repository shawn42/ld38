local Root = require 'modules.clickexperiment.compound'

local function newWorld(opts)
  local world = {
    root=Root.newWorld({
      bounds=opts.bounds
    })
  }
  return world
end


local function searchStructure(struct,x,y)
  -- print("searchStructure "..tflatten(struct))
  if math.pointinbounds(x,y,struct.bounds) then
    for i=#struct.children,1, -1 do -- go backward to match draw order
      local hit = searchStructure(struct.children[i],x,y)
      if hit then return hit end
      -- print("child not hit")
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
      local hit = searchStructure(struct, action.x,action.y)

      local hname = "onmouse"..action.state
      if hit then
        if hit[hname] then
          action = tcopy(hit[hname],{action=action})
          if hit.tag then
            action = tcopy(hit.tag, {action=action})
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
