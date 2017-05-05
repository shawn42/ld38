
-- System to apply paint event to the pixgrid
local paintSystem = defineUpdateSystem(hasComps('pixgrid'), function(e,estore,input,res)
  local evt = input.paintEvent
  if evt then
    local paintFunc = res.pixbrushStyles[evt.brush.style]
    if paintFunc then
      local s = e.pixgrid.pixgrid.scale
      local pgx = math.floor(evt.x / s)
      local pgy = math.floor(evt.y / s)
      paintFunc(e.pixgrid.pixgrid, pgx, pgy, evt.brush, evt.count)
    end
  end
end)

return paintSystem
