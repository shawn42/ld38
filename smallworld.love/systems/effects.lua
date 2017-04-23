
local Comp = require 'ecs/component'
Comp.define('effect',{'path',{}, 'data',{}, 'timer','','animFunc',''})

local effectSystem = defineUpdateSystem({'effect','timer'},
  function(e, estore,input,res)
    local effect = e.effect
    -- local data = effect.data
    local timer = e.timers[effect.timer]
    if timer then
      local ent,comp,key = resolveEntCompKeyByPath(e, effect.path)
      local data = effect.data
      if effect.animFunc ~= '' then
        local fn = res.anims[effect.animFunc]
        if fn then
          comp[key] = fn(timer.t)
        end
      else
        local newVal = nil
        for i=1, #data, 2 do
          if timer.t >= data[i] then
            newVal = data[i+1]
          else
            break
          end
        end
        comp[key] = newVal
      end
    end
  end
)

return effectSystem
