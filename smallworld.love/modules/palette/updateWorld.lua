
local function updateWorld(world, action)
  if action.type == 'keyboard' then
    if action.state == 'pressed' then
      for i=1,#world.items do
        local item = world.items[i]
        if action.key == item.label then -- TODO: give item a field to do a cleaner match?
          world.brushName = item.typeName -- TODO: better symbolic indirection...?
        end
      end
    end
  end

  return world
end

return updateWorld
