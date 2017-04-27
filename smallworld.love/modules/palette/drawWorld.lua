local function drawWorld(world)
  love.graphics.setColor(255,255,255)
  love.graphics.print("PALETTE "..tflatten(world.bounds),0,0)
end
return drawWorld
