

return defineUpdateSystem(hasComps('controller'),
  function(e, estore, input,res)
    forEachMatching(input.events.controller, 'id', e.controller.id, function(evt)
      e.controller[evt.input] = evt.action
    end)
  end
)
