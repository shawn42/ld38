
local function updateWorld(world, action)
  if action.type == 'keyboard' then
    if action.state == 'pressed' then
      -- Find the item whose label matches the pressed key:
      for i=1,#world.items do
        local item = world.items[i]
        if action.key == item.key then
          world.brushName = item.brushName
        end
      end
    end
  end

  return world
end

return updateWorld
