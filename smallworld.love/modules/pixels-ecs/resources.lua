local Pixbrush = require 'pixbrush'
local Scripts = require 'modules.pixels-ecs.scripts'

return {
  load=function()
    return {
      pixbrushStyles = Pixbrush.Styles,
      scripts = Scripts,
    }
  end
}
