require 'ecs/ecshelpers'
local scriptSystem = require 'systems.script'
local pixgridSystem = require 'modules.pixels-ecs.pixgridsystem'
local paintSystem = require 'modules.pixels-ecs.paintsystem'

--
-- Update the world
--
local function updateWorld(world, action)
  if action.type == "tick" then
    pixgridSystem(world.estore, world.input, world.resources)
    scriptSystem(world.estore, world.input, world.resources)
    world.input = {}

  elseif action.type == 'paint' then
    -- Apply the paintSystem to the ecs world immediately
    world.input.paintEvent = action
    paintSystem(world.estore, world.input, world.resources)
    world.input.paintEvent = nil

  end

  return world, nil
end


return updateWorld
