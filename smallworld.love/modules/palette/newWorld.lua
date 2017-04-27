-- local Pixgrid = require 'pixgrid'
-- local Pixtypes = require 'pixtypes'
-- local T = Pixtypes.Type
-- local Color = Pixtypes.Color


local function newWorld(opts)
  local world = {
    bounds=opts.bounds,
  }
  return world
end

return newWorld
