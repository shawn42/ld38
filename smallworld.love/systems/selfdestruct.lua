
local selfDestructSystem = defineUpdateSystem(allOf(hasTag('self_destruct'), hasComps('timer')),
  function(e,estore,input,res)
    if e.timers.self_destruct and e.timers.self_destruct.alarm then
      estore:destroyEntity(e)
    end
  end
)

return selfDestructSystem
