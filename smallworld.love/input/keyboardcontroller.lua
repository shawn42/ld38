require 'ecs/ecshelpers'

function initialize(opts)
  local kbcState = {
    controllerId=opts.controllerId,
    bindings=opts.bindings,
    state={},
  }
  return kbcState
end

function handle(kbcState, action, worldInput, controllerState)
  local key = action.key
  local map = kbcState.bindings
  local controllerState = kbcState.state
  local targetId = kbcState.controllerId
  if key == map.up then
    local mag = 0
    if action.state == 'pressed' then
      controllerState.up = true
      mag = -1
    else
      controllerState.up = false
      if controllerState.down then mag = 1 end
    end
    addInputEvent(worldInput, {type='controller', id=targetId, input="lefty", action=mag})
    return true

  elseif key == map.down then
    local mag = 0
    if action.state == 'pressed' then
      controllerState.down = true
      mag = 1
    else
      controllerState.down = false
      if controllerState.up then mag = -1 end
    end
    addInputEvent(worldInput, {type='controller', id=targetId, input="lefty", action=mag})
    return true

  elseif key == map.left then
    local mag = 0
    if action.state == 'pressed' then
      controllerState.left = true
      mag = -1
    else
      controllerState.left = false
      if controllerState.right then mag = 1 end
    end
    addInputEvent(worldInput, {type='controller', id=targetId, input="leftx", action=mag})
    return true
  elseif key == map.right then
    local mag = 0
    if action.state == 'pressed' then
      controllerState.right = true
      mag = 1
    else
      controllerState.right = false
      if controllerState.left then mag = -1 end
    end
    addInputEvent(worldInput, {type='controller', id=targetId, input="leftx", action=mag})
    return true

  end
  return false
end

return {
  initialize=initialize,
  handleKeyAction=handle,
}
