
local function getPixgrid(estore)
  local pixgrid
  estore:seekEntity(hasComps('pixgrid'), function(e)
    pixgrid = e.pixgrid.pixgrid
  end)
  return pixgrid
end

return {
  getPixgrid=getPixgrid
}
